#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
cd ..
echo "1 Build WS-1 JAR"
cp responder/src/main/java/org/feuyeux/rsocket/api/RSocketController1.cafe responder/src/main/java/org/feuyeux/rsocket/api/RSocketController.java
cp responder/src/main/resources/application_ws.yml responder/src/main/resources/application.yml
mv responder/src/main/java/org/feuyeux/rsocket/service/RSocketTcpConfig.java responder/src/main/java/org/feuyeux/rsocket/service/RSocketTcpConfig.bk
mvn clean install >/dev/null
mv responder/src/main/java/org/feuyeux/rsocket/service/RSocketTcpConfig.bk responder/src/main/java/org/feuyeux/rsocket/service/RSocketTcpConfig.java
cp responder/target/responder-1.0.0.jar docker/rsocket_ws_springboot_demo_1.jar

echo "2 Build TCP-1 JAR"
cp responder/src/main/resources/application_tcp.yml responder/src/main/resources/application.yml
mv responder/src/main/java/org/feuyeux/rsocket/service/RSocketWsConfig.java responder/src/main/java/org/feuyeux/rsocket/service/RSocketWsConfig.bk
mvn clean install >/dev/null
mv responder/src/main/java/org/feuyeux/rsocket/service/RSocketWsConfig.bk responder/src/main/java/org/feuyeux/rsocket/service/RSocketWsConfig.java
cp responder/target/responder-1.0.0.jar docker/rsocket_tcp_springboot_demo_1.jar

echo "3 Build WS-2 JAR"
cp responder/src/main/java/org/feuyeux/rsocket/api/RSocketController2.cafe responder/src/main/java/org/feuyeux/rsocket/api/RSocketController.java
cp responder/src/main/resources/application_ws.yml responder/src/main/resources/application.yml
mv responder/src/main/java/org/feuyeux/rsocket/service/RSocketTcpConfig.java responder/src/main/java/org/feuyeux/rsocket/service/RSocketTcpConfig.bk
mvn clean install >/dev/null
mv responder/src/main/java/org/feuyeux/rsocket/service/RSocketTcpConfig.bk responder/src/main/java/org/feuyeux/rsocket/service/RSocketTcpConfig.java
cp responder/target/responder-1.0.0.jar docker/rsocket_ws_springboot_demo_2.jar

echo "4 Build TCP-2 JAR"
cp responder/src/main/resources/application_tcp.yml responder/src/main/resources/application.yml
mv responder/src/main/java/org/feuyeux/rsocket/service/RSocketWsConfig.java responder/src/main/java/org/feuyeux/rsocket/service/RSocketWsConfig.bk
mvn clean install >/dev/null
mv responder/src/main/java/org/feuyeux/rsocket/service/RSocketWsConfig.bk responder/src/main/java/org/feuyeux/rsocket/service/RSocketWsConfig.java
cp responder/target/responder-1.0.0.jar docker/rsocket_tcp_springboot_demo_2.jar

echo "5 Build WS-3 JAR"
cp responder/src/main/java/org/feuyeux/rsocket/api/RSocketController3.cafe responder/src/main/java/org/feuyeux/rsocket/api/RSocketController.java
cp responder/src/main/resources/application_ws.yml responder/src/main/resources/application.yml
mv responder/src/main/java/org/feuyeux/rsocket/service/RSocketTcpConfig.java responder/src/main/java/org/feuyeux/rsocket/service/RSocketTcpConfig.bk
mvn clean install >/dev/null
mv responder/src/main/java/org/feuyeux/rsocket/service/RSocketTcpConfig.bk responder/src/main/java/org/feuyeux/rsocket/service/RSocketTcpConfig.java
cp responder/target/responder-1.0.0.jar docker/rsocket_ws_springboot_demo_3.jar

echo "6 Build TCP-3 JAR"
cp responder/src/main/resources/application_tcp.yml responder/src/main/resources/application.yml
mv responder/src/main/java/org/feuyeux/rsocket/service/RSocketWsConfig.java responder/src/main/java/org/feuyeux/rsocket/service/RSocketWsConfig.bk
mvn clean install >/dev/null
mv responder/src/main/java/org/feuyeux/rsocket/service/RSocketWsConfig.bk responder/src/main/java/org/feuyeux/rsocket/service/RSocketWsConfig.java
cp responder/target/responder-1.0.0.jar docker/rsocket_tcp_springboot_demo_3.jar

cd docker
echo "7 Build WS-1 IMG"
docker build -f ws1.dockerfile -t registry.cn-beijing.aliyuncs.com/asm_repo/rsocket_ws_springboot_v1:1.0.0 .
echo "8 Build TCP-1 IMG"
docker build -f tcp1.dockerfile -t registry.cn-beijing.aliyuncs.com/asm_repo/rsocket_tcp_springboot_v1:1.0.0 .
echo "9 Build WS-2 IMG"
docker build -f ws2.dockerfile -t registry.cn-beijing.aliyuncs.com/asm_repo/rsocket_ws_springboot_v2:1.0.0 .
echo "10 Build TCP-2 IMG"
docker build -f tcp2.dockerfile -t registry.cn-beijing.aliyuncs.com/asm_repo/rsocket_tcp_springboot_v2:1.0.0 .
echo "11 Build WS-3 IMG"
docker build -f ws3.dockerfile -t registry.cn-beijing.aliyuncs.com/asm_repo/rsocket_ws_springboot_v3:1.0.0 .
echo "12 Build TCP-3 IMG"
docker build -f tcp3.dockerfile -t registry.cn-beijing.aliyuncs.com/asm_repo/rsocket_tcp_springboot_v3:1.0.0 .
echo "RESPONDER DONE"
rm -f rsocket_*.jar
cd .. || exit
rm -f responder/src/main/java/org/feuyeux/rsocket/api/RSocketController.java
