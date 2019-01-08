#!/bin/bash

function cleanup() {
    /opt/maestro/maestro-cli/bin/maestro-cli maestro -m ${MAESTRO_BROKER} -c stop
    /opt/maestro/maestro-cli/bin/maestro-cli maestro -m ${MAESTRO_BROKER} -c unassign
}

if [[ ! -f /etc/maestro/test-profiles/$1.conf ]] ; then
    echo "The test configuration file is missing. Running with default parameters"
else
    source /etc/maestro/test-profiles/$1.conf
fi


if [[ ! -z "${SEND_RECEIVE_URL_OPTS}" ]] ; then
    export SEND_RECEIVE_URL="${SEND_RECEIVE_URL}?${SEND_RECEIVE_URL_OPTS}"
fi

echo "########### ENV START ###########"
env
echo "########### ENV END ###########"

echo "Setting up cleanup trap"
trap cleanup SIGTERM SIGINT

echo "Running ${TEST_DESCRIPTION}"
/opt/maestro/maestro-cli/bin/maestro-cli maestro -m ${MAESTRO_BROKER} -c ping
/opt/maestro/maestro-cli/bin/maestro-cli exec -s /opt/maestro/maestro-cli/scripts/singlepoint/$2


exit 0