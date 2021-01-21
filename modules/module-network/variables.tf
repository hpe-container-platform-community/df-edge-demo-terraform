variable "project_id" { 
    type = string
}
variable "user" {
    type = string
}
variable "aws_zone_id" {
    type = string
}
variable "client_cidr_block" {
    type = string
}
variable "additional_client_ip_list" {
    type = list
}
variable "vpc_cidr_block" {
    type = string
}
variable "subnet_cidr_block" {
    type = string
}
variable "dns_zone_name" {
    type = string
}
variable "ad_server_enabled" {
    type = bool
}
variable "ad_private_ip" {
    type = string
}
variable "deployment_uuid" { 
    type = string
}
