#!/usr/bin/env bash

set -euo pipefail

go get -u golang.org/x/lint/golint
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

golint ./...
golangci-lint run
