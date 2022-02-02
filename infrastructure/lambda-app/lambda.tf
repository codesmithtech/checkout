resource "aws_lambda_function" "app" {
  count = var.create_lambda_function ? 1 : 0

  function_name = var.app_name
  role          = aws_iam_role.iam_for_lambda.arn
  image_uri     = "${var.docker_image_repo_url}:${var.app_version}"
  package_type  = "Image"
  publish       = true

  depends_on = [
    aws_cloudwatch_log_group.app,
    aws_iam_role_policy_attachment.lambda_logs
  ]

  environment {
    variables = {
      APP_VERSION = var.app_version
      CDN_URL     = "//${var.cdn_domain}/${var.app_version}${var.cdn_path}"
    }
  }
}

# This is to optionally manage the CloudWatch Log Group for the Lambda Function.
# If skipping this resource configuration, also add "logs:CreateLogGroup" to the IAM policy below.
resource "aws_cloudwatch_log_group" "app" {
  name              = "/aws/lambda/${var.app_name}"
  retention_in_days = 30
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_execution_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.iam_for_lambda.name
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}