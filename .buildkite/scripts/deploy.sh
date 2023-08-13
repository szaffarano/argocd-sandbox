#!/usr/bin/env bash

set -euo pipefail

GIT_COMMIT="$(git rev-parse --short HEAD)"
VERSION="$(cat .version)"
IMAGE="szaffarano/argocd-sandbox"

docker build \
	-t "$IMAGE:latest" \
	--build-arg VERSION="$VERSION" \
	--build-arg GIT_COMMIT="$GIT_COMMIT" .

docker tag "$IMAGE:latest" "$IMAGE:$VERSION"

echo $DOCKERHUB_TOKEN | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
