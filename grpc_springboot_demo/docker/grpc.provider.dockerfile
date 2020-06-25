FROM openjdk:8-jdk-alpine
ARG JAR_FILE=provider-1.0.0.jar
COPY ${JAR_FILE} provider.jar
COPY grpcurl /usr/bin/grpcurl
ENTRYPOINT ["java","-jar","/provider.jar"]