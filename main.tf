locals {
  RESOURCE_PREFIX = "${lower(var.ENV)}"
}


################################################################################
# EC2
################################################################################
module "ec2" {
  source = "./modules/ec2"

  region = var.REGION
}



################################################################################
# IAM Users
################################################################################
module "iam_user" {
  source = "./modules/iam-user"

  region = var.REGION
  username = ["spark", "big"]
}


################################################################################
# VPC
################################################################################
module "vpc" {
  source = "./modules/vpc"

  name = "${local.RESOURCE_PREFIX}-vpc"
  cidr = var.VPC["CIDR"]

  azs             = ["${var.REGION}a"]
  public_subnets  = var.VPC["SUBNET_PUBLIC"]

  enable_nat_gateway = false
  single_nat_gateway = false
  enable_vpn_gateway = false
}

resource "aws_security_group" "allow" {
  name        = "${local.RESOURCE_PREFIX}-allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  depends_on = [
    module.vpc
  ]
}



################################################################################
# Roles
################################################################################
module "role" {
  source = "./modules/role"
  RESOURCE_PREFIX = local.RESOURCE_PREFIX
}



################################################################################
# Policies
################################################################################
module "policies" {
  source = "./modules/policy"
  RESOURCE_PREFIX = local.RESOURCE_PREFIX
  AWS_REGION = var.REGION
  CURRENT_ACCOUNT_ID = data.aws_caller_identity.current.account_id

  LAMBDA_ROLE_NAME = module.role.LAMBDA_ROLE_NAME
}



################################################################################
# Lambda
################################################################################
module "lambda" {
  source = "./modules/lambda"
  ENV = var.ENV
  RESOURCE_PREFIX = local.RESOURCE_PREFIX

  LAMBDA_ROLE_ARN = module.role.LAMBDA_ROLE_ARN

  depends_on = [
    module.role
  ]
}



################################################################################
# API
################################################################################
module "api" {
  source = "./modules/api-gateway"
  ENV = var.ENV
  RESOURCE_PREFIX = "home"
  
  LAMBDA_HOME_NAME = module.lambda.LAMBDA_HOME_NAME
  LAMBDA_HOME_INVOKE_ARN = module.lambda.LAMBDA_HOME_INVOKE_ARN

  depends_on = [
    module.role,
    module.lambda
  ]
}







resource "aws_instance" "Web-1" {
  ami   = "ami-08df646e18b182346" # ap-south-1
  count=1
  instance_type = "t2.micro"
  user_data = <<-EOF
		#!/bin/bash
    sudo yum update -y
		sudo yum install -y httpd
		sudo systemctl start httpd
		sudo systemctl enable httpd
		echo "<h1>I made it! This is is awesome!</h1>" > /var/www/html/index.html
	EOF
  subnet_id = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.allow.id]
  depends_on = [
    module.vpc
  ]
}