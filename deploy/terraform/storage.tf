resource "aws_s3_bucket" "storage_thanos" {
  bucket = "storage.thanos.e10.camp"
}

resource "aws_s3_bucket" "storage_loki" {
  bucket = "storage.loki.e10.camp"
}

resource "aws_s3_bucket" "turkeltaub_me" {
  bucket = "turkeltaub.me"
}

resource "aws_s3_bucket_website_configuration" "turkeltaub_me_website" {
  bucket = aws_s3_bucket.turkeltaub_me.id

  redirect_all_requests_to {
    host_name = "ethan.haus"
  }
}

resource "aws_s3_bucket" "www_turkeltaub_me" {
  bucket = "www.turkeltaub.me"
}

resource "aws_s3_bucket_website_configuration" "www_turkeltaub_me_website" {
  bucket = aws_s3_bucket.www_turkeltaub_me.id

  redirect_all_requests_to {
    host_name = "ethan.haus"
  }
}
