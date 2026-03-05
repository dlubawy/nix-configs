#!/usr/bin/env python3
"""
hostapd-roamer

A small utility to steer wireless stations (clients) between hostapd interfaces
(e.g. 2.4GHz and 5GHz radios) based on RSSI thresholds.

This module:
- Discovers hostapd interfaces and groups them by frequency (2GHz vs 5GHz).
- Periodically synchronizes neighbor information between access points.
- Checks stations against configured roamers and decides if they should be
  steered between radios based on signal thresholds.
- Invokes AccessPoint.steer_station to perform the steer when appropriate.

The main entrypoint is the `main` function. A simple CLI at the bottom allows
overriding config file, interfaces and roamers.
"""

import argparse
import configparser
import logging
import os
import time
from itertools import chain, combinations
from pathlib import Path
from typing import Any, NamedTuple

from access_point import AccessPoint

# Configure basic logging for the module.
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s: %(message)s"
)
logger = logging.getLogger("hostapd-roamer")

# Configuration file discovery:
# Prefer per-user XDG_CONFIG_HOME if it exists and this is a non-system user.
XDG_CONFIG_HOME = Path(os.getenv("XDG_CONFIG_HOME", "~/.config")).expanduser()
CONFIG_DIR = (
    f"{XDG_CONFIG_HOME}/hostapd-roamer"
    if XDG_CONFIG_HOME.exists() and os.getuid() >= 1000
    else "/etc/hostapd-roamer"
)
CONFIG_FILE = f"{CONFIG_DIR}/config.ini"


class Config(NamedTuple):
    """
    Configuration container returned by get_config.

    Fields:
    - access_points: Mapping from frequency (2 or 5) to list of AccessPoint objects.
    - interfaces: Set of hostapd interface names that are being managed.
    - roamers: Set of station MAC addresses that should be considered for roaming.
    - signal_thresholds: Dict with keys "2to5" and "5to2" containing RSSI thresholds.
    - sync_interval_minutes: How often (in minutes) to sync neighbor information.
    - all_stations: If True the roamers set is populated from all attached stations.
    """

    access_points: dict[int, list[AccessPoint]]
    interfaces: set[str]
    roamers: set[str]
    signal_thresholds: dict[str, int] = {"2to5": 65, "5to2": 75}
    sync_interval_minutes: int = 15
    all_stations: bool = False


def setup_neighbors(access_points: dict[int, list[AccessPoint]]) -> float:
    """
    Initialize neighbor relationships between all AccessPoint instances.

    For every pair of access points the function calls add_neighbor on both
    so that each AP knows about the others. Returns the timestamp when the
    sync was performed (time.time()).
    """
    all_access_points = list(chain.from_iterable(access_points.values()))
    for access_point_a, access_point_b in combinations(all_access_points, 2):
        access_point_a.add_neighbor(access_point_b)
        access_point_b.add_neighbor(access_point_a)
    return time.time()


def check_roamers(
    access_points: dict[int, list[AccessPoint]],
    roamers: set[str],
    signal_thresholds: dict[str, int],
) -> dict[str, dict[str, Any]]:
    """
    Inspect stations on each access point and decide which roamers need steering.

    Returns a mapping keyed by station MAC address with values containing:
    - current_access_point: AccessPoint instance the station is currently on
    - target_frequency: int (2 or 5) for the desired frequency band
    - force: bool indicating whether the steer should be forced

    Decision logic:
    - If on 2.4GHz and signal <= 2to5 threshold -> consider moving to 5GHz.
    - If on 5GHz and signal >= 5to2 threshold -> force move to 2.4GHz
      (5GHz may require forcing because clients often prefer it).
    """
    need_roam = {}
    for frequency, frequency_access_points in access_points.items():
        for access_point in frequency_access_points:
            stations = access_point.get_stations()
            for station in stations:
                address = station.get("addr")
                logger.debug("Checking %s", address)
                if address not in roamers:
                    continue

                signal = int(station.get("signal", "0"))
                if signal == 0:
                    logger.warning("Station %s does not have a signal", address)

                # Check 2.4GHz -> 5GHz
                # If our 2.4GHz signal is very strong (low absolute RSSI value)
                # we can try a roam to 5GHz.
                if frequency == 2 and signal <= signal_thresholds["2to5"]:
                    logger.debug(
                        "Signal <= %s and frequency=%s",
                        signal_thresholds["2to5"],
                        frequency,
                    )
                    need_roam[address] = {
                        "current_access_point": access_point,
                        "target_frequency": 5,
                        "force": False,
                    }
                # Check 5GHz -> 2.4GHz
                # If our 5GHz signal is very weak then force a roam to 2.4GHz
                elif frequency == 5 and signal >= signal_thresholds["5to2"]:
                    logger.debug(
                        "Signal >= %s and frequency=%s",
                        signal_thresholds["5to2"],
                        frequency,
                    )
                    need_roam[address] = {
                        "current_access_point": access_point,
                        "target_frequency": 2,
                        "force": True,  # 5GHz typically needs forcing
                    }
    return need_roam


