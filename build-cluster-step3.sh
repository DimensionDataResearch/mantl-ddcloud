#!/bin/bash

echo "Step 3 of 5 - preparing additional disk volumes..."

# The disk provisioned as part of the CentOS image is too small for our purposes, so we'll just extend the logical volume onto a new drive. 

echo "Add data disk to LVM..."
ansible all -u root -a "pvcreate /dev/sdb"
if [[ $? -ne 0 ]]; then
    echo "Failed to deploy Mantl (unable to copy partitioning script to one or more nodes in the cluster)."

    popd
    exit 1
fi

echo "Add data disk to volume group..."
ansible all -u root -a "vgextend centos /dev/sdb"
if [[ $? -ne 0 ]]; then
    echo "Failed to deploy Mantl (unable add /dev/sdb to LVM)."

    popd
    exit 1
fi

echo "Extend root volume to data disk..."
ansible all -u root -a "lvextend /dev/centos/root /dev/sdb"
if [[ $? -ne 0 ]]; then
    echo "Failed to deploy Mantl (unable extend root volume to data disk)."

    popd
    exit 1
fi

echo "Extend root file system..."
ansible all -u root -a "sudo xfs_growfs /dev/centos/root"
if [[ $? -ne 0 ]]; then
    echo "Failed to deploy Mantl (unable extend root volume to data disk)."

    popd
    exit 1
fi

echo "Partition docker disk..."
ansible all -u root -m copy -a "src='./scripts/partition-sdc.sh' dest='./partition-sdc.sh' mode='u+x'"
if [[ $? -ne 0 ]]; then
    echo "Failed to deploy Mantl (unable to copy partitioning script to one or more nodes in the cluster)."

    popd
    exit 1
fi
ansible all -u root -a "./partition-sdc.sh"
if [[ $? -ne 0 ]]; then
    echo "Failed to deploy Mantl (partitioning script failed on one or more nodes in the cluster)."

    popd
    exit 1
fi
ansible all -u root -a "rm ./partition-sdc.sh"
if [[ $? -ne 0 ]]; then
    echo "Failed to deploy Mantl (unable to clean up partitioning script)."

    popd
    exit 1
fi

echo "Expect errors from the next command since we're rebooting the target servers."
ansible all -u root -e 'ignore_errors=true' -a 'nohup bash -c "sleep 2s && reboot" &'

echo "Step 3 of 5 complete - wait for reboots and then run build-cluster-step4.sh"
