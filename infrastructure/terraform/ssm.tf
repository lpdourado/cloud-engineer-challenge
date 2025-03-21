resource "aws_ssm_parameter" "app-version" {
  name = var.parameter_store_name
  type = "String"
  value = "1.0.0"
}