#!/usr/bin/env bash

set -eo pipefail

golint ./...
golangci-lint run
