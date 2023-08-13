#!/usr/bin/env bash

set -euo pipefail

[ -d "$HOME" ] || mkdir "$HOME"

branch="release/$(cat .version)"

remote=$(
	git remote get-url origin | sed -E s"/https:\/\/(.*)/https:\/\/${GITHUB_TOKEN}@\1/g"
)

git config --global user.email "no-reply@ci-bot"
git config --global user.name "CI Bot"
git remote set-url origin "$remote"

git checkout -b "$branch"
echo "test" > flag
git add flag
git commit -m "Automated CI/CD commit"
git push origin "$branch"

gh pr create -b "Please review" -t "Bump version to $(cat .version)"
