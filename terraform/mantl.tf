provider "ddcloud" {
    region = "AU"
}

# The target data centre in which Mantl will be deployed.
variable "datacenter" { default = "AU10" }

# The top-level domain name to use.
variable "domain_name" { default = "tintoy-mantl.net" }

# The sub-domain name to use (services will appear as "*.subdomain_name.domain_name".
variable "subdomain_name" { default = "dev" }

/*******
 Network
 *******/

module "networkdomain" {
    source      = "./network/networkdomain"
    
    name        = "Mantl"
    description = "Mantl"
    datacenter  = "${var.datacenter}"
}
module "vlan" {
    source        = "./network/vlan"

    name          = "Mantl primary VLAN"
    description   = "Primary VLAN for Mantl."
    base_address  = "192.168.17.0"
    prefix_size   = 24

    networkdomain = "${module.networkdomain.id}"
}

/*******
 Servers
 *******/

 # TODO: Servers.

/*************
 Final outputs
 *************/

output "control_node_dns" {
    value = "control.${var.subdomain_name}.${domain_name}" 
}
output "public_dns" {
    value = "*.${var.subdomain_name}.${domain_name}" 
}
