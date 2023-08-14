#!/usr/bin/env bash

set -euo pipefail

function setup {
  ensure_home
  configure_git
}

function ensure_home {
  [ -d "$HOME" ] || mkdir "$HOME"
}

function configure_git {
  git config --global --add safe.directory "$(pwd)"
  git config --global user.email "no-reply@ci-bot"
  git config --global user.name "CI Bot"
}

function git_revision {
  git rev-parse --short HEAD
}

function app_version {
  if [ -n "${BUILDKITE_TAG:-}" ]; then
    echo "$BUILDKITE_TAG"
  else
    echo "$(git_revision)-dev"
  fi
}

function docker_image {
  echo "szaffarano/argocd-sandbox"
}

function setup_git_remote {
  remote=$(
    git remote get-url origin | sed -E s"/https:\/\/(.*)/https:\/\/${GITHUB_TOKEN}@\1/g"
  )
  git remote set-url origin "$remote"
}

function setup_docker_env {
  echo "$DOCKERHUB_TOKEN" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
}
