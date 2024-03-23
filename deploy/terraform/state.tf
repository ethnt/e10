resource "aws_s3_bucket" "deploy" {
  bucket = "deploy.e10.camp"
}

resource "aws_s3_bucket_versioning" "deploy" {
  bucket = aws_s3_bucket.deploy.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "terraform_lock"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
    bucket         = "deploy.e10.camp"
    key            = "terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform_lock"
  }
}
