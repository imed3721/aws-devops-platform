provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      Project     = "aws-devops-platform"
      Environment = "dev"
      ManagedBy   = "Terraform"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}
