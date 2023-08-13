#!/usr/bin/env bash

set -euo pipefail

mkdir "$HOME"
git config --global --add safe.directory $(pwd)

GIT_COMMIT="$(git rev-parse --short HEAD)"
VERSION="$(cat .version)"
IMAGE="szaffarano/argocd-sandbox"

docker build \
	-t "$IMAGE:latest" \
	--build-arg VERSION="$VERSION" \
	--build-arg GIT_COMMIT="$GIT_COMMIT" .

docker tag "$IMAGE:latest" "$IMAGE:$GIT_COMMIT"

echo $DOCKERHUB_TOKEN | docker login -u "$DOCKERHUB_USERNAME" --password-stdin

docker push "$IMAGE:latest"
docker push "$IMAGE:$GIT_COMMIT"
