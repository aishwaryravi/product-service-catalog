resource "aws_codestarconnections_connection" "github" {
  name          = "prod-svc-gh-connection"
  provider_type = "GitHub"
}

resource "aws_codepipeline" "product_service" {
  name     = "product-service-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "GitHub_Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = "${var.github_repo_owner}/${var.github_repo_name}"
        BranchName       = var.github_branch
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.product_service.name
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy_Dev"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ApplicationName = "product-service-dev"
        DeploymentGroupName = "product-service-dev-dg"
      }
    }

    action {
      name            = "Approval_QA"
      category        = "Approval"
      owner           = "AWS"
      provider        = "Manual"
      version         = "1"
    }

    action {
      name            = "Deploy_QA"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["build_output"]
      version         = "1"
      run_order       = 2

      configuration = {
        ApplicationName = "product-service-qa"
        DeploymentGroupName = "product-service-qa-dg"
      }
    }

    action {
      name            = "Approval_Prod"
      category        = "Approval"
      owner           = "AWS"
      provider        = "Manual"
      version         = "1"
      run_order       = 3
    }

    action {
      name            = "Deploy_Prod"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["build_output"]
      version         = "1"
      run_order       = 4

      configuration = {
        ApplicationName = "product-service-prod"
        DeploymentGroupName = "product-service-prod-dg"
      }
    }
  }
}