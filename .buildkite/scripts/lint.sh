#!/usr/bin/env bash

set -euo pipefail

go install golang.org/x/lint/golint@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

$HOME/go/bin/golint ./...
$HOME/go/bin/golangci-lint run
