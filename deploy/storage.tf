resource "aws_s3_bucket" "deploy" {
  bucket = "deploy.camp.computer"
}

resource "aws_s3_bucket_acl" "deploy_acl" {
  bucket = aws_s3_bucket.deploy.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "deploy" {
  bucket = aws_s3_bucket.deploy.id

  versioning_configuration {
    status = "Enabled"
  }
}
