#!/usr/bin/env bash

set -euo pipefail

function main {
  local branch
  local title
  local k8s_base

  setup_git_remote

  branch="release/$VERSION"
  title="Bump version $VERSION"
  k8s_base="infra/k8s/overlays/production"

  msg_file="$(mktemp)"

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

  grep -lr newTag "$k8s_base" | while read -r f; do
    sed -i s"/newTag: .*/newTag: $VERSION/g" "$f"
  done

  git add "$k8s_base"

  git commit -m "$title" -m "[skip ci]"
  git push origin "$branch"

  gh pr create -F "$msg_file" -t "$title"
}

function setup_git_remote {
  remote=$(
    git remote get-url origin | sed -E s"/https:\/\/(.*)/https:\/\/${GITHUB_TOKEN}@\1/g"
  )
  git remote set-url origin "$remote"
}

main "$@"
