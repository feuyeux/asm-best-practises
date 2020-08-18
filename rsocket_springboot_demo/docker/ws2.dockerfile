FROM openjdk:8-jdk-alpine
RUN apk --no-cache add curl
ARG JAR_FILE=rsocket_ws_springboot_demo_2.jar
COPY ${JAR_FILE} rsocket_springboot_demo.jar
COPY rsocket-cli /usr/local/rsocket-cli
ENTRYPOINT ["java","-jar","/rsocket_springboot_demo.jar"]