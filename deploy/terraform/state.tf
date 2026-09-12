resource "aws_s3_bucket" "deploy" {
  bucket = "deploy.e10.camp"
}

resource "aws_s3_bucket_versioning" "deploy" {
  bucket = aws_s3_bucket.deploy.id

  versioning_configuration {
    status = "Enabled"
  }
}

terraform {
  backend "s3" {
    bucket       = "deploy.e10.camp"
    key          = "terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
  }
}
