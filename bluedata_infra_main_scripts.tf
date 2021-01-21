
resource "local_file" "ca-cert" {
  filename = "${path.module}/generated/ca-cert.pem"
  content =  var.ca_cert
}

resource "local_file" "ca-key" {
  filename = "${path.module}/generated/ca-key.pem"
  content =  var.ca_key
}


//////////////////// Utility scripts  /////////////////////

/// instance start/stop/status

locals {
  instance_id_ad          = module.ad_server.instance_id != null ? module.ad_server.instance_id : ""
  instance_id_mapr_cls_1  = join(" ", aws_instance.mapr_cluster_1_hosts.*.id)
  instance_id_mapr_cls_2  = join(" ", aws_instance.mapr_cluster_2_hosts.*.id)
  instance_ids = join(" ", [
    local.instance_id_ad,
    local.instance_id_mapr_cls_1,
    local.instance_id_mapr_cls_2
   ])
}

resource "local_file" "cli_stop_ec2_instances" {
  filename = "${path.module}/generated/cli_stop_ec2_instances.sh"
  content =  <<-EOF
    #!/bin/bash
    echo "Deprecated.  Please use ./bin/ec2_stop_all_instances.sh"
  EOF
}

resource "local_file" "ssh_ad" {
  filename = "${path.module}/generated/ssh_ad.sh"
  content = <<-EOF
     #!/bin/bash
     source "${path.module}/scripts/variables.sh"
     ssh -o StrictHostKeyChecking=no -i "${var.ssh_prv_key_path}" centos@$AD_PUB_IP "$@"
  EOF
}

resource "local_file" "ssh_mapr_cluster_1_host" {
  count = var.mapr_cluster_1_count

  filename = "${path.module}/generated/ssh_mapr_cluster_1_host_${count.index}.sh"
  content = <<-EOF
     #!/bin/bash
     source "${path.module}/scripts/variables.sh"
     ssh -o StrictHostKeyChecking=no -i "${var.ssh_prv_key_path}" ubuntu@$${MAPR_CLUSTER1_HOSTS_PUB_IPS[${count.index}]} "$@"
  EOF
}

resource "local_file" "ssh_mapr_cluster_2_host" {
  count = var.mapr_cluster_2_count

  filename = "${path.module}/generated/ssh_mapr_cluster_2_host_${count.index}.sh"
  content = <<-EOF
     #!/bin/bash
     source "${path.module}/scripts/variables.sh"
     ssh -o StrictHostKeyChecking=no -i "${var.ssh_prv_key_path}" ubuntu@$${MAPR_CLUSTER2_HOSTS_PUB_IPS[${count.index}]} "$@"
  EOF
}

