locals {
  auth_source_name  = "SecretsManagerRegion"
  auth_source_value = data.aws_region.current.name
  transfer_name     = "${var.name}-transfer-${var.stage}"
}
