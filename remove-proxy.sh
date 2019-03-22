#!/bin/bash

set -e

if [ "$1" == "-help" ]; then
  echo "Usage $(basename $0) [ <container-name> ]"
  echo
  echo "Default container name is 'zabbix-proxy'."
  echo
  exit 0
fi

NAME=${1:-zabbix-proxy}
NAME_2="zabbix-java-gateway"

# Stop and remove zabbix_proxy docker
if [ "$(docker ps -q -f name=${NAME})" ]; then
  docker stop ${NAME}
fi

if  [ "$(docker ps -aq -f name=${NAME})" ]; then
  docker rm ${NAME}
else
  echo "Container '${NAME}' not found - nothing to do."
fi

# Stop and remove java_gateway docker
if [ "$(docker ps -q -f name=${NAME2})" ]; then
  docker stop ${NAME2}
fi

if  [ "$(docker ps -aq -f name=${NAME2})" ]; then
  docker rm ${NAME2}
else
  echo "Container '${NAME2}' not found - nothing to do."
fi
