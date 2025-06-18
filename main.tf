provider "aws" {
  region     = var.region
  access_key = var.aws_access_key # Only for testing, use env vars for production
  secret_key = var.aws_secret_key  # Only for testing
}
module "ecr" {
  source       = "./modules/ecr"
  environments = ["dev", "qa", "prod"]
}

module "dynamodb" {
  source = "./modules/dynamodb"
  tables = {
    dev  = { billing_mode = "PAY_PER_REQUEST" }
    qa   = { billing_mode = "PROVISIONED", read_capacity = 5, write_capacity = 5 }
    prod = { billing_mode = "PROVISIONED", read_capacity = 10, write_capacity = 10 }
  }
}

module "iam" {
  source = "./modules/iam"
  for_each = {
    dev  = { dynamodb_table_arn = module.dynamodb.table_arns["dev"] }
    qa   = { dynamodb_table_arn = module.dynamodb.table_arns["qa"] }
    prod = { dynamodb_table_arn = module.dynamodb.table_arns["prod"] }
  }
  environment        = each.key
  dynamodb_table_arn = each.value.dynamodb_table_arn
}
# module "iam" {
#   source = "./modules/iam"
  
#   # Pass any required variables
#   pipeline_artifacts_bucket_arn = aws_s3_bucket.pipeline_artifacts.arn
# }

module "lambda" {
  source             = "./modules/lambda"
  environment        = "dev"
  ecr_repository_url = module.ecr.repository_urls["dev"]
  #ecr_repository     = module.ecr.repository["dev"]
  iam_role_arn       = module.iam["dev"].lambda_exec_role_arn
  dynamodb_table_arn = module.dynamodb.table_arns["dev"]
  
  depends_on = [null_resource.docker_build_dev]
}

module "api_gateway" {
  source              = "./modules/api_gateway"
  environment         = "dev"
  region              = var.region
  lambda_invoke_arn   = module.lambda.invoke_arn
  lambda_function_name = module.lambda.function_name
}

module "qa_environment" {
  source             = "./modules/ecs"
  environment        = "qa"
  ecr_repository_url = module.ecr.repository_urls["qa"]
  dynamodb_table_arn = module.dynamodb.table_arns["qa"]
  ecs_exec_role_arn  = module.iam["qa"].ecs_execution_role_arn
  vpc_id             = data.aws_vpc.default.id  # Get current/default VPC
  subnet_ids         = data.aws_subnets.default.ids # Get all subnets
  min_capacity       = 1
  max_capacity       = 4
  region             = var.region
}

module "prod_environment" {
  source             = "./modules/ecs"
  environment        = "prod"
  ecr_repository_url = module.ecr.repository_urls["prod"]
  dynamodb_table_arn = module.dynamodb.table_arns["prod"]
  ecs_exec_role_arn  = module.iam["prod"].ecs_execution_role_arn
  vpc_id             = data.aws_vpc.default.id
  subnet_ids         = data.aws_subnets.default.ids
  min_capacity       = 2
  max_capacity       = 10
  enable_waf         = true
  allowed_ips        = var.allowed_ips
  region             = var.region
}

module "waf" {
  source  = "./modules/waf"
  alb_arn = module.prod_environment.lb_arn # Changed from lb_url to lb_arn
}