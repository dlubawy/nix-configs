#!/usr/bin/env python
import json
import subprocess
from datetime import datetime, timedelta
from typing import Any, Dict, List

from prometheus_client import CollectorRegistry, Info, generate_latest


class Address:
    def __init__(self, address: List[int]):
        self.address = address

    def __repr__(self) -> str:
        return ".".join([str(i) for i in self.address])

    def __reversed__(self) -> str:
        return ".".join([str(i) for i in reversed(self.address)])


def get_output(command: List[str]) -> str:
    try:
        output = subprocess.check_output(command, stderr=subprocess.DEVNULL)
    except subprocess.CalledProcessError:
        return None
    return output.decode()


def write_to_prometheus(leases: List[Dict[str, Any]]) -> str:
    namespace = "networkctl"
    registry = CollectorRegistry()
    dhcp_leases = Info(
        "dhcp_server_leases",
        "DHCP Server Leases",
        ["address"],
        namespace=namespace,
        registry=registry,
    )
    for lease in leases:
        dhcp_leases.labels(lease.pop("address")).info(lease)
    print(generate_latest(registry).decode(), end="")


def get_hostname(address: Address, default: str = "") -> str:
    resolvectl_output = get_output(
        [
            "resolvectl",
            "--json=short",
            "--type=PTR",
            "query",
            f"{reversed(address)}.in-addr.arpa",
        ]
    )
    resolvectl = json.loads(resolvectl_output) if resolvectl_output else {}
    return resolvectl.get("name", default)


def main():
    output = []
    for net in ["vl-lan", "vl-user", "vl-iot", "vl-guest"]:
        networkctl = json.loads(
            get_output(["networkctl", "--json=short", "status", net])
        )
        for lease in networkctl.get("DHCPServer", {}).get("Leases", []):
            address = Address(lease.get("Address", [0, 0, 0, 0]))
            hostname = get_hostname(address, lease.get("Hostname", ""))
            client_id = ":".join(
                [hex(i).lstrip("0x") for i in lease.get("ClientId", [])]
            )
            output.append(
                {
                    "hostname": hostname,
                    "address": str(address),
                    "network": net,
                    "expiration": str(
                        datetime.now()
                        + timedelta(microseconds=lease.get("ExpirationUSec", 0))
                    ),
                    "client_id": client_id,
                }
            )
    write_to_prometheus(output)


if __name__ == "__main__":
    main()
