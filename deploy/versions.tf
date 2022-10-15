
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.34.0"
    }
  }

  backend "s3" {
    bucket         = "deploy.camp.computer"
    key            = "terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform_lock"
  }
}
