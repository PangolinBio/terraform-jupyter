variable "region" {
  default = "us-west-2"
  type    = string
}
variable "availability_zone" {
  default = "us-west-2a"
  type    = string
}

variable "contact" {
  default = "contact@sunitjain.com"
  type    = string
}

variable "environment" {
  default = "Devlopment"
  type    = string
}

variable "instance_type" {
  default = "r4.2xlarge"
  type    = string
}

variable "service" {
  default = "jupyter"
  type    = string
}
