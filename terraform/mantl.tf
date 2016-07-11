provider "ddcloud" {
    region = "AU"
}

# The top-level domain name to use.
variable "domain_name" { default = "tintoy-mantl.net" }

# The sub-domain name to use (services will appear as "*.subdomain_name.domain_name".
variable "subdomain_name" { default = "dev" }

# TODO: Add other top-level variables.

# TODO: Create modules for infrastructure required by Mantl.
module "control_node" {
    source = "./control_node"
    servers = 3
}

module "worker_node" {
    source = "./worker_node"
    servers = 3
}

module "edge_node" {
    source = "./edge_node"
    servers = 2
}
