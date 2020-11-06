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
  key = "EXOa9afd5a62a5c6a2ea98e1bf5"
  //secret = "${var.exoscale_secret}"
  secret = "yt2wX8tiZSMF3xkUD-l3DpzpZulA4x6XsWcSX9VhQrI"
}