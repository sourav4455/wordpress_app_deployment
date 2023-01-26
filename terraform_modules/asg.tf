
###### Launch Configuration for a wordpress server ######

# Filter out the AMI ID of wordpress Application
data "aws_ami" "wp_ami" {
  most_recent = true

  dynamic "filter" {
    for_each = "${var.filter_ami_tags}"
    iterator = tag
    content {
      name = "tag:${tag.key}"
      values = ["${tag.value}"]
    }
  }
}

# Key_pair for login to wp server
resource "aws_key_pair" "wp_keys" {
  key_name   = "wp-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDOCx0DrnjbV7RMq9W4NtjjYD+rll/9JBTmYmi3nuLxWwzZ7oR30S7RqZFxxczkQ2ldJr38GGJo7GSDRKrtQUwwSGk3yAxTUJ6jXs4W8gmpftJOE1hsGThwUEp0IlwM9/gPgPuBVX0NZG6E8O3uhHvyLLGtBAO4ZFgp1PLlnsLuOHy3SrbhGxBfvwApyXqKKKwq8ojjX28VCGkspOY/4q2LQB+SP6ahiu04WbDTZDrffQhfMAnTFpYw826+/hUnuFdCI8V8F4/9IJSpEfyPOkxVKf/Z4az5iPv61Rg8gEKIFkq4Al7iO9ybSxsFFIlbbJ6sPc1vVA6ztfSEQQUzA2WNqDZZvEVyFLIge3tafQwlaw7GfviJ4CTdEvD5QprfN1to+/+acOrjFLiOHJJwpov8OmV9d2MHjF8HUNauTEWGr9ktHGwScpCziiG32tmqAUrDZNhNi2fVQKBUBtsENlNb5EM7GeLVnuPMftL64UFOXUPmIl+3YQfCReVnFGi2pf8= shourabh@MacBook-Pro.local"
}

# Wordpress LC configs
resource "aws_launch_configuration" "wp_lc" {
  name            = "${var.environment}-wordpress-lc"
  image_id        = "${data.aws_ami.wp_ami.id}"
  instance_type   = "${var.instance_type}"
  security_groups = "${var.sg_ids}"
  key_name        = "${aws_key_pair.wp_keys.id}"
  #user_data       = "${file(var.userdata_filename.sh)}"
  lifecycle {
    create_before_destroy = true
  }
}

###### AutoScaling Group for wordpress webserver with HA ######
resource "aws_autoscaling_group" "wp_asg" {
  name                 = "${var.environment}-wordpress-asg"
  launch_configuration = "${aws_launch_configuration.wp_lc.id}"
  availability_zones   = "${var.availability_zones}"
  min_size             = "${var.min_instance}"
  max_size             = "${var.max_instance}"
  load_balancers       = ["${aws_elb.wp_elb.name}"]
  health_check_type    = "ELB"

  tag {
    key                 = "Name"
    value               = "${var.environment}-wordpress-asg"
    propagate_at_launch = true
  }
}
