#!/usr/bin/env python
# WARN: this is a terribly lazy method for parsing text

from collections import deque
import re
from prometheus_client import CollectorRegistry, Gauge, generate_latest
import subprocess

def get_output(command):
    try:
        output = subprocess.check_output(command, stderr=subprocess.DEVNULL)
    except subprocess.CalledProcessError:
        return None
    return output.decode()

def write_to_prometheus(interfaces):
    namespace = "iwinfo"
    registry = CollectorRegistry()
    link_quality = Gauge("link_quality", "Wi-Fi link quality", ["interface", "mac_address"], namespace=namespace, registry=registry)
    noise = Gauge("noise_dbm", "Wi-Fi noise level", ["interface", "mac_address"], namespace=namespace, registry=registry)
    for interface in interfaces:
        q1, q2 = interface["Link Quality"].split("/")
        n = interface["Noise"].split(" ")[0]
        if q1 != "unknown":
            link_quality.labels(interface["Interface"], interface["Access Point"]).set(int(q1)/int(q2))
        noise.labels(interface["Interface"], interface["Access Point"]).set(int(n))
    print(generate_latest(registry).decode(), end='')

def main():
    iwinfo = get_output(["iwinfo"]).splitlines()

    regex_divider = re.compile(r"\s{2,}")
    regex_interface = re.compile(r"wlan[0-9.-]+\s+")
    output = []
    idx = None
    for line in iwinfo:
        tokens = deque(re.split(regex_divider, line.strip()))
        if not tokens or not tokens[0]:
            continue
        for token in tokens:
            if token.startswith("wlan"):
                idx = 0 if idx is None else idx + 1
                output.append({"Interface": token.split(" ")[0]})
                tmp = re.split(regex_interface, token)
                if len(tmp) == 1:
                    continue
                token = tmp[1]
            tmp = token.split(": ")
            if idx == len(output):
                output.append({})
            if len(tmp) == 1:
                output[idx]["Interface"] = tmp[0].split(" ")
            else:
                output[idx][tmp[0]] = tmp[1]
    write_to_prometheus(output)

if __name__ == '__main__':
    main()
