package org.feuyeux.rsocket;

import lombok.Setter;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.messaging.rsocket.RSocketRequester;
import org.springframework.stereotype.Service;

import java.time.Duration;

@Slf4j
@Service
public class RSocketTcpConfig {
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
                .timeout(Duration.ofMinutes(1))
                .block();
    }
}
