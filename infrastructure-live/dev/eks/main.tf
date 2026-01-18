terraform {
  backend "s3" {
    bucket         = "raunaq-platform-state-store" 
    key            = "dev/eks/terraform.tfstate"       
    region         = "eu-west-2"                       
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
  }
}





provider "aws" {
  region = "eu-west-2"
}

provider "helm" {
  repository_config_path = "${path.module}/.helm/repositories.yaml"
  repository_cache       = "${path.module}/.helm"
  
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
}


data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "raunaq-platform-state-store"
    key    = "dev/vpc/terraform.tfstate"
    region = "eu-west-2" # Where the state file lives
  }
}

module "eks" {
  source = "../../../modules/eks"

  cluster_name    = "raunaq-eks-cluster"
  cluster_version = "1.31"
  environment     = "dev"

  vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets
  
}