terraform {
  required_version = "~> 0.12.0"

  backend "s3" {
    encrypt = true
  }
}

provider "aws" {
  version = "~> 2.31"
  region  = var.region
  profile = var.profile

  assume_role {
    role_arn = var.assume_role_arn
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "query_group" {
  source = "./datomic"

  assume_role_arn     = var.assume_role_arn
  database_name       = var.database_name
  env                 = var.env
  query_group_cfs_url = "https://s3.amazonaws.com/datomic-cloud-1/cft/535-8812/datomic-query-group-535-8812.json"
  region              = var.region
  rev                 = var.rev
  service_name        = "terraform-example"
  suffix              = var.suffix
}
