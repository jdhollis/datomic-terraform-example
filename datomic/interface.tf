variable "assume_role_arn" {}
variable "database_name" {}
variable "env" {}

variable "instance_type" {
  default = "t3.medium"
}

variable "query_group_cfs_url" {}
variable "region" {}
variable "rev" {}
variable "service_name" {}

variable "suffix" {
  default = ""
}

output "autoscaling_group_name" {
  value = data.aws_autoscaling_groups.query_group.names[0]
}

output "codedeploy_deployment_group" {
  value = aws_cloudformation_stack.query_group.outputs["CodeDeployDeploymentGroup"]
}

output "ions" {
  value = null_resource.ions.id
}
