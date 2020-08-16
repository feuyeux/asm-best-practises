package org.feuyeux.rsocket;

import lombok.Setter;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.messaging.rsocket.RSocketRequester;

/**
 * @author feuyeux@gmail.com
 */
@Slf4j
@SpringBootApplication
public class RequesterApplication {
    public static void main(String[] args) {
        SpringApplication.run(RequesterApplication.class);
    }

    @Value("${back.host}")
    @Setter
    private String host;

    @Value("${back.port}")
    @Setter
    private int port;

    @Bean
    RSocketRequester rSocketRequester(RSocketRequester.Builder builder) {
        log.info("host={},port={}", host, port);
        return builder
                .connectTcp(host, port)
                .block();
    }
}

