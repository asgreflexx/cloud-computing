resource "exoscale_security_group" "sg" {
  name = "project-sg"
}

resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.sg.id
  type = "INGRESS"
  protocol = "tcp"
  cidr = "0.0.0.0/0"
  start_port = 80
  end_port = 80
}

resource "exoscale_security_group_rule" "http2" {
  security_group_id = exoscale_security_group.sg.id
  type = "INGRESS"
  protocol = "tcp"
  cidr = "0.0.0.0/0"
  start_port = 8080
  end_port = 8080
}

resource "exoscale_security_group_rule" "http3" {
  security_group_id = exoscale_security_group.sg.id
  type = "INGRESS"
  protocol = "tcp"
  cidr = "0.0.0.0/0"
  start_port = 9100
  end_port = 9100
}

resource "exoscale_security_group_rule" "http_prometheus" {
  security_group_id = exoscale_security_group.sg.id
  type = "INGRESS"
  protocol = "tcp"
  cidr = "0.0.0.0/0"
  start_port = 9090
  end_port = 9090
}

resource "exoscale_security_group_rule" "ssh" {
  security_group_id = exoscale_security_group.sg.id
  type = "INGRESS"
  protocol = "tcp"
  cidr = "0.0.0.0/0"
  start_port = 22
  end_port = 22
}
