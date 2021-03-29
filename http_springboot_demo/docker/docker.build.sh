#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit

echo "start to build jars"
cd ..

time_stamp=$(date "+%Y%m%d.%H%M%S")
cp docker/banner.txt src/main/resources/banner.txt
echo "$time_stamp" >>src/main/resources/banner.txt

cp src/main/resources/application-hello src/main/resources/application.properties
cp src/main/java/org/feuyeux/http/api/HttpController1.cafe src/main/java/org/feuyeux/http/api/HttpController.java
mvn clean install
cp target/spring-boot-http-1.0.0.jar docker/http_springboot_demo_1.jar

cp src/main/java/org/feuyeux/http/api/HttpController2.cafe src/main/java/org/feuyeux/http/api/HttpController.java
mvn clean install >/dev/null
cp target/spring-boot-http-1.0.0.jar docker/http_springboot_demo_2.jar

cp src/main/java/org/feuyeux/http/api/HttpController3.cafe src/main/java/org/feuyeux/http/api/HttpController.java
mvn clean install >/dev/null
cp target/spring-boot-http-1.0.0.jar docker/http_springboot_demo_3.jar

cd docker
echo "start to build images"
YOUR_REPO=feuyeux
docker build -f dockerfile1 -t ${YOUR_REPO}/http_springboot_v1:"$time_stamp" .
docker build -f dockerfile2 -t ${YOUR_REPO}/http_springboot_v2:"$time_stamp" .
docker build -f dockerfile3 -t ${YOUR_REPO}/http_springboot_v3:"$time_stamp" .

rm -f http_*.jar
cd .. || exit
mvn clean
rm -f src/main/resources/application.properties
rm -f src/main/java/org/feuyeux/http/api/HttpController.java
rm -f src/main/resources/banner.txt
echo "$time_stamp" >time_stamp
sh docker/docker.push.sh "$time_stamp"
