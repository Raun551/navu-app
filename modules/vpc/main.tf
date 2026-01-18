variable "vpc_cidr" {}
variable "environment" {}
variable "cluster_name" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2" # Pin versions in production!

  name = "raunaq-vpc-${var.environment}"
  cidr = var.vpc_cidr

  # We use 2 Availability Zones (AZs) for High Availability
  azs             = ["eu-west-2a", "eu-west-2b"]
  
  # Subnet logic: 
  # VPC is 10.0.0.0/16
  # Private: 10.0.1.0/24, 10.0.2.0/24
  # Public:  10.0.101.0/24, 10.0.102.0/24
  private_subnets = [cidrsubnet(var.vpc_cidr, 8, 1), cidrsubnet(var.vpc_cidr, 8, 2)]
  public_subnets  = [cidrsubnet(var.vpc_cidr, 8, 101), cidrsubnet(var.vpc_cidr, 8, 102)]

  enable_nat_gateway = true
  single_nat_gateway = true 
  # PROD NOTE: In strict prod, set 'single_nat_gateway = false' to have one per AZ. 
  # For this tutorial/dev, 'true' saves you ~$30/month.

  enable_dns_hostnames = true

  # CRITICAL TAGS FOR EKS
  # EKS needs to know where to put Load Balancers. These tags tell it.
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}