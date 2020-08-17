#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
cd ../..

if [ "$1" = tcp ]; then
  echo "MODE:TCP"
  java -Dserver.port="$2" -Dback.port="$3" -jar test_jar/tcp-requester.jar
fi

if [ "$1" = ws ]; then
  echo "MODE:WEBSOCKETS"
  java -Dserver.port="$2" -Dback.port="$3" -jar test_jar/ws-requester.jar
fi
