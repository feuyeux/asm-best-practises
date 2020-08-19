#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
cd ../grpc_springboot_demo/
mvn clean install -DskipTests
java -jar consumer/target/consumer-1.0.0.jar
