#!/bin/bash

# Create the container image providing the `native-image` executable from the Mandrel project
# Usage: build-mandrel-images.sh version-of-the-mandrel-module
# Example:
#    build-mandrel-images.sh 20.1.0.1.Final-java11


set -e

PREFIX_NAME=quay.io/quarkus/ubi-quarkus-mandrel
IMAGE=quarkus-mandrel.yaml
BUILD_ENGINE=${BUILD_ENGINE:-docker}
VERSION=$1
OVERRIDES="{'version': '${VERSION}', 'modules': {'install': [{'name':'mandrel', 'version': '${VERSION}'}]}}"

virtualenv --python=python3 .cekit
source .cekit/bin/activate

# Add s2i in the PATH - required for testing
export PATH=$PATH:$PWD/s2i
echo "Path is $PATH"
s2i version

echo "Generating ${PREFIX_NAME}:${VERSION}"
cekit --descriptor ${IMAGE} build \
    --overrides "${OVERRIDES}" \
    ${BUILD_ENGINE} --tag="${PREFIX_NAME}:${VERSION}"

echo "Verifying ${PREFIX_NAME}:${VERSION}"
cekit test \
   --image ${PREFIX_NAME}:${VERSION} \
   --overrides-file ${IMAGE} \
   --overrides "${OVERRIDES}" \
    behave \
   --steps-url https://github.com/cescoffier/behave-test-steps

