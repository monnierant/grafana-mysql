# Grafana for mysql in Docker
The purpose of this script is to capture the data of one of your database to showcase it.

The database can be located anywhere.
## How to use it
Clone the repository
Edit the config file

    config.conf

Then run

    sudo ./startup.sh

## How to customize it
The config.conf file contain almoste all of the configuration avaliable for the script.

### Prometheus

Prometheus got a configuration file located into

    prometheus/config/prometheus.yml

It's already setup to use the mysqld_exporter but you can customise it to include any other source.

More information can be found at:
https://hub.docker.com/r/prom/prometheus/

### DB

You must setup the information of your DB in this section.

    DB_HOST=HostOrIp
    DB_PORT=3306
    DB_NAME=hawkeye
    DB_USER=user
    DB_PASSWORD=password

For more information you can check:
https://hub.docker.com/r/prom/mysqld-exporter/
Especially for rights of the users to connect to the database.

### Grafana

Grafana need to get a password setup for the first startup.
The port will be used to publish grafana access on the server so you can then connect to grafana by going to http://localhost:3000.


    PORT_Grafana=3000
    GRAFANA_PASSWORD=password

Grafana got a configuration file under

    grafana/etc/grafana.ini
More information about grafana can be found at:
https://hub.docker.com/r/grafana/grafana/

### RAM
You can controll the ammoun of ram of every docker container

    #-------------------------------------------
    # Swap
    #-------------------------------------------
    RAM_MAX_SWAP=300m
    #-------------------------------------------
    # MysqlD Exporter
    #-------------------------------------------
    RAM_MAX_EXPORTER_DB=50m
    #-------------------------------------------
    # Site Controll
    #-------------------------------------------
    RAM_MAX_Controll_Prometheus=150m
    RAM_MAX_Controll_Grafana=100m

## Data storage

Datas are stored into 4 folders next to the script

    mkdir -p $CURRENT_DIR/prometheus/config
    mkdir -p $CURRENT_DIR/prometheus/data
    mkdir -p $CURRENT_DIR/grafana/etc
    mkdir -p $CURRENT_DIR/grafana/var_lib

## How it works

This script will install docker and startup 3 containers.

 1. MysqlD-Exporter that will extract the data's from the Mysql server at a specific time
 2. Prometheus that will collect datas from the MysqlD-Exporter and retain those datas
 3. Grafana that will showcase datas from Prometheus into dashboards

