package org.feuyeux.rsocket;

import lombok.Setter;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.messaging.rsocket.RSocketRequester;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.time.Duration;

@Slf4j
@Service
public class RSocketWsConfig {
    @Value("${back.host}")
    @Setter
    private String host;

    @Value("${back.port}")
    @Setter
    private int port;

    @Bean
    RSocketRequester rSocketRequester(RSocketRequester.Builder builder) {
        String uri = String.format("ws://%s:%d", host, port);
        log.info("uri={}", uri);
        return builder
                .connectWebSocket(URI.create(uri))
                .timeout(Duration.ofMinutes(1))
                .block();
    }
}
