############## ALl out ###########################

function cleanup() {
    echo "Cleaning up the SUT"
    docker rmi -f maestro_sut  || true
}


function runTest() {
    echo "Launching a SUT instance w/ Apache Artemis"
    docker-compose -f docker-compose.yml -f $1 up --scale worker=2 --scale agent=0 --scale inspector=0 -d
    echo "Waiting 10s for the infra to come up"
    sleep 10s

    echo "Launching the test execution"
    docker run -it -h maestro_client -v maestro:/maestro --network=work_cluster -e PRODUCT_NAME="Artemis 2.6.3" maestro-test-client /usr/bin/test-runner-all-out.sh

    echo "Waiting 30s for the system to quiesce and shutdown"
    sleep 30s

    echo "Shutting down the Maestro mini-cluster"
    docker-compose -f docker-compose.yml -f $1 down
    cleanup
}

# Artemis 2.6
function testArtemis() {
    echo "Launching a SUT instance w/ Apache Artemis"
    runTest suts/docker-artemis-compose.yml
}


# MQ Light
function testIbmMqLight() {
    echo "Launching a SUT instance w/ IBM MQ Light"
    wget -c https://gist.githubusercontent.com/orpiske/43574edf7c6c3ef150550c70820c25b8/raw/21def540f911ac8bdbfe9bd899521e924a76c018/docker-ibmmqlight-compose.yml -O suts/docker-ibmmqlight-compose.yml

    runTest suts/docker-ibmmqlight-compose.yml
}



# Apache ActiveMQ
function testActiveMQ() {
    echo "Launching a SUT instance w/ ActiveMQ"

    runTest suts/docker-activemq-compose.yml
}

# Interconnect
function testQpidDispatch() {
    echo "Launching a SUT instance w/ QPid Dispatch Router"
    runTest suts/docker-interconnect-compose.yml
}

# QpidCPP
function testQpidCpp() {
    echo "Launching an experimental SUT instance w/ QPid CPP Broker"
    localDir="$(dirname $0)"

    echo "Building the SUT image for the test"
    docker build -t maestro_test_qpid ${localDir}/suts/qpid/

    runTest ${localDir}/suts/qpid/docker-compose.yml
}

# RabbitMQ
function testRabbitMq() {
    echo "Launching an experimental SUT instance w/ RabbitMQ"

    localDir="$(dirname $0)"

    echo "Building the SUT image for the test"
    docker build -t maestro_test_rabbitmq ${localDir}/suts/rabbitmq/

    runTest ${localDir}/suts/rabbitmq/docker-compose.yml
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

esac

exit 0