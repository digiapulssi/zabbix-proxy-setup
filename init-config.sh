#!/bin/bash

function safe_mkdir {
    if [ ! -d "$1" ]; then
      mkdir "$1"
    fi
}

echo "# NOTE: If you modify this file manually, make the corresponding changes to init-config.sh both locally and at https://github.com/digiapulssi/zabbix-proxy-setup/edit/master/init-config.sh" > env.list

HOSTNAME=`hostname`

read -p "Use hostname '${HOSTNAME}' for proxy hostname (Y/n)?" -n 1 -r
echo
if [[ ${REPLY} =~ ^[nN]$ ]]; then
  read -p "Enter proxy hostname: " HOSTNAME
fi

read -p "Active proxy (Y/n)?" -n 1 -r
echo
if [[ ${REPLY} =~ ^[nN]$ ]]; then
  # Passive proxy
  echo "Configuring passive proxy"
  PASSIVE_PROXY="1"
else
  read -p "Enter Zabbix server hostname: " SERVER_HOST
  read -p "Enter Zabbix server port: " SERVER_PORT
fi

read -p "Enable SNMP traps (Y/n)?" -n 1 -r
echo
if [[ ${REPLY} =~ ^[yY]$ ]]; then
  echo "ZBX_ENABLE_SNMP_TRAPS=true" >>env.list
fi

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

echo "ubuntu-5.0.6" >zabbix/container.version

echo "ZBX_HOSTNAME=${HOSTNAME}" >env.list
if [ -z "$PASSIVE_PROXY" ]; then
  echo "ZBX_SERVER_HOST=${SERVER_HOST}" >>env.list
  echo "ZBX_SERVER_PORT=${SERVER_PORT}" >>env.list
else
  echo "ZBX_PROXYMODE=1" >>env.list
fi
echo "ZBX_CONFIGFREQUENCY=300" >>env.list
echo "ZBX_CACHESIZE=1000M" >>env.list
echo "ZBX_STARTHTTPPOLLERS=20" >>env.list
echo "ZBX_TIMEOUT=30" >>env.list
echo "ZBX_ENABLE_SNMP_TRAPS=true" >>env.list
echo "ZBX_JAVAGATEWAY_ENABLE=true" >>env.list
echo "ZBX_JAVAGATEWAY=zabbix-java-gateway" >>env.list
echo "ZBX_JAVAGATEWAYPORT=10052" >>env.list
echo "ZBX_STARTJAVAPOLLERS=20" >>env.list
echo "ZBX_STARTPOLLERSUNREACHABLE=20" >>env.list
echo "ZBX_STARTPOLLERS=50" >>env.list
echo "ZBX_STARTTRAPPERS=50" >> env.list
echo "ZBX_HISTORYINDEXCACHESIZE=20M" >>env.list
echo "ZBX_HISTORYCACHESIZE=40M" >>env.list
echo "ZBX_STARTDISCOVERERS=3" >> env.list
echo "ZBX_STARTDBSYNCERS=6" >> env.list
