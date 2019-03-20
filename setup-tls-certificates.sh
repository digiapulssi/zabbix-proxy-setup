#!/bin/bash

# Usage: opt_replace <key> <value> <file>
# Add or replace option in file. Key and value must not contain pipe character.
function opt_replace {
  grep -q "^$1" "$3" && sed -i "s|^$1.*|$1=$2|" "$3" || echo "$1=$2" >>"$3"
}
# Filenames:
CERT_FILE=zabbix_proxy.pem
KEY_FILE=zabbix_proxy.pem
CA_FILE=zabbix_proxy.ca

# Obtain TLSCert
read -p "Enter TLSCert: " TLS_Cert

# Obtain TLSKey
read -p "Enter TLSKey: " TLS_Key

# Obtain TLSCA
read -p "Enter TLSCA: " TLS_CA

# Check for existing files and replacing with new one if wanted
# Check CA_FILE and replace with new one if ch
if [ -e "zabbix/ssl/ssl_ca/${CA_FILE}" ]; then
  read -p "Old CA_FILE exists - overwrite [y/N]?" -n 1 -r
  echo
  if [[ "$REPLY" =~ ^[yY]$ ]]; then
    rm "zabbix/ssl/ssl_ca/${CA_FILE}"
    # Create CA file
    echo "${TLS_CA}" >"zabbix/ssl/ssl_ca/${CA_FILE}"
  else
    echo "Using old CA_FILE."
  fi
else
  # Create CA file
  echo "${TLS_CA}" >"zabbix/ssl/ssl_ca/${CA_FILE}"
  # Setup environment options
  opt_replace ZBX_TLSCAFILE "${TLS_CA}" env.list
fi

# Check KEY_FILE
if [ -e "zabbix/ssl/keys/${KEY_FILE}" ]; then
  read -p "Old KEY_FILE exists - overwrite [y/N]?" -n 1 -r
  echo
  if [[ "$REPLY" =~ ^[yY]$ ]]; then
    rm "zabbix/ssl/keys/${KEY_FILE}"
    # Create Key file
    echo "${TLS_Key}" >"zabbix/ssl/keys/${KEY_FILE}"
  else
    echo "Using old KEY_FILE."
  fi
else
  # Create Key file
  echo "${TLS_Key}" >"zabbix/ssl/keys/${KEY_FILE}"
  # Setup environment options
  opt_replace ZBX_TLSKEYFILE "${TLS_Key}" env.list
fi

# Check CERT_FILE
if [ -e "zabbix/ssl/certs/${CERT_FILE}" ]; then
  read -p "Old CERT_FILE exists - overwrite [y/N]?" -n 1 -r
  echo
  if [[ "$REPLY" =~ ^[yY]$ ]]; then
    rm "zabbix/ssl/certs/${CERT_FILE}"
    # Create Cert file
    echo "${TLS_Cert}" >"zabbix/ssl/certs/${CERT_FILE}"
  else
    echo "Using old CERT_FILE."
  fi
else
  # Create Cert file
  echo "${TLS_Cert}" >"zabbix/ssl/certs/${CERT_FILE}"
  # Setup environment option
  opt_replace ZBX_TLSCERTFILE "${TLS_Cert}" env.list
fi


# Setup other environment TLS options
opt_replace ZBX_TLSCONNECT cert env.list
