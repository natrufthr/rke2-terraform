#!/bin/bash
echo "Starting RKE2 worker install script"

s3_path="s3://nts3test2"


set -e
# Log Location on Server.
LOG_LOCATION=/var/log
exec > >(sudo tee -a $LOG_LOCATION/bootstrap.log)
exec 2>&1

echo "installing awscli"
sudo apt update
sudo apt install awscli -y

echo "Setting private IP env variable"

export PRIVATE_IP=$(hostname -I | awk '{print $1}')

echo "installing ssm agent to ubuntu"
sudo snap install amazon-ssm-agent --classic
sudo snap list amazon-ssm-agent
sudo snap start amazon-ssm-agent
sudo snap services amazon-ssm-agent

sleep 10

aws s3 cp $s3_path/test-s3pull-script2.sh /home/ubuntu/test-s3pull-script2.sh


nohup sudo bash /home/ubuntu/test-s3pull-script2.sh

echo "Log Location should be: [ $LOG_LOCATION ]"
