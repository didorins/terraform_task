
# Instance type. Stick to t2.micro for free tier
variable "instance_type" {
  default = "t2.micro"
}

# Region in which to place VPC
variable "region" {
  default = "eu-central-1"
}

# List of Availability Zones in which Auto Scaling Group & subnets will span.
variable "azs" {
  type    = list(any)
  default = ["eu-central-1a", "eu-central-1b"]
}

# Key pair for EC2
variable "path_to_key" {
  type    = string
  default = "mynew_key.pub"
}

# Main VPC CIDR range (up to /16)
variable "vpc_cidr" {
  type        = string
  description = "VPC IP range"
  default     = "10.0.0.0/16"
}

# List of ports to allow in web layer
variable "dynamicports" {
  type        = list(any)
  description = "List of ports for SG rules"
  default     = [22, 80 ,443, 2049]
}

variable "database_port" {
  type        = number
  description = "DB default port, used in ASG SG to allow communication between app and db layers"
  default     = 3306
}

variable "prefix" {
  type        = string
  description = "S3 bucket prefix for LB log writing."
  default     = "logs"
}

variable "your-ip" {
  description = "Whitelist CIDR block for EC2 SSH"
  default = "130.204.133.250"
}

variable "rds-username" {
 type = string
 description = "Your DB username"
 default = "dido"

 }

variable "db2_instance_class" {
  default = "db.t2.micro"
}
