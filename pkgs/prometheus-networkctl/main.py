#!/usr/bin/env python

from prometheus_client import CollectorRegistry, Info, generate_latest
import subprocess
import json
from datetime import datetime, timedelta

def get_output(command):
    try:
        output = subprocess.check_output(command, stderr=subprocess.DEVNULL)
    except subprocess.CalledProcessError:
        return None
    return output.decode()

def write_to_prometheus(leases):
    namespace = "networkctl"
    registry = CollectorRegistry()
    dhcp_leases = Info("dhcp_server_leases", "DHCP Server Leases", ["address"], namespace=namespace, registry=registry)
    for lease in leases:
        dhcp_leases.labels(lease.pop("address")).info(lease)
    print(generate_latest(registry).decode(), end='')

def main():
    output = []
    for net in ["vl-lan", "vl-user", "vl-iot", "vl-guest"]:
        networkctl = json.loads(get_output(["networkctl", "--json=short", "status", net]))
        for lease in networkctl.get("DHCPServer", {}).get("Leases", []):
            output.append({"hostname": lease.get("Hostname", ""), "address": ".".join([str(i) for i in lease.get("Address", [0, 0, 0, 0])]), "expiration": str(datetime.now() + timedelta(microseconds=lease.get("ExpirationUSec", 0)))})
    write_to_prometheus(output)

if __name__ == '__main__':
    main()
