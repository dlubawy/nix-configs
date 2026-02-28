#!/usr/bin/env python3
import argparse
import configparser
import logging
import os
import time
from itertools import chain, combinations
from pathlib import Path
from typing import Any, NamedTuple

from access_point import AccessPoint

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s: %(message)s"
)
logger = logging.getLogger("hostapd-roamer")

XDG_CONFIG_HOME = Path(os.getenv("XDG_CONFIG_HOME", "~/.config")).expanduser()
CONFIG_DIR = (
    f"{XDG_CONFIG_HOME}/hostapd-roamer"
    if XDG_CONFIG_HOME.exists() and os.getuid() >= 1000
    else "/etc/hostapd-roamer"
)
CONFIG_FILE = f"{CONFIG_DIR}/config.ini"


class Config(NamedTuple):
    access_points: dict[int, list[AccessPoint]]
    interfaces: set[str]
    roamers: set[str]
    signal_thresholds: dict[str, int] = {"2to5": 65, "5to2": 75}
    sync_interval_minutes: int = 15
    all_stations: bool = False


def setup_neighbors(access_points: dict[int, list[AccessPoint]]) -> float:
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
                # If our 2.4GHz signal is very strong we can try a roam to 5GHz
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
    if isinstance(access_points, dict):
        for freq_access_points in access_points.values():
            sync_neighbors(freq_access_points)
    else:
        for access_point in access_points:
            access_point.sync_neighbors()


def _parse_csv_to_set(line: str) -> set[str]:
    return {item.strip() for item in line.split(",") if item.strip()}


def all_stations(access_points: dict[int, list[AccessPoint]]) -> set[str]:
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
    logger.info("Config: %s", config)
    last_neighbor_sync = setup_neighbors(config.access_points)
    logger.info("Initial sync of neighbors complete")

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
            if need_roam:
                steer(config.access_points, need_roam)
            last_neighbor_sync = time.time()

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
