"""
hostapd-roamer access_point module.

Provides utilities to parse and manage neighbor reports from hostapd, build and
request beacon measurement frames, and perform AP-level operations such as
steering stations to neighboring APs.

Key classes:
- ScanMode: Enumeration of scan request modes.
- Neighbor: Representation of a single neighbor entry parsed from a neighbor
  report string.
- NeighborReport: Container and manager for multiple Neighbor instances,
  including operations that call hostapd control commands.
- AccessPoint: Convenience subclass representing the current AP and helpers to
  manage/synchronize neighbors and steer stations.

This module expects a Hostapd wrapper (imported from hostapd) that provides
methods such as request, wait_event, get_sta, own_addr, and close_ctrl.
"""

import atexit
import binascii
import re
import struct
import warnings
from collections import UserList
from enum import Enum
from time import sleep
from typing import Callable

from hostapd import Hostapd


class ScanMode(Enum):
    """Enumeration of beacon scan request modes.

    - PASSIVE: No active probing (listen only).
    - ACTIVE: Probe requests should be sent.
    - TABLE: Use an internal table (implementation-specific).
    """

    PASSIVE = 0
    ACTIVE = 1
    TABLE = 2


class Neighbor:
    """Representation of a neighbor AP entry.

    A neighbor is initialized using:
      - bssid: MAC address in colon-separated format (e.g. "aa:bb:cc:dd:ee:ff")
      - ssid: SSID represented as a hex string in the neighbor report
      - nr:  Neighbor report TLV (hex string) from which op_class, channel, and
             phy are parsed

    The constructor parses the 'nr' field to extract operating class, channel,
    and PHY. An attached Hostapd interface may be provided to perform requests
    against the neighbor's hostapd instance.
    """

    def __init__(self, bssid: str, ssid: str, nr: str, interface: Hostapd = None):
        self.bssid: str = bssid
        self.ssid: str = ssid
        self.nr: str = nr
        self.interface = interface

        # Parse the neighbor report (nr) to extract op_class, channel, and phy.
        # The pattern expects the compact (no colons) bssid followed by TLV bytes.
        pattern = re.compile(
            r"^"
            + re.escape(self.compact_bssid)
            + r"([a-z0-9]{8})([a-z0-9]{2})([a-z0-9]{2})([a-z0-9]{2})",
            re.IGNORECASE,
        )
        match = pattern.search(nr)

        if match:
            # match.group(1) is reserved (random/other bytes), groups 2-4 hold op_class,
            # channel, and phy (hex) respectively.
            self.op_class = int(match.group(2), 16)
            self.channel = int(match.group(3), 16)
            self.phy = int(match.group(4))
        else:
            raise ValueError(f"Could not parse nr: {nr}")

        # Ensure that when the program exits, any opened control connection is closed.
        atexit.register(self.detach_interface)

    def __repr__(self):
        """Developer-friendly representation of a Neighbor."""
        return f"Neighbor(bssid={self.bssid}, ssid={self.ssid}, nr={self.nr})"

    def __str__(self):
        """User-friendly string representation (BSSID)."""
        return self.bssid

    def detach_interface(self, close: bool = True):
        """Close and detach any Hostapd control interface associated with this neighbor.

        This is idempotent: if no interface is attached, this becomes a no-op.
        """
        if self.interface is not None and close:
            self.interface.close_ctrl()
        self.interface = None

    def attach_interface(self, interface: Hostapd):
        """Attach a Hostapd interface to this neighbor for further control calls.

        Parameters:
        - interface: Hostapd wrapper instance exposing control methods.
        """
        self.interface = interface

    def request_measurement(
        self,
        scanning_station: str,
        scan_mode: ScanMode = ScanMode.PASSIVE,
    ) -> tuple[str]:
        """Request a beacon measurement from this neighbor via the attached interface.

        Parameters:
        - scanning_station: MAC address of the station performing the scan.
        - scan_mode: A ScanMode enum or integer indicating passive/active/table mode.

        Returns:
        - Tuple containing the dialog token and a list of response events.

        Raises:
        - ValueError if required attributes (interface/op_class/channel) are missing.
        - Exceptions propagated from build_beacon_request and request_beacon.
        """
        scan_mode = (
            scan_mode.value if isinstance(scan_mode, ScanMode) else int(scan_mode)
        )
        if None in {self.interface, self.op_class, self.channel}:
            raise ValueError("Neighbor must have an interface attached")
        request = build_beacon_request(
            op_class=self.op_class,
            channel=self.channel,
            mode=scan_mode,
            bssid=self.bssid,
        )
        return request_beacon(self.interface, scanning_station, request)

    @property
    def compact_bssid(self) -> str:
        """Return the BSSID without colon separators in lower-case.

        This format is used to match the compact BSSID prefix inside Neighbor
        Report TLV strings.
        """
        return self.bssid.replace(":", "").lower()


