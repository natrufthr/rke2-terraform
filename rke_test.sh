#!/bin/bash

s3_path="s3://nts3test2"

pwd=$(pwd)

echo "removing preexisting KUBECONFIG in " + $pwd

rm rke2.yaml

echo "copying KUBECONFIG from " $s3_path

aws s3 cp $s3_path/rke2.yaml rke2.yaml

export KUBECONFIG=$pwd/rke2.yaml

kubectl version
