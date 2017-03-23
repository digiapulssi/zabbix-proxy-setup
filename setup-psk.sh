#!/bin/bash

# Usage: opt_replace <key> <value> <file>
# Add or replace option in file. Key and value must not contain pipe character.
function opt_replace {
  grep -q "^$1" "$3" && sed -i "s|^$1.*|$1=$2|" "$3" || echo "$1=$2" >>"$3"
}

if [ "$USER" != "root" ]; then
  echo "This script must be run as root because it has to manage permissions of the PSK key file."
  exit 1
fi

PSK_IDENTITY=PSK_001
PSK_FILE=zabbix/ssl/keys/zabbix_proxy.psk
ZABBIX_UID=100

# Obtain PSK identity
read -p "Enter PSK identity [${PSK_IDENTITY}]: " input
PSK_IDENTITY=${input:-$PSK_IDENTITY}

# Obtain PSK key
read -p "Enter pre-generated PSK key - leave empty to generate one now: " PSK_KEY
if [ "${PSK_KEY}" == "" ]; then
  PSK_KEY=`openssl rand -hex 32`

  echo "Generated PSK: ${PSK_KEY}"
  echo
fi

# Check for PSK file
if [ -e "${PSK_FILE}" ]; then
  read -p "Old PSK key file exists - remove [y/N]?" -n 1 -r
  echo
  if [[ "$REPLY" =~ ^[yY]$ ]]; then
    rm "${PSK_FILE}"
  else
    echo "PSK setup terminated."
    exit 0
  fi
fi

# Create PSK file
echo "${PSK_KEY}" >"${PSK_FILE}"
chown ${ZABBIX_UID} "${PSK_FILE}" && chmod 600 "${PSK_FILE}"

# Setup environment options
opt_replace ZBX_TLSCONNECT psk env.list
opt_replace ZBX_TLSPSKIDENTITY "${PSK_IDENTITY}" env.list
opt_replace ZBX_TLSPSKFILE "/var/lib/zabbix/ssl/keys/zabbix_proxy.psk" env.list
