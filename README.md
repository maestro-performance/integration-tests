Maestro Integration Tests: integration tests for Maestro
============


Introduction
----

This project automates running a couple of integration tests for Maestro. The test suite is based on Docker and 
Docker Compooser.


Build Status
----

Build Status (master): [![Build Status](https://travis-ci.org/maestro-performance/integration-tests.svg?branch=master)](https://travis-ci.org/maestro-performance/integration-tests)


Requirements
----

* Docker (newer than 1.13)
* Docker compose
* Bash
* Make


Usage
---- 

Running the tests is as simple as it can be. First, prepare the environment:

```./prepare.sh```

Then run the tests:

```cd work && ./test.sh```


Individual or specific tests can be run. For example, to run only the all out tests: 

```cd work && ./test-all-out.sh all```

You can also run the tests for one specific SUT. For example, to run the test on Apache Artemis: 

```cd work && ./test-all-out.sh artemis```


Integrations and Result management
---- 

The test suite will setup Maestro to save xUnit files in `work/test/results` directory. If running
the tests on Jenkins, you can just point the xUnit archiver to load the results from that directory.
For additional details, check the `Jenkinsfile` provided along with this project.