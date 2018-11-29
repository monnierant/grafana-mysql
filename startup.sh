#!/bin/bash

DIR_NAME=$(pwd)
DIR_SUFFIX=$(dirname $0)
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"


echo $CURRENT_DIR

# include coonfig file
[ -f "$CURRENT_DIR/config.conf" ] && source $CURRENT_DIR/config.conf || echo "ERROR: No config file found at $CURRENT_DIR/config.conf"

# make the required foders
#mkdir -p $CURRENT_DIR/prometheus/config
#mkdir -p $CURRENT_DIR/prometheus/data
#mkdir -p $CURRENT_DIR/grafana/etc
#mkdir -p $CURRENT_DIR/grafana/var_lib

mkdir -p $CURRENT_DIR/prometheus/
mkdir -p $CURRENT_DIR/grafana/

# install docker
sudo apt-get update
sudo apt-get install -y curl
sudo apt-get install -y unzip


sudo curl -fsSL https://get.docker.com/ | sh


echo "------------------------------------"
echo "Stop and Remove docker containers"
echo "------------------------------------"
# Stop and delete all existing containers
# stop containers
sudo docker stop mysql-exporter
sudo docker stop grafana
sudo docker stop prometheus

# remove containers
sudo docker rm mysql-exporter
sudo docker rm grafana
sudo docker rm prometheus


sleep 5

# update all docker images

echo "------------------------------------"
echo "Start Mysqld_Exporter"
echo "------------------------------------"
sudo docker run -d \
    --name="mysql-exporter" \
    --restart="unless-stopped" \
    --memory-swap=$RAM_MAX_SWAP \
    --memory $RAM_MAX_EXPORTER_DB \
    -e DATA_SOURCE_NAME="$DB_USER:$DB_PASSWORD@($DB_HOST:$DB_PORT)/$DB_NAME" \
    prom/mysqld-exporter:latest

echo "------------------------------------"
echo "Start Prometheus"
echo "------------------------------------"
docker run -d \
    --name="prometheus" \
    --restart="unless-stopped" \
    -v $CURRENT_DIR/prometheus/config/prometheus.yml:/etc/prometheus/prometheus.yml \
    -v $CURRENT_DIR/prometheus/data:/prometheus/data \
    --link=mysql-exporter:mysql-exporter \
    --memory-swap=$RAM_MAX_SWAP \
    --memory $RAM_MAX_Prometheus \
    prom/prometheus:latest \
    --config.file=/etc/prometheus/prometheus.yml

echo "------------------------------------"
echo "Start grafana"
echo "------------------------------------"
docker run -d \
    -p $PORT_Grafana:3000 \
    --name="grafana" \
    --restart="unless-stopped" \
    -v $CURRENT_DIR/grafana/etc:/etc/grafana \
    -v $CURRENT_DIR/grafana/var_lib:/var/lib/grafana \
    --link=prometheus:prometheus \
    --memory-swap=$RAM_MAX_SWAP \
    --memory $RAM_MAX_Grafana \
    -e GF_SECURITY_ADMIN_PASSWORD=$GRAFANA_PASSWORD \
    -e "GF_INSTALL_PLUGINS=percona-percona-app" \
    grafana/grafana:latest