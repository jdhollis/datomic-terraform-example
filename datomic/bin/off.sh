#!/usr/bin/env bash

asg=$(terraform output datomic_autoscaling_group_name)

aws autoscaling update-auto-scaling-group --profile ops-dev --region us-east-1 --auto-scaling-group-name ${asg} --min-size 0 --desired-capacity 0
