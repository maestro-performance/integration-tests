#!/bin/bash

function cleanup() {
    /opt/maestro/maestro-cli/bin/maestro-cli maestro -m ${MAESTRO_BROKER} -c stop
}

export TEST_DURATION=5m 
export TEST_DESCRIPTION="${PRODUCT_NAME} test (AMQP) w/ ${MESSAGE_SIZE} bytes message (all-out)" 

echo "Running ${TEST_DESCRIPTION}"
/opt/maestro/maestro-cli/bin/maestro-cli maestro -m ${MAESTRO_BROKER} -c ping
/opt/maestro/maestro-cli/bin/maestro-cli exec -s /opt/maestro/maestro-cli/scripts/singlepoint/FixedRateTest.groovy

trap cleanup SIGTERM SIGINT

exit 0