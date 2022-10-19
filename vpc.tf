# Main VPC in which all resources will be deployed with dns resolution
resource "aws_vpc" "main" {

  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Main VPC"
  }
}

# Public and Pirivate subnets, 2 in each AZ
# TODO : implement cidr block calculation and consolidation with element. Update references with wildcare like "aws_subnet.public/private.*.id".
resource "aws_subnet" "public-1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 1)
  availability_zone       = var.azs[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public subnet 1"
  }
}

resource "aws_subnet" "public-2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 2)
  availability_zone       = var.azs[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public subnet 2"
  }
}

resource "aws_subnet" "private-1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 3)
  availability_zone = var.azs[0]

  tags = {
    Name = "Private subnet 1"
  }
}

resource "aws_subnet" "private-2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 4)
  availability_zone = var.azs[1]

  tags = {
    Name = "Private subnet 2"
  }
}

# SG of web layer
# TODO: Restrict EC2 access from external; Only allow EC2 access from SG of ALB; consider bastion host

resource "aws_security_group" "web_sg" {
  name   = "Web Tier"
  vpc_id = aws_vpc.main.id


  dynamic "ingress" {
    for_each = var.dynamicports
    iterator = port
    content {
      from_port       = port.value
      to_port         = port.value
      protocol        = "tcp"
      #fix cidr to vpc only
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = [aws_security_group.lb-sg.id]
    }
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.your-ip}/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name  = "main"
    Owner = "terraform"
  }
}

# Route traffic from IGW to LB
resource "aws_route_table" "igw_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name  = "route"
    Owner = "terraform"

  }
}

# Associate public subnets with IGW
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public-1.id
  route_table_id = aws_route_table.igw_rt.id
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public-2.id
  route_table_id = aws_route_table.igw_rt.id
}