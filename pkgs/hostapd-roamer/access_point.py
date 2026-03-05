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
from typing import Callable, NamedTuple

from hostapd import Hostapd


class NeighborComponents(NamedTuple):
    """
    Simple container for parsed neighbor components.

    Fields:
    - op_class: operating class (int)
    - channel: radio channel number (int)
    - phy: PHY identifier (int)
    """

    op_class: int
    channel: int
    phy: int


class ScanMode(Enum):
    """Enumeration of beacon scan request modes.

    Use these values when building beacon measurement requests:
    - PASSIVE: No active probing (listen only).
    - ACTIVE: Probe requests should be sent.
    - TABLE: Use an internal table (implementation-specific).
    """

    PASSIVE = 0
    ACTIVE = 1
    TABLE = 2


def parse_nr(compact_bssid: str, nr: str) -> NeighborComponents:
    """Parse neighbor report (nr) string and extract TLV subcomponents.

    The neighbor report format expected here contains a compact (no-colon)
    bssid prefix followed by TLV bytes as a hex string. The regex extracts
    reserved/random bytes plus the bytes holding operating class, channel and
    phy. The extracted values are converted to integers and returned as a
    NeighborComponents tuple.

    Parameters:
    - compact_bssid: BSSID with no separators and in lower-case (used as regex prefix).
    - nr: neighbor report payload as a hex string.

    Returns:
    - NeighborComponents(op_class, channel, phy)

    Raises:
    - ValueError if the provided nr string does not match the expected pattern.
    """
    # Compile a regex to find the compact BSSID followed by 4/1/1/1 bytes groups.
    pattern = re.compile(
        r"^"
        + re.escape(compact_bssid)
        + r"([a-z0-9]{8})([a-z0-9]{2})([a-z0-9]{2})([a-z0-9]{2})",
        re.IGNORECASE,
    )
    match = pattern.search(nr)

    if match:
        # match.group(1) is reserved (random/other bytes), groups 2-4 hold op_class,
        # channel, and phy (hex) respectively.
        op_class = int(match.group(2), 16)
        channel = int(match.group(3), 16)
        # Note: original code converts group(4) without explicit base; preserve behavior.
        phy = int(match.group(4))
    else:
        raise ValueError(f"Could not parse nr: {nr}")
    return NeighborComponents(op_class=op_class, channel=channel, phy=phy)


