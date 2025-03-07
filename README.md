# Network Scan Script

I'm studying for the CCNA and have created some scripts to explore my local network and practice various topics I’m learning. This script is one of those experiments and is designed to help you understand network scanning, ARP table population, and host discovery.

## Overview

This Bash script performs a network scan on your local network by:

- Automatically detecting your network settings from a specified network interface.
- Pinging all IP addresses on the subnet to populate the ARP table.
- Running `arp-scan` to gather IP and MAC address mappings.
- Retrieving neighbor states using `ip neigh`.
- Attempting to resolve hostnames via the system resolver.
- Displaying the results in a formatted table.

## Features

- **Dynamic Network Detection:** Automatically determines your network CIDR based on the active interface.
- **ARP Table Population:** Pings all IP addresses on the subnet to update ARP/neigh tables.
- **IP ↔ MAC Mapping:** Uses `arp-scan` to map IP addresses to MAC addresses.
- **Neighbor States:** Retrieves device states (e.g., REACHABLE, STALE) using `ip neigh`.
- **Hostname Resolution:** Attempts to resolve hostnames using `getent hosts`.
- **Formatted Output:** Displays a neat table with columns for IP Address, MAC Address, State, and Hostname.

## Prerequisites

Ensure the following tools are installed on your Fedora (or compatible) Linux system:

- `ip` (usually comes with the `iproute2` package)
- `fping`
- `arp-scan`

You can install the missing tools using:

```bash
sudo dnf install fping arp-scan
```
