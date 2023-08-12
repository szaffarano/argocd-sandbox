#!/usr/bin/env bash

set -euo pipefail

echo "---------- env ----------"
env
echo "---------- /env ----------"

rustup component add rustfmt

cargo fmt --all -- --check
