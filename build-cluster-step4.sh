#!/bin/bash

echo "Step 4 of 4 - installing mantl..."

./mantl/security-setup
ansible-playbook -u root -e @mantl/security.yml mantl/playbooks/upgrade-packages.yml
ansible-playbook -u root -e @mantl/security.yml mantl/playbooks/check-requirements.yml
ansible-playbook -u root -e @mantl/security.yml mantl.yml

echo "Step 4 of 4 complete"
echo "Done"