class SetNeighborError(Exception):
    """Raised when setting a neighbor in hostapd's neighbor report fails."""


class RemoveNeighborError(Exception):
    """Raised when removing a neighbor from hostapd's neighbor report fails."""


class NeighborReport(UserList):
    """Container and manager for Neighbor objects parsed from a raw neighbor report.

    The container behaves like a list of Neighbor objects and provides helper
    methods to add, update and remove neighbors by issuing corresponding
    hostapd control commands.
    """

    def __init__(self, raw_report: str):
        """Parse a raw neighbor report string and populate Neighbor entries.

        The raw_report is expected to contain lines with the format:
          "<bssid> ssid=<hex> nr=<hex>"

        Matching is case-insensitive.
        """
        super().__init__()
        matches = re.findall(
            r"([a-f0-9]{2}:[a-f0-9]{2}:[a-f0-9]{2}:[a-f0-9]{2}:[a-f0-9]{2}:[a-f0-9]{2}) ssid=([a-f0-9]+) nr=([a-f0-9]+)",
            raw_report,
            re.IGNORECASE,
        )
        for bssid, ssid, nr in matches:
            self.data.append(Neighbor(bssid, ssid, nr))

    def remove(self, hapd: Hostapd, neighbor: Neighbor):
        """Remove a neighbor from the report via hostapd control.

        Parameters:
        - hapd: Hostapd instance used to send the REMOVE_NEIGHBOR command.
        - neighbor: Neighbor object to remove.

        Raises:
        - ValueError if the neighbor does not exist in this report.
        - RemoveNeighborError if hostapd returns FAIL.
        - ValueError for unknown hostapd responses.
        """
        if neighbor not in self.data:
            raise ValueError(f"Neighbor not in report: {neighbor.bssid}")

        match hapd.request(f"REMOVE_NEIGHBOR {neighbor.bssid.upper()}").strip():
            case "OK":
                return self.data.remove(neighbor)
            case "FAIL":
                raise RemoveNeighborError()
            case unknown:
                raise ValueError(f"Unknown error: {unknown}")

    def _set_neighbor(
        self, hapd: Hostapd, neighbor: Neighbor, ok_func: Callable[[Neighbor], None]
    ):
        """Internal helper to set (add/update) a neighbor by calling hostapd.

        - hapd: Hostapd instance to use for the SET_NEIGHBOR command.
        - neighbor: Neighbor object to set.
        - ok_func: Function to call on success (typically list.append or a setter).

        Raises:
        - SetNeighborError if hostapd returns FAIL.
        - ValueError for unknown hostapd responses.
        """
        match hapd.request(
            f"SET_NEIGHBOR {neighbor.bssid.upper()} ssid={neighbor.ssid} nr={neighbor.nr}"
        ).strip():
            case "OK":
                return ok_func(neighbor)
            case "FAIL":
                raise SetNeighborError()
            case unknown:
                raise ValueError(f"Unknown error: {unknown}")

    def update(self, hapd: Hostapd, neighbor: Neighbor):
        """Update an existing neighbor entry in the report.

        Parameters:
        - hapd: Hostapd instance to send the update command.
        - neighbor: Neighbor containing new data (must match an existing BSSID).

        Raises:
        - ValueError if the neighbor does not exist in the report.
        """
        old_neighbor = None
        for idx, value in enumerate(self.data):
            if value.bssid == neighbor.bssid:
                old_neighbor = value
                break
        if old_neighbor is None:
            raise ValueError(f"Neighbor does not exist in report: {neighbor.bssid}")

        def ok_func(neighbor):
            self.data[idx] = neighbor

        return self._set_neighbor(hapd, neighbor, ok_func)

    def append(self, hapd: Hostapd, neighbor: Neighbor):
        """Append a new neighbor to the report via hostapd control.

        Parameters:
        - hapd: Hostapd instance to send the SET_NEIGHBOR command.
        - neighbor: Neighbor to add.

        Raises:
        - ValueError if the neighbor already exists in the report.
        - SetNeighborError if hostapd returns FAIL.
        """
        if neighbor.bssid in {current_neighbor.bssid for current_neighbor in self.data}:
            raise ValueError(f"Neighbor already exists in report: {neighbor.bssid}")
        return self._set_neighbor(hapd, neighbor, self.data.append)

    @staticmethod
    def request(hapd: Hostapd) -> "NeighborReport":
        """Request the current neighbor report string from a Hostapd instance.

        Returns a NeighborReport parsed from the hostapd "SHOW_NEIGHBOR" response.
        """
        return NeighborReport(hapd.request("SHOW_NEIGHBOR"))


