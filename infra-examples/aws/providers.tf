terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">=5.88"
    }
  }
}

provider "aws" {
  region = var.region
}
