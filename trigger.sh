#!/bin/bash

# Trigger builds on travis using GitHub username and password
# https://docs.travis-ci.com/api?http#creating-a-temporary-github-token
# 
# For example, to build arduino:
# bash <(curl -s https://raw.githubusercontent.com/probonopd/AppImages/master/trigger.sh) arduino

set +e

USERNAME=probonopd
PROJECT=AppImages

USER_AGENT='Travis/1.8.0 (Compatible; curl '$(curl --version | head -n 1 | cut -d " " -f 1-4)')'

echo $@
MATRIX=""
for RECIPE in $@ ; do
  MATRIX="\"RECIPE=$RECIPE\",$MATRIX"
done
MATRIX=$(echo -n $MATRIX | head -c -1 ) # Remove extra comma at the end

read -s -p "GitHub Password: " PASSWORD
if [ "$PASSWORD" == "" ] ; then
  exit 1
else
  echo ""
fi

#########################################################
echo "Delete the GitHub authorization at the end"
#########################################################

trap atexit EXIT

atexit()
{    
  set +e

  RESL=$(curl -u $USERNAME:$PASSWORD -k -s -X DELETE \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    $GH_AUTH_URL)

  echo $RESL
}

#########################################################
echo "Create a temporary GitHub authorization"
#########################################################

body='{
  "scopes": [
    "read:org", "user:email", "repo_deployment",
    "repo:status", "write:repo_hook"
  ],
  "note": "temporary token to auth against travis"
}'

RES1=$(curl -k -u $USERNAME:$PASSWORD -s -X POST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "$body" \
  https://api.github.com/authorizations)

echo $RES1

GH_TOKEN=$(echo $RES1 | grep -Po '"token":.*?[^\\]",' | cut -d '"' -f 4 | head -n 1)
GH_AUTH_URL=$(echo $RES1 | grep -Po '"url":.*?[^\\]",' | cut -d '"' -f 4| head -n 1)

#########################################################
echo "Get a travis token using the GitHub token"
#########################################################

RES2=$(curl -A "$USER_AGENT" -k -s -X POST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"github_token":"'$GH_TOKEN'"}' \
  https://api.travis-ci.org/auth/github)

echo $RES2

TRAVIS_TOKEN=$(echo $RES2 | cut -d '"' -f 4 | head -n 1)
echo $TRAVIS_TOKEN

[ $TRAVIS_TOKEN == "error" ] && exit 1

#########################################################
echo "Trigger a build"
#########################################################

body='{
  "request": {
    "message": "Build triggered by api request",
    "branch":"master",
    "config": {
      "env": {
        "matrix": ['$MATRIX']
      }
    }
  }
}'
echo $body
curl -A "$USER_AGENT" -k -s -X POST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Travis-API-Version: 3" \
  -H "Authorization: token $TRAVIS_TOKEN" \
  -d "$body" \
  https://api.travis-ci.org/repo/$USERNAME%2F$PROJECT/requests
