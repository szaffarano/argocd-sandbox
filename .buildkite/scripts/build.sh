#!/usr/bin/env bash

set -euo pipefail

CGO_ENABLED=0 GOOS=linux go build
