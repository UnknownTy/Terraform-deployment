variable "private_subnets" {
    description = "Private subnet for the app instances"
    type = list
}
variable "private_sg" {
    description = "Security group to connect to"
    type = string
}
variable "target_arn" {
    description = "ARN for the LB's target group"
    type = string
}
variable "instance_profile_arn" {
    description = "Cloudwatch & S3 Profile ARN"
    type = string
}

variable "DBip" {
    description = "Address of the mysql database"
    type = string
}
variable "DBUsername" {
    description = "Database connection Username"
    type = string
}
variable "DBPassword" {
    description = "Database connection Password"
    type = string
}
variable "DBName" {
    description = "Database's name"
    type = string
}
variable "S3_name" {
    description = "S3 Bucket's name"
}
variable "region" {
    description = "Region to be used by all EC2 Instances"
}