#!/bin/bash

echo "Step 3 of 4 - preparing /dev/sdb1 (will be used as a volume for Docker)..."

ansible all -u root -m copy -a "src='./scripts/partition-sdb.sh' dest='./partition-sdb.sh' mode='u+x'"
if [[ $? -ne 0 ]]; then
    echo "Failed to deploy Mantl (unable to copy partitioning script to one or more nodes in the cluster)."

    popd
    exit 1
fi

ansible all -u root -a "./partition-sdb.sh"
if [[ $? -ne 0 ]]; then
    echo "Failed to deploy Mantl (partitioning script failed on one or more nodes in the cluster)."

    popd
    exit 1
fi

ansible all -u root -a "rm ./partition-sdb.sh"
if [[ $? -ne 0 ]]; then
    echo "Failed to deploy Mantl (unable to clean up partitioning script)."

    popd
    exit 1
fi

ansible all -u root -e ignore_errors=true -a 'nohup bash -c "sleep 2s && reboot" &'

echo "Step 3 of 4 complete - wait for reboots and then run build-cluster-step4.sh"
