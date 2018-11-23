#!/bin/bash

function cleanup() {
    /opt/maestro/maestro-cli/bin/maestro-cli maestro -m ${MAESTRO_BROKER} -c stop
}

source /etc/maestro/test-profiles/$1.conf

if [[ ! -z "${SEND_RECEIVE_URL_OPTS}" ]] ; then
    export SEND_RECEIVE_URL="${SEND_RECEIVE_URL}?${SEND_RECEIVE_URL_OPTS}"
fi

echo "Running ${TEST_DESCRIPTION}"
/opt/maestro/maestro-cli/bin/maestro-cli maestro -m ${MAESTRO_BROKER} -c ping
/opt/maestro/maestro-cli/bin/maestro-cli exec -s /opt/maestro/maestro-cli/scripts/singlepoint/$2

trap cleanup SIGTERM SIGINT

exit 0