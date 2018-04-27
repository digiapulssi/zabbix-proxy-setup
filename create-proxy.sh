#!/bin/bash

set -e

CONTAINER_VERSION=`cat zabbix/container.version`
CONTAINER_IMAGE=`cat zabbix/container.image`
if [ -z "$CONTAINER_IMAGE" ]; then
  CONTAINER_IMAGE="zabbix/zabbix-proxy-sqlite3"
fi

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
PSK_FILE=zabbix/enc/zabbix_proxy.psk
START_CMD="docker-entrypoint.sh"

if [ "$(docker ps -aq -f name=${NAME})" ]; then
  echo "Container with name '${NAME}' already exists. Stop and remove old container before creating new one."
  exit 1
fi

echo "Creating container [${NAME}] using image [${CONTAINER_IMAGE}:${CONTAINER_VERSION}]."

if [ -e "${PSK_FILE}" ]; then
  COMMAND="chown zabbix:zabbix \"/var/lib/${PSK_FILE}\"; chmod 600 \"/var/lib/${PSK_FILE}\"; ${START_CMD}"
else
  COMMAND="${START_CMD}"
fi

docker create \
  --restart=unless-stopped \
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
  -p 10051:10051 \
  --name ${NAME} \
  --env-file env.list \
  --entrypoint=/bin/bash \
  ${CONTAINER_IMAGE}:${CONTAINER_VERSION} \
  -c "${COMMAND}"
