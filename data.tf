# Data block will fetch AMI from Amazon, where creator is Amazon and will grep by name, using wildcard
data "aws_ami" "app_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# Data fetch of current region for bootstrap user data reference
data "aws_region" "current" {}

# Fetch your identity for s3 policy reference
data "aws_caller_identity" "current" {}

# Fetch service account ID for LB bucket policy
data "aws_elb_service_account" "main" {}