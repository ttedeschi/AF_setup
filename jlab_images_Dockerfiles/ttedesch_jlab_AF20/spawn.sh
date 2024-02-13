#!/usr/bin/env bash

curl -d grant_type=urn:ietf:params:oauth:grant-type:token-exchange \
   -u $IAM_CLIENT_ID:$IAM_CLIENT_SECRET \
   -d audience="https://wlcg.cern.ch/jwt/v1/any" \
   -d subject_token=$ACCESS_TOKEN \
   -d scope="openid profile wlcg wlcg.groups" \
   https://cms-auth.web.cern.ch/token \
   | tee /tmp/response | jq .access_token |  tr -d '"' |  tr -d '\n'> /tmp/token

while true; do
    curl -d grant_type=urn:ietf:params:oauth:grant-type:token-exchange \
        -u $IAM_CLIENT_ID:$IAM_CLIENT_SECRET \
        -d audience="https://wlcg.cern.ch/jwt/v1/any" \
        -d subject_token=`cat /tmp/token` \
        -d scope="openid profile wlcg wlcg.groups" \
        https://cms-auth.web.cern.ch/token \
        | tee /tmp/response | jq .access_token |  tr -d '"' |  tr -d '\n'> /tmp/token_tmp \
    && cp /tmp/token_tmp /tmp/token
    sleep 72000
done &
