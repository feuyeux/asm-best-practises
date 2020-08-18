FROM openjdk:8-jdk-alpine
RUN apk --no-cache add curl
ADD rsocket-cli.tar.gz /opt/
ARG JAR_FILE=rsocket_ws_springboot_demo_2.jar
COPY ${JAR_FILE} rsocket_springboot_demo.jar
ENTRYPOINT ["java","-jar","/rsocket_springboot_demo.jar"]