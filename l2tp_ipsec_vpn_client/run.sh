#!/usr/bin/env bash
set -e

CONFIG_PATH="/data/options.json"

VPN_SERVER=$(jq -r '.server' "$CONFIG_PATH")
VPN_PSK=$(jq -r '.psk' "$CONFIG_PATH")
VPN_USER=$(jq -r '.username' "$CONFIG_PATH")
VPN_PASS=$(jq -r '.password' "$CONFIG_PATH")

echo "Starting L2TP/IPsec VPN Client ..."
echo "VPN Server: $VPN_SERVER"

# Export variables so they're picked up by the scripts
export VPN_SERVER VPN_PSK VPN_USER VPN_PASS
export IDLE REQUIRE_CHAP REFUSE_CHAP REFUSE_EAP REFUSE_PAP

# template out all the config files using env vars
sed -i 's/right=.*/right='$VPN_SERVER'/' /etc/ipsec.conf
# echo ': PSK "'$VPN_PSK'"' > /etc/ipsec.secrets
echo '%any %any : PSK "'$VPN_PSK'"' > /etc/ipsec.secrets
sed -i 's/lns = .*/lns = '$VPN_SERVER'/' /etc/xl2tpd/xl2tpd.conf
sed -i 's/name .*/name '$VPN_USER'/' /etc/ppp/options.l2tpd.client
sed -i 's/password .*/password '"$VPN_PASS"'/' /etc/ppp/options.l2tpd.client
echo "$VPN_USER * \"$VPN_PASS\" *" > /etc/ppp/chap-secrets


# --- PRINT THE RESULTING FILES ---
echo "=== /etc/ipsec.conf ==="
cat /etc/ipsec.conf
echo

echo "=== /etc/ipsec.secrets ==="
cat /etc/ipsec.secrets
echo

echo "=== /etc/xl2tpd/xl2tpd.conf ==="
cat /etc/xl2tpd/xl2tpd.conf
echo

echo "=== /etc/ppp/options.l2tpd.client ==="
cat /etc/ppp/options.l2tpd.client
echo

echo "=== /etc/ppp/chap-secrets ==="
cat /etc/ppp/chap-secrets
echo

echo "Starting StrongSwan VPN connection..."

# Start StrongSwan (Pluto is specific to Libreswan, so we use StrongSwan commands)
ipsec start
sleep 5  # Allow time for IPsec to initialize

# Bring up the IPsec tunnel using StrongSwan
ipsec up L2TP-IPsec
sleep 3  # Allow time for negotiation

# Show the current status of IPsec connections
ipsec status
sleep 3

# Ensure the control file directory exists before writing
mkdir -p /var/run/xl2tpd

# Start xl2tpd in debug mode (-D)
echo "Starting xl2tpd..."
exec /usr/sbin/xl2tpd -D -c /etc/xl2tpd/xl2tpd.conf &

# Wait and then send the connection command to xl2tpd
sleep 7
echo "c myVPN" > /var/run/xl2tpd/l2tp-control
echo "VPN connection started."

# Keep container running (prevents Docker from exiting)
tail -f /dev/null