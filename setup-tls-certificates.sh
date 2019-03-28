#!/bin/bash
set -e
# Usage: opt_replace <key> <value> <file>
# Add or replace option in file. Key and value must not contain pipe character.
function opt_replace {
  grep -q "^$1" "$3" && sed -i "s|^$1.*|$1=$2|" "$3" || echo "$1=$2" >>"$3"
}
# Filenames:
CERT_FILE=zabbix_proxy.pem
KEY_FILE=zabbix_proxy.pem
CA_FILE=zabbix_proxy.ca

# Check CERT_FILE and replace with new one if chosen
if [ -e "zabbix/ssl/certs/${CERT_FILE}" ]; then
  read -p "Old CERT_FILE exists - overwrite [y/N]?" -n 1 -r
  echo
  if [[ "$REPLY" =~ ^[yY]$ ]]; then
    rm "zabbix/ssl/certs/${CERT_FILE}"
    # Obtain TLSCert
    echo "Enter TLSCert (Ctrl+D to end input): "
    TLS_Cert=$(</dev/stdin)
    # Create Cert file and add Cert to enviromental variables
    echo "${TLS_Cert}" >"zabbix/ssl/certs/${CERT_FILE}"
    opt_replace ZBX_TLSCERTFILE "/var/lib/zabbix/ssl/certs/${CERT_FILE}" env.list
  else
    echo "Using old CERT_FILE."
  fi
else
  # Obtain TLSCert
  echo "Enter TLSCert (Ctrl+D to end input): "
  TLS_Cert=$(</dev/stdin)
  # Create Cert file
  echo "${TLS_Cert}" >"zabbix/ssl/certs/${CERT_FILE}"
  # Setup environment option
  opt_replace ZBX_TLSCERTFILE "/var/lib/zabbix/ssl/certs/${CERT_FILE}" env.list
fi

# Check KEY_FILE and replace with new one if chosen
if [ -e "zabbix/ssl/keys/${KEY_FILE}" ]; then
  read -p "Old KEY_FILE exists - overwrite [y/N]?" -n 1 -r
  echo
  if [[ "$REPLY" =~ ^[yY]$ ]]; then
    rm "zabbix/ssl/keys/${KEY_FILE}"
    # Obtain TLSKey
    echo "Enter TLSKey (Ctrl+D to end input): "
    TLS_Key=$(</dev/stdin)
    # Create Key file and add Key to enviromental variables
    echo "${TLS_Key}" >"zabbix/ssl/keys/${KEY_FILE}"
    opt_replace ZBX_TLSKEYFILE "/var/lib/zabbix/ssl/keys/${KEY_FILE}" env.list
  else
    echo "Using old KEY_FILE."
  fi
else
  # Obtain TLSKey
  echo "Enter TLSKey (Ctrl+D to end input): "
  TLS_Key=$(</dev/stdin)
  # Create Key file
  echo "${TLS_Key}" >"zabbix/ssl/keys/${KEY_FILE}"
  # Setup environment options
  opt_replace ZBX_TLSKEYFILE "/var/lib/zabbix/ssl/keys/${KEY_FILE}" env.list
fi

# Check for existing files and replacing with new one if chosen so
# Check CA_FILE and replace with new one if chosen
if [ -e "zabbix/ssl/ssl_ca/${CA_FILE}" ]; then
  read -p "Old CA_FILE exists - overwrite [y/N]?" -n 1 -r
  echo
  if [[ "$REPLY" =~ ^[yY]$ ]]; then
    rm "zabbix/ssl/ssl_ca/${CA_FILE}"
    # Obtain TLSCA
    echo "Enter TLSCA (Ctrl+D to end input): "
    TLS_CA=$(</dev/stdin)
    # Create CA file and add CA to enviromental variables
    echo "${TLS_CA}" >"zabbix/ssl/ssl_ca/${CA_FILE}"
    opt_replace ZBX_TLSCAFILE "/var/lib/zabbix/ssl/ssl_ca/${CA_FILE}" env.list
  else
    echo "Using old CA_FILE."
  fi
else
  # Obtain TLSCA
  echo "Enter TLSCA (Ctrl+D to end input): "
  TLS_CA=$(</dev/stdin)
  # Create CA file
  echo "${TLS_CA}" >"zabbix/ssl/ssl_ca/${CA_FILE}"
  # Setup environment options
  opt_replace ZBX_TLSCAFILE "/var/lib/zabbix/ssl/ssl_ca/${CA_FILE}" env.list
fi


# Setup other environment TLS options
opt_replace ZBX_TLSCONNECT cert env.list
