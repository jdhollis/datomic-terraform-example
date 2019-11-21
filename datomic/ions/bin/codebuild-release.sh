

#!/usr/bin/env bash

creds=$(aws sts assume-role --role-arn $ASSUME_ROLE_ARN --role-session-name datomic-push | jq -r '.Credentials | @sh " AWS_SESSION_TOKEN=\(.SessionToken) AWS_ACCESS_KEY_ID=\(.AccessKeyId) AWS_SECRET_ACCESS_KEY=\(.SecretAccessKey)"')

eval $creds sh bin/naked-release.sh


