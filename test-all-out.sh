############## ALl out ###########################

function cleanup() {
    docker rmi -f maestro_sut  || true
}

# Artemis 2.6
function testArtemis() {
    echo "Launching a SUT instance w/ Apache Artemis"
    docker-compose -f docker-compose.yml -f suts/docker-artemis-compose.yml up --scale worker=2 --scale agent=0 --scale inspector=0 -d
    docker run -it -h maestro_client -v maestro:/maestro --network=work_cluster -e PRODUCT_NAME="Artemis 2.6.3" maestro-test-client /usr/bin/test-runner-all-out.sh
    sleep 30s
    docker-compose -f docker-compose.yml -f suts/docker-artemis-compose.yml down
    cleanup
}


# MQ Light
function testIbmMqLight() {
    echo "Launching a SUT instance w/ IBM MQ Light"
    wget -c https://gist.githubusercontent.com/orpiske/43574edf7c6c3ef150550c70820c25b8/raw/21def540f911ac8bdbfe9bd899521e924a76c018/docker-ibmmqlight-compose.yml -O suts/docker-ibmmqlight-compose.yml
    docker-compose -f docker-compose.yml -f suts/docker-ibmmqlight-compose.yml up --scale worker=2 --scale agent=0 --scale inspector=0 -d
    docker run -it -h maestro_test_client -v maestro:/maestro --network=work_cluster -e PRODUCT_NAME="IBM MQ Light" maestro-test-client /usr/bin/test-runner-all-out.sh
    sleep 30s
    docker-compose -f docker-compose.yml -f docker-ibmmqlight-compose.yml down
    cleanup
}



# Apache ActiveMQ
function testActiveMQ() {
    echo "Launching a SUT instance w/ Artemis"
    docker-compose -f docker-compose.yml -f suts/docker-activemq-compose.yml up --scale worker=2 --scale agent=0 --scale inspector=0 -d
    docker run -it -h maestro_test_client -v maestro:/maestro --network=work_cluster -e PRODUCT_NAME="ActiveMQ 5.15.2" maestro-test-client /usr/bin/test-runner-all-out.sh
    sleep 30s
    docker-compose -f docker-compose.yml -f suts/docker-activemq-compose.yml down
    cleanup
}

# Interconnect
function testQpidDispatch() {
    echo "Launching a SUT instance w/ QPid Dispatch Router"
    docker-compose -f docker-compose.yml -f suts/docker-interconnect-compose.yml up --scale worker=2 --scale agent=0 --scale inspector=0 -d
    docker run -it -h maestro_test_client -v maestro:/maestro --network=work_cluster -e PRODUCT_NAME="Interconnect 1.4.0" maestro-test-client /usr/bin/test-runner-all-out.sh
    sleep 90s
    docker-compose -f docker-compose.yml -f suts/docker-interconnect-compose.yml down
    cleanup
}

# QpidCPP
function testQpidCpp() {
    localDir="$(dirname $0)"

    docker build -t maestro_test_qpid ${localDir}/suts/qpid/
    docker-compose -f docker-compose.yml -f ${localDir}/suts/qpid/docker-compose.yml up --scale worker=2 --scale agent=0 --scale inspector=0 -d
    docker run -it --network=work_cluster -e PRODUCT_NAME="QPid CPP" maestro-test-client /usr/bin/test-runner-all-out.sh
    sleep 90s
    docker-compose -f docker-compose.yml -f suts/docker-interconnect-compose.yml down
    cleanup
}

# RabbitMQ
function testRabbitMq() {
    localDir="$(dirname $0)"

    docker build -t maestro_test_rabbitmq ${localDir}/suts/rabbitmq/
    docker-compose -f docker-compose.yml -f ${localDir}/suts/rabbitmq/docker-compose.yml up --scale worker=2 --scale agent=0 --scale inspector=0 -d
    sleep 10s
    docker run -it -h maestro_client -v maestro:/maestro --network=work_cluster -e PRODUCT_NAME="RabbitMQ" -e SEND_RECEIVE_URL="amqp://sut:5672/test.performance.queue?protocol=RABBITAMQP" maestro-test-client /usr/bin/test-runner-all-out.sh
    sleep 30s
    docker-compose -f docker-compose.yml -f suts/docker-rabbitmq-compose.yml down
    cleanup
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