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
output "name" {
    value       = "${ddcloud_vlan.vlan.name}"
}
output "ipv4_base_address" {
    value       = "${ddcloud_vlan.vlan.ipv4_base_address}"
}
output "ipv4_prefix_size" {
    value       = "${ddcloud_vlan.vlan.ipv4_prefix_size}"
}
