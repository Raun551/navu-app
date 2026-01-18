provider "aws" {
    region = "eu-west-2"
}
resource "aws_s3_bucket" "terraform_state" {
    bucket = "raunaq-platform-state-store"
    lifecycle {
      prevent_destroy = true
    }
}

resource "aws_s3_bucket_versioning" "enabled" {
    bucket = aws_s3_bucket.terraform_state.id
    versioning_configuration {
      status = "Enabled"
    }
  
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
    bucket = aws_s3_bucket.terraform_state.id
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  
}

resource "aws_dynamodb_table" "terraform_locks" {
    name = "terraform-locks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"
    attribute {
      name = "LockID"
      type = "S"
    }
  
}
output "s3_bucket_name" {
    value = aws_s3_bucket.terraform_state.id
  
}

output "dynamedb_table_name" {
    value = aws_dynamodb_table.terraform_locks.name
  
}