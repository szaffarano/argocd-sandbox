#!/usr/bin/env bash

set -euo pipefail

function main {
  base_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$base_dir/common.sh"

  setup
  setup_docker_env

  GIT_COMMIT="$(git_revision)"
  VERSION="$(app_version)"
  IMAGE="$(docker_image)"

  docker build \
    -t "$IMAGE:latest" \
    --build-arg VERSION="$VERSION" \
    --build-arg GIT_COMMIT="$GIT_COMMIT" .

  docker tag "$IMAGE:latest" "$IMAGE:$GIT_COMMIT"
  docker push "$IMAGE:latest"
  docker push "$IMAGE:$GIT_COMMIT"
}

main "$@"
