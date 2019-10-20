# Optional user specified target architecture
ARG TARGET

# Dockerfile to build docker-compose
FROM ${TARGET}${TARGET:+/}python:3.6.5-stretch

# Add env
ENV LANG C.UTF-8

# "six" is needed for PyInstaller. v1.11.0 is the latest as of PyInstaller 3.3.1
ENV SIX_VER 1.11.0

# Install dependencies
# RUN apt-get update && apt-get install -y
RUN pip install --upgrade pip six==$SIX_VER

# docker-compose requires pyinstaller 3.3.1 (check github.com/docker/compose/requirements-build.txt)
# If this changes, you may need to modify the version of "six" below
ENV PYINSTALLER_VER 3.3.1
# Compile the pyinstaller "bootloader"
# https://pyinstaller.readthedocs.io/en/stable/bootloader-building.html
WORKDIR /build/pyinstallerbootloader
RUN curl -fsSL https://github.com/pyinstaller/pyinstaller/releases/download/v$PYINSTALLER_VER/PyInstaller-$PYINSTALLER_VER.tar.gz | tar xvz >/dev/null \
    && cd PyInstaller*/bootloader \
    && python3 ./waf all

ARG VERSION
# Set the versions
ENV DOCKER_COMPOSE_VER ${VERSION:-master}
# Clone docker-compose
WORKDIR /build/dockercompose
RUN git clone https://github.com/docker/compose.git . \
    && git checkout $DOCKER_COMPOSE_VER

ARG TARGET
# Run the build steps (taken from github.com/docker/compose/script/build/linux-entrypoint)
RUN mkdir ./dist \
    && pip install -q -r requirements.txt -r requirements-build.txt \
    && ./script/build/write-git-sha \
    && pyinstaller docker-compose.spec \
    && mv -v dist/docker-compose ./docker-compose-$DOCKER_COMPOSE_VER-$(uname -s)-${TARGET:-$(uname -m)}

# Copy out the generated binary
VOLUME /dist
CMD cp docker-compose-* /dist
