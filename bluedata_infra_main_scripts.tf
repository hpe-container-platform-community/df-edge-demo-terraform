
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

