terraform {
  required_version = "1.13.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" # Use the latest 6.x (6.1 to 6.9) version of the AWS provider.
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
}

provider "aws" {
  region = var.region
}

# Using local backend
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}


# remote backend: This allows multiple developers or teams to work on the same infrastructure project without overwriting each other’s changes.

# terraform {
#   backend "s3" {
#     bucket         = "my-backend-devops101-terraform"
#     key            = "tfstate/terraform.tfstate"
#     region         = "ap-south-1"
#     encrypt        = true
#     #dynamodb_table = "terraform-lock-table"
#   }
# }