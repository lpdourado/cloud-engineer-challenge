resource "aws_s3_bucket" "main" {
  bucket = "cloud-engineer-challenge-main-api"
}

resource "aws_s3_bucket" "auxiliary" {
  bucket = "cloud-engineer-challenge-aux-service"
}

resource "aws_ssm_parameter" "app_version" {
  name  = "/cloud-engineer-challenge/app-version"
  type  = "String"
  value = "1.0.0"
}