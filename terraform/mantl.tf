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
variable "cluster_vlan_address_base" { default = "192.168.17" }

# The last quad of the first IP address used by the cluster (i.e. without cluster_vlan_address_base).
variable "cluster_vlan_address_start" { default = 20 }

# Automatically start servers after they are deployed?
variable "server_auto_start" { default = false }

# Control nodes.
variable "control_count" { default = 3 }
variable "control_cpu_count" { default = 2 }
variable "control_memory" { default = 8 }
variable "control_address_start" { default = 0 }        # Added to cluster_vlan_address_start

# Edge (public-facing) nodes.
variable "edge_count" { default = 2 }
variable "edge_cpu_count" { default = 2 }
variable "edge_memory" { default = 6 }
variable "edge_address_start" { default = 5 }

# Worker nodes.
variable "worker_count" { default = 4 }
variable "worker_cpu_count" { default = 2 }
variable "worker_memory" { default = 8 }
variable "worker_address_start" { default = 10 }        # Added to cluster_vlan_address_start

# Kubernetes worker nodes.
variable "kubeworker_count" { default = 2 }
variable "kubeworker_cpu_count" { default = 2 }
variable "kubeworker_memory" { default = 8 }
variable "kubeworker_address_start" { default = 15 }    # Added to cluster_vlan_address_start

#########
# Network
#########

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
    base_address        = "${var.cluster_vlan_address_base}.0"
    prefix_size         = 24

    networkdomain       = "${module.networkdomain.id}"
}
module "dns" {
    source              = "./network/dns/aws"

    cluster_short_name  = "${var.cluster_short_name}"
    domain_name         = "${var.subdomain_name}.${var.domain_name}"
    hosted_zone_id      = "${var.aws_hosted_zone_id}"

    control_count       = "${var.control_count}"
    control_ips         = "${module.control-nodes.ipv4s}"
    
    edge_count          = "${var.edge_count}"
    edge_ips            = "${module.edge-nodes.ipv4s}"
    
    worker_count        = "${var.worker_count}"
    worker_ips          = "${module.worker-nodes.ipv4s}"

    kubeworker_count    = "${var.kubeworker_count}"
    kubeworker_ips      = "${module.kubeworker-nodes.ipv4s}"
}

#########
# Servers
#########

module "control-nodes" {
    source              = "./server/multi"
    count               = "${var.control_count}"

    role                = "control"
    name                = "${var.cluster_short_name}"
    description         = "Control node {} for ${var.cluster_short_name} cluster."
    admin_password      = "sn4u$$ag3s!"
    auto_start          = "${var.server_auto_start}"

    networkdomain       = "${module.networkdomain.id}"
    vlan                = "${module.vlan.id}"
    ipv4_base           = "${var.cluster_vlan_address_base}"
    ipv4_start          = "${var.cluster_vlan_address_start + var.control_address_start}"
}
module "edge-nodes" {
    source              = "./server/multi"
    count               = "${var.edge_count}"

    role                = "edge"
    name                = "${var.cluster_short_name}"
    description         = "Edge node {} for ${var.cluster_short_name} cluster."
    admin_password      = "sn4u$$ag3s!"
    auto_start          = "${var.server_auto_start}"

    networkdomain       = "${module.networkdomain.id}"
    vlan                = "${module.vlan.id}"
    ipv4_base           = "${var.cluster_vlan_address_base}"
    ipv4_start          = "${var.cluster_vlan_address_start + var.edge_address_start}"
}
module "worker-nodes" {
    source              = "./server/multi"
    count               = "${var.worker_count}"

    role                = "worker"
    name                = "${var.cluster_short_name}"
    description         = "Worker node {} for ${var.cluster_short_name} cluster."
    admin_password      = "sn4u$$ag3s!"
    auto_start          = "${var.server_auto_start}"

    networkdomain       = "${module.networkdomain.id}"
    vlan                = "${module.vlan.id}"
    ipv4_base           = "${var.cluster_vlan_address_base}"
    ipv4_start          = "${var.cluster_vlan_address_start + var.worker_address_start}"
}
module "kubeworker-nodes" {
    source              = "./server/multi"
    count               = "${var.kubeworker_count}"

    role                = "kubeworker"
    name                = "${var.cluster_short_name}"
    description         = "Kubernetes worker node {} for ${var.cluster_short_name} cluster."
    admin_password      = "sn4u$$ag3s!"
    auto_start          = "${var.server_auto_start}"

    networkdomain       = "${module.networkdomain.id}"
    vlan                = "${module.vlan.id}"
    ipv4_base           = "${var.cluster_vlan_address_base}"
    ipv4_start          = "${var.cluster_vlan_address_start + var.kubeworker_address_start}"
}

###############
# Final outputs
###############

output "fqdn_control" {
    value = "control.${var.subdomain_name}.${var.domain_name}" 
}
output "fqdn_wildcard" {
    value = "*.${var.subdomain_name}.${var.domain_name}" 
}
output "ipv4_control_nodes" {
    value = "${module.control-nodes.ipv4s}"
}
output "ipv4_edge_nodes" {
    value = "${module.edge-nodes.ipv4s}"
}
output "ipv4_worker_nodes" {
    value = "${module.worker-nodes.ipv4s}"
}
output "ipv4_kubeworker_nodes" {
    value = "${module.kubeworker-nodes.ipv4s}"
}
