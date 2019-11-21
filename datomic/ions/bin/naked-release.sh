#!/usr/bin/env sh

clojure -A:dev -m release "{:group \"${DEPLOYMENT_GROUP}\" :uname \"${UNAME}\" :region \"${REGION}\"}"
