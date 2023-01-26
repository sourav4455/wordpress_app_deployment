
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.mainVPC.id
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public_subnet[*].id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private_subnet[*].id
}

output "db_subnets" {
  description = "List of IDs of DB subnets"
  value       = aws_subnet.db_subnet[*].id
}

output "public_security_group_id" {
  description = "The ID of Public security group"
  value       = aws_security_group.public_sg.id
}

output "private_security_group_id" {
  description = "The ID of private security group"
  value       = aws_security_group.private_sg.id
}

output "db_security_group_id" {
  description = "The ID of DB security group"
  value       = aws_security_group.db_sg.id
}

output "elb_security_group_id" {
  description = "The ID of ELB security group"
  value       = aws_security_group.alb_sg.id
}
