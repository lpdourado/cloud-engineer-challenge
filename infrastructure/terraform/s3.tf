resource "aws_s3_bucket" "main-api" {
  bucket = var.s3_bucket_main
}

resource "aws_s3_bucket" "aux-service" {
  bucket = var.s3_bucket_aux
}