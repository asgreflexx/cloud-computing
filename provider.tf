variable "exoscale_key" {
  description = "The Exoscale API key"
  type = string
}
variable "exoscale_secret" {
  description = "The Exoscale API secret"
  type = string
}

terraform {
  required_providers {
    exoscale = {
      source  = "terraform-providers/exoscale"
    }
  }
}

//noinspection HILConvertToHCL
provider "exoscale" {
  //key = "${var.exoscale_key}"
  key = "EXO0050496d690d74aa8c23cd2d"
  //secret = "${var.exoscale_secret}"
  secret = "143nj6FJ0INcRNc0Kbqt28qUrWBjgQKzNFoZD7ntm6c"
}
