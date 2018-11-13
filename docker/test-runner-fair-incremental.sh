#!/bin/bash

function cleanup() {
    /opt/maestro/maestro-cli/bin/maestro-cli maestro -m ${MAESTRO_BROKER} -c stop
}


export MAXIMUM_LATENCY=100 COMBINED_INITIAL_RATE=200 COMBINED_CEILING_RATE=10000 STEPS=10 INITIAL_PARALLEL_COUNT=2 CEILING_PARALLEL_COUNT=2 PARALLEL_COUNT_INCREMENT=0 TEST_DURATION=5m
export TEST_DESCRIPTION="${PRODUCT_NAME} test (AMQP) w/ ${MESSAGE_SIZE} bytes message (incremental)"

if [[ ! -z "${SEND_RECEIVE_URL_OPTS}" ]] ; then
    export SEND_RECEIVE_URL="${SEND_RECEIVE_URL}?${SEND_RECEIVE_URL_OPTS}"
fi

echo "Running ${TEST_DESCRIPTION}"
/opt/maestro/maestro-cli/bin/maestro-cli maestro -m ${MAESTRO_BROKER} -c ping
/opt/maestro/maestro-cli/bin/maestro-cli exec -s /opt/maestro/maestro-cli/scripts/singlepoint/FairIncrementalTest.groovy

trap cleanup SIGTERM SIGINT

exit 0