def build_beacon_request(
    op_class=81, channel=0, random_int=0, duration=0, mode=0, bssid="FF:FF:FF:FF:FF:FF"
) -> str:
    """Build a beacon measurement request payload.

    The returned string is a hex-encoded TLV followed by the BSSID without
    separators. The TLV is packed as little-endian with fields:
      op_class (1 byte), channel (1 byte), random_int (2 bytes), duration (2 bytes), mode (1 byte)

    Parameters:
    - op_class: operating class (integer)
    - channel: channel number
    - random_int: random or reserved integer field
    - duration: duration for scan (ms or units as used by hostapd)
    - mode: scan mode flag (0=passive, 1=active, etc.)
    - bssid: destination BSSID (colon-separated string)

    Returns:
    - Hex string representing the request accepted by hostapd's REQ_BEACON command.
    """
    request = struct.pack("<BBHHB", op_class, channel, random_int, duration, mode)
    return binascii.hexlify(request).decode() + bssid.replace(":", "")


class ReqBeaconError(Exception):
    """Raised when REQ_BEACON token generation/acknowledgement fails."""


class TimeoutError(Exception):
    """Raised when waiting for a beacon response times out."""


class NoAckError(Exception):
    """Raised when a TX event indicates no ACK was received for the request."""


def request_beacon(hapd: Hostapd, address: str, request: str) -> tuple[str]:
    """Send a REQ_BEACON command and wait for response events.

    Parameters:
    - hapd: Hostapd instance used to send the REQ_BEACON command.
    - address: MAC address of the target STA (scanning station).
    - request: Hex-encoded beacon request payload as produced by build_beacon_request.

    Returns:
    - A tuple (token, resp) where token is the dialog token returned by hostapd
      and resp is a list of response event strings collected before the TX status.

    Raises:
    - ReqBeaconError: if hostapd returns a failure for REQ_BEACON.
    - ValueError: for unexpected or malformed events.
    - TimeoutError: if no TX status event is observed within retry attempts.
    - NoAckError: if the TX status indicates no ACK (ack=0).
    """
    token = hapd.request("REQ_BEACON " + address + " " + request)
    if "FAIL" in token:
        raise ReqBeaconError()

    resp = []
    for i in range(24):
        ev = hapd.wait_event(["BEACON-REQ-TX-STATUS", "BEACON-RESP-RX"], timeout=5)
        if ev is None:
            raise ValueError("No TX status event for beacon request received")
        if "BEACON-REQ-TX-STATUS" in ev:
            break
        resp.append(ev)
    else:
        raise TimeoutError()
    fields = ev.split(" ")
    if fields[1] != address:
        raise ValueError("Unexpected STA address in TX status: " + fields[1])
    if fields[2] != token:
        raise ValueError(
            "Unexpected dialog token in TX status: "
            + fields[2]
            + " (expected "
            + token
            + ")"
        )
    if fields[3] != "ack=1":
        raise NoAckError()
    return token, resp


class InterfaceConnectionError(Exception):
    """Failed to connect to interface"""


