
###### Creating ELB for Wordpress application ######

resource "aws_elb" "wp_elb" {
  name                        = "${var.environment}-wordpress-elb"
  subnets                     = "${var.pub_subnet_ids}"
  security_groups             = "${var.elb_security_group}"
  availability_zones          = "${var.availability_zones}"
  internal                    = "${var.internal_lb}"
  cross_zone_load_balancing   = "${var.cross_zone_load_balancing}"
  connection_draining         = "${var.connection_draining}"
  connection_draining_timeout = "${var.connection_draining_timeout}"

  health_check {
    healthy_threshold   = "${var.health_check_healthy_threshold}"
    unhealthy_threshold = "${var.health_check_unhealthy_threshold}"
    timeout             = "${var.health_check_timeout}"
    interval            = "${var.health_check_interval}"
    target              = "${var.health_check_target}"
  }

  dynamic "listener" {
    for_each = [for rule_obj in var.listeners : {
      lb_port           = rule_obj.lb_port
      instance_port     = rule_obj.instance_port
      lb_protocol       = rule_obj.lb_protocol
      instance_protocol = rule_obj.instance_protocol
    }]
    content {
      lb_port           = listener.value["lb_port"]
      lb_protocol       = listener.value["lb_protocol"]
      instance_port     = listener.value["instance_port"]
      instance_protocol = listener.value["instance_protocol"]
    }
  }

  tags = {
    Name        = "${var.environment}-wordpress-elb"
    Environment = "${var.environment}"
  }
}

# Fetches the Zone-ID for "wp-c2fo.com" domain
data "aws_route53_zone" "wp_zone" {
  name         = "wp-c2fo.com."
  private_zone = true
}

# This will create route53 entry for ALB
resource "aws_route53_record" "wp_record" {
  zone_id = data.aws_route53_zone.wp_zone.zone_id
  name    = "dev.wp-c2fo.com"
  type    = "A"

  alias {
    name                   = "${aws_elb.wp_elb.dns_name}"
    zone_id                = "${aws_elb.wp_elb.zone_id}"
    evaluate_target_health = true
  }
}