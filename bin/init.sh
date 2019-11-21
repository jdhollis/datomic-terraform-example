#!/usr/bin/env bash

touch .suffix

suffix=$(cat .suffix)
branch=$(git branch | grep \* | cut -d ' ' -f2)
rev=$(git rev-parse --short HEAD)
: ${suffix:="${rev}-${branch////-}"}

terraform init \
  -backend-config backend.dev.tfvars \
  -backend-config "key=terraform-example-${suffix}/terraform.tfstate" ${1-}

