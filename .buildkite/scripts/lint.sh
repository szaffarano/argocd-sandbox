#!/usr/bin/env bash

rustup component add rustfmt

cargo fmt --all -- --check
