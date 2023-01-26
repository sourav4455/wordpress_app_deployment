####### Common variables #######

variable "region" {
  type    = string
  default = "us-west-2"
}

variable "environment" {
  type    = string
  default = "dev"
}

####### Launch Configuration variables #######

# variable "ami_id" {
#   type    = string
# }

variable "filter_ami_tags" {
  description = "Custom tags get the AMI ID"
  type        = map(string)
  default     = {
    "ami_name" = "amz2_ami_wordpress"
  }
}

variable "instance_type" {
  type    = string
}

variable "sg_ids" {
  type    = list
}

variable "userdata_filename" {
  type    = string
}

####### ASG variables #######

variable "availability_zones" {
  type    = list 
}

variable "min_instance" {
  type    = string 
}

variable "max_instance" {
  type    = string 
}

####### ELB variables #######

# variable "elb_name" {
#   type    = string
# }

variable "pub_subnet_ids" {
  type    = list 
}

variable "elb_security_group" {
  type    = list 
}

variable "internal_lb" {
  type    = bool
  default = true
}

variable "cross_zone_load_balancing" {
  type    = bool
  default = true
}

variable "connection_draining" {
  type    = bool
  default = true
}

variable "connection_draining_timeout" {
  type    = string
  default = "300"
}

# ELB listener details
variable "listeners" {
  type = map(object({
    lb_port           = string
    instance_port     = string
    lb_protocol       = string
    instance_protocol = string
  }))
  default = {}
}

# ELB healthcheck variables
variable "health_check_healthy_threshold" {
  type    = string
  default = "2"
}

variable "health_check_unhealthy_threshold" {
  type    = string
  default = "2"
}

variable "health_check_timeout" {
  type    = string
  default = "3"
}

variable "health_check_interval" {
  type    = string
  default = "30"
}

variable "health_check_target" {
  type    = string
  default = "HTTP:80/"
}
