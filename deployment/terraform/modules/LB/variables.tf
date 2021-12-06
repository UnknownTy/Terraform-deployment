variable "public_sg_id" {
    description = "Load balancer's public security group"
    type = string
}
variable "public_subnets" {
    description = "Load balancer's public subnets"
    type = list
}
variable "vpc_id" {
    description = "VPC of the entire application"
    type = string
}
// variable "instance_ids" {
//     description = "Instances for the LB to direct to"
//     type = list
// }