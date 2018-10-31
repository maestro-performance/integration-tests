FROM fedora:28 as maestro_test_rabbitmq
RUN yum install -y rabbitmq-server
ADD rabbitmq.config /etc/rabbitmq/rabbitmq.config
EXPOSE 5672
EXPOSE 15672
CMD ["/usr/sbin/rabbitmq-server"]