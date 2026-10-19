terraform {
  required_version = ">= 1.10.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }
  }

  backend "s3" {
    bucket       = "aws-devops-state-demi"
    key          = "aws-devops-platform/dev/terraform.tfstate"
    region       = "eu-west-2"
    use_lockfile = true
  }
}
