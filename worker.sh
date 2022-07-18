#!/bin/bash
echo "Starting RKE2 worker install script"

s3_path="s3://nts3test2"

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

echo "Starting RKE2 worker install"
set -e
# Log Location on Server.
LOG_LOCATION=/var/log
exec > >(sudo tee -a $LOG_LOCATION/bootstrap.log)
exec 2>&1
sudo apt update
apt install openssh-server -y
curl https://releases.rancher.com/install-docker/20.10.sh | sh
usermod -aG docker ubuntu
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
sudo chmod 666 /var/run/docker.sock
systemctl enable docker
systemctl start docker
ssh-keygen -t rsa -N "" -f /home/ubuntu/.ssh/id_rsa
chmod 666 /home/ubuntu/.ssh/id_rsa
echo "export KUBECONFIG=/home/ubuntu/rke2.yaml" > /etc/profile.d/kubec.sh
echo "export PRIVATE_IP=$(echo $SSH_CONNECTION | cut -d ' ' -f 3)" > ~/privateip.sh
echo "export PUBLIC_IP=$(echo $SSH_CONNECTION | cut -d ' ' -f 1)" > ~/publicip.sh
mv ~/privateip.sh /etc/profile.d/privateip.sh
mv ~/publicip.sh /etc/profile.d/publicip.sh
curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -
systemctl enable rke2-agent.service
mkdir -p /etc/rancher/rke2/
touch /etc/rancher/rke2/config.yaml

echo "pulling config.yaml from s3"
aws s3 cp $s3_path/config.yaml /etc/rancher/rke2/config.yaml

echo "pulling kubeconfig from s3"
aws s3 cp $s3_path/rke2.yaml /home/ubuntu/rke2.yaml

systemctl start rke2-agent.service
echo "Log Location should be: [ $LOG_LOCATION ]"
