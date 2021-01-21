// Usage: terraform <action> -var-file="etc/bluedata_infra.tfvars"

provider "aws" {
  profile = var.profile
  region  = var.region
}

data "aws_availability_zone" "main" {
  name = var.az
}

resource "aws_key_pair" "main" {
  key_name   = "${var.project_id}-keypair"
  public_key = file("${path.module}/generated/controller.pub_key")
}

resource "random_uuid" "deployment_uuid" {}

/******************* modules ********************/

// random_uuid.deployment_uuid.result

/******************* modules ********************/

module "network" {
  source                    = "./modules/module-network"
  project_id                = var.project_id
  user                      = var.user
  deployment_uuid           = random_uuid.deployment_uuid.result
  client_cidr_block         = var.client_cidr_block
  additional_client_ip_list = var.additional_client_ip_list
  subnet_cidr_block         = var.subnet_cidr_block
  vpc_cidr_block            = var.vpc_cidr_block
  aws_zone_id               = data.aws_availability_zone.main.zone_id
  dns_zone_name             = var.dns_zone_name
  ad_server_enabled         = var.ad_server_enabled
  ad_private_ip             = module.ad_server.private_ip
}

module "ad_server" {
  source            = "./modules/module-ad-server"
  project_id        = var.project_id
  user              = var.user
  deployment_uuid   = random_uuid.deployment_uuid.result
  ssh_prv_key_path  = "${path.module}/generated/controller.prv_key"
  ad_ec2_ami        = var.EC2_CENTOS7_AMIS[var.region]
  ad_instance_type  = var.ad_instance_type
  ad_server_enabled = var.ad_server_enabled
  key_name          = aws_key_pair.main.key_name
  vpc_security_group_ids = [
    module.network.security_group_allow_all_from_client_ip,
    module.network.security_group_main_id
  ]
  subnet_id = module.network.subnet_main_id
}
