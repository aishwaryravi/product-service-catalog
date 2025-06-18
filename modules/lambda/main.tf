resource "aws_lambda_function" "this" {
  function_name = "product-service-${var.environment}"
  package_type  = "Image"
  image_uri     = "${var.ecr_repository_url}:latest"
  role          = var.iam_role_arn
  timeout       = 30
  memory_size   = 512

  # # Explicit dependency on ECR repository
  # depends_on  = [var.ecr_repository]

  environment {
    variables = {
      ENVIRONMENT = var.environment
      DEBUG       = "true"
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.this.function_name}"
  retention_in_days = 7
}