terraform {
  # This config tells Terraform where to store state
  backend "s3" {
    bucket = "us-west-2-wordpress-01-terraform-state"
    key    = "dev/wordpress/terraform.tfstate"
    region = "us-west-2"

    dynamodb_table = "us-west-2-wordpress-01-terraform-lock-table"
    encrypt        = true
  }
  # This config tells Terraform which versions are required
  required_version = "~> 1.3.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.24.0"
    }
  }
}
