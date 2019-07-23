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
DEFAULT_TAG="$1"
IMAGE="$2"

TAG_SUFFIX_SLUG=""
if [ -n "${TAG_SUFFIX}" ]; then
    TAG_SUFFIX_SLUG="-${TAG_SUFFIX}"
fi

set -o nounset
if [ -z "${DEFAULT_TAG}" ]; then
    echo "Usage: tags.sh DEFAULT_TAG [IMAGE]" >&2
    exit 1
fi

PROJECT_ROOT=$(dirname "${BASH_SOURCE[0]}")/../..
cd "${PROJECT_ROOT}"

echo "${DEFAULT_TAG}${TAG_SUFFIX_SLUG}"
docker run --rm "${IMAGE}" php -r "echo PHP_VERSION . \"${TAG_SUFFIX_SLUG}\n\";"
