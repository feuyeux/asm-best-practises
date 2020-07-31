#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit

echo "start to build jars"
cd ..

cp src/main/resources/application-hello src/main/resources/application.properties
cp src/main/java/org/feuyeux/http/api/HttpController1.cafe src/main/java/org/feuyeux/http/api/HttpController.java
mvn clean install >/dev/null
cp target/spring-boot-http-1.0.0.jar vm/http-hello-en.jar

cp src/main/java/org/feuyeux/http/api/HttpController2.cafe src/main/java/org/feuyeux/http/api/HttpController.java
mvn clean install >/dev/null
cp target/spring-boot-http-1.0.0.jar vm/http-hello-fr.jar

cp src/main/java/org/feuyeux/http/api/HttpController3.cafe src/main/java/org/feuyeux/http/api/HttpController.java
mvn clean install >/dev/null
cp target/spring-boot-http-1.0.0.jar vm/http-hello-es.jar

echo "start to scp jar"
cd vm
source vm.config

#apt install openjdk-14-jre-headless -y
scp http-hello-fr.jar root@"$VM_1_IP":/var/lib/http-hello-fr.jar
ssh root@"$VM_1_IP" "java -jar /var/lib/http-hello-fr.jar"

scp http-hello-es.jar root@"$VM_2_IP":/var/lib/http-hello-es.jar
ssh root@"$VM_2_IP" "java -jar /var/lib/http-hello-es.jar"

echo "test vm services"
curl -vs "$VM_1_IP":8001/hello/fr-server
curl -vs "$VM_2_IP":8001/hello/es-server

rm -f http*.jar
cd ..
mvn clean
rm -f src/main/resources/application.properties
rm -f src/main/java/org/feuyeux/http/api/HttpController.java