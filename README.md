# Zabbix Proxy Setup Scripts

Provides Linux scripts for setting up Zabbix proxy docker container. Check out
repository files into directory where you want to have the configuration
(zabbix directory with volume mount directories will be generated under it) and
execute scripts as needed.

Initialization script creates subdirectories for all volume mounts supported by
[zabbix-proxy-sqllite3](https://hub.docker.com/r/zabbix/zabbix-proxy-sqlite3/)
and all those are added to container by the proxy start script. Start script
also adds odbc subdirectory to /var/lib/zabbix/odbc and ODBC configuration
files to /etc to the container to configure database drivers.

To setup Zabbix proxy:

1. Initialize proxy configuration structure: `./init-config.sh`.
2. Setup proxy configuration by running necessary setup scripts or manually setting up files
3. Create and run proxy docker container: `./start-proxy.sh`

To modify proxy configuration:

1. Stop and destroy container: `./stop-proxy.sh`
2. Update proxy configuration by running necessary setup scripts or manually setting up files
3. Create and run new proxy docker container: `./start-proxy.sh`

The docker container created is named zabbix-proxy by default. Different container
name can be given as argument to start and stop scripts as argument.

The docker container version used is alpine-latest. This can be overridden by
giving second argument to start script.

## Setup scripts

*NOTE: Running setup scripts while proxy container is running is not guaranteed to be safe.*

### IBM DB2 ODBC Driver Setup

This setup script unpacks ODBC driver into configuration structure and generates
ODBC driver configuration in zabbix/odbcinst.ini.

Obtain suitable ODBC driver package for 64-bit Linux from: http://www-01.ibm.com/support/docview.wss?uid=swg21418043

Driver package should begin with version number (e.g. v10.1fp6_linuxx64_odbc_cli.tar.gz).

1. Setup driver by running `./setup-db2-odbc.sh <driver-archive>`
2. Configure database connections in driver's cfg folder `zabbix/odbc/db2/<version>/clidriver/cfg`. See example below.
3. Configure ODBC datasources in `zabbix/odbc.ini`
4. Copy DB2 Connect license file to `zabbix/odbc/db2/<version>/clidriver/license` folder

NOTE: Running install multiple times for same driver will generate duplicate
sections in odbcinst.ini. DON'T run setup multiple times for same driver.

#### DB2 ODBC Configuration Example

The ODBC driver configuration for DB2 can be done in multiple different ways. Here
is simple example for connecting to database using ODBC datasource named "sample".
Default schema with this configuration is user's own schema (i.e. db2inst1).

*cfg/db2dsdriver.cfg:*

```
<configuration>
   <dsncollection>
      <dsn alias="sample" name="sample" host="10.0.10.10" port="50000"/>
   </dsncollection>
</configuration>
```

*cfg/db2cli.ini:*

```
[sample]
uid=db2inst1
pwd=db2inst1-pwd
```

*odbc.ini:*

```
[sample]
Driver=db2_v101
```

### TLS PSK Connection Setup

The setup script generates PSK key in zabbix/ssl/keys/zabbix_proxy.psk and adds
necessary environment variables to env.list used in container startup. Script
must run as root since created PSK key file must have special permissions setup.

1. Run `sudo ./setup-psk.sh` to setup PSK key and identity for proxy
2. Configure same PSK key and identity on Zabbix server
