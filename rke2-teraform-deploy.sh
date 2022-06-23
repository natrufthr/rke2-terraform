#!/bin/bash

pwd=$(pwd)

echo "commenting out rke2 worker tf file"

sed -i '/^#/!s/\(.*\)/# \1/g' rke2_worker.tf

cat rke2_worker.tf

echo "uncommenting rke2 worker tf file"

sed -i '/ /s/^#//g' rke2_worker.tf

cat rke2_worker.tf

# var=testvar

# echo $var