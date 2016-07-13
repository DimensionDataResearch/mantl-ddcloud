#!/bin/bash

echo "Step 3 of 4 - preparing /dev/sdb1 (will be used as a volume for Docker)..."

ansible all -u root -m copy -a "src='./scripts/partition-sdb.sh' dest='./partition-sdb.sh' mode='u+x'"
ansible all -u root -a "./partition-sdb.sh"
ansible all -u root -a "rm ./partition-sdb.sh"
ansible all -u root -a "reboot"

echo "Step 3 of 4 complete - wait for reboots and then run build-cluster-step4.sh"
