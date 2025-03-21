provider "aws" {
  region = "eu-west-1"  # Change to your preferred region
}

resource "aws_s3_bucket" "main" {
  bucket = "kubernetes-challenge-main-api"
}

resource "aws_s3_bucket" "auxiliary" {
  bucket = "kubernetes-challenge-aux-service"
}

resource "aws_ssm_parameter" "app_version" {
  name  = "/kubernetes-challenge/app-version"
  type  = "String"
  value = "1.0.0"
}

resource "aws_iam_role" "github_oidc" {
  name = "GitHubActionsOIDC"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::890742573274:oidc-provider/token.actions.githubusercontent.com"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:lpdourado/cloud-engineer-challenge:*"
        }
      }
    }]
  })
}

