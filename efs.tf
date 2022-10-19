# Creating EFS
resource "aws_efs_file_system" "efs" {
  creation_token = "my-efs"
}

# Creating Mount target of EFS one for each private subnet
resource "aws_efs_mount_target" "mount1" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.private-1.id
  security_groups = [aws_security_group.web_sg.id]
}

resource "aws_efs_mount_target" "mount2" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.private-2.id
  security_groups = [aws_security_group.web_sg.id]
}

# SG of EFS
resource "aws_security_group" "efs-sg" {
  name   = "efs-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description     = "Allow incomming connections from SG of ASG on EFS port"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    cidr_blocks     = [var.vpc_cidr]
    security_groups = [aws_security_group.web_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
