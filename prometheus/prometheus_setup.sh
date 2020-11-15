#!/bin/bash
set -e
apt update
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo docker pull prom/prometheus
sudo docker run -d -p 9090:9090 -v /srv/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus