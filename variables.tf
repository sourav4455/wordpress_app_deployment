variable "region" {
  type    = string
  default = "us-west-2"
}

variable "environment" {
  type    = string
}

variable "vpc_cidr_range" {
  type    = string
}

variable "public_subnets_cidr" {
  type    = list
}

variable "private_subnets_cidr" {
  type    = list
}

variable "db_subnets_cidr" {
  type    = list
}

variable "sg_name" {
  type    = string
}

######## Public SG details ########

variable "sg_inbound_public_ports" {
  type    = list
  default = [22]
}

variable "sg_outbound_public_ports" {
  type    = list
  default = [0]
}

variable "ingress_cidr_public_allowed" {
  type    = list
  default = ["0.0.0.0/0"]
}

variable "egress_cidr_public_allowed" {
  type    = list
  default = ["0.0.0.0/0"]
}

######## ALB SG details ########

variable "sg_inbound_alb_ports" {
  type    = list
  default = [80]
}

variable "sg_outbound_alb_ports" {
  type    = list
  default = [0]
}

variable "ingress_cidr_alb_allowed" {
  type    = list
  default = ["0.0.0.0/0"]
}

variable "egress_cidr_alb_allowed" {
  type    = list
  default = ["0.0.0.0/0"]
}

######## Private SG details ########

variable "sg_inbound_private_ports" {
  type    = list
  default = [22,80]
}

variable "sg_outbound_private_ports" {
  type    = list
}

# variable "ingress_sgid_private_allowed" {
#   type    = list
#}

variable "egress_cidr_private_allowed" {
  type    = list
  default = ["0.0.0.0/0"]
}

######## Database SG details ########

variable "sg_inbound_db_ports" {
  type    = list
  default = [3306]
}

variable "sg_outbound_db_ports" {
  type    = list
  default = [0]
}

variable "egress_cidr_db_allowed" {
  type    = list
  default = ["0.0.0.0/0"]
}

######## NACL details ########

variable "nacl_public_rules" {
  type = map(object({
    port     = string
    rule_num = string
    cidr     = string
    protocol = string
  }))
  default = {}
}

variable "nacl_private_rules" {
  type = map(object({
    port     = string
    rule_num = string
    cidr     = string
    protocol = string
  }))
  default = {}
}