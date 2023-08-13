#!/usr/bin/env bash

set -euo pipefail

go install golang.org/x/lint/golint@latest

$HOME/go/bin/golint ./...
