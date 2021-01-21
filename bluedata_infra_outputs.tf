output "project_dir" {
  value = abspath(path.module)
}

output "user" {
  value = var.user
}

output "aws_profile" {
  value = var.profile
}

output "aws_region" {
  value = var.region
}

output "subnet_cidr_block" {
  value = var.subnet_cidr_block
}

output "vpc_cidr_block" {
  value = var.vpc_cidr_block
}

output "deployment_uuid" {
  value = random_uuid.deployment_uuid.result
}

output "ssh_pub_key_path" {
  value = var.ssh_pub_key_path
}

output "ssh_prv_key_path" {
  value = var.ssh_prv_key_path
}

output "ca_cert" {
  value = var.ca_cert
}

output "ca_key" {
  value = var.ca_key
}

output "client_cidr_block" {
 value = var.client_cidr_block
}


//// MAPR Cluster 1

output "mapr_cluster_1_hosts_instance_id" {
  value = [aws_instance.mapr_cluster_1_hosts.*.id]
}
output "mapr_cluster_1_hosts_public_ip" {
  value = [aws_instance.mapr_cluster_1_hosts.*.public_ip]
}
output "mapr_cluster_1_hosts_public_dns" {
  value = [aws_instance.mapr_cluster_1_hosts.*.public_dns]
}
output "mapr_cluster_1_hosts_private_ip" {
  value = [aws_instance.mapr_cluster_1_hosts.*.private_ip]
}
output "mapr_cluster_1_hosts_private_ip_flat" {
  value = join("\n", aws_instance.mapr_cluster_1_hosts.*.private_ip)
}
output "mapr_cluster_1_hosts_public_ip_flat" {
  value = join("\n", aws_instance.mapr_cluster_1_hosts.*.public_ip)
}
output "mapr_cluster_1_hosts_private_dns" {
  value = [aws_instance.mapr_cluster_1_hosts.*.private_dns]
}
output "mapr_cluster_1_count" {
  value = [var.mapr_cluster_1_count]
}
output "mapr_cluster_1_name" {
  value = [var.mapr_cluster_1_name]
}

/// MAPR Cluster 2

output "mapr_cluster_2_hosts_instance_id" {
  value = [aws_instance.mapr_cluster_2_hosts.*.id]
}
output "mapr_cluster_2_hosts_public_ip" {
  value = [aws_instance.mapr_cluster_2_hosts.*.public_ip]
}
output "mapr_cluster_2_hosts_public_dns" {
  value = [aws_instance.mapr_cluster_2_hosts.*.public_dns]
}
output "mapr_cluster_2_hosts_private_ip" {
  value = [aws_instance.mapr_cluster_2_hosts.*.private_ip]
}
output "mapr_cluster_2_hosts_private_ip_flat" {
  value = join("\n", aws_instance.mapr_cluster_2_hosts.*.private_ip)
}
output "mapr_cluster_2_hosts_public_ip_flat" {
  value = join("\n", aws_instance.mapr_cluster_2_hosts.*.public_ip)
}
output "mapr_cluster_2_hosts_private_dns" {
  value = [aws_instance.mapr_cluster_2_hosts.*.private_dns]
}
output "mapr_cluster_2_count" {
  value = [var.mapr_cluster_2_count]
}
output "mapr_cluster_2_name" {
  value = [var.mapr_cluster_2_name]
}

// AD Server Output

output "ad_server_instance_id" {
  value = module.ad_server.instance_id
}

output "ad_server_private_ip" {
  value = module.ad_server.private_ip
}

output "ad_server_public_ip" {
  value = module.ad_server.public_ip
}

output "ad_server_ssh_command" {
  value = module.ad_server.ssh_command
}

output "ad_server_enabled" {
  value = var.ad_server_enabled
}
