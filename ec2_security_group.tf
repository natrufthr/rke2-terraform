resource "aws_security_group" "rkeSecurityGroup" {

  name        = "${var.ec2_security_group_name}"
  description = "${var.ec2_security_group_name}"
  # vpc_id      = aws_vpc.main.id
  vpc_id      = "${var.ec2_security_group_vpc}"

  ingress {
    description      = "port 6443 TCP"
    from_port        = 6443
    to_port          = 6443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  } 
  ingress {
    description      = "port 9345 TCP"
    from_port        = 9345
    to_port          = 9345
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.ec2_security_group_name}"
  }

}
