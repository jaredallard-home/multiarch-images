#!/usr/bin/env bash
#
# Build all of the multi-arch docker images.
set -e

. builder.lib.sh

if ! command -v yq >/dev/null 2>&1; then
  echo "Error: missing yq"
  exit 1
fi

read -a images <<< "$(yq -r '.images | keys | join(" ")' < images.yaml)"

for image in "${images[@]}"; do
  echo " -> building '$image'"

  build_image "$image"
done