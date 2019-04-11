#!/bin/bash

set -e

export CONTAINER_VERSION=`cat zabbix/container.version`
export CONTAINER_IMAGE=`cat zabbix/container.image`
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
CERT_FILE=zabbix/enc/zabbix_proxy_cert.pem
KEY_FILE=zabbix/enc/zabbix_proxy_key.pem
CA_FILE=zabbix/enc/zabbix_proxy.ca

read -p "Use default user 1000 for UID (Y/n)?" -n 1 -r
echo
if [[ ${REPLY} =~ ^[nN]$ ]]; then
  read -p 'Enter UID: ' user
else
  user=1000
fi

if [ "$(docker ps -aq -f name=${NAME})" ]; then
  echo "Container with name '${NAME}' already exists. Stop and remove old container before creating new one."
  exit 1
elif [ "$(docker ps -aq -f name="zabbix-java-gateway")" ]; then
  echo "Container with name 'zabbix-java-gateway' already exists. Stop and remove old container before creating new one."
  exit 1
fi

echo "Creating container [${NAME}] using image [${CONTAINER_IMAGE}:${CONTAINER_VERSION}]."

export uid="${user}"
docker-compose up --no-start
