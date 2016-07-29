# Inputs
variable "count" {}
variable "role" {}
variable "consul_dc" {}
variable "name" {}
variable "description" {}
variable "auto_start" { default = false }
variable "memory_gb" { default = 8 }
variable "cpu_count" { default = 2 }
variable "os_disk_size_gb" { default = 15 }
variable "data_disk_size_gb" { default = 10 }
variable "docker_disk_size_gb" { default = 10 }
variable "networkdomain" {}
variable "vlan" {}
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

    memory_gb               = "${var.memory_gb}"
    cpu_count               = "${var.cpu_count}"

    # OS disk (/dev/sda) - expand to ${var.os_disk_size_gb}.
    disk {
        scsi_unit_id      = 0
        size_gb           = "${var.os_disk_size_gb}"
        speed             = "STANDARD"
    }

    # Data disk (/dev/sdb)
    disk {
        scsi_unit_id        = 1
        size_gb             = "${var.data_disk_size_gb}"
        speed               = "STANDARD"
    }

    # Docker disk (/dev/sdc)
    disk {
        scsi_unit_id        = 2
        size_gb             = "${var.docker_disk_size_gb}"
        speed               = "STANDARD"
    }

    networkdomain           = "${var.networkdomain}"
    primary_adapter_vlan    = "${var.vlan}"
    primary_adapter_ipv4    = "${format("%s.%d", var.ipv4_base, var.ipv4_start + count.index)}"

    dns_primary             = "8.8.8.8"
    dns_secondary           = "8.8.4.4"

    osimage_name            = "CentOS 7 64-bit 2 CPU"

    tag {
        name  = "role"
        value = "${var.role}"
    }
    tag {
        name  = "consul_dc"
        value = "${var.consul_dc}"
    }
}

# Outputs
output "role" {
    value       = "${var.role}"
}
output "consul_dc" {
    value       = "${var.consul_dc}"
}
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
