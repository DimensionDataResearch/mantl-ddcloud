# Inputs
variable "name" {}
variable "description" {}
variable "networkdomain" {}
variable "vlan" {}
variable "admin_password" {
    sensitive = true
}

# Resources
resource "ddcloud_server" "server" {
    name					= "${var.name}"
	description 			= "${var.description}"
	admin_password			= "${var.admin_password}"

	memory_gb				= 8

	networkdomain           = "${var.networkdomain}"
	primary_adapter_vlan    = "${var.vlan}" # Will use first available IPv4 address on this VLAN.

	dns_primary				= "8.8.8.8"
	dns_secondary			= "8.8.4.4"

	osimage_name			= "CentOS 7 64-bit 2 CPU"
}

# Outputs
output "id" {
    value       = "${ddcloud_server.server.id}"
}
output "name" {
    value       = "${ddcloud_server.server.name}"
}
output "ipv4" {
    value       = "${ddcloud_server.server.primary_adapter_ipv4}"
}
output "ipv6" {
    value       = "${ddcloud_server.server.primary_adapter_ipv6}"
}
