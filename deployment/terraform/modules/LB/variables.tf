variable "public_sg_id" {
  description = "Load balancer's public security group"
  type        = string
}
variable "public_subnets" {
  description = "Load balancer's public subnets"
  type        = list(any)
}
variable "vpc_id" {
  description = "VPC of the entire application"
  type        = string
}
variable "cert_arn" {
  description = "SSL Certificate validation ARN"
  type        = string
}
// variable "instance_ids" {
//     description = "Instances for the LB to direct to"
//     type = list
// }