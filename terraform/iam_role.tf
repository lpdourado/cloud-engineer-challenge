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