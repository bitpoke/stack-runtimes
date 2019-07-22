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

install-wordpress() {
    docker-compose exec -T wordpress wp core install \
        --url=http://${TEST_HOSTNAME}:${TEST_PORT} \
        --title="Test: ${BATS_TEST_NAME}" \
        --admin_user=admin \
        --admin_email=admin@example.com \
        --admin_password=not-secure
}

setup() {
    [ -n "$TEST_IMAGE" ]
    TEST_TMP_DIR=$(mktemp -d)
    cp "$BATS_TEST_DIRNAME/docker-compose.yml" "$TEST_TMP_DIR"
    TEST_PORT="$((30000 + RANDOM % 1000))"
    export TEST_PORT
    docker-compose up -d
    docker-compose exec -T wordpress dockerize -wait tcp://mysql:3306 -timeout 30s
}

teardown() {
    docker-compose logs --no-color wordpress
    docker-compose rm -fs
    [ -d "$TEST_TMP_DIR" ] && rm -rf "$TEST_TMP_DIR"
}

@test "serves WordPress on the chosen PORT" {
    install-wordpress
    local http_status_code=$(curl -s -o /dev/null -w "%{http_code}" "http://${TEST_HOSTNAME}:${TEST_PORT}")
    echo "HTTP Request: http://${TEST_HOSTNAME}:${TEST_PORT}"
    echo "HTTP Response Code: ${http_status_code}"
    [ "$http_status_code" -eq 200 ]
}
