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

// Gets all active availability zones. 
//This ensures that we have 3 availability zones in the selected region.
data "aws_availability_zones" "available" {
  state = "available"
}

//Setup the VPC and its respective security groups & gateways
module "network_vpc" {
  source = "./modules/VPC"

  region = var.region
  az1    = data.aws_availability_zones.available.names[0]
  az2    = data.aws_availability_zones.available.names[1]
  az3    = data.aws_availability_zones.available.names[2]

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

// Setup the MySQL RDS Database
module "mysql_database" {
  source = "./modules/DB"

  db_sg                   = module.network_vpc.rds_sg_id
  db_az                   = data.aws_availability_zones.available.names[1]
  database_admin_password = var.database_admin_password
  rds_private_subnets     = module.network_vpc.priv_rds_subnets
}

// Setup the S3 Bucket
module "bucket" {
  source = "./modules/S3"

  bucket_name = var.bucket_name
}

// Setup the IAM roles for EC2 Instances
module "iam_roles" {
  source = "./modules/IAM"

  bucket_name = var.bucket_name
}

// Setup an HTTPS Load balancer
module "load_balancer" {
  source = "./modules/LB"

  public_sg_id   = module.network_vpc.pub_http_sg_id
  public_subnets = module.network_vpc.pub_lb_subnets
  vpc_id         = module.network_vpc.vpc_id
  cert_arn       = module.Route53.cert_arn
}

// Create the elastic instanes used by the load balancer
module "app_instances" {
  source = "./modules/EC2"

  public_subnet = module.network_vpc.pub_lb_subnets[0]
  ssh_key       = var.ssh_key
  test_sg_id    = module.network_vpc.testing_sg_id

  private_subnets      = module.network_vpc.priv_ec2_subnets
  private_sg           = module.network_vpc.ec2_sg_id
  target_arn           = module.load_balancer.lb_target_arn
  instance_profile_arn = module.iam_roles.instance_profile_arn

  DBip       = module.mysql_database.DBip
  DBUsername = module.mysql_database.DBUsername
  DBPassword = var.database_admin_password
  DBName     = module.mysql_database.DBName

  S3_name = var.bucket_name
  region  = var.region
}

// Setup the routing and SSL certificate used for the domain name.
module "Route53" {
  source = "./modules/Route53"

  lb_ip       = module.load_balancer.dns_name
  lb_zone_id  = module.load_balancer.lb_zone_id
  domain_name = var.domain_name
}