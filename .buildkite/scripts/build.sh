#!/usr/bin/env bash

set -euo pipefail

RUN CGO_ENABLED=0 GOOS=linux go build
