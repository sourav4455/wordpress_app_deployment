## Creates network level stuffs

# Get all availability zone data from AWS
data "aws_availability_zones" "available" {}

######## This will create a VPC ########
resource "aws_vpc" "mainVPC" {
  cidr_block = "${var.vpc_cidr_range}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags {
    Name        = "${var.environment}-vpc"
    Environment = "${var.environment}"
  }
}

######## Create public subnets in every AZ (for Web Tier) ########
resource "aws_subnet" "public_subnet" {
  count                   = "${length(var.public_subnets_cidr)}"
  vpc_id                  = "${aws_vpc.mainVPC.id}"
  cidr_block              = "${element(var.public_subnets_cidr, count.index)}"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = false

  tags {
    Name        = "${var.environment}-${element(data.aws_availability_zones.available.names, count.index)}-PublicSubnet"
    Environment = "${var.environment}"
  }
}

# Internet gateway for the public subnets
resource "aws_internet_gateway" "myIGW" {
  vpc_id = "${aws_vpc.mainVPC.id}"

  tags {
    Name        = "${var.environment}-igw"
    Environment = "${var.environment}"
  }
}

######## Create private subnets in every AZ (for application tier) ########
resource "aws_subnet" "private_subnet" {
  count                   = "${length(var.private_subnets_cidr)}"
  vpc_id                  = "${aws_vpc.mainVPC.id}"
  cidr_block              = "${element(var.private_subnets_cidr, count.index)}"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = false

  tags {
    Name        = "${var.environment}-${element(data.aws_availability_zones.available.names, count.index)}-PrivateSubnet"
    Environment = "${var.environment}"
  }
}

######## Create DB subnets in every AZ (for data tier) ########
resource "aws_subnet" "db_subnet" {
  count                   = "${length(var.db_subnets_cidr)}"
  vpc_id                  = "${aws_vpc.mainVPC.id}"
  cidr_block              = "${element(var.db_subnets_cidr, count.index)}"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = false

  tags {
    Name        = "${var.environment}-${element(data.aws_availability_zones.available.names, count.index)}-DBSubnet"
    Environment = "${var.environment}"
  }
}

######## Routing table for public subnets ########
resource "aws_route_table" "rtPublic" {
  vpc_id = "${aws_vpc.mainVPC.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.myIGW.id}"
  }

  tags {
    Name        = "${var.environment}-rtPublic"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table_association" "route" {
  count          = "${length(var.public_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.rtPublic.id}"
}

# Elastic IP for NAT gateway
resource "aws_eip" "nat" {
  depends_on = [aws_internet_gateway.myIGW]

  vpc = true
}

# NAT Gateway
resource "aws_nat_gateway" "nat-gw" {
  depends_on    = [aws_internet_gateway.myIGW]
  
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${element(aws_subnet.public_subnet.*.id, 0)}"

  tags = {
    Name        = "NAT"
    Environment = "${var.environment}"
  }
}

######## Routing table for private subnets ########
resource "aws_route_table" "rtPrivate" {
  vpc_id = "${aws_vpc.mainVPC.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat-gw.id}"
  }

  tags {
    Name = "rtPrivate"
  }
}

resource "aws_route_table_association" "private_route" {
  count          = "${length(var.private_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.rtPrivate.id}"
}

######## Public Security Groups ########
resource "aws_security_group" "public_sg" {
  vpc_id      = "${aws_vpc.mainVPC.id}"
  name        = "${var.sg_name}-public-sg"

  dynamic "ingress" {
    for_each = "${var.sg_inbound_public_ports}"
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = "${var.ingress_cidr_public_allowed}"
    }
  }

  dynamic "egress" {
    for_each = "${var.sg_outbound_public_ports}"
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "-1"
      cidr_blocks = "${var.egress_cidr_public_allowed}"
    }
  }

  tags = {
    Name        = "${var.sg_name}-${var.environment}-public-sg"
    Environment = "${var.environment}"
  }
}

# Loadbalancer Security Group
resource "aws_security_group" "alb_sg" {
  vpc_id      = "${aws_vpc.mainVPC.id}"
  name        = "${var.sg_name}-alb-sg"

  dynamic "ingress" {
    for_each = "${var.sg_inbound_alb_ports}"
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = "${var.ingress_cidr_alb_allowed}"
    }
  }

  dynamic "egress" {
    for_each = "${var.sg_outbound_alb_ports}"
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "-1"
      cidr_blocks = "${var.egress_cidr_alb_allowed}"
    }
  }

  tags = {
    Name        = "${var.sg_name}-${var.environment}-alb-sg"
    Environment = "${var.environment}"
  }
}

