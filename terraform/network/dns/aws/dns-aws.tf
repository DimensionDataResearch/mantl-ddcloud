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

# The private IPv4 addresses for all the control nodes in the Mantl cluster.
variable "control_ips" {}

# The public IPv4 addresses for all the control nodes in the Mantl cluster.
variable "control_public_ips" {}

# The number of edge (externally-facing) nodes in the Mantl cluster.
variable "edge_count" {}

# The IPv4 addresses for all the edge nodes in the Mantl cluster.
variable "edge_ips" {}

# The public IPv4 addresses for the edge servers (will be aggregated under a single wildcard record).
variable "edge_public_ips" {}

# The number of worker nodes in the Mantl cluster.
variable "worker_count" {}

# The IPv4 addresses for all the worker nodes in the Mantl cluster.
variable "worker_ips" {}

# The public IPv4 addresses for the worker servers.
variable "worker_public_ips" {}

# The number of Kubernetes worker nodes in the Mantl cluster.
variable "kubeworker_count" {}

# The IPv4 addresses for all the Kubernetes worker nodes in the Mantl cluster.
variable "kubeworker_ips" {}

# The public IPv4 addresses for the Kubernetes worker servers.
variable "kubeworker_public_ips" {}

# Control nodes.
resource "aws_route53_record" "dns-control-node" {
    type    = "A"
    ttl     = 60
    zone_id = "${var.hosted_zone_id}"

    name    = "${var.cluster_short_name}-control-${format("%02d", count.index+1)}.node.${var.domain_name}"
    records = ["${element(split(",", var.control_ips), count.index)}"]
    
    count   = "${var.control_count}"
}
resource "aws_route53_record" "dns-control-public" {
    type    = "A"
    ttl     = 60
    zone_id = "${var.hosted_zone_id}"

    name    = "${var.cluster_short_name}-control-${format("%02d", count.index+1)}.public.${var.domain_name}"
    records = ["${element(split(",", var.control_public_ips), count.index)}"]
    
    count   = "${var.control_count}"
}

# Control nodes (group).
resource "aws_route53_record" "dns-control" {
    type    = "A"
    ttl     = 60
    zone_id = "${var.hosted_zone_id}"

    name    = "control.${var.domain_name}"
    records = ["${split(",", var.control_public_ips)}"]
}

# Edge (externally-facing) nodes.
resource "aws_route53_record" "dns-edge-node" {
    type    = "A"
    ttl     = 60
    zone_id = "${var.hosted_zone_id}"

    name    = "${var.cluster_short_name}-edge-${format("%02d", count.index+1)}.node.${var.domain_name}"
    records = ["${element(split(",", var.edge_ips), count.index)}"]
    
    count   = "${var.edge_count}"
}
resource "aws_route53_record" "dns-edge-public" {
    type    = "A"
    ttl     = 60
    zone_id = "${var.hosted_zone_id}"

    name    = "${var.cluster_short_name}-edge-${format("%02d", count.index+1)}.public.${var.domain_name}"
    records = ["${element(split(",", var.edge_public_ips), count.index)}"]
    
    count   = "${var.edge_count}"
}

# Edge nodes wildcard (group).
resource "aws_route53_record" "dns-edge-wildcard" {
    type    = "A"
    ttl     = 60
    zone_id = "${var.hosted_zone_id}"

    name    = "*.${var.domain_name}"
    records = ["${split(",", var.edge_public_ips)}"] # TODO: Consider changing this to use a CloudControl VIP.
}

# Worker nodes.
resource "aws_route53_record" "dns-worker-node" {
    type    = "A"
    ttl     = 60
    zone_id = "${var.hosted_zone_id}"

    name    = "${var.cluster_short_name}-worker-${format("%02d", count.index+1)}.node.${var.domain_name}"
    records = ["${element(split(",", var.worker_ips), count.index)}"]
    
    count   = "${var.worker_count}"
}
resource "aws_route53_record" "dns-worker-public" {
    type    = "A"
    ttl     = 60
    zone_id = "${var.hosted_zone_id}"

    name    = "${var.cluster_short_name}-worker-${format("%02d", count.index+1)}.public.${var.domain_name}"
    records = ["${element(split(",", var.worker_public_ips), count.index)}"]
    
    count   = "${var.worker_count}"
}

# Kubernetes worker nodes.
resource "aws_route53_record" "dns-kubeworker-node" {
    type    = "A"
    ttl     = 60
    zone_id = "${var.hosted_zone_id}"

    name    = "${var.cluster_short_name}-kubeworker-${format("%02d", count.index+1)}.node.${var.domain_name}"
    records = ["${element(split(",", var.kubeworker_ips), count.index)}"]
    
    count   = "${var.kubeworker_count}"
}
resource "aws_route53_record" "dns-kubeworker-public" {
    type    = "A"
    ttl     = 60
    zone_id = "${var.hosted_zone_id}"

    name    = "${var.cluster_short_name}-kubeworker-${format("%02d", count.index+1)}.public.${var.domain_name}"
    records = ["${element(split(",", var.kubeworker_public_ips), count.index)}"]
    
    count   = "${var.kubeworker_count}"
}

#########
# Outputs
#########

output "control_group_fqdn" {
    value = "${aws_route53_record.dns-control.fqdn}"
}

output "control_node_fqdns" {
    value = "${join(\",\", aws_route53_record.dns-control-node.*.fqdn)}"
}
output "control_public_fqdns" {
    value = "${join(\",\", aws_route53_record.dns-control-public.*.fqdn)}"
}

output "edge_node_fqdns" {
    value = "${join(\",\", aws_route53_record.dns-edge-node.*.fqdn)}"
}
output "edge_public_fqdns" {
    value = "${join(\",\", aws_route53_record.dns-edge-public.*.fqdn)}"
}

output "worker_node_fqdns" {
    value = "${join(\",\", aws_route53_record.dns-worker-node.*.fqdn)}"
}
output "worker_public_fqdns" {
    value = "${join(\",\", aws_route53_record.dns-worker-public.*.fqdn)}"
}

output "kubeworker_node_fqdns" {
    value = "${join(\",\", aws_route53_record.dns-kubeworker-node.*.fqdn)}"
}
output "kubeworker_public_fqdns" {
    value = "${join(\",\", aws_route53_record.dns-kubeworker-public.*.fqdn)}"
}
