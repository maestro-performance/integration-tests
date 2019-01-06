#!/bin/bash


echo "Cleaning Maestro edge images"
docker rmi -f $(docker images 'maestroperf/*' -q) || true

echo "Preparing work directories and copying Maestro composer files"
mkdir -p work/results/{incremental,all-out}
cd work
cp ../test*.sh .
cp ../docker*.yml .
cp -Rv ../suts/ .

echo "Building the new test images"
cd ../docker
make


