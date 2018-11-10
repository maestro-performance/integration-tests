FROM fedora:28 as maestro_test_qpid
EXPOSE 5672
RUN dnf install -y qpid-cpp-server
RUN dnf clean all
RUN qpid-config add queue test.performance.queue
CMD ["/usr/sbin/qpidd"]