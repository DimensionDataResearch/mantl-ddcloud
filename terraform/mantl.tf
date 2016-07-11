provider "ddcloud" {
    region = "AU"
}

# The target data centre in which Mantl will be deployed.
variable "datacenter" { default = "AU10" }

# A short name for the Mantl cluster. 
variable "cluster_short_name" { default = "mantl" }

# The top-level domain name to use.
variable "domain_name" { default = "tintoy-mantl.net" }

# The sub-domain name to use (services will appear as "*.subdomain_name.domain_name".
variable "subdomain_name" { default = "dev" }

# The AWS hosted zone Id associated with this domain.
variable "aws_hosted_zone_id" { default = "Z1JI3N3D48XF25" }

# The cluster VLAN's base IP address (without the trailing ".0").
variable "cluster_vlan_address_prefix" { default="192.168.17" }

# Control nodes.
variable "control_count" { default = 3 }
variable "control_cpu_count" { default = 8 }
variable "control_memory" { default = 2 }

# Edge (public-facing) nodes.
variable "edge_count" { default = 2 }
variable "edge_cpu_count" { default = 4 }
variable "edge_memory" { default = 6 }

# Worker nodes.
variable "worker_count" { default = 3 }
variable "worker_cpu_count" { default = 4 }
variable "worker_memory" { default = 8 }

# Kubernetes worker nodes.
variable "kubeworker_count" { default = 3 }
variable "kubeworker_cpu_count" { default = 4 }
variable "kubeworker_memory" { default = 8 }

/*******
 Network
 *******/

module "networkdomain" {
    source              = "./network/networkdomain"
    
    name                = "Mantl"
    description         = "Mantl"
    datacenter          = "${var.datacenter}"
}
module "vlan" {
    source              = "./network/vlan"

    name                = "Mantl primary VLAN"
    description         = "Primary VLAN for Mantl."
    base_address        = "${var.cluster_vlan_address_prefix}.0"
    prefix_size         = 24

    networkdomain       = "${module.networkdomain.id}"
}
module "dns" {
    source              = "./network/dns/aws"

    cluster_short_name  = "${var.cluster_short_name}"
    domain_name         = "${var.subdomain_name}.${var.domain_name}"
    hosted_zone_id      = "${var.aws_hosted_zone_id}"
    
    # TODO: Get IPs from deployed servers.

    control_count       = "${var.control_count}"
    control_ips         = "${var.cluster_vlan_address_prefix}.20,${var.cluster_vlan_address_prefix}.21,${var.cluster_vlan_address_prefix}.22"
    
    edge_count          = "${var.edge_count}"
    edge_ips            = "${var.cluster_vlan_address_prefix}.23,${var.cluster_vlan_address_prefix}.24"
    
    worker_count        = "${var.worker_count}"
    worker_ips          = "${var.cluster_vlan_address_prefix}.25,${var.cluster_vlan_address_prefix}.26,${var.cluster_vlan_address_prefix}.27"

    kubeworker_count    = "${var.kubeworker_count}"
    kubeworker_ips      = "${var.cluster_vlan_address_prefix}.28,${var.cluster_vlan_address_prefix}.29,${var.cluster_vlan_address_prefix}.30"
}

/*******
 Servers
 *******/

module "control-nodes" {
    source              = "./server/multi"
    count               = "${var.control_count}"

    role                = "control"
    name                = "${var.cluster_short_name}"
    description         = "Control node {} for ${var.cluster_short_name} cluster."
    admin_password      = "sn4u$$ag3s!"

    networkdomain       = "${module.networkdomain.id}"
    vlan                = "${module.vlan.id}"
}

/*************
 Final outputs
 *************/

output "control_node_dns" {
    value = "control.${var.subdomain_name}.${domain_name}" 
}
output "public_dns" {
    value = "*.${var.subdomain_name}.${domain_name}" 
}
