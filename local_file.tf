resource "local_file" "test-s3pull-script" {
    # content  = "foo!"
    content = <<EOF
    #!/bin/bash

    s3_path="s3://${var.s3_bucket_name}"

    echo "Starting RKE2 worker install"
    # Log Location on Server.
    LOG_LOCATION=/var/log
    exec > >(sudo tee -a $LOG_LOCATION/rke2start.log)
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

    while ! test -f "/etc/rancher/rke2/config.yaml"; do
    sleep 5
    echo "Still waiting on config.yaml"
    echo "pulling config.yaml from s3"
    aws s3 cp $s3_path/config.yaml /etc/rancher/rke2/config.yaml
    done

    echo "config.yaml found"

    while ! test -f "/home/ubuntu/rke2.yaml"; do
    sleep 5
    echo "Still waiting on rke2.yaml"
    echo "pulling kubeconfig from s3"
    aws s3 cp $s3_path/rke2.yaml /home/ubuntu/rke2.yaml
    done

    echo "rke2.yaml found"

    sleep 1
    echo "doing other stuff"
    sleep 1
    echo "sleeping for 90 seconds"
    sleep 90
    echo "starting rke2 on device"

    systemctl start rke2-agent.service

    echo "Log Location should be: [ $LOG_LOCATION ]"
    EOF
    filename = "${path.module}/test-s3pull-script.sh"
}

resource "local_file" "test-s3pull-script2" {
    # content  = "foo!"
    content = <<EOF
    #!/bin/bash

    s3_path="s3://${var.s3_bucket_name}"

    echo "Starting RKE2 worker install"
    # Log Location on Server.
    LOG_LOCATION=/var/log
    exec > >(sudo tee -a $LOG_LOCATION/rke2start.log)
    exec 2>&1


    while ! test -f "/home/ubuntu/config.yaml"; do
    sleep 5
    echo "Still waiting on config.yaml"
    echo "pulling config.yaml from s3"
    aws s3 cp $s3_path/config.yaml /home/ubuntu/config.yaml
    done

    echo "config.yaml found"

    while ! test -f "/home/ubuntu/rke2.yaml"; do
    sleep 5
    echo "Still waiting on rke2.yaml"
    echo "pulling kubeconfig from s3"
    aws s3 cp $s3_path/rke2.yaml /home/ubuntu/rke2.yaml
    done

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

    cp /home/ubuntu/config.yaml /etc/rancher/rke2/config.yaml

    sleep 1

    sudo systemctl start rke2-agent.service

    echo "Log Location should be: [ $LOG_LOCATION ]"

    EOF
    filename = "${path.module}/test-s3pull-script2.sh"
}