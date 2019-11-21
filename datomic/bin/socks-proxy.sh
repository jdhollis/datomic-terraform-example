#!/bin/bash
while [ $# -gt 1 ]
do
    case "$1" in
        -p)
            PROFILE_COMMAND="--profile $2"
            ;;
        -r)
            REGION=$2
            ;;
        --port)
            SOCKS_PORT=$2
            ;;
    esac
    shift 2
done

if [ "$1" == "" ]; then
   echo "Usage: $0 (-p aws-profile)? (-r aws-region)? (--port socks-port)? system-name"
   exit -1
fi 

SYSTEM=$1

if [ "$REGION" == "" ]; then
    REGION_ARG=
else
    REGION_ARG="--region $REGION"
fi

S3=`aws resourcegroupstaggingapi get-resources $REGION_ARG --resource-type-filters s3 --tag-filters Key=datomic:system,Values=$SYSTEM --query "ResourceTagMappingList | [].ResourceARN" --output text $PROFILE_COMMAND | sed -e 's/.*://g'`
if [ "$S3" == None ] || [ "$S3" == "" ]; then
    echo "Datomic system $SYSTEM not found, make sure your system name and AWS creds are correct."
    exit 1
fi
PK=~/.ssh/datomic-${REGION}-${SYSTEM}-bastion
aws s3 cp $PROFILE_COMMAND s3://${S3}/${SYSTEM}/datomic/access/private-keys/bastion $PK
if [ "$?" -ne 0 ]; then
    echo "Unable to read bastion key, make sure your AWS creds are correct."
    exit 1
fi
chmod 600 $PK
BASTION_IP=`aws ec2 describe-instances $REGION_ARG --filters Name=tag:Name,Values=${SYSTEM}-bastion Name=instance-state-name,Values=running --query Reservations[0].Instances[0].PublicIpAddress --output text $PROFILE_COMMAND`
if [ "$?" -ne 0 ] || [ "${BASTION_IP}" == None ]; then
    echo "Bastion not found, make sure bastion is running."
    exit 1
fi
ssh -v -o IdentitiesOnly=yes -i $PK -CND ${SOCKS_PORT:=8182} ec2-user@${BASTION_IP}


