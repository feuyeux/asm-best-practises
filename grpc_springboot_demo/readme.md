## gRPC Spring Boot Demo

### run server

```sh
$ mvn clean install -DskipTests -U
$ java -jar provider/target/provider-1.0.0.jar
```

### test server
```sh
$ grpcurl -v -plaintext localhost:6565 list

$ grpcurl -v -plaintext -d @ localhost:6565 org.feuyeux.grpc.Greeter/SayHello <<EOM
{
  "name":"feuyeux"
}
EOM

$ grpcurl -v -plaintext localhost:6565 org.feuyeux.grpc.Greeter/SayBye
```

### run client
```sh
$ java -jar consumer/target/consumer-1.0.0.jar
```

### test client
```sh
$ curl -i localhost:9001/hello/feuyeux
$ curl localhost:9001/bye
```

### build docker images
```dockerfile
FROM openjdk:8-jdk-alpine
ARG JAR_FILE=provider-1.0.0.jar
COPY ${JAR_FILE} provider.jar
ENTRYPOINT ["java","-jar","/provider.jar"]
```

```dockerfile
FROM openjdk:8-jdk-alpine
ARG JAR_FILE=consumer-1.0.0.jar
COPY ${JAR_FILE} consumer.jar
ENTRYPOINT ["java","-jar","/consumer.jar"]
```

```sh
cp ../provider/target/provider-1.0.0.jar .
cp ../consumer/target/consumer-1.0.0.jar .
docker build -f grpc.provider.dockerfile -t feuyeux/grpc_provider .
docker build -f grpc.consumer.dockerfile -t feuyeux/grpc_consumer .
```

### run docker containers
```sh
docker run --name provider -p 6565:6565 feuyeux/grpc_provider
```

```sh
export LOCAL=$(ipconfig getifaddr en0)
echo "LOCAL=${LOCAL}"
docker run --name provider -e GRPC_PROVIDER_HOST=${LOCAL} -p 9001:9001 feuyeux/grpc_consumer
```

### appendix
```sh
$ brew install grpcurl
```

- https://github.com/LogNet/grpc-spring-boot-starter
- https://github.com/fullstorydev/grpcurl