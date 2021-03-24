#!/usr/bin/env bash
set -x

# Available environment variables
#
# BUILD_OPTS
# DOCKER_REGISTRY
# REPOSITORY
# UBUNTU_VERSION
# VERSION

# Set default values

BUILD_OPTS=${BUILD_OPTS:-}
CREATED=$(date --rfc-3339=ns)
DOCKER_REGISTRY=${DOCKER_REGISTRY:-quay.io}
REVISION=$(git rev-parse HEAD)
UBUNTU_VERSION=${UBUNTU_VERSION:-18.04}
VERSION=${VERSION:-latest}

if [[ -n $DOCKER_REGISTRY ]]; then
    REPOSITORY="$DOCKER_REGISTRY/$REPOSITORY"
fi

docker buildx build \
    --load \
    --build-arg "VERSION=$VERSION" \
    --build-arg "UBUNTU_VERSION=$UBUNTU_VERSION" \
    --tag "$REPOSITORY:$REVISION" \
    --label "org.opencontainers.image.created=$CREATED" \
    --label "org.opencontainers.image.revision=$REVISION" \
    --label "org.opencontainers.image.version=$VERSION" \
    $BUILD_OPTS .
