terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}

resource "aws_budgets_budget" "mybudget" {
  name              = "monthly-budget"
  budget_type       = "COST"
  limit_amount      = "10.0"
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2025-01-01_00:01"
}

resource "aws_s3_bucket" "glacier_bucket" {
	bucket = "my-beaver-backup"
	lifecycle {
		prevent_destroy = true
	}
	tags = {
		Name = "Beaver backup bucket"
		Environment = "Production"
	}
}

resource "aws_s3_bucket" "state_bucket" {
  bucket = "tp-terraform-state-backend-bucket"
  acl    = "private"

  tags = {
    Name = "Terraform State Bucket"
  }
}