def steer(
    access_points: dict[str, list[AccessPoint]],
    roamers: dict[str, dict[str, Any]],
):
    """
    Attempt to steer each roamer to its target frequency.

    For each roamer found in the `roamers` mapping, try to steer it from the
    current access point to the first available access point on the target
    frequency. Logs success or failure.
    """
    for roamer, info in roamers.items():
        target_frequency = info["target_frequency"]
        current_access_point = info["current_access_point"]
        force_roam = info["force"]
        target_list = access_points[target_frequency]
        if target_list:
            success = current_access_point.steer_station(
                roamer, target_list[0], force=force_roam
            )
            if success:
                logger.info(
                    "Steered %s from %s to %s",
                    roamer,
                    current_access_point,
                    target_list[0],
                )
            else:
                logger.warning("Failed to steer %s", roamer)


def sync_neighbors(access_points: list[AccessPoint] | dict[str, list[AccessPoint]]):
    """
    Ensure neighbor information is synced for every AccessPoint.

    Accepts either a list of AccessPoint objects or a dict mapping frequency to
    lists of AccessPoint objects.
    """
    if isinstance(access_points, dict):
        for freq_access_points in access_points.values():
            sync_neighbors(freq_access_points)
    else:
        for access_point in access_points:
            access_point.sync_neighbors()


def _parse_csv_to_set(line: str) -> set[str]:
    """
    Parse a comma separated string into a set of stripped non-empty values.

    Example: "wlan0, wlan1" -> {"wlan0", "wlan1"}
    """
    return {item.strip() for item in line.split(",") if item.strip()}


def all_stations(access_points: dict[int, list[AccessPoint]]) -> set[str]:
    """
    Return a set of all station MAC addresses seen across all access points.
    """
    roamers = set()
    for frequency_access_points in access_points.values():
        for access_point in frequency_access_points:
            roamers.update([station["addr"] for station in access_point.get_stations()])
    return roamers


