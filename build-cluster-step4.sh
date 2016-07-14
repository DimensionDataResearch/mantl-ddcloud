#!/bin/bash

echo "Step 4 of 4 - installing mantl..."

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

# TODO: Ensure nodes were rebooted after upgrade.
ansible-playbook -u root -i ./ddcloud.inventory -e consul_dc=dc1 -e @security.yml ./mantl.yml
if [[ $? -ne 0 ]]; then
    echo "Failed to deploy Mantl (one or more deployment actions failed)."

    popd
    exit 1
fi

echo "Step 4 of 4 complete"

popd

echo "Done"
