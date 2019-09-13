#!/bin/bash
# Installs ODBC CLI driver into directory and generates ODBC configuration
# section for the driver to use with zabbix docker container.

set -e

if [[ "$#" -lt 1 || "$1" == "-help" ]]; then
  echo "Usage: $(basename $0) <driver-archive>"
  echo
  exit 0
fi

DRIVER=$1
ODBC_DIR=zabbix/odbc

if ! [ -e "$DRIVER" ]; then
  echo "Driver file '$DRIVER' does not exist."
  exit 1
fi

DRIVER_DIR=${ODBC_DIR}/db2
DRIVER_FILE=`basename $DRIVER`
VERSION=`expr match "$DRIVER_FILE" '\(v[0-9]*\.[0-9]*\)'`
ODBCINST_INI=zabbix/odbcinst.ini
ODBC_INI=zabbix/odbc.ini

if [ ! -d "${ODBC_DIR}/db2" ]; then
  mkdir -p "${ODBC_DIR}/db2"
fi

# Extracted directory structure may be different on older versions
tar xzf "${DRIVER}" -C "${DRIVER_DIR}"
mv -T "${DRIVER_DIR}/odbc_cli" "${DRIVER_DIR}/${VERSION}"

# Ensure required directories exist
if [ ! -d "${DRIVER_DIR}/${VERSION}/clidriver/db2" ]; then
  mkdir "${DRIVER_DIR}/${VERSION}/clidriver/db2"
fi
if [ ! -d "${DRIVER_DIR}/${VERSION}/clidriver/db2dump" ]; then
  mkdir "${DRIVER_DIR}/${VERSION}/clidriver/db2dump"
fi

# Generate driver configuration
echo "[db2_${VERSION//.}]" >>${ODBCINST_INI}
echo "Description=DB2 Database Driver ${VERSION}" >>${ODBCINST_INI}
echo "Driver=/var/lib/zabbix/odbc/db2/${VERSION}/clidriver/lib/libdb2.so" >>${ODBCINST_INI}
# These were recommended by http://www.unixodbc.org/doc/db2.html
echo "FileUsage=1" >>${ODBCINST_INI}
echo "DontDLClose=1" >>${ODBCINST_INI}
echo >>${ODBCINST_INI}

touch ${ODBC_INI}

# Driver will not run on alpine based image because it has dependencies to gcc
echo "ubuntu-4.0-latest" >zabbix/container.version

echo
echo "Driver install complete. Driver name for odbc.ini is 'db2_${VERSION//.}'."
echo "To finish setup configure database connection in files: "
echo " - ${ODBC_DIR}/${VERSION}/clidriver/cfg/db2dsdriver.cfg"
echo " - ${ODBC_DIR}/${VERSION}/clidriver/cfg/db2cli.ini"
echo " - ${ODBC_INI}"
