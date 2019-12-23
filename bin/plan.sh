#!/usr/bin/env bash

suffix=$(cat .suffix)
branch=$(git branch | grep \* | cut -d ' ' -f2)
rev=$(git rev-parse --short HEAD)
: ${suffix:="${rev}-${branch////-}"}

touch user.tfvars

terraform plan \
  -var-file dev.tfvars \
  -var-file user.tfvars \
  -var "suffix=${suffix}" \
  -out plan ${1-}
