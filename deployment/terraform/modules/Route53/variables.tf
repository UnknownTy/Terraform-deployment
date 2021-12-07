variable "lb_ip" {
    description = "The IP address of the load balancer"
    type = string
}
variable "lb_zone_id" {
    description = "Load balancer's zone ID"
    type = string
}
variable "domain_name" {
    description = "Domain name to be used for deployment"
    type = string
}