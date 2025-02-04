resource "aws_lambda_function" "sftp-idp" {
  filename         = "${path.module}/sftp-idp.zip"
  function_name    = "sftp-idp-${local.transfer_name}"
  role             = aws_iam_role.iam_for_lambda_idp.arn
  handler          = "index.lambda_handler"
  source_code_hash = data.archive_file.sftp-idp.output_base64sha256
  runtime          = "python3.12"

  environment {
    variables = {
      "${local.auth_source_name}" = local.auth_source_value
    }
  }
}

data "archive_file" "sftp-idp" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/source/"
  output_path = "${path.module}/sftp-idp.zip"
}

resource "aws_iam_role" "iam_for_lambda_idp" {
  name = "iam_for_lambda_idp-${local.transfer_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs_idp" {
  role       = aws_iam_role.iam_for_lambda_idp.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "sftp-idp" {
  name        = "sftp-idp-${local.transfer_name}"
  path        = "/"
  description = "IAM policy IdP service for SFTP in Lambda"

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : "secretsmanager:GetSecretValue",
        Resource : "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:SFTP/${var.name}-*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sftp-idp1" {
  role       = aws_iam_role.iam_for_lambda_idp.name
  policy_arn = aws_iam_policy.sftp-idp.arn
}

resource "aws_iam_role_policy_attachment" "sftp-idp2" {
  role       = aws_iam_role.iam_for_lambda_idp.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
