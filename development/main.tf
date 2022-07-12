variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}
variable "cidr_block" {}
variable "private_subnets_count" {}
variable "public_subnets_count" {}
variable "availability_zones" {}
variable "public_key" {}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

terraform {
  backend "s3" {
    bucket  = "backend-state-caesar-tutorial-jenkins"
    key     = "jenkins/development/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

resource "aws_vpc" "main_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "jenkins-instance-main_vpc"
  }
}


module "subnet_module" {
  source                = "./modules"
  vpc_id                = aws_vpc.main_vpc.id
  vpc_cidr_block        = aws_vpc.main_vpc.cidr_block
  availability_zones    = var.availability_zones
  public_subnets_count  = var.public_subnets_count
  private_subnets_count = var.private_subnets_count
  public_key            = var.public_key
}