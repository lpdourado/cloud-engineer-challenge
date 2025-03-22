resource "aws_iam_policy" "github_oidc_policy" {
  name        = "GitHubActionsOIDCPolicy"
  description = "Policy for GitHub Actions to interact with S3 and SSM"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:*"]
        Effect   = "Allow"
        Resource = [
          "${aws_s3_bucket.main.arn}",
          "${aws_s3_bucket.main.arn}/*",
          "${aws_s3_bucket.auxiliary.arn}",
          "${aws_s3_bucket.auxiliary.arn}/*"
        ]
      },
      {
        Action   = ["ssm:*"]
        Effect   = "Allow"
        Resource = "${aws_ssm_parameter.app_version.arn}"
      }
    ]
  })
}