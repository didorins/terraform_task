# Provider & region
provider "aws" {
  region = var.region
}

# Private and public keys (key pair) to enable SSH to EC2s in ASG
resource "aws_key_pair" "public_key" {
  key_name   = "terraform.public.key"
  public_key = file(var.path_to_key)
}

# Launch template for the ASG. Fetch AMI from Amazon
# Passing user data (shell script) to newly created EC2s to install & enable http server to write simple app
# TODO : Clone "real" functional app from external repo to use instead of simple .sh test app  OR use wordpress
# TODO : Use template file for cleaner code

resource "aws_launch_template" "micro" {
  image_id               = data.aws_ami.app_ami.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.public_key.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  depends_on = [
    aws_efs_mount_target.mount1,
    aws_efs_mount_target.mount2
  ]

  user_data = base64encode(<<EOF

  #! /bin/bash
  sudo yum update -y
  sudo yum install -y httpd
  sudo yum install mariadb -y
  sudo systemctl start httpd
  sudo systemctl enable httpd
  echo "Hello World from $(hostname -f)" > /var/www/html/index.html
  sudo mkdir /efs
  sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.efs.id}.efs.${data.aws_region.current.name}.amazonaws.com:/  /efs
  chmod 777 /etc/fstab
  sudo echo "${aws_efs_file_system.efs.id}.efs.${data.aws_region.current.name}.amazonaws.com:/ /efs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0'">>/etc/fstab
  
    EOF
  )
}

# ASG spanning across 2 AZs for high availability, created from launch template. Association with ALB through target group.

resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier = [aws_subnet.public-1.id, aws_subnet.public-2.id]

  desired_capacity = 2
  max_size         = 4
  min_size         = 1

  target_group_arns = [aws_lb_target_group.alb-example.arn]
  depends_on        = [aws_route_table_association.a]

  lifecycle {
    ignore_changes = [load_balancers, target_group_arns]
  }
  launch_template {
    id      = aws_launch_template.micro.id
    version = aws_launch_template.micro.latest_version
  }
}

# Target tracking ASG policy, tracking CPU metric with taget 60% util
# Can test ASG with stress test 'dd if=/dev/zero of=/dev/null'. This creates 100% CPU load. If more than one instance is present, you need to raise average CPU accordingly.

resource "aws_autoscaling_policy" "scaling" {
  name                   = "cpuscale"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 60.0
  }
}
