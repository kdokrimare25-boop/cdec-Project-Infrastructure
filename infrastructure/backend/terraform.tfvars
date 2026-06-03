# Copy to terraform.tfvars. Do not commit terraform.tfvars.

aws_region   = "eu-west-1"
environment  = "dev"
project_name = "cdec"
cluster_name = "cdec-eks"

# VPC — change AZ names for your region
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
availability_zones   = ["eu-west-1a", "eu-west-1b"]

single_nat_gateway = true

# EKS
kubernetes_version  = "1.34"
node_instance_types = ["c7i-flex.large"]
desired_size        = 2
min_size            = 1
max_size            = 3

cluster_endpoint_public_access       = true
cluster_endpoint_private_access      = true
cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

additional_tags = {
  Owner = "platform-team"
}
