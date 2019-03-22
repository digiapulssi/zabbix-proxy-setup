# Zabbix Proxy Setup Scripts

Provides Linux scripts for setting up Zabbix proxy and Zabbix Java Gateway docker container. Check out
repository files into directory where you want to have the configuration
(zabbix directory with volume mount directories will be generated under it) and
execute scripts as needed.

Initialization script creates subdirectories for all volume mounts supported by
[zabbix-proxy-sqllite3](https://hub.docker.com/r/zabbix/zabbix-proxy-sqlite3/)
and all those are added to container by `create-proxy.sh` script. The script
also adds odbc subdirectory to /var/lib/zabbix/odbc and ODBC configuration
files to /etc to the container to configure database drivers.

Initialization script defines default container version to start in file
zabbix/container.version as alpine-latest. Setup scripts may modify this to
avoid compatibility issues.

To setup Zabbix proxy:

1. Initialize proxy configuration structure: `./init-config.sh`.
2. Setup proxy configuration by running necessary setup scripts or manually setting up files
3. Create proxy docker container: `./create-proxy.sh`
4. Start proxy docker container: `docker start zabbix-proxy`
5. Start java gateway container: `docker start zabbix-java-gateway`

To modify proxy configuration:

1. Stop and destroy container: `./remove-proxy.sh`
2. Update proxy configuration by running necessary setup scripts or manually setting up files
3. Create and run new proxy docker container: `./create-proxy.sh` and `docker start zabbix-proxy` 
   & `docker start zabbix-java-gateway`

The docker container created is named zabbix-proxy by default. Java Gateway container is
named zabbix-java-gateway.
Different container name for zabbix-proxy can be given to create and remove scripts as argument.

The docker container version is read from zabbix/container.version. This can be
overridden by giving second argument to `create-proxy.sh` script.

## Setup scripts

*NOTE: Running setup scripts while proxy container is running is not guaranteed to be safe.*

### TLS PSK Connection Setup

The setup script generates PSK key in zabbix/ssl/keys/zabbix_proxy.psk and adds
necessary environment variables to env.list used in container startup.

1. Run `sudo ./setup-psk.sh` to setup PSK key and identity for proxy
2. Configure the same PSK key and identity on Zabbix server

### TLS Cert Connection Setup
The setup script for predefined certification files (Ca, Cert and Key).
The script creates and deposites those files:
CA File -> zabbix/ssl/ssl_ca/
Key File -> zabbix/ssl/keys/
Cert File -> zabbix/ssl/certs/

The script also creates and initializes necessary environment variables.

1. Run `sudo ./setup-tls-certificates.sh` to setup certification files

### Zabbix PROXY SQlite Database ODBC Data Source Setup

The setup script configures ODBC data source to use for accessing Zabbix Proxy SQLite database

1. Run `./setup-sqlite-odbc.sh`

The data source will be available as `zabbixproxy` and can be used with database monitor items in Zabbix.

### IBM DB2 ODBC Driver Setup

This setup script unpacks ODBC driver into configuration structure and generates
ODBC driver configuration in zabbix/odbcinst.ini.

Obtain suitable ODBC driver archive for 64-bit Linux from: http://www-01.ibm.com/support/docview.wss?uid=swg21418043

Driver archive should begin with version number (e.g. v10.1fp6_linuxx64_odbc_cli.tar.gz).

Connecting directly to some editions of DB2 requires DB2 Connect license which
can only be obtained from DB2 Connect installation. See the driver download page
for details.

1. Setup driver by running `./setup-db2-odbc.sh <driver-archive>`
2. Configure database connections in driver's cfg folder `zabbix/odbc/db2/<version>/clidriver/cfg`. See example below.
3. Configure ODBC datasources in `zabbix/odbc.ini`
4. (Optional) Copy DB2 Connect license file to `zabbix/odbc/db2/<version>/clidriver/license` folder.

NOTE: Running install multiple times for same driver will generate duplicate
sections in odbcinst.ini. DON'T run setup multiple times for same driver.

NOTE: The driver has dependencies to gcc and will not work on alpine based
image. To fix this setup script sets the container default version to
ubuntu-latest.

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

#### Troubleshooting Connection Issues

Connection to server from container can be tested using isql within container:

```
[zabbix-proxy-setup]$docker exec -ti zabbix-proxy /bin/bash
root@67832464215f:/var/lib/zabbix# isql -v sample db2inst1
+---------------------------------------+
| Connected!                            |
|                                       |
| sql-statement                         |
| help [tablename]                      |
| quit                                  |
|                                       |
+---------------------------------------+
SQL> quit
```

The isql command reports descriptive error if there are connection configuration
issues or connecting to database fails.
