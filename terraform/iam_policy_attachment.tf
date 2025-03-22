resource "aws_iam_role_policy_attachment" "github_oidc_policy_attachment" {
  role       = aws_iam_role.github_oidc.name
  policy_arn = aws_iam_policy.github_oidc_policy.arn
}