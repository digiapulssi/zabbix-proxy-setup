#!/bin/bash
# Setup Zabbix Proxy SQLite database ODBC data source

set -e

echo '[SQLite]
Description = ODBC for SQLite
Driver      = /usr/local/lib/libsqlite3odbc.so' >> zabbix/odbcinst.ini

echo '[zabbixproxy]
Description=Zabbix Proxy SQLite database
Driver=SQLite
Database=/var/lib/zabbix/zabbix_proxy_db' >> zabbix/odbc.ini

# Usage digiapulssi version of the image because it contains pre-built SQLite driver
echo 'digiapulssi/zabbix-proxy-sqlite3' > zabbix/container.image
echo "alpine-3.4-latest" > zabbix/container.version
