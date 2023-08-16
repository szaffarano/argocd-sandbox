#!/usr/bin/env bash

set -euo pipefail

function main {
  docker build \
    -t "$IMAGE:latest" \
    --build-arg VERSION="$VERSION" \
    --build-arg GIT_COMMIT="$GIT_COMMIT" .

  docker tag "$IMAGE:latest" "$IMAGE:$GIT_COMMIT"
  docker push "$IMAGE:latest"
  docker push "$IMAGE:$GIT_COMMIT"
}

main "$@"
