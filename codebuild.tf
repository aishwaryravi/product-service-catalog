resource "aws_codebuild_project" "product_service" {
  name          = "product-service-build"
  description   = "Build project for Product Service"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/buildspec.yml")
  }
}

resource "aws_s3_bucket" "pipeline_artifacts" {
  bucket = "product-service-pipeline-artifacts-${random_id.bucket_suffix.hex}"
  #acl    = "private"
}

resource "random_id" "bucket_suffix" {
  byte_length = 8
}