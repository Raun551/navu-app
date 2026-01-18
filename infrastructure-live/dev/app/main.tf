terraform {
  backend "s3" {
    bucket         = "raunaq-platform-state-store" 
    key            = "dev/app/terraform.tfstate"       
    region         = "eu-west-2"                       
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = "eu-west-2"
}

resource "aws_ecr_repository" "app_repo" {
  name                 = "navu-app"
  image_tag_mutability = "MUTABLE" 


  image_scanning_configuration {
    scan_on_push = true
  }
}

output "repository_url" {
  value = aws_ecr_repository.app_repo.repository_url
}