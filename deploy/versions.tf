
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.34.0"
    }

    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.11"
    }
  }

  backend "s3" {
    bucket         = "deploy.e10.network"
    key            = "terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform_lock"
  }
}
