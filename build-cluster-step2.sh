#!/bin/bash

echo "Generating ddcloud.inventory..."
./generate-inventory.py > ./ddcloud.inventory

# Use SSH key file.
echo "Step 1 of 4 - configuring cluster machines to use SSH keyfile (initial password can be found in mantl.tf)..."

ansible all -u root -k -m authorized_key -a "user=root key='{{ lookup('file', '$HOME/.ssh/id_rsa.pub') }}'"

echo "Step 1 of 4 complete"

# Set host names.
echo "Step 2 of 4 - configuring cluster machine host names..."
ansible all -u root -a "hostnamectl set-hostname {{ inventory_hostname }}" 
ansible all -u root -e ignore_errors=true -a 'nohup bash -c "sleep 2s && reboot" &'

echo "Step 2 of 4 complete - wait for reboots and then run build-cluster-step3.sh"
