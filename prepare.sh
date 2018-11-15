#!/bin/bash

mkdir -p work/results/{incremental,all-out}
cd work
cp ../test*.sh .
cp ../docker*.yml .
git clone https://github.com/maestro-performance/maestro-java.git -b devel
make -f maestro-java/extra/docker-compose/maestro/Makefile clean || true
mkdir -p suts
cd suts &&  cp -Rv ../maestro-java/extra/docker-compose/maestro/suts/* .
cp -Rv ../../suts/* .
cd ../../docker
make


