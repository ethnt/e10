resource "aws_s3_bucket" "storage_thanos" {
  bucket = "storage.thanos.e10.camp"
}

resource "aws_s3_bucket" "storage_loki" {
  bucket = "storage.loki.e10.camp"
}
