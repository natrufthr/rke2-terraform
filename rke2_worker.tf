             ## uncomment and run after you deploy master
             
             resource "aws_instance" "worker" {
             ami           = data.aws_ami.ubuntu.id
             instance_type = var.ec2_instance_type
             
             tags = {
                 Name = "${var.node_name_prefix}-tf-test-worker"
             }
             user_data = filebase64("${path.module}/worker.sh")
               
             iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"
#
             vpc_security_group_ids = [var.security_group_id]
#
             }
             
             
             resource "aws_instance" "worker-2" {
             ami           = data.aws_ami.ubuntu.id
             instance_type = var.ec2_instance_type
             
             tags = {
                 Name = "${var.node_name_prefix}-tf-test-worker"
             }
             user_data = filebase64("${path.module}/worker.sh")
               
             iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"
#
             vpc_security_group_ids = [var.security_group_id]
#
             }
             
            # uncomment and run after you deploy master
             
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
