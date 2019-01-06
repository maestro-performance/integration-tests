#!/bin/bash


mkdir -p work/results/{incremental,all-out}
cd work
cp ../test*.sh .
cp ../docker*.yml .

echo "Cleaning Maestro edge images"
docker rmi -f $(docker images 'maestroperf/*' -q) || true


echo "Preparing work directories and copying Maestro composer files"
git clone https://github.com/maestro-performance/maestro-java.git -b devel


mkdir -p suts
cd suts &&  cp -Rv ../maestro-java/extra/docker-compose/maestro/suts/* .
cp -Rv ../../suts/* .

echo "Building new images"
cd ../../docker
make


