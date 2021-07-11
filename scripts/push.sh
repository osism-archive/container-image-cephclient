#!/usr/bin/env bash
set -x

# Available environment variables
#
# DOCKER_REGISTRY
# REPOSITORY
# VERSION

DOCKER_REGISTRY=${DOCKER_REGISTRY:-quay.io}
REVISION=$(git rev-parse HEAD)

if [[ -n $DOCKER_REGISTRY ]]; then
    REPOSITORY="$DOCKER_REGISTRY/$REPOSITORY"
fi

# push e.g. osism/cephclient:pacific
docker tag "$REPOSITORY:$REVISION" "$REPOSITORY:$VERSION"
docker push "$REPOSITORY:$VERSION"

# push e.g. osism/cephclient:16.2.5
version=$(docker run --rm "$REPOSITORY:$VERSION" ceph --version | awk '{ print $3 }')

if DOCKER_CLI_EXPERIMENTAL=enabled docker manifest inspect "${REPOSITORY}:${version}" > /dev/null; then
    echo "The image ${REPOSITORY}:${version} already exists."
else
    docker tag "$REPOSITORY:$REVISION" "$REPOSITORY:$version"
    docker push "$REPOSITORY:$version"
fi
