variable "cluster_name" {}
variable "cluster_version" {}
variable "vpc_id" {}
variable "subnet_ids" {}
variable "environment" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0" 
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version


  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  

  cluster_endpoint_public_access = true


  enable_irsa = true


  eks_managed_node_groups = {
    general = {
      min_size     = 1
      max_size     = 2
      desired_size = 2

      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
    }
  }


  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

# Outputs (What we need to see after it's built)
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}