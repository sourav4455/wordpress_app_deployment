
# Keeping all the reusable things at one place
locals {
  region               = "us-west-2"
  environment          = "dev"
  vpc_cidr_range       = "10.0.0.0/16"
  public_subnets_cidr  = ["10.0.88.0/23", "10.0.90.0/23", "10.0.92.0/23"]
  private_subnets_cidr = ["10.0.64.0/21", "10.0.72.0/21", "10.0.80.0/21"]
  db_subnets_cidr      = ["10.0.1.0/26", "10.0.1.64/26", "10.0.1.128/26"]
}

# This creates VPC with subnets, SG and NACL 
module "wp_vpc" {
  source = "../../terraform_modules/vpc"

  region                      = local.region
  environment                 = local.environment
  vpc_cidr_range              = local.vpc_cidr_range
  public_subnets_cidr         = local.public_subnets_cidr
  private_subnets_cidr        = local.private_subnets_cidr
  db_subnets_cidr             = local.db_subnets_cidr
  sg_name                     = "wordpress"
  sg_inbound_public_ports     = [22]
  sg_inbound_private_ports    = [22,80]
  sg_inbound_alb_ports        = [80]
  sg_inbound_db_ports         = [3306]
  ingress_cidr_public_allowed = ["0.0.0.0/0"]
  ingress_cidr_alb_allowed    = ["0.0.0.0/0"]
  nacl_public_rules = {
    port     = "0",
    rule_num = "200",
    cidr     = ["0.0.0.0/0"],
    protocol = "-1"
  }
  nacl_private_rules = {
    port     = "0",
    rule_num = "200",
    cidr     = ["0.0.0.0/0"],
    protocol = "-1"
  }
}

# This creates AWS RDS with MySQL engine & Secretmanager to store DB password
module "wp_database" {
  source = "../../terraform_modules/database"

  region                  = local.region
  environment             = local.environment
  db_subnet_ids           = module.wp_vpc.db_subnets
  identifier              = "wp-rds"
  instance_class          = "db.t4g.small"
  allocated_storage       = "20"
  engine                  = "mysql"
  engine_version          = "5.7"
  db_name                 = "wordpress_db"
  wp_db_user              = "admin"
  vpc_security_group_ids  = module.wp_vpc.db_security_group_id
  deletion_protection     = "false"
  preferred_backup_window = "07:00-09:00"
}

# This creates Instance using workpress AMI under ASG behind Load balancer
module "wp_asg_elb" {
  source = "../../terraform_modules/asg_with_elb"
  
  region             = local.region
  environment        = local.environment

  # ASG and LC
  instance_type      = "t3.medium"
  sg_ids             = module.wp_vpc.private_security_group_id
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  min_instance       = 3
  max_instance       = 10
  filter_ami_tags = {
    "ami_name" = "amz2_ami_wordpress"
  }
  
  # ELB
  pub_subnet_ids              = module.wp_vpc.public_subnets
  elb_security_group          = module.wp_vpc.elb_security_group_id
  internal_lb                 = false
  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = "300"
  listeners   = {
    lb_port           = "80"
    instance_port     = "80"
    lb_protocol       = "http"
    instance_protocol = "http"
  }

  # ELB health check
  health_check_healthy_threshold   = "2"
  health_check_unhealthy_threshold = "2"
  health_check_timeout             = "3"
  health_check_interval            = "30"
  health_check_target              = "HTTP:80/"
}
