#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
cd ../..
mvn clean install -DskipTests
java -Dserver.port=6667 -Dback.port=8001 -jar requester/target/requester-1.0.0.jar