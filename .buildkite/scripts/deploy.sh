#!/usr/bin/env bash

set -euo pipefail

function main {
  "$(dirname "${BASH_SOURCE[0]}")"/setup.sh

  docker build \
    -t "$IMAGE:latest" \
    --build-arg VERSION="$VERSION" \
    --build-arg GIT_COMMIT="$GIT_COMMIT" .

  echo "pushing docker image"

  docker tag "$IMAGE:latest" "$IMAGE:$GIT_COMMIT"
  docker push "$IMAGE:latest"
  docker push "$IMAGE:$GIT_COMMIT"
}

main "$@"
