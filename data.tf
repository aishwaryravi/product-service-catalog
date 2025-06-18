data "aws_vpc" "default" {
  default = true  # Uses your account's default VPC
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}