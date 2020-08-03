#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit

echo "start to build jars"
cd ..

cp provider/src/main/java/org/feuyeux/grpc/api/GreeterImpl1.cafe provider/src/main/java/org/feuyeux/grpc/api/GreeterImpl.java
mvn clean install >/dev/null
cp provider/target/provider-1.0.0.jar docker/grpc_springboot_demo_1.jar

cp provider/src/main/java/org/feuyeux/grpc/api/GreeterImpl2.cafe provider/src/main/java/org/feuyeux/grpc/api/GreeterImpl.java
mvn clean install >/dev/null
cp provider/target/provider-1.0.0.jar docker/grpc_springboot_demo_2.jar

cp provider/src/main/java/org/feuyeux/grpc/api/GreeterImpl3.cafe provider/src/main/java/org/feuyeux/grpc/api/GreeterImpl.java
mvn clean install >/dev/null
cp provider/target/provider-1.0.0.jar docker/grpc_springboot_demo_3.jar

cd docker
echo "start to build images"
docker build -f dockerfile1 -t registry.cn-beijing.aliyuncs.com/asm_repo/grpc_springboot_v1:1.0.0 .
docker build -f dockerfile2 -t registry.cn-beijing.aliyuncs.com/asm_repo/grpc_springboot_v2:1.0.0 .
docker build -f dockerfile3 -t registry.cn-beijing.aliyuncs.com/asm_repo/grpc_springboot_v3:1.0.0 .

rm -f grpc_*.jar
cd ..
mvn clean
rm -f provider/src/main/java/org/feuyeux/grpc/api/GreeterImpl.java