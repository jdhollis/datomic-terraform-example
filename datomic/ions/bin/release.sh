

#!/usr/bin/env bash

branch=$(git branch | grep \* | cut -d ' ' -f2)
rev=$(git rev-parse --short HEAD)
suffix="${rev}-${branch////-}"

deployment_group=$(cd ../.. && terraform output datomic_deployment_group)

creds=$(aws sts assume-role --profile ops --role-arn "INSERT ROLE ARN HERE" --role-session-name datomic-push | jq -r '.Credentials | @sh " AWS_SESSION_TOKEN=\(.SessionToken) AWS_ACCESS_KEY_ID=\(.AccessKeyId) AWS_SECRET_ACCESS_KEY=\(.SecretAccessKey)"')

eval $creds DEPLOYMENT_GROUP=${deployment_group} UNAME=terraform-example-${suffix} REGION=us-east-1 sh bin/naked-release.sh


