#!/usr/bin/env bats

NOW="$(date +%s)"
TEST_PORT="8080"
TEST_TMP_DIR=""
: "${TEST_HOSTNAME:=localhost}"

docker-compose() {
    local _orig="$(which docker-compose)"
    if [ -f "${_orig}" ] ; then
        cd "$TEST_TMP_DIR" && ${_orig} "$@"
    else
        echo "Could not find docker-compose." >&2
        return 1
    fi
}

wp() {
    docker-compose exec -T wordpress wp "$@"
}

install-wordpress() {
    wp core install \
            --url=http://${TEST_HOSTNAME}:${TEST_PORT} \
            --title="Test: ${BATS_TEST_NAME}" \
            --admin_user=admin \
            --admin_email=admin@example.com \
            --admin_password=not-secure
    wp option update siteurl "http://${TEST_HOSTNAME}:${TEST_PORT}/wp"
}

request() {
    local url="$1"
    echo ">>> Request: ${url}"
    read http_status_code http_redirect_url <<< "$(curl -sv -o /dev/stderr -w "%{http_code} %{redirect_url}" "${url}")"
    echo ">>> Response Code: ${http_status_code}"
    echo ">>> Redirect URL: ${http_redirect_url}"
}

setup() {
    [ -n "$TEST_IMAGE" ]
    TEST_TMP_DIR=$(mktemp -d)
    cp "$BATS_TEST_DIRNAME/docker-compose.yml" "$TEST_TMP_DIR"
    TEST_PORT="$((30000 + RANDOM % 1000))"
    export TEST_PORT
    export TEST_HOSTNAME
    docker-compose up -d
    docker-compose exec -T wordpress dockerize -wait tcp://mysql:3306 -timeout 30s
    http_status_code=0
    http_redirect_url=""
}

teardown() {
    docker-compose logs --no-color wordpress
    docker-compose rm -fs
    [ -d "$TEST_TMP_DIR" ] && rm -rf "$TEST_TMP_DIR"
}

@test "serves WordPress on the chosen PORT" {
    install-wordpress
    local url="http://${TEST_HOSTNAME}:${TEST_PORT}"
    request "$url"
    [ "$http_status_code" -eq 200 ]
    [ -z "$http_redirect_url" ]
}

@test "WordPress is installed as subdirectory" {
    install-wordpress
    local url="http://${TEST_HOSTNAME}:${TEST_PORT}/wp-admin/"
    request "$url"
    [ "$http_status_code" -eq 302 ]
    [ "$http_redirect_url" == "http://${TEST_HOSTNAME}:${TEST_PORT}/wp/wp-admin/" ]
}
