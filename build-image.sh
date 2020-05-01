#!/usr/bin/env bash
#
# Build a multi-arch docker image.
set -e

. builder.lib.sh

if ! command -v yq >/dev/null 2>&1; then
  echo "Error: missing yq"
  exit 1
fi

if [[ -z "$1" ]]; then
  echo "usage: build-image.sh <image>"
  exit 1
fi

build_image "$1"