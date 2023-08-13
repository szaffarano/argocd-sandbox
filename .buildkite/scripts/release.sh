#!/usr/bin/env bash

set -euo pipefail

function main {
  base_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$base_dir/common.sh"

  setup
  setup_git_remote
  setup_docker_env

  GIT_COMMIT="$(git_revision)"
  VERSION="$(app_version)"
  IMAGE="$(docker_image)"
  branch="release/$(cat .version)"
  msg="Bump version to $VERSION"

  docker pull "$IMAGE:$GIT_COMMIT"
  docker tag "$IMAGE:$GIT_COMMIT" "$IMAGE:$VERSION"
  docker push "$IMAGE:$VERSION"

  git checkout -b "$branch"

  grep -lr newTag infra/k8s/overlays/production | while read -r f; do
    sed s"/newTag: .*/newTag: $VERSION/g" "$f"
  done

  git commit -m "$msg" -m "[skip ci]"
  git push origin "$branch"

  gh pr create -b "Please review" -t "$msg"
}

main "$@"
