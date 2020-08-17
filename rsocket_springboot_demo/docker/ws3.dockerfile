#https://hub.docker.com/_/openjdk
FROM openjdk:8-jdk-alpine
RUN apk --no-cache add curl
ARG JAR_FILE=rsocket_ws_springboot_demo_3.jar
COPY ${JAR_FILE} rsocket_springboot_demo.jar
ENTRYPOINT ["java","-jar","/rsocket_springboot_demo.jar"]