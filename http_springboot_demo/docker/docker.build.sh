#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit

echo "start to build jars"
cd ..

cp src/main/resources/application-proxy src/main/resources/application.properties
cp src/main/java/org/feuyeux/http/api/HttpController0.cafe src/main/java/org/feuyeux/http/api/HttpController.java
mvn clean install
cp target/spring-boot-http-1.0.0.jar docker/http_springboot_proxy.jar

cp src/main/resources/application-hello src/main/resources/application.properties
cp src/main/java/org/feuyeux/http/api/HttpController1.cafe src/main/java/org/feuyeux/http/api/HttpController.java
mvn clean install >/dev/null
cp target/spring-boot-http-1.0.0.jar docker/http_springboot_demo_1.jar

cp src/main/java/org/feuyeux/http/api/HttpController2.cafe src/main/java/org/feuyeux/http/api/HttpController.java
mvn clean install >/dev/null
cp target/spring-boot-http-1.0.0.jar docker/http_springboot_demo_2.jar

cp src/main/java/org/feuyeux/http/api/HttpController3.cafe src/main/java/org/feuyeux/http/api/HttpController.java
mvn clean install >/dev/null
cp target/spring-boot-http-1.0.0.jar docker/http_springboot_demo_3.jar

cd docker
echo "start to build images"
docker build -f proxy-dockerfile -t registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_proxy:1.0.1 .
docker build -f dockerfile1 -t registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v1:1.0.1 .
docker build -f dockerfile2 -t registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v2:1.0.1 .
docker build -f dockerfile3 -t registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v3:1.0.1 .

rm -f http_*.jar
cd .. || exit
mvn clean
rm -f src/main/resources/application.properties
rm -f src/main/java/org/feuyeux/http/api/HttpController.java