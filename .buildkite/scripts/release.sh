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
  branch="release/$VERSION"
  msg="Bump version to $VERSION"

  echo "Doing release --- ENV ---"
  env
  echo "Doing release --- /ENV ---"

  echo ":release: About to release $VERSION"

  docker build \
    -t "$IMAGE:latest" \
    --build-arg VERSION="$VERSION" \
    --build-arg GIT_COMMIT="$GIT_COMMIT" .

  docker tag "$IMAGE:latest" "$IMAGE:$GIT_COMMIT"
  docker tag "$IMAGE:latest" "$IMAGE:$VERSION"

  docker push "$IMAGE:latest"
  docker push "$IMAGE:$GIT_COMMIT"
  docker push "$IMAGE:$VERSION"

  git checkout -b "$branch"

  grep -lr newTag infra/k8s/overlays/production | while read -r f; do
    sed -i s"/newTag: .*/newTag: $VERSION/g" "$f"
  done

  git add infra/k8s/overlays/production

  git commit -m "$msg" -m "[skip ci]"
  git push origin "$branch"

  gh pr create -b "Please review" -t "$msg"
}

main "$@"
