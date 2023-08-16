#!/usr/bin/env bash

function main {
  ensure_home
  configure_git
  setup_docker_env
}

function ensure_home {
  [ -d "$HOME" ] || mkdir "$HOME"
}

function configure_git {
  git config --global --add safe.directory "$(pwd)"
  git config --global user.email "no-reply@ci-bot"
  git config --global user.name "CI Bot"

  # TODO: configure gpg key to sign commits
}

function setup_docker_env {
  echo "$DOCKERHUB_TOKEN" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
}

main "$@"
