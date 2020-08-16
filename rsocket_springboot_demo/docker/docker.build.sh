#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit

echo "start to build jars"
cd ..
cp responder/src/main/java/org/feuyeux/rsocket/api/RSocketController1.cafe responder/src/main/java/org/feuyeux/rsocket/api/RSocketController.java
mvn clean install >/dev/null
cp responder/target/responder-1.0.0.jar docker/rsocket_springboot_demo_1.jar

cp responder/src/main/java/org/feuyeux/rsocket/api/RSocketController2.cafe responder/src/main/java/org/feuyeux/rsocket/api/RSocketController.java
mvn clean install >/dev/null
cp responder/target/responder-1.0.0.jar docker/rsocket_springboot_demo_2.jar

cp responder/src/main/java/org/feuyeux/rsocket/api/RSocketController3.cafe responder/src/main/java/org/feuyeux/rsocket/api/RSocketController.java
mvn clean install >/dev/null
cp responder/target/responder-1.0.0.jar docker/rsocket_springboot_demo_3.jar

cd docker
echo "start to build images"
docker build -f dockerfile1 -t registry.cn-beijing.aliyuncs.com/asm_repo/rsocket_springboot_v1:1.0.0 .
docker build -f dockerfile2 -t registry.cn-beijing.aliyuncs.com/asm_repo/rsocket_springboot_v2:1.0.0 .
docker build -f dockerfile3 -t registry.cn-beijing.aliyuncs.com/asm_repo/rsocket_springboot_v3:1.0.0 .

rm -f rsocket_*.jar
cd .. || exit
mvn clean
rm -f responder/src/main/java/org/feuyeux/rsocket/api/RSocketController.java
