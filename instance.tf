data "exoscale_compute_template" "ubuntu" {
  zone = "at-vie-1"
  name = "Linux Ubuntu 20.04 LTS 64-bit"
}

# resource "exoscale_ssh_keypair" "ssh-key" {
#   name = "ssh-key"
#   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCxEi31wQgag0GHKiVeuHqXTYivfb2ei8KSvZ3n1kmEoCQ2yayVrw6vt0J/cNDuGtqmy9p4nRyv0fAf0y0VvTXzsEpLXJb31abJFc8DL+Prudx/sCBmpFjaV0pgJAg075DDmMze8zfT2iFBmMbCQgFyEk+3lMhKDQ999v+79YRxXabVaQwYc7atTA5HMaSK5IsNodcNqT+WC16GEkDueOhh9SMH3S5oDdWz0x+s/6r1vjseb/m0/WWD2B2GiQPYxVVS7L02k9rAQ6Sy3QpzmwXd5QO2C/Tp5Kl/4lXH+DEbM4QqmIS1xAHUPd1FsgDr71zkRZ+kCrR6ysFpI/olti0j3Gr1YNEA972P8KcpBJXMEmI6h+dODI7Nz6JeCs5kImj0U//T3TeqVR8L29tcEw2dEAE3UHuzyIiqLU9GCbNrbKNO/mRmaoEuVoMDHl1fEfwy08DR5PkcPrpIpe7pcySmWTUhElmD9XxKF6HK1RP08laOTQZTR1P0moqXDEN+cIKv+bOzSK2k22jzuFrtdWUXPAvkysc2q3JWbIvIqdB8XrY4+Emrf/bxJKTLdSbkKpiwVZdJfuT/igCB5JoxruWyvy28Vvc82bZMjcxl8UhEyXlhiOp8H0U1l+7Bqw0J0Q+PvuL6X+40xSgQ3GLNUWAJg6KS5OdO+LoTlqHOnJbb+w== cloud-computing-exoscale-sshkey"
# }

resource "exoscale_instance_pool" "myinstancepool" {
  zone = "at-vie-1"
  name = "instancepool-webapp"
  template_id = data.exoscale_compute_template.ubuntu.id
  size         = 1
  disk_size    = 10
  service_offering = "micro"
  description = "This is my first instance pool"
  security_group_ids = [exoscale_security_group.sg.id]
  #key_pair = "ssh-key"
  user_data = <<EOF
#!/bin/bash
set -e
apt update
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo docker pull janoszen/http-load-generator:latest
sudo docker pull prom/node-exporter
sudo docker run -d --rm -p 80:8080 janoszen/http-load-generator
docker run -d -p 9100:9100 --net="host" prom/node-exporter
EOF
}

resource "exoscale_nlb" "website" {
  zone = "at-vie-1"
  name = "website"
  description = "Network Load Balancer for my website"
}

resource "exoscale_nlb_service" "website" {
  zone = "at-vie-1"
  name = "website"
  description = "Website over HTTP"
  nlb_id = exoscale_nlb.website.id
  instance_pool_id = exoscale_instance_pool.myinstancepool.id
    protocol = "tcp"
    port = 80
    target_port = 80
    strategy = "round-robin"

  healthcheck {
    port = 80
    mode = "http"
    uri = "/health"
    interval = 5
    retries = 1
    timeout = 3
  }
}

resource "exoscale_compute" "prometheus" {
  display_name = "prometheus"
  zone = "at-vie-1"
  template_id = data.exoscale_compute_template.ubuntu.id
  disk_size    = 10
  size = "micro"
  security_group_ids = [exoscale_security_group.sg.id]
  # key_pair = "ssh-key"
  user_data = <<EOF
#!/bin/bash
set -e
apt update
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo docker pull asgreflexx/service-discovery_cc:latest
mkdir /home/ubuntu/srv
mkdir /home/ubuntu/srv/service-discovery
touch /home/ubuntu/srv/service-discovery/config.json
chown ubuntu:ubuntu /home/ubuntu/srv/service-discovery/config.json
chmod 777 /home/ubuntu/srv/service-discovery/config.json

sudo docker run -d -v /home/ubuntu/srv/service-discovery/config.json:/srv/service-discovery/config.json -e EXOSCALE_KEY='${var.exoscale_key}' -e EXOSCALE_SECRET='${var.exoscale_secret}' -e EXOSCALE_ZONE='${exoscale_instance_pool.myinstancepool.zone}' -e TARGET_PORT='9100' -e EXOSCALE_INSTANCEPOOL_ID='${exoscale_instance_pool.myinstancepool.id}' asgreflexx/service-discovery_cc:latest
sudo docker pull asgreflexx/prometheus_cc:latest
sudo docker run -d -p 9090:9090 -v /home/ubuntu/srv/service-discovery/config.json:/service-discovery/config.json asgreflexx/prometheus_cc:latest

EOF
}