# Inputs
variable "control_count" {}
variable "control_private_ipv4s" {}
variable "edge_count" {}
variable "edge_private_ipv4s" {}
variable "worker_count" {}
variable "worker_private_ipv4s" {}
variable "kubeworker_count" {}
variable "kubeworker_private_ipv4s" {}
variable "networkdomain" {}

resource "ddcloud_nat" "control-node-public-ip" {
    count           = "${var.control_count}"

    private_ipv4    = "${element(split(",", var.control_private_ipv4s), count.index)}"
    networkdomain   = "${var.networkdomain}"
}

resource "ddcloud_nat" "edge-node-public-ip" {
    count           = "${var.edge_count}"

    private_ipv4    = "${element(split(",", var.edge_private_ipv4s), count.index)}"
    networkdomain   = "${var.networkdomain}"
}

resource "ddcloud_nat" "worker-node-public-ip" {
    count           = "${var.worker_count}"

    private_ipv4    = "${element(split(",", var.worker_private_ipv4s), count.index)}"
    networkdomain   = "${var.networkdomain}"
}

resource "ddcloud_nat" "kubeworker-node-public-ip" {
    count           = "${var.kubeworker_count}"

    private_ipv4    = "${element(split(",", var.kubeworker_private_ipv4s), count.index)}"
    networkdomain   = "${var.networkdomain}"
}

# Outputs
output "control_public_ipv4s" {
    value = "${join(",", ddcloud_nat.control-node-public-ip.*.public_ipv4)}"
}
output "edge_public_ipv4s" {
    value = "${join(",", ddcloud_nat.edge-node-public-ip.*.public_ipv4)}"
}
output "worker_public_ipv4s" {
    value = "${join(",", ddcloud_nat.worker-node-public-ip.*.public_ipv4)}"
}
output "kubeworker_public_ipv4s" {
    value = "${join(",", ddcloud_nat.kubeworker-node-public-ip.*.public_ipv4)}"
}