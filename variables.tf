variable "security_group_id" {
	default = "sg-00459613f9c685856"
}

variable "node_name_prefix" {
	default = "rke2"
}

variable "ec2_instance_type" {
    default = "t2.large"
}

variable "s3_bucket_name" {}

variable "instance_profile_name" {}

variable "ec2_security_group_vpc" {}

variable "ec2_security_group_name" {}

variable "k8s_worker_amount" {
	default = "1"
}