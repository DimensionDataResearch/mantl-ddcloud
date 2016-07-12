# Inputs
variable "count" {}
variable "role" {}
variable "name" {}
variable "description" {}
variable "auto_start" { default = false }
variable "networkdomain" {}
variable "vlan" {}
variable "data_disk_size" { default = 5 }
variable "ipv4_base" {}
variable "ipv4_start" {}
variable "admin_password" {
    sensitive = true
}

# Private
variable "count_format" { default = "%02d" }

# Resources
resource "ddcloud_server" "server" {
    count                    = "${var.count}"
    name                    = "${var.name}-${var.role}-${format(var.count_format, count.index + 1)}"
    description             = "${replace(var.description, "{}", count.index+1)}"
    admin_password          = "${var.admin_password}"
    auto_start              = "${var.auto_start}"

    memory_gb               = 8

    # Data disk
    additional_disk {
        scsi_unit_id        = 1
        size_gb             = "${data_disk_size}"
    }

    networkdomain           = "${var.networkdomain}"
    primary_adapter_vlan    = "${var.vlan}"
    primary_adapter_ipv4    = "${format("%s.%d", var.ipv4_base, var.ipv4_start + count.index)}"

    dns_primary             = "8.8.8.8"
    dns_secondary           = "8.8.4.4"

    osimage_name            = "CentOS 7 64-bit 2 CPU"
}

# Outputs
output "ids" {
    value       = "${join(",", ddcloud_server.server.*.id)}"
}
output "names" {
    value       = "${join(",", ddcloud_server.server.*.name)}"
}
output "ipv4s" {
    value       = "${join(",", ddcloud_server.server.*.primary_adapter_ipv4)}"
}
output "ipv6s" {
    value       = "${join(",", ddcloud_server.server.*.primary_adapter_ipv6)}"
}


