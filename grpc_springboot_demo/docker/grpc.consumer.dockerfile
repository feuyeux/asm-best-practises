FROM openjdk:8-jdk-alpine
ARG JAR_FILE=consumer-1.0.0.jar
COPY ${JAR_FILE} consumer.jar
COPY grpcurl /usr/bin/grpcurl
ENTRYPOINT ["java","-jar","/consumer.jar"]