class AccessPoint(Neighbor):
    """Representation of the local access point with neighbor management helpers.

    This class wraps a Hostapd interface for the AP named by `name` and exposes
    convenience methods to manage and synchronize neighbor reports as well as
    steering stations to other neighbors.
    """

    def __init__(self, name: str):
        # Needed for initial report
        self.interface = Hostapd(ifname=name)

        counter = 0
        while not self.interface.ping:
            # Raise exception if no ping returned in 60 seconds
            if counter >= 12:
                raise InterfaceConnectionError()
            sleep(5)
            counter += 1

        self.bssid = self.interface.own_addr()

        # Get a cleared report
        self._neighbor_report = self._clear_neighbors()

        # Init super class using own report as the only neighbor in list
        if not self._neighbor_report:
            raise ValueError("Could not determine own neighbor information")
        own_neighbor = self._neighbor_report[0]
        own_neighbor.attach_interface(self.interface)
        super().__init__(
            bssid=own_neighbor.bssid,
            ssid=own_neighbor.ssid,
            nr=own_neighbor.nr,
            interface=own_neighbor.interface,
        )

    def add_neighbor(self, neighbor: "AccessPoint"):
        """Add a neighbor AccessPoint to this AP's neighbor report.

        Raises:
        - ValueError if attempting to add self as a neighbor.
        - Propagates errors from NeighborReport.append when hostapd interaction fails.
        """
        if self.bssid == neighbor.bssid:
            raise ValueError("Cannot add self as neighbor")
        self._neighbor_report.append(self.interface, neighbor)

    def sync_neighbors(self):
        """Synchronize local neighbor data with information fetched from each neighbor.

        For every neighbor that has an attached interface, fetch that neighbor's
        current neighbor report and update the local report entry for that BSSID.
        Missing interfaces are logged as warnings and skipped.
        """
        for neighbor in self._neighbor_report:
            if neighbor.interface is None:
                warnings.warn(
                    f"AccessPoint neighbor missing interface: {neighbor.bssid}",
                    RuntimeWarning,
                )
                continue
            new_neighbor_report = NeighborReport.request(neighbor.interface)
            new_neighbor_info = list(
                filter(lambda x: x.bssid == neighbor.bssid, new_neighbor_report)
            )
            if not new_neighbor_info:
                continue
            # Detach interface from old Neighbor without closing socket
            neighbor.detach_interface(close=False)
            # Attach interface to the new Neighbor
            new_neighbor_info[0].attach_interface(self.interface)
            self._neighbor_report.update(self.interface, new_neighbor_info[0])

    def steer_station(
        self, station: str, target: Neighbor, force: bool = False
    ) -> bool:
        """Steer a station to a target neighbor using a BSS Transition Management request.

        Parameters:
        - station: MAC address of the station to steer.
        - target: Neighbor instance representing the target AP (must have parsed op_class, channel, phy).
        - force: If True, include disassociation imminent flags to force the steer.

        Returns:
        - True if hostapd returned OK, False if FAIL.

        Raises:
        - ValueError if target missing op_class/channel/phy or for unknown hostapd responses.
        """
        if None in {target.op_class, target.channel, target.phy}:
            raise ValueError("Target Neighbor must have op_class, channel, and phy set")

        request = f"BSS_TM_REQ {station} pref=1 abridged=1 neighbor={target.bssid.upper()},0x0000,{target.op_class},{target.channel},{target.phy}"
        if force:
            request = f"{request} disassoc_imminent=1 disassoc_timer=10"

        result = self.interface.request(request)
        match result.strip():
            case "OK":
                return True
            case "FAIL":
                return False
            case unknown:
                raise ValueError(f"Unknown error: {unknown}")

    def get_stations(self) -> dict[str, str]:
        """Return a list of stations known to this AP by iterating get_sta.

        The method iterates hostapd.get_sta until no next station is returned.
        """
        stations = []
        current_station = {}
        while current_station := self.interface.get_sta(
            addr=current_station.get("addr"),
            next=current_station.get("addr") is not None,
        ):
            if current_station.get("addr").strip() == "FAIL":
                raise ValueError("Failed to get stations")
            stations.append(current_station)
        return stations

    def _clear_neighbors(self) -> NeighborReport:
        """Clear all neighbors except the AP's own entry from the hostapd neighbor report.

        Returns the fresh neighbor report after clearing.
        """
        report = NeighborReport.request(self.interface)

        counter = 0
        while not report:
            if counter >= 12:
                raise InterfaceConnectionError("Could not generate NeighborReport")
            sleep(5)
            report = NeighborReport.request(self.interface)
            counter += 1

        for neighbor in report:
            if neighbor.bssid == self.bssid:
                continue
            neighbor.detach_interface(close=False)
            report.remove(self.interface, neighbor)
        return NeighborReport.request(self.interface)
