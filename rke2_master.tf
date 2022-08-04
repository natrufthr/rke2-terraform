data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_iam_instance_profile" "test_profile" {
  name = "${var.instance_profile_name}"
  role = "AmazonSSMRoleForInstancesQuickSetup"
}

resource "aws_instance" "master" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ec2_instance_type

  tags = {
    Name = "${var.node_name_prefix}-tf-test-master"
  }

  user_data = <<EOF
#!/bin/bash

s3_path="s3://${var.s3_bucket_name}"

echo "Starting RKE2 controlplane install script"


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

echo "Starting RKE2 controlplane install"
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
curl -sfL https://get.rke2.io | sh -
systemctl enable rke2-server.service
systemctl start rke2-server.service
touch /home/ubuntu/rke2.yaml
cat /etc/rancher/rke2/rke2.yaml > /home/ubuntu/rke2.yaml

echo "setting node-token as ENV variable"
export TOKEN=$(cat /var/lib/rancher/rke2/server/node-token)

echo "creating file for worker node"
echo "server: https://$PRIVATE_IP:9345" > /home/ubuntu/config.yaml
echo "token: $TOKEN" >> /home/ubuntu/config.yaml

aws s3 cp /home/ubuntu/config.yaml $s3_path

aws s3 cp /home/ubuntu/rke2.yaml $s3_path

echo "Log Location should be: [ $LOG_LOCATION ]"
EOF
  
  iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"

  vpc_security_group_ids = [var.security_group_id]
}

output "master_ip_addr" {
  value = aws_instance.master.public_ip
}

output "master_ip_addr_private" {
  value = aws_instance.master.private_ip
}
