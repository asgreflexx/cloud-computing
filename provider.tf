variable "exoscale_key" {
  description = "The Exoscale API key"
  type = string
  default = ""
}
variable "exoscale_secret" {
  description = "The Exoscale API secret"
  type = string
  default = ""
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
  key = var.exoscale_key
  secret = var.exoscale_secret
}
