package org.feuyeux.rsocket.service;

import io.rsocket.RSocket;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.messaging.rsocket.RSocketRequester;
import org.springframework.stereotype.Service;
import org.springframework.util.MimeType;

import java.net.URI;
import java.time.Duration;

@Slf4j
@Service
public class RSocketWsConfig {
    @Bean
    RSocketRequester rSocketRequester(RSocketRequester.Builder builder) {
        String RSOCKET_HELLO_BACKEND = System.getenv("RSOCKET_HELLO_BACKEND");
        if (RSOCKET_HELLO_BACKEND != null) {
            String uri = String.format("ws://%s:%d", RSOCKET_HELLO_BACKEND, 9001);
            log.info("RSOCKET_HELLO_BACKEND WEBSOCKETS URI={}", uri);
            return builder
                    .connectWebSocket(URI.create(uri))
                    .timeout(Duration.ofMinutes(10))
                    .block();
        }
        return fake();
    }

    private RSocketRequester fake() {
        return new RSocketRequester() {
            @Override
            public RSocket rsocket() {
                return null;
            }

            @Override
            public MimeType dataMimeType() {
                return null;
            }

            @Override
            public MimeType metadataMimeType() {
                return null;
            }

            @Override
            public RequestSpec route(String route, Object... routeVars) {
                return null;
            }

            @Override
            public RequestSpec metadata(Object metadata, MimeType mimeType) {
                return null;
            }
        };
    }
}
