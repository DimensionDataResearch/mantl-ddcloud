# Inputs
variable "control_count" {}
variable "control_private_ipv4s" {}
variable "edge_count" {}
variable "edge_private_ipv4s" {}
variable "edge_insecure" { default = false }
variable "worker_count" {}
variable "worker_private_ipv4s" {}
variable "kubeworker_count" {}
variable "kubeworker_private_ipv4s" {}
variable "networkdomain" {}

# Allow SSH for all machines
resource "ddcloud_firewall_rule" "all-nodes-ssh4-in" {
	name 					= "ssh4.inbound"
	placement				= "first"
	action					= "accept" # Valid values are "accept" or "drop."
	enabled					= true
	
	ip_version				= "ipv4"
	protocol				= "tcp"

	destination_port 		= "22"

	networkdomain 			= "${var.networkdomain}"
}

# Control nodes
resource "ddcloud_nat" "control-node-public-ip" {
    count           = "${var.control_count}"

    private_ipv4    = "${element(split(",", var.control_private_ipv4s), count.index)}"
    networkdomain   = "${var.networkdomain}"
}
resource "ddcloud_firewall_rule" "control-node-https4-in" {
    count                   = "${var.control_count}"
	name 					= "control${count.index}.httsp4.inbound"
	placement				= "first"
	action					= "accept" # Valid values are "accept" or "drop."
	enabled					= true
	
	ip_version				= "ipv4"
	protocol				= "tcp"

	destination_address		= "${element(ddcloud_nat.control-node-public-ip.*.public_ipv4, count.index)}"
	destination_port 		= "80"

	networkdomain 			= "${var.networkdomain}"
}

# Edge nodes
resource "ddcloud_nat" "edge-node-public-ip" {
    count           = "${var.edge_count}"

    private_ipv4    = "${element(split(",", var.edge_private_ipv4s), count.index)}"
    networkdomain   = "${var.networkdomain}"
}
resource "ddcloud_firewall_rule" "edge-node-https4-in" {
    count                   = "${var.edge_count}"
	name 					= "edge${count.index}.https4.inbound"
	placement				= "first"
	action					= "accept" # Valid values are "accept" or "drop."
	enabled					= true
	
	ip_version				= "ipv4"
	protocol				= "tcp"

	destination_address		= "${element(ddcloud_nat.edge-node-public-ip.*.public_ipv4, count.index)}"
	destination_port 		= "80"

	networkdomain 			= "${var.networkdomain}"
}
resource "ddcloud_firewall_rule" "edge-node-http4-in" {
    count                   = "${var.edge_count}"
	name 					= "edge${count.index}.http4.inbound"
	placement				= "first"
	action					= "accept" # Valid values are "accept" or "drop."
	enabled					= "${var.edge_insecure}"
	
	ip_version				= "ipv4"
	protocol				= "tcp"

	destination_address		= "${element(ddcloud_nat.edge-node-public-ip.*.public_ipv4, count.index)}"
	destination_port 		= "80"

	networkdomain 			= "${var.networkdomain}"
}


# Worker nodes
resource "ddcloud_nat" "worker-node-public-ip" {
    count           = "${var.worker_count}"

    private_ipv4    = "${element(split(",", var.worker_private_ipv4s), count.index)}"
    networkdomain   = "${var.networkdomain}"
}

# Kubernetes worker nodes
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