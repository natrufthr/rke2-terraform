# rke2-terraform
## Files used in teraform deployment
- variables.tf
  - Contains all the variables for the tf deployment

- main.tf
  - Contains teraform main provder aws and its region

- rke2_master.tf
  - Deploys aws ec2 rke2 controlplane/etc node (master node)
  - Uses master.sh as bootstrap script when instance is starting up

- rke2_worker.tf
  - Deploys aws ec2 rke2 worker nodes
  - Uses worker.sh as bootstrap script when instance is starting up

- rke_test.sh
  - Pulls rke2.yaml from s3 bucket and runs test kubectl command on nodes