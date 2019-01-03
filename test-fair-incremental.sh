#!/bin/bash

function cleanup() {
    echo "Cleaning up the SUT"
    docker rmi -f work_sut
    if [[ $? != 0 ]] ; then
        echo "Failed to remove the SUT image (ignoring ...)"
    fi
}

function runTest() {
    docker-compose -f docker-compose.yml -f $1 up --scale worker=2 --scale agent=0 --scale inspector=0 -d
    if [[ $? != 0 ]] ; then
        echo "Mini-cluster setup failed"
        exit 1
    fi


    echo "Waiting 10s for the infra to come up"
    sleep 10s

    echo "Launching the test execution"
    docker run -h maestro_client -v "$PWD"/results/incremental:/maestro/tests/results --network=work_cluster \
        -e PRODUCT_NAME="$2" -e TEST_XUNIT_NAME="$3" \
        -e SEND_RECEIVE_URL_OPTS="$4" \
        maestro-test-client /usr/bin/test-runner.sh amqp/fair-incremental FairIncrementalTest.groovy
    if [[ $? != 0 ]] ; then
        echo "Test execution failed"
        exit 1
    fi

    echo "Waiting 30s for the system to quiesce and shutdown"
    sleep 30s

    echo "Shutting down the Maestro mini-cluster"
    docker-compose -f docker-compose.yml -f $1 down
    cleanup
}

# Artemis 2.6
function testArtemis() {
    local productName="Apache Artemis 2.6.3"

    echo "Launching a SUT instance w/ ${productName}"
    runTest suts/docker-artemis-compose.yml "${productName}" "incremental-artemis"
}


# MQ Light
function testIbmMqLight() {
    local productName="IBM MQ Light"

    echo "Launching a SUT instance w/ ${productName}"
    wget -c https://gist.githubusercontent.com/orpiske/43574edf7c6c3ef150550c70820c25b8/raw/21def540f911ac8bdbfe9bd899521e924a76c018/docker-ibmmqlight-compose.yml -O suts/docker-ibmmqlight-compose.yml

    runTest suts/docker-ibmmqlight-compose.yml "${productName}" "incremental-ibm-mq-light"
}

# Apache ActiveMQ
function testActiveMQ() {
    local productName="Apache ActiveMQ 5.15.3"

    echo "Launching a SUT instance w/ ${productName}"

    runTest suts/docker-activemq-compose.yml "${productName}" "incremental-activemq"
}

# Interconnect
function testQpidDispatch() {
    local productName="QPID Dispatch Router"

    echo "Launching a SUT instance w/ ${productName}"
    runTest suts/docker-interconnect-compose.yml "${productName}" "incremental-qpid-dispatch-router" "jms.closeTimeout=500&jms.requestTimeout=2000&jms.sendTimeout=1000"
}

# QpidCPP
function testQpidCpp() {
    local productName="QPid CPP Broker"

    echo "Launching an experimental SUT instance w/ ${productName}" "incremental-qpid-cpp"
    localDir="$(dirname $0)"

    echo "Building the SUT image for the test"
    docker build -t maestro_test_qpid ${localDir}/suts/qpid/

    runTest ${localDir}/suts/qpid/docker-compose.yml "${productName}"
}

# RabbitMQ
function testRabbitMq() {
    local productName="RabbitMQ"

    echo "Launching an experimental SUT instance w/ ${productName}"

    localDir="$(dirname $0)"

    echo "Building the SUT image for the test"
    docker build -t maestro_test_rabbitmq ${localDir}/suts/rabbitmq/

    runTest ${localDir}/suts/rabbitmq/docker-compose.yml "${productName}" "incremental-rabbitmq"
}

trap cleanup SIGTERM SIGINT

case "${1}" in
        artemis)
                testArtemis
                ;;
        activemq)
                testActiveMQ
                ;;
        ibmmqlight)
                testIbmMqLight
                ;;
        qpid-dispatch)
                testQpidDispatch
                ;;
        qpid-cpp)
                testQpidCpp
                ;;
        rabbitmq)
                testRabbitMq
                ;;
        all)
              testArtemis
              testActiveMQ
              testQpidDispatch
              ;;
        *)
            echo "Invalid option"
            ;;

esac

exit 0