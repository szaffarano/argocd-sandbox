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
  title="Bump version $VERSION"

  msg_file="$(mktemp)"
  trap rm "$msg_file" EXIT

  cat <<EOF >"$msg_file"
    Bump version $VERSION

    [skip ci]
EOF

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

  git commit -m "$title" -m "[skip ci]"
  git push origin "$branch"

  gh pr create -F "$msg_file" -t "$title"
}

main "$@"
