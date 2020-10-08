data "exoscale_compute_template" "ubuntu" {
  zone = "at-vie-1"
  name = "Linux Ubuntu 20.04 LTS 64-bit"
}

resource "exoscale_instance_pool" "myinstancepool" {
  zone = "at-vie-1"
  name = "instancepool-webapp"
  template_id = data.exoscale_compute_template.ubuntu.id
  size         = 2
  disk_size    = 10
  key_pair     = ""
  service_offering = "micro"
  description = "This is my first instance pool"
  security_group_ids = [exoscale_security_group.sg.id]
  user_data = <<EOF
#!/bin/bash
set -e
apt update
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo docker pull janoszen/http-load-generator:latest
sudo docker run -d --rm -p 80:8080 janoszen/http-load-generator
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