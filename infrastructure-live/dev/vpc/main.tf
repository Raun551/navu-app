terraform {
  backend "s3" {
    bucket = "raunaq-platform-state-store"
    key = "dev/vpc/terraform.tfstate"
    region = "eu-west-2"
    dynamodb_table = "terraform-locks"
    encrypt = true
    
  }
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

module "vpc" {
    source = "../../../modules/vpc"
    vpc_cidr = "10.0.0.0/16"
    environment = "dev"
    cluster_name = "raunaq-cluster-dev"
  
}

output "vpc_id" {
    value = module.vpc.vpc_id
  
}
output "private_subnets" {
  value = module.vpc.private_subnets
}
