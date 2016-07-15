#!/bin/bash

echo "Step 4 of 5 - upgrading packages..."

cp ./ddcloud.inventory ./mantl/ddcloud.inventory
cp ./mantl.yml ./mantl/mantl.yml

pushd ./mantl
./security-setup
if [[ $? -ne 0 ]]; then
    echo "Failed to deploy Mantl (security configuration is invalid)."

    popd
    exit 1
fi

ansible-playbook -u root -i ./ddcloud.inventory -e consul_dc=dc1 -e @security.yml ./playbooks/upgrade-packages.yml
if [[ $? -ne 0 ]]; then
    echo "Failed to deploy Mantl (unable to upgrade required packages on one or more nodes in the cluster)."

    popd
    exit 1
fi

echo "Expect errors from the next command since we're rebooting the target servers."
ansible all -u root -i ./ddcloud.inventory -e 'ignore_errors=true' -a 'nohup bash -c "sleep 2s && reboot" &'

popd

echo "Done"