def get_config(
    config_file: str = CONFIG_FILE,
    interfaces: set[str] | None = None,
    roamers: set[str] | None = None,
) -> Config:
    """
    Load configuration from config_file and construct a Config NamedTuple.

    Parameters:
    - config_file: Path to an INI-style config file with a [HostapdRoamer] section.
    - interfaces: Optional set of interface names to override the config file.
    - roamers: Optional set of station MACs to override the config file.

    Behavior:
    - If the config file has no sections a default HostapdRoamer section is used.
    - Interfaces are required either via parameter or config file.
    - If roamers are not provided the function will default to all stations
      discovered on the listed interfaces.
    """
    config_parser = configparser.ConfigParser()
    config_parser.read(config_file)
    if config_parser.sections() and "HostapdRoamer" not in config_parser:
        raise KeyError(f"'HostapdRoamer' section not provided in {config_file}")
    elif not config_parser.sections():
        config_parser["HostapdRoamer"] = {}

    config = config_parser["HostapdRoamer"]

    if interfaces is None:
        interfaces = config.get("Interfaces")
        if interfaces is None:
            raise ValueError("Must specify hostapd interfaces to control")
        else:
            interfaces = _parse_csv_to_set(interfaces)

    access_points: dict[int, list[AccessPoint]] = {2: [], 5: []}
    for name in interfaces:
        access_point = AccessPoint(name=name)
        # Determine if the interface is 2.4GHz or 5GHz by examining its freq.
        is_2g = int(access_point.interface.get_status().get("freq")) < 3000
        if is_2g:
            access_points[2].append(access_point)
        else:
            access_points[5].append(access_point)

    all = False
    if roamers is None:
        roamers = config.get("Roamers")
        if roamers is None:
            logger.info("No roamers set. Defaulting to all stations.")
            all = True
            roamers = all_stations(access_points)
        else:
            roamers = _parse_csv_to_set(roamers)

    return Config(
        access_points=access_points,
        roamers=roamers,
        interfaces=interfaces,
        signal_thresholds={
            "2to5": config.getint("SignalThreshold2To5", 65),
            "5to2": config.getint("SignalThreshold5To2", 75),
        },
        sync_interval_minutes=config.getint("SyncInterval", 15),
        all_stations=all,
    )


def main(config: Config):
    """
    Main event loop.

    - Performs an initial neighbor setup and roamer check.
    - Periodically re-syncs neighbors and re-evaluates roaming needs based on
      the configured sync interval.
    - If config.all_stations is enabled the roamers list will be refreshed with
      all currently seen stations on each neighbor sync.
    """
    logger.info("Config: %s", config)
    last_neighbor_sync = setup_neighbors(config.access_points)
    logger.info("Initial sync of neighbors complete")
    need_roam = check_roamers(
        config.access_points, config.roamers, config.signal_thresholds
    )
    logger.info("Initial check of roamers")

    sync_interval = 60 * config.sync_interval_minutes
    sleep_interval = sync_interval // 2
    while True:
        current_time = time.time()
        if current_time - last_neighbor_sync >= sync_interval:
            sync_neighbors(config.access_points)
            logger.info("Synced neighbors")
            if config.all_stations:
                logger.info("Syncing all stations list with roamers")
                updated_stations = all_stations(config.access_points)
                deleted_stations = config.roamers.difference(updated_stations)
                new_stations = updated_stations.difference(config.roamers)
                logger.info("Removed stations: %s", deleted_stations)
                logger.info("Added stations: %s", new_stations)
                config.roamers.clear()
                config.roamers.update(updated_stations)
            need_roam = check_roamers(
                config.access_points, config.roamers, config.signal_thresholds
            )
            logger.info("Checked roamers")
            last_neighbor_sync = time.time()
        if need_roam:
            steer(config.access_points, need_roam)
            need_roam = {}

        # NOTE: there may be a better way to do this, but
        # this is needed to prevent over usage of the CPU
        time.sleep(sleep_interval)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-c",
        "--config-file",
        dest="config_file",
        default=CONFIG_FILE,
        help=f"Path to config file [default: {CONFIG_FILE}].",
    )
    parser.add_argument(
        "-i",
        "--interfaces",
        dest="interfaces",
        default="",
        type=str,
        help="Comma separated list of hostapd interfaces. Supersedes config.ini values.",
    )
    parser.add_argument(
        "-r",
        "--roamers",
        dest="roamers",
        default="",
        type=str,
        help="Comma separated list of roaming stations. Supersedes config.ini values.",
    )
    parser.add_argument(
        "-l",
        "--log-level",
        dest="log_level",
        default=None,
        choices=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        help="Set logging level (overrides default INFO).",
    )
    args = parser.parse_args()
    if args.log_level:
        logging.getLogger().setLevel(getattr(logging, args.log_level))
    interfaces = _parse_csv_to_set(args.interfaces) if args.interfaces else None
    roamers = _parse_csv_to_set(args.roamers) if args.roamers else None
    config = get_config(args.config_file, interfaces=interfaces, roamers=roamers)
    main(config)
