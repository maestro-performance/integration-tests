#!/bin/bash

mkdir -p work
cd work
cp ../test*.sh .
cp ../docker*.yml .
git clone https://github.com/maestro-performance/maestro-java.git -b devel
mkdir -p suts
cd suts &&  cp -Rv ../maestro-java/extra/docker-compose/maestro/suts/* .
cp -Rv ../../suts/* .
cd ..


