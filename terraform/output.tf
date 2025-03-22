output "main_s3_bucket_arn" {
  description = "ARN of the main S3 bucket"
  value       = aws_s3_bucket.main.arn
}

output "auxiliary_s3_bucket_arn" {
  description = "ARN of the auxiliary S3 bucket"
  value       = aws_s3_bucket.auxiliary.arn
}

output "app_version_parameter_arn" {
  description = "ARN of the app version parameter"
  value       = aws_ssm_parameter.app_version.arn
}