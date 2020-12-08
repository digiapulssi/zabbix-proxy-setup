#!/bin/bash

# Usage: opt_replace <key> <value> <file>
# Add or replace option in file. Key and value must not contain pipe character.
function opt_replace {
  grep -q "^$1" "$3" && sed -i "s|^$1.*|$1=$2|" "$3" || echo "$1=$2" >>"$3"
}

PSK_IDENTITY=PSK_001
PSK_FILE=zabbix_proxy.psk

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
if [ -e "zabbix/enc/${PSK_FILE}" ]; then
  read -p "Old PSK key file exists - remove [y/N]?" -n 1 -r
  echo
  if [[ "$REPLY" =~ ^[yY]$ ]]; then
    rm "zabbix/enc/${PSK_FILE}"
  else
    echo "PSK setup terminated."
    exit 0
  fi
fi

# Create PSK file
echo "${PSK_KEY}" >"zabbix/enc/${PSK_FILE}"

# Given the right rights
chown 1997:1995  "zabbix/enc/${PSK_FILE}"
chmod 0600  "zabbix/enc/${PSK_FILE}"

# Setup environment options
opt_replace ZBX_TLSCONNECT psk env.list
opt_replace ZBX_TLSACCEPT psk env.list
opt_replace ZBX_TLSPSKIDENTITY "${PSK_IDENTITY}" env.list
opt_replace ZBX_TLSPSKFILE "${PSK_FILE}" env.list
