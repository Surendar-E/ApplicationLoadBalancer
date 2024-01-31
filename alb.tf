# main.tf

provider "aws" {
  region = "us-east-1"  # Specify your desired AWS region
}

# Create an ALB
resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  enable_deletion_protection = false
  subnets            = ["subnet-0d49c9c004969a730", "subnet-0c57316f05925ac07"]  # Replace with your subnet IDs
}

# Create a security group for the ALB
resource "aws_security_group" "alb" {
  name        = "alb-sg"
  description = "Security group for ALB"
  vpc_id      = "vpc-013feb576ac0611b3"  # Replace with your VPC ID

  // Add inbound rules as needed
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an Auto Scaling Group
resource "aws_launch_configuration" "my_launch_config" {
  name = "i-launch-config"

  // Specify your AMI ID and other configuration settings
  image_id = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "my_asg" {
  desired_capacity     = 2
  max_size             = 5
  min_size             = 1
  launch_configuration = aws_launch_configuration.my_launch_config.id
  vpc_zone_identifier  = ["subnet-0d49c9c004969a730", "subnet-0c57316f05925ac07"]  # Replace with your subnet IDs

  tag {
    key                 = "Name"
    value               = "my-asg-instance"
    propagate_at_launch = true
  }
}
