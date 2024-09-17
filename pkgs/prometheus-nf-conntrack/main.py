#!/usr/bin/env python

import fileinput
import re
from collections import deque
from prometheus_client import CollectorRegistry, Gauge, generate_latest

def write_to_prometheus(connections):
    namespace = "nf_conntrack"
    registry = CollectorRegistry()
    nat_bytes = Gauge("nat_bytes", "nf_conntrack connections", ["dst", "src"], namespace=namespace, registry=registry)
    for connection in connections:
        nat_bytes.labels(connection["dst"], connection["src"]).inc(int(connection["bytes"]))
    print(generate_latest(registry).decode(), end='')

def main():
    with open("/proc/net/nf_conntrack", "r") as conntrack:
        regex_space = re.compile(r"\s+")
        output = []
        for line in conntrack:
            connection = {}
            tokens = deque(re.split(regex_space, line))
            for token in tokens:
                tmp = token.split("=")
                if len(tmp) == 2 and tmp[0] in ("src", "dst", "bytes"):
                    connection[tmp[0]] = tmp[1]
            if connection:
                if not connection.get("bytes"):
                    connection["bytes"] = "0"
                output.append(connection)
        write_to_prometheus(output)

if __name__ == "__main__":
    main()
