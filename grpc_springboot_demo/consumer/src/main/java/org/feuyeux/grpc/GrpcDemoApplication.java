package org.feuyeux.grpc;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@ComponentScan("org.feuyeux.grpc")
public class GrpcDemoApplication {
	public static void main(String[] args) {
		SpringApplication.run(GrpcDemoApplication.class, args);
	}
}
