package org.feuyeux.grpc;

import io.grpc.*;
import org.lognet.springboot.grpc.GRpcGlobalInterceptor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@ComponentScan("org.feuyeux.grpc")
public class GrpcDemoApplication {
    private static final Logger LOGGER = LoggerFactory.getLogger(GrpcDemoApplication.class);

    public static void main(String[] args) {
        SpringApplication.run(GrpcDemoApplication.class, args);
    }

    @Bean
    @GRpcGlobalInterceptor
    public ServerInterceptor globalSInterceptor() {
        return new HelloServerInterceptor();
    }

    @Bean
    @GRpcGlobalInterceptor
    public ClientInterceptor globalCInterceptor() {
        return new HelloClientInterceptor();
    }
}
