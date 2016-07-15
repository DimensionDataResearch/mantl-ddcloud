#!/bin/bash

cat << EOF | fdisk /dev/sdc
n
p
1


w
EOF
