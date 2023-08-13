#!/usr/bin/env bash

set -euo pipefail

rustup component add rustfmt

cargo fmt --all -- --check
