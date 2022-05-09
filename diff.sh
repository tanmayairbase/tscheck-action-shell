#!/bin/bash

set -e

PR_NUMBER=$(jq -r ".pull_request.number" "$GITHUB_EVENT_PATH")

if [[ "$PR_NUMBER" == "null" ]]; then
  PR_NUMBER=$(jq -r ".issue.number" "$GITHUB_EVENT_PATH")
fi

if [[ "$PR_NUMBER" == "null" ]]; then
  echo "Failed to determine PR Number."
  exit 1
fi

echo "Collecting information about PR #$PR_NUMBER of $GITHUB_REPOSITORY..."

API_URI=https://api.github.com
API_HEADER="Accept: application/vnd.github.v3+json"
AUTH_HEADER="Authorization: token $GITHUB_TOKEN"

PR_RESP=$(curl -X GET -s -H "${AUTH_HEADER}" -H "${API_HEADER}" \
  "${API_URI}/repos/$GITHUB_REPOSITORY/pulls/$PR_NUMBER")

BASE_BRANCH=$(echo "$PR_RESP" | jq -r .base.ref)
HEAD_BRANCH=$(echo "$PR_RESP" | jq -r .head.ref)

if [[ -z "$BASE_BRANCH" ]]; then
  echo "Cannot get base branch information for PR #$PR_NUMBER!"
  exit 1
fi

set -o xtrace

git checkout $BASE_BRANCH && git pull
git checkout $HEAD_BRANCH && git pull

GIT_DIFF=$(git diff $BASE_BRANCH $HEAD_BRANCH)
ADD_COUNT=$(echo $GIT_DIFF | grep ^+ | grep @ts-nocheck | wc -l)
REMOVE_COUNT=$(echo $GIT_DIFF | grep ^- | grep @ts-nocheck | wc -l)

if [[ $ADD_COUNT > $REMOVE_COUNT ]]; then
  echo "Oh no! This PR introduces new @ts-nochecks :("
  exit 1
fi

exit 0