class Neighbor:
    """Representation of a neighbor AP entry.

    A Neighbor encapsulates the parsed SSID and neighbor report TLV for a
    remote AP, and may optionally hold an attached Hostapd control interface
    to issue commands against that neighbor.

    Typical initialization:
      Neighbor(bssid="aa:bb:cc:dd:ee:ff", ssid="6d7953736964", nr="<hex-tlv>")

    The neighbor registers atexit cleanup to ensure any attached control
    interface is closed when the process exits.
    """

    def __init__(self, bssid: str, ssid: str, nr: str, interface: Hostapd = None):
        self.bssid: str = bssid
        self.ssid = ssid
        self.nr = nr
        self.interface = interface

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

        Parameters:
        - close: if True, call close_ctrl() on the attached Hostapd interface.
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

        This builds a beacon measurement request TLV using the neighbor's parsed
        components and sends a REQ_BEACON command via the attached Hostapd
        instance. It then waits for response events and returns the dialog token
        and collected response events.

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
        if None in {self.interface, self.neighbor_components}:
            raise ValueError(
                "Neighbor must have an interface attached and parsed NeighborComponents"
            )
        request = build_beacon_request(
            op_class=self.neighbor_components.op_class,
            channel=self.neighbor_components.channel,
            mode=scan_mode,
            bssid=self.bssid,
        )
        return request_beacon(self.interface, scanning_station, request)

    @property
    def nr(self):
        """The nr property: neighbor report TLV as a hex string."""
        return self._nr

    @nr.setter
    def nr(self, value: str):
        """Setter for nr: parse and update neighbor_components when nr is updated.

        The setter parses the provided nr value to extract NeighborComponents and
        stores the raw nr string. Parsing failures will raise ValueError.
        """
        new_neighbor_components = parse_nr(self.compact_bssid, value)
        self._nr = value
        self.neighbor_components = new_neighbor_components

    @property
    def ssid(self):
        """The ssid property: SSID stored as a hex string."""
        return self._ssid

    @ssid.setter
    def ssid(self, value: str):
        """Setter for ssid; disallow empty values to avoid invalid neighbor entries."""
        if not value:
            raise ValueError("Must provide value for SSID to be updated")
        self._ssid = value

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

    Behaves like a standard Python list (UserList) but provides helpers to
    interact with hostapd control commands for adding, updating and removing
    neighbors. The Neighbor objects inside the report do not, by default, have
    Hostapd interfaces attached — those must be set explicitly using attach_interface.
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

        The method sends a SET_NEIGHBOR <BSSID> ssid=<hex> nr=<hex> command and
        dispatches based on the hostapd response.
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
            # On successful SET_NEIGHBOR, update the in-memory fields for the entry.
            self.data[idx].nr = neighbor.nr
            self.data[idx].ssid = neighbor.ssid

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
    # Pack the fields into binary (little-endian) and return hex + compact BSSID.
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

    This function performs the following steps:
    - Send REQ_BEACON <addr> <request> to hostapd and capture the dialog token.
    - Wait for BEACON-RESP-RX events (responses) until a BEACON-REQ-TX-STATUS
      event is received which signals the TX completion.
    - Validate the TX status contains the expected station address, dialog token,
      and an ACK (ack=1).

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
    # Wait for response events until we receive a TX status event.
    for i in range(24):
        ev = hapd.wait_event(["BEACON-REQ-TX-STATUS", "BEACON-RESP-RX"], timeout=5)
        if ev is None:
            raise ValueError("No TX status event for beacon request received")
        # If the event is the TX status, break and validate it below.
        if "BEACON-REQ-TX-STATUS" in ev:
            break
        # Otherwise accumulate response events (BEACON-RESP-RX).
        resp.append(ev)
    else:
        # Loop exhausted without a TX status.
        raise TimeoutError()
    # Validate the TX status payload format and expected values.
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
        # Create and store a Hostapd control wrapper for the given interface name.
        self.interface = Hostapd(ifname=name)

        # Wait for the control interface to become responsive (ping).
        counter = 0
        while not self.interface.ping():
            # Raise exception if no ping returned in 60 seconds
            if counter >= 12:
                timeout_seconds = counter * 5
                raise InterfaceConnectionError(
                    f"Failed to establish connection to interface '{name}' "
                    f"within {timeout_seconds} seconds"
                )
            sleep(5)
            counter += 1

        # Set the AP's own BSSID from the hostapd instance.
        self.bssid = self.interface.own_addr()

        # Get a cleared neighbor report (only includes own entry after clearing).
        self._neighbor_report = self._clear_neighbors()

        # Init super class using own report as the only neighbor in list.
        if not self._neighbor_report:
            raise ValueError("Could not determine own neighbor information")
        own_neighbor = self._neighbor_report[0]
        self.ssid = own_neighbor.ssid
        self.nr = own_neighbor.nr
        # Ensure any attached interface is detached when process exits.
        atexit.register(self.detach_interface)

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
            # Filter to find the entry corresponding to the neighbor's own BSSID.
            new_neighbor_info = list(
                filter(lambda x: x.bssid == neighbor.bssid, new_neighbor_report)
            )
            if not new_neighbor_info:
                continue
            new_neighbor = new_neighbor_info[0]
            self._neighbor_report.update(self.interface, new_neighbor)

    def steer_station(
        self, station: str, target: Neighbor, force: bool = False
    ) -> bool:
        """Steer a station to a target neighbor using a BSS Transition Management request.

        Parameters:
        - station: MAC address of the station to steer.
        - target: Neighbor instance representing the target AP (must have parsed NeighborComponents).
        - force: If True, include disassociation imminent flags to force the steer.

        Returns:
        - True if hostapd returned OK, False if FAIL.

        Raises:
        - ValueError if target missing NeighborComponents or for unknown hostapd responses.
        """
        if target.neighbor_components is None:
            raise ValueError("Target Neighbor must have a NeighborComponents set")

        request = f"BSS_TM_REQ {station} pref=1 abridged=1 neighbor={target.bssid.upper()},0x0000,{target.neighbor_components.op_class},{target.neighbor_components.channel},{target.neighbor_components.phy}"
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
        Each returned entry is expected to be a dict-like object; the function
        accumulates those and returns the list.

        Note: the declared return type is the original project's annotation;
        the implementation actually returns a list of station dictionaries.
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

        The function requests the current neighbor report, waits for a non-empty
        report (with retries), removes every neighbor that does not match the
        AP's own BSSID, and returns the resulting fresh NeighborReport.
        """
        report = NeighborReport.request(self.interface)

        counter = 0
        while not report:
            if counter >= 12:
                raise InterfaceConnectionError("Could not generate NeighborReport")
            sleep(5)
            report = NeighborReport.request(self.interface)
            counter += 1

        # Remove any neighbor entries that do not belong to this AP.
        to_clear = [neighbor for neighbor in report if neighbor.bssid != self.bssid]
        for neighbor in to_clear:
            # Detach any attached interface reference before removing the entry.
            neighbor.detach_interface(close=False)
            report.remove(self.interface, neighbor)

        return report
