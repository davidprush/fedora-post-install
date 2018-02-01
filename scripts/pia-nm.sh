#!/bin/bash
#
# Install OpenVPN profiles in NetworkManager for PIA
#

error() {
	echo $@ >&2
	exit 255
}

HTTP_PIA_CERT="https://www.privateinternetaccess.com/openvpn/"
HTTP_PIA_INFO="https://www.privateinternetaccess.com/vpninfo/servers?version=24"

. "$SCRIPT_DIR/LIBRARY.sh"

LIB_TEST_ROOT
if [ $(LIB_TEST_APP "python") ]; then 
	LIB_INSTALL_APP python
fi
if [ $(LIB_TEST_APP "NetworkManager-openvpn") ]; then
	LIB_INSTALL_APP NetworkManager-openvpn
fi

# Get user data
LIB_ECHO YELLOW "$(LIB_BANNER_BEGIN ' PIA ACCOUNT INFORMATION AND OPTIONS ')"
echo -n "PIA username (pNNNNNNN): "
read pia_username
if [ -z "$pia_username" ]; then
	error "Username is required, aborting."
fi
echo -n "PIA password ($pia_username): "
read pia_password
if [ -z "$pia_password" ]; then
	error "Password is required, aborting."
fi
echo -n "Connection method (UDP/tcp): "
read pia_tcp
case "$pia_tcp" in
	U|u|UDP|udp|"")
		pia_tcp=no
		;;
	T|t|TCP|tcp)
		pia_tcp=yes
		;;
	*)
		error "Connection protocol must be UDP or TCP."
esac
echo -n "Strong encryption (Y/n): "
read pia_strong
case "$pia_strong" in
	Y|y|yes|"")
		pia_cert=ca.rsa.4096.crt
		pia_cipher=AES-256-CBC
		pia_auth=SHA256
		
		if [ "$pia_tcp" = "yes" ]; then
			pia_port=501
		else
			pia_port=1197
		fi
		;;
	
	N|n|no)
		pia_cert=ca.rsa.2048.crt
		pia_cipher=AES-128-CBC
		pia_auth=SHA1
		
		if [ "$pia_tcp" = "yes" ]; then
			pia_port=502
		else
			pia_port=1198
		fi
		;;
	*)
		error "Strong encryption must be on or off."
esac

# Download and install
curl -sS -o "/etc/openvpn/pia-$pia_cert" \
	"$HTTP_PIA_CERT" \
	|| error "Failed to download OpenVPN CA certificate, aborting."

IFS=$(echo)
servers=$(curl -Ss "HTTP_PIA_INFO$pia_cert" | head -1)

if [ -z "$servers" ]; then
	error "Failed to download server list, aborting."
fi

rm -f "/etc/NetworkManager/system-connections/PIA - "*

servers=$(python2.7 <<EOF
import sys
import json
data = json.loads('$servers')

for k in data.keys():
	if k != "info":
		print data[k]["dns"] + ':' + data[k]["name"]
EOF
)

echo "$servers" | while read server; do
	host=$(echo "$server" | cut -d: -f1)
	name="PIA - "$(echo "$server" | cut -d: -f2)
	nmfile="/etc/NetworkManager/system-connections/$name"
	
cat <<EOF > "$nmfile"
[connection]
id=$name
uuid=$(uuidgen)
type=vpn
autoconnect=false

[vpn]
service-type=org.freedesktop.NetworkManager.openvpn
username=$pia_username
comp-lzo=yes
remote=$host
cipher=$pia_cipher
auth=$pia_auth
connection-type=password
password-flags=0
port=$pia_port
proto-tcp=$pia_tcp
ca=/etc/openvpn/pia-$pia_cert

[vpn-secrets]
password=$pia_password

[ipv4]
method=auto
EOF
	chmod 0600 "$nmfile"
done

nmcli connection reload || \
	error "Failed to reload NetworkManager connections: installation was complete, but may require a restart to be effective."

echo "Installation is complete!"