terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket   =  "your_bucket_name"
    key      = "terraform.tfstate"
    region   =  "us-east-1"

  }
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "InstanceProfile"
  path = "/"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role" "ec2_role" {
  name               = "EC2Role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow", 
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  path = "/"

  inline_policy {
    name = "S3ListBucketsPolicy"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListAllMyBuckets"       
      ],
      "Resource": "arn:aws:s3:::*"
    },
    {
      "Effect": "Allow",
      "Action": [      
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::${var.bucket_name}/nginx_playbook.yml"
    }
  ]
}
EOF
  }
}

resource "aws_launch_template" "launch_template" {
  name = "MyLaunchTemplate"
  image_id      = "ami-04823729c75214919"
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = base64encode(<<EOF
#!/bin/bash
sudo amazon-linux-extras install ansible2 -y
aws s3 cp s3://${var.bucket_name}/nginx_playbook.yml /home/ec2-user/nginx_playbook.yml
ansible-playbook /home/ec2-user/nginx_playbook.yml
EOF
  )

  iam_instance_profile {
    arn = aws_iam_instance_profile.instance_profile.arn
  }
}

resource "aws_security_group" "security_group" {
  name        = "SecurityGroup"
  description = "Security group for the EC2 instances"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # For SSH Into Instance 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_autoscaling_group" "auto_scaling_group" {
  name                 = "AutoScalingGroupForNginx"
  availability_zones   = var.availability_zones
  launch_template {
    id      = aws_launch_template.launch_template.id
    version = aws_launch_template.launch_template.latest_version
  }
  min_size             = 1
  max_size             = 3
  desired_capacity     = 2
}