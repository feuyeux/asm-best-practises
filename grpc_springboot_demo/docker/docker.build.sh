#!/usr/bin/env bash

export SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/"
cd $SCRIPTPATH
docker login -u feuyeux

cd ..
mvn clean install
cd $SCRIPTPATH
echo "pwd: $(PWD)"
cp ../provider/target/provider-1.0.0.jar .
cp ../consumer/target/consumer-1.0.0.jar .
docker build -f grpc.provider.dockerfile -t feuyeux/grpc_provider_v1:1.0.0 .
#docker build -f grpc.provider.dockerfile -t feuyeux/grpc_provider_v2:1.0.0 .
docker build -f grpc.consumer.dockerfile -t feuyeux/grpc_consumer:1.0.0 .
echo "docker images"
docker images
docker push feuyeux/grpc_provider_v1:1.0.0
#docker push feuyeux/grpc_provider_v2:1.0.0
docker push feuyeux/grpc_consumer:1.0.0