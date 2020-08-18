#https://hub.docker.com/_/openjdk
FROM openjdk:8-jdk-alpine
RUN apk --no-cache add curl
ADD rsocket-cli.tar.gz /opt/
ARG JAR_FILE=rsocket_tcp_springboot_demo_3.jar
COPY ${JAR_FILE} rsocket_springboot_demo.jar
ENTRYPOINT ["java","-jar","/rsocket_springboot_demo.jar"]