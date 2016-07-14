#!/bin/bash

echo "Installing ELK stack..."

pushd ./mantl
ansible-playbook -u root -i ./ddcloud.inventory -e consul_dc=dc1 -e @../elasticsearch.yml -e @security.yml ./addons/elk.yml
if [[ $? -ne 0 ]]; then
    echo "Failed to deploy Mantl (security configuration is invalid)."

    popd
    exit 1
fi

echo "Done."
popd
