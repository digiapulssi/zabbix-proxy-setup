#!/bin/bash

set -e

CONTAINER_VERSION=`cat zabbix/container.version`

if [ "$1" == "-help" ]; then
  echo "Usage: $(basename $0) [ <container-name> [ <container-version> ] ]"
  echo
  echo "Default for container name is 'zabbix-proxy' and version is '${CONTAINER_VERSION}'"
  echo
  exit 0
fi

DIR=`realpath $(dirname $0)`
NAME=${1:-zabbix-proxy}
CONTAINER_VERSION=${2:-${CONTAINER_VERSION}}

if [ "$(docker ps -aq -f name=${NAME})" ]; then
  echo "Container with name '${NAME}' already exists. Stop and remove old container before creating new one."
  exit 1
fi

echo "Starting container [${NAME}] using image version [${CONTAINER_VERSION}]."

docker run \
  -v ${DIR}/zabbix/odbcinst.ini:/etc/odbcinst.ini \
  -v ${DIR}/zabbix/odbc.ini:/etc/odbc.ini \
  -v ${DIR}/zabbix/odbc:/var/lib/zabbix/odbc \
  -v ${DIR}/zabbix/enc:/var/lib/zabbix/enc \
  -v ${DIR}/zabbix/externalscripts:/usr/lib/zabbix/externalscripts \
  -v ${DIR}/zabbix/mibs:/var/lib/zabbix/mibs \
  -v ${DIR}/zabbix/modules:/var/lib/zabbix/modules \
  -v ${DIR}/zabbix/snmptraps:/var/lib/zabbix/snmptraps \
  -v ${DIR}/zabbix/ssh_keys:/var/lib/zabbix/ssh_keys \
  -v ${DIR}/zabbix/ssl/certs:/var/lib/zabbix/ssl/certs \
  -v ${DIR}/zabbix/ssl/keys:/var/lib/zabbix/ssl/keys \
  -v ${DIR}/zabbix/ssl/ssl_ca:/var/lib/zabbix/ssl/ssl_ca \
  --name ${NAME} \
  --restart=always \
  -d zabbix/zabbix-proxy-sqlite3:${CONTAINER_VERSION}
