# Public facing ALB standing in front of EC2s in ASG. Use HTTP (port 80) DNS name to connect.
resource "aws_lb" "app-lb" {
  name               = "app-loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-sg.id]
  subnets            = [aws_subnet.public-1.id, aws_subnet.public-2.id]

  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.lb-access-logs.bucket
    prefix  = var.prefix
    enabled = true
  }
}

# SG of LB. Allowing anyone to connect on HTTP port
resource "aws_security_group" "lb-sg" {
  name        = "Custom-ELB-SG"
  description = "Allow inbound traffic from ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow traffic from web layer"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Target group of LB. See ASG target_group_arns.
resource "aws_lb_target_group" "alb-example" {
  name        = "tf-example-lb-alb-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
}

# Forward HTTP requests to target group (asg). Listen for connection requests using protocol and port.
resource "aws_lb_listener" "front-end" {
  load_balancer_arn = aws_lb.app-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-example.arn
  }
}

# S3 bucket to store LB logs. 
# TODO: Move policy to aws_s3_bucket_policy and use reference instead of hardcode
resource "aws_s3_bucket" "lb-access-logs" {
  bucket        = "lb-logs-storage"
  force_destroy = true
}

# Bucket policy allowing LB to write to S3
resource "aws_s3_bucket_policy" "allow_elb_logging" {
  bucket = aws_s3_bucket.lb-access-logs.id
  policy = <<POLICY

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_elb_service_account.main.arn}"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::lb-logs-storage/logs/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    }
  ]
}
POLICY
}

# Connect bucket policy to bucket
resource "aws_s3_bucket_acl" "logs_acl" {
  bucket = aws_s3_bucket.lb-access-logs.id
  acl    = "private"
}

# Block public access to s3
resource "aws_s3_bucket_public_access_block" "private" {
  bucket = aws_s3_bucket.lb-access-logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


