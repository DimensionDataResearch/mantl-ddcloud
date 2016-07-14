#!/usr/bin/env python3

import json
import os


def load_json(filename):
    with open(filename, 'r') as json_file:
        return json.load(json_file)


def get_modules(state):
    modules = {}

    for module in state['modules']:
        if 'resources' not in module:
            continue

        name = module['path'][-1]
        module['name'] = name

        modules[name] = module

    return modules


def get_resources(module, resource_type):
    resources = module['resources']

    for resource_name in resources:
        resource = resources[resource_name]
        if resource['type'] == resource_type:
            yield resource

def get_nat_map(modules):
    return {
        resource['primary']['attributes']['private_ipv4']: resource['primary']['attributes']['public_ipv4']
        for resource in get_resources(modules['public-ips'], 'ddcloud_nat')
    }

def get_outputs(module):
    raw_outputs = module['outputs']

    return {
        key: raw_outputs[key]['value'] for key in raw_outputs.keys()
    }

all_modules = get_modules(
    load_json("./terraform/terraform.tfstate")
)
nat_map = get_nat_map(all_modules)
module_outputs = {
    module_name: get_outputs(all_modules[module_name]) for module_name in all_modules
}

all_server_names = set()
for module_name in sorted(module_outputs.keys()):
    module_output = module_outputs[module_name]

    try:
        role_name = module_output['role']
    except KeyError:
        continue

    print("[role={}]".format(role_name))

    names = module_output['names'].split(',')
    private_ipv4s = module_output['ipv4s'].split(',')
    public_ipv4s = [
        nat_map[private_ipv4] for private_ipv4 in private_ipv4s
    ]

    for host_index in range(len(names)):
        all_server_names.add(names[host_index])

        print("{name} private_ipv4={private_ipv4} public_ipv4={public_ipv4} ansible_ssh_host={public_ipv4}".format(
            name=names[host_index],
            private_ipv4=private_ipv4s[host_index],
            public_ipv4=nat_map[private_ipv4s[host_index]]
        ))

    print()
    print("[role={}:vars]".format(role_name))
    if role_name == "control":
        print("consul_is_server=true")
    else:
        print("consul_is_server=false")
    print("docker_lvm_backed=true")
    print('docker_lvm_data_volume_size="80%FREE"')
    print("lvm_physical_device=/dev/sdb1")
    print("provider=bare-metal") # For now it's easier to ask Mantl to treat us as a bare-metal install.
    print()

# TODO: Group servers by data center. 

print("[dc=dc1]")
for server_name in sorted(all_server_names):
    print(server_name)
