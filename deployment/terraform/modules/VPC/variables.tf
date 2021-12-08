variable "region" {
  description = "Region"
  type        = string
}
variable "az1" {
  description = "First availability zone"
  type        = string
}
variable "az2" {
  description = "Second availability zone"
  type        = string
}
variable "az3" {
  description = "Third availability zone"
  type        = string
}

variable "vpc_cidr_block" {
  description = "cidr block for the VPC"
  type        = string
}

variable "priv_ec2_subnet_1" {
  description = "CIDR block for EC2's first private subnet"
  type        = string
}
variable "priv_ec2_subnet_2" {
  description = "CIDR block for EC2's second private subnet"
  type        = string
}
variable "priv_ec2_subnet_3" {
  description = "CIDR block for EC2's third private subnet"
  type        = string
}

variable "priv_rds_subnet_1" {
  description = "CIDR block for RDS's first private subnet"
  type        = string
}
variable "priv_rds_subnet_2" {
  description = "CIDR block for RDS's second private subnet"
  type        = string
}
variable "priv_rds_subnet_3" {
  description = "CIDR block for RDS's third private subnet"
  type        = string
}

variable "pub_lb_subnet_1" {
  description = "CIDR block for LB's first public subnet"
  type        = string
}
variable "pub_lb_subnet_2" {
  description = "CIDR block for LB's second public subnet"
  type        = string
}
variable "pub_lb_subnet_3" {
  description = "CIDR block for LB's third public subnet"
  type        = string
}

