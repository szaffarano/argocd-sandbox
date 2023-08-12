#!/usr/bin/env bash

set -euo pipefail

echo "---------- env ----------"
env
echo "---------- /env ----------"

echo "------- I should not show GITHUB_TOKEN:${GITHUB_TOKEN}!!!"

rustup component add rustfmt

cargo fmt --all -- --check
