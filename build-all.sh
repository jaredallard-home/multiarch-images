#!/usr/bin/env bash
#
# Build all of the multi-arch docker images.

set -e

platform="linux/amd64,linux/arm64"
baserepo="jaredallard"

if ! command -v yq >/dev/null 2>&1; then
  echo "Error: missing yq"
  exit 1
fi

read -a images <<< "$(yq -r '.images | keys | join(" ")' < images.yaml)"

for image in "${images[@]}"; do
  echo " -> building '$image'"

  if [[ ! -e "$image/Dockerfile" ]]; then
    echo "Error: image not found in curdir."
    exit 1
  fi

  repo=$(yq -r ".images[\"$image\"].repo" < images.yaml)
  name=$(yq -r ".images[\"$image\"].name" < images.yaml)
  version=$(yq -r ".images[\"$image\"].version" < images.yaml)

  if [[ ! -e "/tmp/$image" ]]; then
    git clone "https://$repo" "/tmp/$image"
  else
    pushd "/tmp/$image" >/dev/null || exit 1
    git checkout master
    git pull
    popd >/dev/null || exit 1
  fi

  cp "$image/Dockerfile" "/tmp/$image/Dockerfile"

  pushd "/tmp/$image" >/dev/null || exit 1
  git checkout "$version"

  if [[ ! -e "go.mod" ]]; then
    echo "INFO: JIT adding go module support"
    go mod init "$repo"
    go mod download
  fi

  echo "INFO: Building docker image"
  docker buildx build --platform "$platform" -t "$baserepo/$name:$version" --build-arg "VERSION=$version" -f Dockerfile --push .
  docker rmi "$baserepo/$name:$version"
  popd >/dev/null || exit 1
done