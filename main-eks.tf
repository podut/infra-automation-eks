provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

# VPC for Cluster
data "aws_availability_zones" "azs" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.name
  cidr = var.vpc_cidr_block

  azs             = data.aws_availability_zones.azs.names
  private_subnets = var.private_subnet_cidr_blocks
  public_subnets  = var.public_subnet_cidr_blocks

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = var.tags
}

# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.16"

  cluster_name                   = var.name
  cluster_version                = var.k8s_version
  cluster_endpoint_public_access = true
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  create_cluster_security_group = false
  create_node_security_group    = false

  manage_aws_auth_configmap = true
  aws_auth_roles = local.aws_k8s_role_mapping
  
  cluster_addons = {
    kube-proxy = {}
    vpc-cni    = {}
    coredns = {}
  }
  
  eks_managed_node_groups = {
    initial = {
      instance_types = ["t3.micro"]
      min_size     = 2
      max_size     = 20
      desired_size = 4
    }
  }

  tags = var.tags
}