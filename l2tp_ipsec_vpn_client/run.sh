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

echo "Stopping any existing StrongSwan and xl2tpd processes..."
pkill -f charon
pkill -f xl2tpd

sleep 2

echo "Starting StrongSwan VPN connection..."
ipsec start

sleep 5  # Allow time for StrongSwan to initialize

echo "Bringing up the IPsec tunnel..."
ipsec up L2TP-IPsec

sleep 3  # Allow time for negotiation

echo "Starting xl2tpd..."
mkdir -p /var/run/xl2tpd
xl2tpd -D &

sleep 7  # Give xl2tpd some time to start

echo "Sending connection command to xl2tpd..."
echo "c L2TP-IPsec" > /var/run/xl2tpd/l2tp-control

echo "VPN connection started."

# Keep the container running
exec tail -f /dev/null