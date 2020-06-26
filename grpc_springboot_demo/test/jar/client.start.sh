#!/usr/bin/env bash
export SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/"
cd "$SCRIPT_PATH"
cd ../..
mvn clean install -DskipTests -U
##
export GRPC_PROVIDER_HOST=localhost
java -jar consumer/target/consumer-1.0.0.jar