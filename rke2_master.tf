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
  name = "test_profile"
  role = "AmazonSSMRoleForInstancesQuickSetup"
}

resource "aws_instance" "master" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ec2_instance_type

  tags = {
    Name = "${var.node_name_prefix}-tf-test-master"
  }
  user_data = filebase64("${path.module}/master.sh")
  
  iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"

  vpc_security_group_ids = [var.security_group_id]
}

output "master_ip_addr" {
  value = aws_instance.master.public_ip
}

output "master_ip_addr_private" {
  value = aws_instance.master.private_ip
}
