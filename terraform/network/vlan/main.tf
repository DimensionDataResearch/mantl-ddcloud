# Inputs
variable "name" {}
variable "description" {}
variable "networkdomain" {}
variable "base_address" {}
variable "prefix_size" {}

resource "ddcloud_vlan" "vlan" {
    name              = "${var.name}"
    description       = "${var.description}"
    networkdomain     = "${var.networkdomain}"
    ipv4_base_address = "${var.base_address}"
	ipv4_prefix_size  = "${var.prefix_size}"
}

# Outputs
output "id" {
    value       = "${ddcloud_vlan.vlan.id}"
}
output "id" {
    value       = "${ddcloud_vlan.vlan.id}"
}
