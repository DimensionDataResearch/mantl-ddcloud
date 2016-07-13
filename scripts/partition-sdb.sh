#!/bin/bash

cat << EOF | fdisk /dev/sdb
n
p
1


w
EOF
