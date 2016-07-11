# Inputs
variable "role" {}
variable "name" {}
variable "description" {}
variable "auto_start" { default = false }
variable "networkdomain" {}
variable "vlan" {}
variable "ipv4_address" { default = "" }
variable "admin_password" {
    sensitive = true
}

# Resources
resource "ddcloud_server" "server" {
    name                    = "${var.name}-${var.role}"
    description             = "${var.description}"
    admin_password          = "${var.admin_password}"
    auto_start              = "${var.auto_start}"

    memory_gb               = 8

    networkdomain           = "${var.networkdomain}"
    primary_adapter_vlan    = "${var.vlan}"
    primary_adapter_ipv4    = "${var.ipv4_address}"

    dns_primary             = "8.8.8.8"
    dns_secondary           = "8.8.4.4"

    osimage_name            = "CentOS 7 64-bit 2 CPU"
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
