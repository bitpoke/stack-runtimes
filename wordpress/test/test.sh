#!/usr/bin/env bash

# Copyright 2019 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o pipefail
export IMAGE="$1"

set -o nounset
if [ -z "${IMAGE}" ] ; then
    echo "Usage: test.sh TEST_IMAGE" >&2
    exit 1
fi

export PROJECT_ROOT=$(dirname "${BASH_SOURCE}")/../..
cd "${PROJECT_ROOT}"

TEST_IMAGE="${IMAGE}-test"

TEST_CONTEXT="wordpress/test/classic"

RUNTIME_IMAGE="${IMAGE}"
BUILDER_IMAGE="${IMAGE/bedrock/bedrock-build}"

if [[ $IMAGE == *"bedrock"* ]] ; then
    TEST_CONTEXT="wordpress/test/bedrock"
    if [[ $IMAGE == *"bedrock-build"* ]] ; then
        RUNTIME_IMAGE="${IMAGE/bedrock-build/bedrock}"
        BUILDER_IMAGE="${IMAGE}"
    fi
fi
if [[ $IMAGE == *"bedrock-php-8."* ]] ; then
    TEST_CONTEXT="wordpress/test/bedrock-php-8"
fi

export TEST_IMAGE

set -x

docker build -t "${TEST_IMAGE}" \
    --build-arg "BUILDER_IMAGE=${BUILDER_IMAGE}" \
    --build-arg "RUNTIME_IMAGE=${RUNTIME_IMAGE}" \
    -f "${TEST_CONTEXT}/Dockerfile" "${TEST_CONTEXT}"
hack/container-structure-test test --config wordpress/test/container-structure-test.yaml --image "$TEST_IMAGE"
hack/bats/bin/bats wordpress/test/e2e.bats
