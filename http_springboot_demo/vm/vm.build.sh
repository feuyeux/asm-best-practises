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
scp http-hello-es.jar root@"$VM_2_IP":/var/lib/http-hello-es.jar

rm -f http*.jar
cd .. || exit
mvn clean
rm -f src/main/resources/application.properties
rm -f src/main/java/org/feuyeux/http/api/HttpController.java

alias k="kubectl --kubeconfig $USER_CONFIG"
hello3_ip=$(k get service hello3-svc -n hello -o jsonpath={.spec.clusterIP})
echo "$hello3_ip hello3-svc.hello.svc.cluster.local"
ssh root@"$VM_1_IP" "echo $hello3_ip hello3-svc.hello.svc.cluster.local >> /etc/hosts"
ssh root@"$VM_2_IP" "echo $hello3_ip hello3-svc.hello.svc.cluster.local >> /etc/hosts"