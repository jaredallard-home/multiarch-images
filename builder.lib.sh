#!/usr/bin/env bash

# Globals
platform="linux/amd64,linux/arm64"
baserepo="jaredallard"

build_image() {
  image="$1"

  if [[ ! -e "$image/Dockerfile" ]]; then
    echo "Error: image not found in curdir."
    exit 1
  fi

  repo=$(yq -r ".images[\"$image\"].repo" < images.yaml)
  name=$(yq -r ".images[\"$image\"].name" < images.yaml)
  version=$(yq -r ".images[\"$image\"].version" < images.yaml)
  language=$(yq -r ".images[\"$image\"].language" < images.yaml)

  if [[ -z "$repo" ]]; then
    echo "Error: missing repo in images.yaml"
    exit 1
  fi

  if [[ -z "$name" ]]; then
    echo "Error: missing name in images.yaml"
    exit 1
  fi

  if [[ -z "$version" ]]; then
    echo "Error: missing version in images.yaml"
    exit 1
  fi

  # Support version:tag_as_version format
  if [[ -n "$(awk -F ':' '{ print $2 }' <<< "$version")" ]]; then
    tag_version="$(awk -F ':' '{ print $2 }' <<< "$version")" 
    version="$(awk -F ':' '{ print $1 }' <<< "$version")"
  else
    tag_version="$version"
  fi

  if [[ ! -e "/tmp/$image" ]]; then
    git clone "https://$repo" "/tmp/$image"
  else
    pushd "/tmp/$image" >/dev/null || exit 1
    git checkout master
    git reset --hard HEAD
    git pull
    popd >/dev/null || exit 1
  fi

  echo "INFO: checking out $version"
  pushd "/tmp/$image" >/dev/null || exit 1
  git checkout "$version"
  popd >/dev/null || exit 1

  # copy our Dockerfile over an overwrite a previously existing one, if it exists
  cp -v "$image/"* "$image/".[^.]* "/tmp/$image/" || true

  pushd "/tmp/$image" >/dev/null || exit 1
  if [[ ! -e "go.mod" ]] && [[ "$language" == "go" ]]; then
    echo "INFO: JIT adding go module support"
    go mod init "$repo"
    go mod download
  fi

  echo "INFO: Building docker image"
  docker buildx build --platform "$platform" -t "$baserepo/$name:$tag_version" --build-arg "VERSION=$version" -f Dockerfile --push .
  popd >/dev/null || exit 1
}