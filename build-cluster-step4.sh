#!/bin/bash

echo "Step 4 of 4 - installing mantl..."

cp mantl.yml ./mantl/mantl.yml
./generate-inventory.py > ./mantl/ddcloud.inventory

pushd ./mantl
./security-setup
ansible-playbook -u root -i ./ddcloud.inventory -e consul_dc=dc1 -e @security.yml ./mantl.yml
popd

echo "Step 4 of 4 complete"
echo "Done"
