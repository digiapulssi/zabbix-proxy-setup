#!/bin/bash

function safe_mkdir {
    if [ ! -d "$1" ]; then
      mkdir "$1"
    fi
}

HOSTNAME=`hostname`

read -p "Use hostname '${HOSTNAME}' for proxy hostname (Y/n)?" -n 1 -r
echo
if [[ ${REPLY} =~ ^[nN]$ ]]; then
  read -p "Enter proxy hostname: " HOSTNAME
fi

read -p "Enter Zabbix server hostname: " SERVER_HOST

safe_mkdir zabbix
safe_mkdir zabbix/enc
safe_mkdir zabbix/externalscripts
safe_mkdir zabbix/mibs
safe_mkdir zabbix/modules
safe_mkdir zabbix/odbc
safe_mkdir zabbix/snmptraps
safe_mkdir zabbix/ssh_keys
safe_mkdir zabbix/ssl
safe_mkdir zabbix/ssl/certs
safe_mkdir zabbix/ssl/keys
safe_mkdir zabbix/ssl/ssl_ca

touch zabbix/odbcinst.ini
touch zabbix/odbc.ini

echo "ZBX_HOSTNAME=${HOSTNAME}" >env.list
echo "ZBX_SERVER_HOST=${SERVER_HOST}" >>env.list
echo "ZBX_CONFIGFREQUENCY=300" >>env.list
