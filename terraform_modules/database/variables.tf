variable "region" {
  type    = string
  default = "us-west-2"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "db_subnet_ids" {
  type    = list
}

###### Database specific paramaters ######

variable "identifier" {
  type    = string
  default = "wp-rds"
}

variable "instance_class" {
  type    = string
  default = "db.t4g.small"
}

variable "allocated_storage" {
  type    = string
  default = "20"
}

variable "engine" {
  type    = string
  default = "mysql"
}

variable "db_name" {
  type    = string
  default = "wordpress_db"
}

variable "wp_db_user" {
  type    = string
  default = "admin"
}

variable "engine_version" {
  type    = string
  default = "5.7"
}

variable "vpc_security_group_ids" {
  type    = list
}

variable "deletion_protection" {
  type    = string
  default = "false"
}

variable "preferred_backup_window" {
  type    = string
  default = "07:00-09:00"
}
