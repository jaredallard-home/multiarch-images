# multiarch docker images

These are some repos that have been forked / pinned to different versions with specific Dockerfiles.

# Availability

Each of the Dockerfiles here are accessible at `jaredallard` under the `name` in the `images.yaml` file in the root of this repository. Each version is tagged, according to the version in that yaml file as well. There is no `latest`.

## Supported Platforms

Currently the following platforms are supported:

 * arm64
 * amd64

ARMv7 is not supported due to the lack of ARMv7 images in the k8s community. You can install ARM64 host images on the Raspberry Pi 4 and 3B+ (ubuntu 20.04 provides them).

## License

Apache-2.0