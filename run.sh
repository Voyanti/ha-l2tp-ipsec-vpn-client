#!/usr/bin/env bash
set -e

CONFIG_PATH="/data/options.json"

VPN_SERVER=$(jq -r '.server' "$CONFIG_PATH")
VPN_PSK=$(jq -r '.psk' "$CONFIG_PATH")
VPN_USER=$(jq -r '.username' "$CONFIG_PATH")
VPN_PASS=$(jq -r '.password' "$CONFIG_PATH")
IDLE=$(jq -r '.idle' "$CONFIG_PATH")
REQUIRE_CHAP=$(jq -r '.require_chap' "$CONFIG_PATH")
REFUSE_CHAP=$(jq -r '.refuse_chap' "$CONFIG_PATH")
REFUSE_EAP=$(jq -r '.refuse_eap' "$CONFIG_PATH")
REFUSE_PAP=$(jq -r '.refuse_pap' "$CONFIG_PATH")

echo "Starting L2TP/IPsec VPN Client ..."
echo "VPN Server: $VPN_SERVER"

# Export variables so they're picked up by the scripts
export VPN_SERVER VPN_PSK VPN_USER VPN_PASS
export IDLE REQUIRE_CHAP REFUSE_CHAP REFUSE_EAP REFUSE_PAP

# If you have the original scripts from the GitHub repo, call them here.
# e.g. /usr/local/bin/entrypoint.sh
# or replicate the original commands from Dockerfile, for example:
# strongswan start; xl2tpd -c /etc/xl2tpd/xl2tpd.conf ...
# etc.

# For demonstration, just sleep so the container doesn't exit
# Replace this with the actual start commands for the VPN client
# from the original GitHub instructions.
tail -f /dev/null