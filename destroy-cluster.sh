#!/bin/bash

pushd ./terraform
terraform get -update
terraform destroy
popd
