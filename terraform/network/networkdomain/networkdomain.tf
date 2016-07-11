# Inputs
variable "name" {}
variable "description" {}
variable "datacenter" {}

# This is the network domain that will contain the Mantl cluster.
resource "ddcloud_networkdomain" "networkdomain" {
    name        = "${var.name}"
    description = "${var.description}"
    datacenter  = "${var.datacenter}"

    # Change this to "advanced" if VIP / load-balancer support is required.
    plan        = "ESSENTIALS" 
}

# Outputs
output "id" {
    value       = "${ddcloud_networkdomain.networkdomain.id}"
}
