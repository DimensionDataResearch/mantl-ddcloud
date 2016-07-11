########
# Inputs
########

# The short name of the Mantl cluster. 
variable "cluster_short_name" {}

# The target domain name. 
variable "domain_name" {}

# The target AWS hosted zone Id. 
variable "hosted_zone_id" {}

# The number of control nodes in the Mantl cluster.
variable "control_count" {}

# The IPv4 addresses for all the control nodes in the Mantl cluster.
variable "control_ips" {}

# The number of edge (externally-facing) nodes in the Mantl cluster.
variable "edge_count" {}

# The IPv4 addresses for all the edge nodes in the Mantl cluster.
variable "edge_ips" {}

# The number of worker nodes in the Mantl cluster.
variable "worker_count" {}

# The IPv4 addresses for all the worker nodes in the Mantl cluster.
variable "worker_ips" {}

# The number of Kubernetes worker nodes in the Mantl cluster.
variable "kubeworker_count" {}

# The IPv4 addresses for all the Kubernetes worker nodes in the Mantl cluster.
variable "kubeworker_ips" {}

# Control nodes.
resource "aws_route53_record" "dns-control" {
    type    = "A"
    ttl     = 60
    zone_id = "${var.hosted_zone_id}"

    name    = "${var.cluster_short_name}-control-${format("%02d", count.index+1)}.node.${var.domain_name}"
    records = ["${element(split(",", var.control_ips), count.index)}"]
    
    count   = "${var.control_count}"
}

# Control nodes (group).
resource "aws_route53_record" "dns-control-group" {
    type    = "A"
    ttl     = 60
    zone_id = "${var.hosted_zone_id}"

    name    = "control.${var.domain_name}"
    records = ["${element(split(",", var.control_ips), count.index)}"]
    
    count   = "${var.control_count}"
}

# Edge (externally-facing) nodes.
resource "aws_route53_record" "dns-edge" {
    type    = "A"
    ttl     = 60
    zone_id = "${var.hosted_zone_id}"

    name    = "${var.cluster_short_name}-edge-${format("%02d", count.index+1)}.node.${var.domain_name}"
    records = ["${element(split(",", var.edge_ips), count.index)}"]
    
    count   = "${var.edge_count}"
}

# Worker nodes.
resource "aws_route53_record" "dns-worker" {
    type    = "A"
    ttl     = 60
    zone_id = "${var.hosted_zone_id}"

    name    = "${var.cluster_short_name}-worker-${format("%02d", count.index+1)}.node.${var.domain_name}"
    records = ["${element(split(",", var.worker_ips), count.index)}"]
    
    count   = "${var.worker_count}"
}

# Kubernetes worker nodes.
resource "aws_route53_record" "dns-kubeworker" {
    type    = "A"
    ttl     = 60
    zone_id = "${var.hosted_zone_id}"

    name    = "${var.cluster_short_name}-kubeworker-${format("%02d", count.index+1)}.node.${var.domain_name}"
    records = ["${element(split(",", var.kubeworker_ips), count.index)}"]
    
    count   = "${var.kubeworker_count}"
}

#########
# Outputs
#########

output "control_group_fqdn" {
    value = "${aws_route53_record.dns-control-group.fqdn}"
}

output "control_fqdns" {
    value = "${join(\",\", aws_route53_record.dns-control.*.fqdn)}"
}

output "edge_fqdns" {
    value = "${join(\",\", aws_route53_record.dns-edge.*.fqdn)}"
}

output "worker_fqdns" {
    value = "${join(\",\", aws_route53_record.dns-worker.*.fqdn)}"
}