######## Private Security Groups ########
resource "aws_security_group" "private_sg" {
  vpc_id      = "${aws_vpc.mainVPC.id}"
  name        = "${var.sg_name}-private-sg"

  dynamic "ingress" {
    for_each = "${var.sg_inbound_private_ports}"
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = "{var.public_subnets_cidr}"
    }
  }

  dynamic "egress" {
    for_each = "${var.sg_outbound_private_ports}"
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "-1"
      cidr_blocks = "${var.egress_cidr_private_allowed}"
    }
  }

  tags = {
    Name        = "${var.sg_name}-${var.environment}-private-sg"
    Environment = "${var.environment}"
  }
}

######## Database Security Groups ########
resource "aws_security_group" "db_sg" {
  vpc_id      = "${aws_vpc.mainVPC.id}"
  name        = "${var.sg_name}-${var.environment}-db-sg"

  ingress {
    from_port   = "${var.sg_inbound_db_ports}"
    to_port     = "${var.sg_inbound_db_ports}"
    protocol    = "tcp"
    cidr_blocks = "{var.public_subnets_cidr}"
  }

  egress {
    from_port   = "${var.sg_outbound_db_ports}"
    to_port     = "${var.sg_outbound_db_ports}"
    protocol    = "-1"
    cidr_blocks = "${var.egress_cidr_db_allowed}"
  }

  tags = {
    Name        = "${var.sg_name}-${var.environment}-db-sg"
    Environment = "${var.environment}"
  }
}

######## Create NACL rules for public tier ########
resource "aws_network_acl" "public_tier" {
  vpc_id = aws_vpc.mainVPC.id
  subnet_ids = [for s in aws_subnet.public_subnet : s.id]

  dynamic "ingress" {
    for_each = [for rule_obj in var.nacl_public_rules : {
      port       = rule_obj.port
      rule_no    = rule_obj.rule_num
      cidr_block = rule_obj.cidr
      protocol   = rule_obj.protocol
    }]
    content {
      protocol   = ingress.value["protocol"]
      rule_no    = ingress.value["rule_no"]
      action     = "allow"
      cidr_block = ingress.value["cidr_block"]
      from_port  = ingress.value["port"]
      to_port    = ingress.value["port"]
    }
  }

  dynamic "egress" {
    for_each = [for rule_obj in var.nacl_public_rules : {
      port       = rule_obj.port
      rule_no    = rule_obj.rule_num
      cidr_block = rule_obj.cidr
      protocol   = rule_obj.protocol
    }]
    content {
      protocol   = egress.value["protocol"]
      rule_no    = egress.value["rule_no"]
      action     = "allow"
      cidr_block = egress.value["cidr_block"]
      from_port  = egress.value["port"]
      to_port    = egress.value["port"]
    }
  }

  tags = {
    Name        = "${var.environment}-public-nacl"
    Environment = "${var.environment}"
  }
}

######## Create NACL rules for private tier ########
resource "aws_network_acl" "private_tier" {
  vpc_id = aws_vpc.mainVPC.id
  subnet_ids = [for s in aws_subnet.private_subnet : s.id]

  dynamic "ingress" {
    for_each = [for rule_obj in var.nacl_private_rules : {
      port       = rule_obj.port
      rule_no    = rule_obj.rule_num
      cidr_block = rule_obj.cidr
      protocol   = rule_obj.protocol
    }]
    content {
      protocol   = ingress.value["protocol"]
      rule_no    = ingress.value["rule_no"]
      action     = "allow"
      cidr_block = ingress.value["cidr_block"]
      from_port  = ingress.value["port"]
      to_port    = ingress.value["port"]
    }
  }

  dynamic "egress" {
    for_each = [for rule_obj in var.nacl_private_rules : {
      port       = rule_obj.port
      rule_no    = rule_obj.rule_num
      cidr_block = rule_obj.cidr
      protocol   = rule_obj.protocol
    }]
    content {
      protocol   = egress.value["protocol"]
      rule_no    = egress.value["rule_no"]
      action     = "allow"
      cidr_block = egress.value["cidr_block"]
      from_port  = egress.value["port"]
      to_port    = egress.value["port"]
    }
  }

  tags = {
    Name        = "${var.environment}-private-nacl"
    Environment = "${var.environment}"
  }
}