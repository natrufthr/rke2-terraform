# rke2-terraform

1. variables.tf
- contains all the variables for the tf deployment

2. main.tf
- contains teraform main provder aws and its region

3. rke2-teraform-deploy.sh

4. rke2_master.tf
- deploys aws ec2 rke2 controlplane/etc node (master node)
- uses master.sh as bootstrap script when instance is starting up

5. rke2_worker.tf
- deploys aws ec2 rke2 worker nodes
- uses worker.sh as bootstrap script when instance is starting up

6. rke_test.sh
- pulls rke2.yaml from s3 bucket and runs test kubectl command on nodes

7. s3_cleanup.sh
- removes s3 files created during terraform apply : rke2.yaml and config.yaml
  (to be run upon teraform destroy)
