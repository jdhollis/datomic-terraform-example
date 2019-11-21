provider "null" {
  version = "~> 2.1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "terraform_remote_state" "datomic" {
  backend = "s3"

  # TODO: Fill in the blanks
  config = {
    bucket         = "…"
    key            = "datomic/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "…"
    profile        = "ops-tools"
  }
}

# Datomic documentation (https://docs.datomic.com/cloud/operation/query-groups.html#details) recommends keeping the stack name at fewer than 24 characters, so trying to inject the full suffix will be basically useless. Instead, let's just use the rev portion of the suffix.

locals {
  base_stack_name = "${var.service_name}-qg"
  split_suffix    = split("-", var.suffix)
  rev             = local.split_suffix[0]
  stack_name      = "${local.base_stack_name}${local.rev == "" ? "" : "-${local.rev}"}"
}

data "aws_iam_policy_document" "ions" {
  # TODO: Insert any Ion-specific IAM permissions
}

resource "aws_iam_policy" "ions" {
  name   = "${local.stack_name}-ions"
  policy = data.aws_iam_policy_document.ions.json
}

resource "aws_cloudformation_stack" "query_group" {
  name         = local.stack_name
  capabilities = ["CAPABILITY_NAMED_IAM"]

  parameters = {
    ApplicationName = var.service_name
    EnvironmentMap  = "{:env \"${var.env}\" :query-group \"${local.stack_name}\" :system \"${data.terraform_remote_state.datomic.outputs.system_name[var.env]}\" :region \"${var.region}\" :database-name \"${var.database_name}\"}"
    InstanceType    = var.instance_type
    KeyName         = data.terraform_remote_state.datomic.outputs.key_name[var.env]
    NodePolicyArn   = aws_iam_policy.ions.arn
    SystemName      = data.terraform_remote_state.datomic.outputs.system_name[var.env]
  }

  template_url = var.query_group_cfs_url
}

locals {
  ion_dependency_hashes = [
    md5(file("${path.module}/ions/deps.edn")),
    md5(file("${path.module}/ions/resources/datomic/ion-config.edn")),
    # TODO: Add any other Ion file dependencies
  ]

  ion_dependency_hash = md5(join("\n", local.ion_dependency_hashes))
}

resource "null_resource" "ions" {
  depends_on = [aws_cloudformation_stack.query_group]

  triggers = {
    ion_dependency_hash  = local.ion_dependency_hash
    query_group_stack_id = aws_cloudformation_stack.query_group.id
  }

  provisioner "local-exec" {
    command = var.env == "dev" ? "cd \"${path.module}/ions\" && DEPLOYMENT_GROUP=${aws_cloudformation_stack.query_group.outputs["CodeDeployDeploymentGroup"]} bash bin/dev-release.sh" : "cd \"${path.module}/ions\" && ASSUME_ROLE_ARN=${var.assume_role_arn} DEPLOYMENT_GROUP=${aws_cloudformation_stack.query_group.outputs["CodeDeployDeploymentGroup"]} UNAME=${var.rev} REGION=${var.region} bash bin/codebuild-release.sh"
  }
}

data "aws_autoscaling_groups" "query_group" {
  depends_on = [aws_cloudformation_stack.query_group]

  filter {
    name   = "Key"
    values = ["aws:cloudformation:stack-name"]
  }

  filter {
    name   = "Value"
    values = [aws_cloudformation_stack.query_group.name]
  }
}
