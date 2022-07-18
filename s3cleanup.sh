#!/bin/bash

s3_path="s3://nts3test2"

echo "existing resources in" $s3_path

aws s3 ls $s3_path
echo "deleteing config.yaml from " $s3_path
aws s3 rm $s3_path/config.yaml
echo "deleteing rke2.yaml from " $s3_path
aws s3 rm $s3_path/rke2.yaml

echo "executing grep for rke2.yaml to confirm removal from" $s3_path

aws s3 ls $s3_path | grep rke2.yaml

echo "executing grep for config.yaml to confirm removal from" $s3_path

aws s3 ls $s3_path | grep config.yaml
