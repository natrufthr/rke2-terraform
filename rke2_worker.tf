    ## uncomment and run after you deploy master
    
    resource "aws_instance" "worker" {
    ami           = data.aws_ami.ubuntu.id
    instance_type = var.ec2_instance_type
    
    tags = {
        Name = "${var.node_name_prefix}-tf-test-worker"
    }
    # user_data = filebase64("${path.module}/worker.sh")
    
    iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"

    vpc_security_group_ids = [var.security_group_id]

    user_data = <<EOF
#!/bin/bash
echo "Starting RKE2 worker install script"

s3_path="s3://${var.s3_bucket_name}"


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

EOF


    }
    
    
    resource "aws_instance" "worker-2" {
    ami           = data.aws_ami.ubuntu.id
    instance_type = var.ec2_instance_type
    
    tags = {
        Name = "${var.node_name_prefix}-tf-test-worker"
    }
#  user_data = filebase64("${path.module}/worker.sh")
    
    iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"

    vpc_security_group_ids = [var.security_group_id]

    user_data = <<EOF
#!/bin/bash
echo "Starting RKE2 worker install script"

s3_path="s3://${var.s3_bucket_name}"


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

EOF

    }
    
    ## uncomment and run after you deploy master
    
    output "worker_ip_addr" {
    value = aws_instance.worker.public_ip
    }
    
    output "worker_ip_addr_private" {
    value = aws_instance.worker.private_ip
    }
    
    output "worker-2_ip_addr" {
    value = aws_instance.worker-2.public_ip
    }
    
    output "worker-2_ip_addr_private" {
    value = aws_instance.worker-2.private_ip
    }
