#!/usr/bin/env bash
#
# Usage:
#   ./network-scan.sh [INTERFACE]
#
# If no interface is specified, defaults to wlp9s0.
#
# This script is a generic network scanner and does not contain any personal information.
# It is intended for educational and network diagnostic purposes.

# 1. Set interface dynamically from the first argument or default to wlp9s0
INTERFACE="${1:-wlp9s0}"

# 2. Detect the IP/CIDR of the specified interface (e.g. "192.168.1.16/24")
NET_CIDR=$(ip -f inet addr show dev "$INTERFACE" 2>/dev/null \
  | grep -oP '(?<=inet\s)\d+(\.\d+){3}/\d+')

if [ -z "$NET_CIDR" ]; then
  echo "ERROR: Could not determine an IPv4 address/CIDR for interface: $INTERFACE"
  echo "Make sure the interface is up and has an assigned IPv4 address."
  exit 1
fi

echo "Interface: $INTERFACE"
echo "Detected network: $NET_CIDR"

# 3. Ping the entire subnet to populate ARP/neigh tables
echo -e "\n[1/4] Pinging all IPs on $NET_CIDR..."
if ! command -v fping >/dev/null 2>&1; then
  echo "fping not found. Please install it (e.g., 'sudo dnf install fping')"
  exit 1
fi
fping -a -g "$NET_CIDR" > /dev/null 2>&1

# 4. Run arp-scan to get IP ↔ MAC mappings
echo "[2/4] Running arp-scan on interface $INTERFACE..."
if ! command -v arp-scan >/dev/null 2>&1; then
  echo "arp-scan not found. Please install it (e.g., 'sudo dnf install arp-scan')"
  exit 1
fi
sudo arp-scan --interface="$INTERFACE" --localnet > /tmp/arp-scan-output 2>/dev/null

# 5. Capture the neighbor table (ip neigh)
echo "[3/4] Retrieving neighbor states from ip neigh..."
IP_NEIGH_OUTPUT=$(ip neigh)

# 6. Parse results and print in a table
echo -e "\n[4/4] Results (IP, MAC, State, Hostname)\n"
echo -e "IP Address\tMAC Address\t\tState\t\tHostname"
echo "--------------------------------------------------------------------"

while read -r line; do
  # Example line from arp-scan: "192.168.1.1   28:9e:fc:66:6e:d2   Sagemcom Broadband SAS"
  IPADDR=$(echo "$line" | awk '{print $1}')
  MACADDR=$(echo "$line" | awk '{print $2}')

  # Skip summary or blank lines
  if [[ ! "$IPADDR" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    continue
  fi

  # Get neighbor state from ip neigh
  # e.g. "192.168.1.1 dev wlp9s0 lladdr 28:9e:fc:66:6e:d2 REACHABLE"
  STATE=$(echo "$IP_NEIGH_OUTPUT" | grep -w "$IPADDR" | awk '{print $6}' | head -n1)
  [ -z "$STATE" ] && STATE="UNKNOWN"

  # Resolve hostname
  HOSTNAME=$(getent hosts "$IPADDR" | awk '{print $2}')
  [ -z "$HOSTNAME" ] && HOSTNAME="UNKNOWN"

  # Print results
  echo -e "${IPADDR}\t${MACADDR}\t${STATE}\t${HOSTNAME}"
done < /tmp/arp-scan-output

# Cleanup
rm -f /tmp/arp-scan-output
