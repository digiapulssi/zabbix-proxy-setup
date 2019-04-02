#!/bin/bash
set -e
# Usage: opt_replace <key> <value> <file>
# Add or replace option in file. Key and value must not contain pipe character.
function opt_replace {
  grep -q "^$1" "$3" && sed -i "s|^$1.*|$1=$2|" "$3" || echo "$1=$2" >>"$3"
}
# Filenames:
CERT_FILE=zabbix_proxy_cert.pem
KEY_FILE=zabbix_proxy_key.pem
CA_FILE=zabbix_proxy.ca

# Check CERT_FILE and replace with new one if chosen
if [ -e "zabbix/enc/${CERT_FILE}" ]; then
  read -p "Old client certificate exists - overwrite [y/N]?" -n 1 -r
  echo
  if [[ "$REPLY" =~ ^[yY]$ ]]; then
    rm "zabbix/enc/${CERT_FILE}"
    # Obtain client certificate
    echo "Enter client certificate (Ctrl+D to end input): "
    TLS_Cert=$(</dev/stdin)
    # Create Cert file and add Cert to enviromental variables
    echo "${TLS_Cert}" >"zabbix/enc/${CERT_FILE}"
    opt_replace ZBX_TLSCERTFILE "${CERT_FILE}" env.list
  else
    echo "Using old client certificate."
  fi
else
  # Obtain client certificate
  echo "Enter client certificate (Ctrl+D to end input): "
  TLS_Cert=$(</dev/stdin)
  # Create Cert file
  echo "${TLS_Cert}" >"zabbix/enc/${CERT_FILE}"
  # Setup environment option
  opt_replace ZBX_TLSCERTFILE "${CERT_FILE}" env.list
fi

# Check KEY_FILE and replace with new one if chosen
if [ -e "zabbix/enc/${KEY_FILE}" ]; then
  read -p "Old client private key exists - overwrite [y/N]?" -n 1 -r
  echo
  if [[ "$REPLY" =~ ^[yY]$ ]]; then
    rm "zabbix/enc/${KEY_FILE}"
    # Obtain client private key
    echo "Enter client private key (Ctrl+D to end input): "
    TLS_Key=$(</dev/stdin)
    # Create Key file and add Key to enviromental variables
    echo "${TLS_Key}" >"zabbix/enc/${KEY_FILE}"
    opt_replace ZBX_TLSKEYFILE "${KEY_FILE}" env.list
  else
    echo "Using old client private key."
  fi
else
  # Obtain client private key
  echo "Enter client private key (Ctrl+D to end input): "
  TLS_Key=$(</dev/stdin)
  # Create Key file
  echo "${TLS_Key}" >"zabbix/enc/${KEY_FILE}"
  # Setup environment options
  opt_replace ZBX_TLSKEYFILE "${KEY_FILE}" env.list
fi

# Check for existing files and replacing with new one if chosen so
# Check CA_FILE and replace with new one if chosen
if [ -e "zabbix/enc/${CA_FILE}" ]; then
  read -p "Old server CA certificate exists - overwrite [y/N]?" -n 1 -r
  echo
  if [[ "$REPLY" =~ ^[yY]$ ]]; then
    rm "zabbix/enc/${CA_FILE}"
    # Obtain server CA certificate
    echo "Enter server CA certificate (Ctrl+D to end input): "
    TLS_CA=$(</dev/stdin)
    # Create CA file and add CA to enviromental variables
    echo "${TLS_CA}" >"zabbix/enc/${CA_FILE}"
    opt_replace ZBX_TLSCAFILE "${CA_FILE}" env.list
  else
    echo "Using old server CA certificate."
  fi
else
  # Obtain server CA certificate
  echo "Enter server CA certificate (Ctrl+D to end input): "
  TLS_CA=$(</dev/stdin)
  # Create CA file
  echo "${TLS_CA}" >"zabbix/enc/${CA_FILE}"
  # Setup environment options
  opt_replace ZBX_TLSCAFILE "${CA_FILE}" env.list
fi


# Setup other environment TLS options
opt_replace ZBX_TLSCONNECT cert env.list
