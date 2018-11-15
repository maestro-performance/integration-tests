FROM maestroperf/maestro-client:edge as maestro-test-client
RUN mkdir -p /etc/maestro/test-profiles
ADD test-profiles /etc/maestro/test-profiles
ADD test-runner.sh /usr/bin/test-runner.sh
VOLUME /maestro/tests/results
