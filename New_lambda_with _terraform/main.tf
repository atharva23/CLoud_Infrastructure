terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


variable "lambda_name" {
  description = "Name of the Lambda function"
  type        = string
}

resource "aws_iam_role" "lambda_role" {
  name = "Lambda_Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_logs_policy" {
  name        = "Lambda_Logs_Policy"
  description = "Policy to access Lambda logs"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "rds:DescribeDBSnapshots",
          "rds:DeleteDBSnapshot"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_logs_policy.arn
  role       = aws_iam_role.lambda_role.name
}

resource "aws_lambda_function" "example_lambda" {
  filename         = "example_lambda.zip"
  function_name    = var.lambda_name
  role             = aws_iam_role.lambda_role.arn
  handler          = "example_lambda.handler"
  runtime          = "python3.7"
  source_code_hash = data.archive_file.example_lambda_function.output_base64sha256
  environment {
    variables = {
      RETENTION_DAYS = "30"
    }
  }
}

data "archive_file" "example_lambda_function"{
  type        = "zip"
  source_file = "example_lambda.py"
  output_path = "example_lambda.zip"
}

resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  name        = "DailyLambdaTrigger"
  description = "Trigger Lambda every day at 12 AM"
  schedule_expression = "cron(0 0 * * ? *)" 
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule = aws_cloudwatch_event_rule.lambda_schedule.name
  arn  = aws_lambda_function.example_lambda.arn
}


resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowCloudWatchToInvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule.arn
}
