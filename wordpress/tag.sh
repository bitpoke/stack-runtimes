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
cat <<EOF | docker run --rm -i "${IMAGE}" php
<?php
\$wp_version = "";
if ( file_exists( '/app/web/wp/wp-includes/version.php' ) ) {
    include_once '/app/web/wp/wp-includes/version.php';
}

\$subtag = "";
if ( preg_match( "/^[0-9.]+-(.*?)$/s", "${DEFAULT_TAG}", \$m ) ) {
    \$subtag = "-\$m[1]";
}

\$main_tag = "${DEFAULT_TAG}";
if ( preg_match( "/^(.*?)-php-[0-9]+\\.[0-9]+$/s", "${DEFAULT_TAG}", \$m ) ) {
    \$main_tag = \$m[1];
}

if ( ! empty( \$wp_version ) ) {
    echo \$wp_version . \$subtag . "${TAG_SUFFIX_SLUG}" . PHP_EOL;
    echo \$wp_version . "-php-" . PHP_MAJOR_VERSION . "." . PHP_MINOR_VERSION . "${TAG_SUFFIX_SLUG}" . PHP_EOL;
} else {
    echo \$main_tag . "-php-" . PHP_MAJOR_VERSION . "." . PHP_MINOR_VERSION . "${TAG_SUFFIX_SLUG}" . PHP_EOL;
    echo \$main_tag . "-php-" . PHP_VERSION . "${TAG_SUFFIX_SLUG}" . PHP_EOL;
}
EOF
