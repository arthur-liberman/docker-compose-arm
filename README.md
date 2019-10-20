# native docker-compose binaries

This repository contains helpers to build a docker-compose binary natively. It can be used on x86_64 and on other platforms, such as armhf/arm32 and aarch64/arm64. This project exists because, currently, docker-compose [releases](https://github.com/docker/compose/releases) do not include arm binaries.

## To build

```bash
docker build . -t docker-compose-builder --build-arg TARGET=arm32v7 --build-arg VERSION=1.24.1
docker run --rm -v "$(pwd)":/dist docker-compose-builder
# this will generate a `docker-compose-1.24.1-Linux-arm32v7` in "$(pwd)"
# you can change the TARGET and VERSION variables to build for other architectures and/or versions of docker-compose.
# if you remove TARGET, docker-compose will be built for the current architecture.
# if you remove VERSION, docker-compose will be built from source code in the master branch.
```

