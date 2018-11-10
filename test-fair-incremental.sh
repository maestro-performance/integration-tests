# MQ Light
function testIbmMqLight() {
    wget -c https://gist.githubusercontent.com/orpiske/43574edf7c6c3ef150550c70820c25b8/raw/21def540f911ac8bdbfe9bd899521e924a76c018/docker-ibmmqlight-compose.yml
    docker-compose -f docker-compose.yml -f docker-ibmmqlight-compose.yml up --scale worker=2 --scale agent=0 --scale inspector=0 -d
    docker run -it -h maestro_client -v maestro:/maestro --network=work_cluster -e PRODUCT_NAME="IBM MQ Light" maestro-test-client /usr/bin/test-runner-fair-incremental.sh
    sleep 30s
    docker-compose -f docker-compose.yml -f docker-ibmmqlight-compose.yml down
    docker rmi -f maestro_sut || true
}


# Artemis 2.6
function testArtemis() {
    docker-compose -f docker-compose.yml -f docker-artemis-compose.yml up --scale worker=2 --scale agent=0 --scale inspector=0 -d
    docker run -it -h maestro_client -v maestro:/maestro --network=work_cluster -e PRODUCT_NAME="Artemis 2.6.3" maestro-test-client /usr/bin/test-runner-fair-incremental.sh
    sleep 30s
    docker-compose -f docker-compose.yml -f docker-artemis-compose.yml down
    docker rmi -f maestro_sut || true
}


# ActiveMQ
function testActiveMQ() {
    docker-compose -f docker-compose.yml -f docker-activemq-compose.yml up --scale worker=2 --scale agent=0 --scale inspector=0 -d
    docker run -it -h maestro_client -v maestro:/maestro --network=work_cluster -e PRODUCT_NAME="ActiveMQ 5.15.2" maestro-test-client /usr/bin/test-runner-fair-incremental.sh
    sleep 30s
    docker-compose -f docker-compose.yml -f docker-activemq-compose.yml down
    docker rmi -f maestro_sut || true
}


# Interconnect
function testQpidDispatch() {
    docker-compose -f docker-compose.yml -f docker-interconnect-compose.yml up --scale worker=2 --scale agent=0 --scale inspector=0 -d
    docker run -it -h maestro_client -v maestro:/maestro --network=work_cluster -e PRODUCT_NAME="Interconnect 1.4.0" maestro-test-client /usr/bin/test-runner-fair-incremental.sh
    sleep 90s
    docker-compose -f docker-compose.yml -f docker-interconnect-compose.yml down
    docker rmi -f maestro_sut || true
}

# QpidCpp
function testQpidCpp() {
    localDir="$(dirname $0)"

    docker build -t maestro_test_rabbitmq ${localDir}/docker/suts/rabbitmq/
    docker-compose -f docker-compose.yml -f ${localDir}/docker/suts/qpid/docker-compose.ymlup --scale worker=2 --scale agent=0 --scale inspector=0 -d
    docker run -it -h maestro_client -v maestro:/maestro --network=work_cluster -e PRODUCT_NAME="Qpid CPP" maestro-test-client /usr/bin/test-runner-fair-incremental.sh
    sleep 90s
    docker-compose -f docker-compose.yml -f docker-interconnect-compose.yml down
    docker rmi -f maestro_sut || true
}


# RabbitMQ
function testRabbitMq() {
    localDir="$(dirname $0)"

    docker build -t maestro_test_rabbitmq ${localDir}/docker/suts/rabbitmq/
    docker-compose -f docker-compose.yml -f ${localDir}/docker/suts/rabbitmq/docker-compose.yml up --scale worker=2 --scale agent=0 --scale inspector=0 -d
    10s
    docker run -it -h maestro_client -v maestro:/maestro --network=work_cluster -e PRODUCT_NAME="RabbitMQ" -e SEND_RECEIVE_URL="amqp://sut:5672/test.performance.queue?protocol=RABBITAMQP" maestro-test-client /usr/bin/test-runner-fair-incremental.sh
    sleep 30s
    docker-compose -f docker-compose.yml -f docker-rabbitmq-compose.yml down
    docker rmi -f maestro_sut || true
}


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