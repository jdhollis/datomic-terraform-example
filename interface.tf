variable "assume_role_arn" {
  default = ""
}

variable "database_name" {}
variable "env" {}

variable "profile" {
  default = ""
}

variable "region" {}

variable "rev" {
  default = ""
}

variable "suffix" {
  default = ""
}

output "datomic_autoscaling_group_name" {
  value = module.query_group.autoscaling_group_name
}

output "datomic_deployment_group" {
  value = module.query_group.codedeploy_deployment_group
}
