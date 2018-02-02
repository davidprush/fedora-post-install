#!/bin/bash
#####################################################################
# Install OpenVPN profiles in NetworkManager for PIA
# Script originally created by Private Internet Access (PIA)
# Original script downloaded from:
# 		https://www.privateinternetaccess.com/installer/pia-nm.sh
# I removed all code for other Linux distros, because this is 
# exclusively for Fedora to run in tandem with fedora-post-install.sh.
# This script gets called as a function within fedora-post-install.sh.
# To invoke this script via fedora-post-install.sh use:
#		sudo bash fedora-post-install.sh pia-nm
# This script is modified to include the function script LIBRARY.sh
# DEPENDENCY: fedora-post-install/scripts/LIBRARY.sh
# POST_CONDITION: Returns to calling script fedora-post-install.sh
#####################################################################

# Created some VAR to make easy changes in the future
# NetworkManager system connections directory
NM_SYS_CON="/etc/NetworkManager/system-connections/"

# PIA certificate address 
HTTP_PIA_CERT="https://www.privateinternetaccess.com/openvpn/"

# PIA VPN information
HTTP_PIA_INFO="https://www.privateinternetaccess.com/vpninfo/servers?version=24"

# Load LIBRARY.sh for general functions
. "$SCRIPT_DIR/LIBRARY.sh"

# Test if running as root
LIB_TEST_ROOT

# Verify python is installed
if [ $(LIB_TEST_APP "python") ]; then 
	LIB_INSTALL_APP "python"
fi

# Verify NetworkManager-openvpn is installed
if [ $(LIB_TEST_APP "NetworkManager-openvpn") ]; then
	LIB_INSTALL_APP "NetworkManager-openvpn"
fi

# Prompt input user account information and settings
LIB_ECHO YELLOW "$(LIB_BANNER_BEGIN ' PIA ACCOUNT INFORMATION AND OPTIONS ')"

# Get username
echo -n "PIA username (pNNNNNNN): "
read pia_username

# Prompt user for PIA username
if [ -z "$pia_username" ]; then
	LIB_ERROR "Username is required, aborting."
fi

# Get password and live dangerously
echo -n "PIA password ($pia_username): "
read pia_password

# Prompt user for PIA password
if [ -z "$pia_password" ]; then
	LIB_ERROR "Password is required, aborting."
fi

# Prompt for protocol
echo -n "Connection method (UDP/tcp): "
read pia_tcp

# Set protocol
case "$pia_tcp" in
	U|u|UDP|udp|"")
		pia_tcp=no
		;;
	T|t|TCP|tcp)
		pia_tcp=yes
		;;
	*)
		LIB_ERROR "Connection protocol must be UDP or TCP."
esac

# Prompt for encryption level
echo -n "Strong encryption (Y/n): "
read pia_strong

# Set encryption level
# No input defaults to YES
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
		LIB_ERROR "Strong encryption must be on or off."
esac

# Download and install PIA cert
curl -sS -o "/etc/openvpn/pia-$pia_cert" \
	"${HTTP_PIA_CERT}$pia_cert" \
	|| LIB_ERROR "Failed to download OpenVPN CA certificate, aborting."

IFS=$(echo)
servers=$(curl -Ss "$HTTP_PIA_INFO" | head -1)

if [ -z "$servers" ]; then
	LIB_ERROR "Failed to download server list, aborting."
fi

rm -f "${NM_SYST_CON}PIA - "*

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
	nmfile="${NM_SYST_CON}$name"
	
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
	LIB_ERROR "NetworkManager connections: $(LIB_FAIL) \
				\n Installation Status: $(LIB_OK) \
				\n Computer requires restart."
LIB_FINISHED