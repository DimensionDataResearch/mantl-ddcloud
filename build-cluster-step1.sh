
#!/bin/bash

echo "Step 1 of 4 - running Terraform to create cluster infrastructure..."

pushd ./terraform
terraform get -update
terraform plan -out ./terraform.plan
terraform apply ./terraform.plan
popd

echo "Step 1 of 4 complete - wait for boot and then run build-cluster-step2.sh to continue."
