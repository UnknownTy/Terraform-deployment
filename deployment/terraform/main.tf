terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}
provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "network_vpc" {
  source = "./modules/VPC"

  az1            = data.aws_availability_zones.available.names[0]
  az2            = data.aws_availability_zones.available.names[1]
  az3            = data.aws_availability_zones.available.names[2]
  
  vpc_cidr_block = "10.0.0.0/16"
  
  priv_ec2_subnet_1 = "10.0.10.0/24"
  priv_ec2_subnet_2 = "10.0.11.0/24"
  priv_ec2_subnet_3 = "10.0.12.0/24"

  priv_rds_subnet_1 = "10.0.20.0/24"
  priv_rds_subnet_2 = "10.0.21.0/24"
  priv_rds_subnet_3 = "10.0.22.0/24"
  
  pub_lb_subnet_1 = "10.0.30.0/24"
  pub_lb_subnet_2 = "10.0.31.0/24"
  pub_lb_subnet_3 = "10.0.32.0/24"
}

module "app_instances" {
  source = "./modules/EC2"

  private_subnets = module.network_vpc.priv_ec2_subnets
  private_sg = module.network_vpc.ec2_sg_id
  DBip = ""
  DBUsername = "" 
  DBPassword = ""
  DBName = ""
  S3_name = ""
  region = var.region
}