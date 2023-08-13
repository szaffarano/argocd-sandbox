#!/usr/bin/env bash

set -euo pipefail

[ -d "$HOME" ] || mkdir "$HOME"

git config --global --add safe.directory "$(pwd)"

GIT_COMMIT="$(git rev-parse --short HEAD)"
VERSION="$(cat .version)"
IMAGE="szaffarano/argocd-sandbox"

branch="release/$(cat .version)"

remote=$(
  git remote get-url origin | sed -E s"/https:\/\/(.*)/https:\/\/${GITHUB_TOKEN}@\1/g"
)

echo "$DOCKERHUB_TOKEN" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin

docker pull "$IMAGE:$GIT_COMMIT"
docker tag "$IMAGE:$GIT_COMMIT" "$IMAGE:$VERSION"
docker push "$IMAGE:$VERSION"

git config --global user.email "no-reply@ci-bot"
git config --global user.name "CI Bot"
git remote set-url origin "$remote"

git checkout -b "$branch"
echo "test" >flag
git add flag
git commit -m "Automated CI/CD commit" -m "[skip ci]"
git push origin "$branch"

gh pr create -b "Please review" -t "Bump version to $(cat .version)"
