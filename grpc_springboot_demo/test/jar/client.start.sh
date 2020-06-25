#!/usr/bin/env bash
export SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/"
cd $SCRIPTPATH
cd ../..
mvn clean install -DskipTests -U
##
export GRPC_PROVIDER_HOST=localhost
java -jar consumer/target/consumer-1.0.0.jar