#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
cd ..
mkdir test_jar
echo "1 Build TCP JAR"
mv requester/src/main/java/org/feuyeux/rsocket/RSocketWsConfig.java requester/src/main/java/org/feuyeux/rsocket/RSocketWsConfig.java.bk
mvn clean install -DskipTests
mv requester/src/main/java/org/feuyeux/rsocket/RSocketWsConfig.java.bk requester/src/main/java/org/feuyeux/rsocket/RSocketWsConfig.java
mv requester/target/requester-1.0.0.jar test_jar/tcp-requester.jar

echo "2 Build WS JAR"
mv requester/src/main/java/org/feuyeux/rsocket/RSocketTcpConfig.java requester/src/main/java/org/feuyeux/rsocket/RSocketTcpConfig.java.bk
mvn clean install -DskipTests
mv requester/src/main/java/org/feuyeux/rsocket/RSocketTcpConfig.java.bk requester/src/main/java/org/feuyeux/rsocket/RSocketTcpConfig.java
mv requester/target/requester-1.0.0.jar test_jar/ws-requester.jar
echo "REQUESTER DONE"
