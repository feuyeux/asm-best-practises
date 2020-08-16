package org.feuyeux.rsocket;

import io.rsocket.RSocket;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.messaging.rsocket.RSocketRequester;
import org.springframework.util.MimeType;

@SpringBootApplication
public class ResponderApplication {
    public static void main(String[] args) {
        SpringApplication.run(ResponderApplication.class, args);
    }

    @Bean
    RSocketRequester rSocketRequester(RSocketRequester.Builder builder) {
        String RSOCKET_HELLO_BACKEND = System.getenv("RSOCKET_HELLO_BACKEND");
        if (RSOCKET_HELLO_BACKEND != null) {
            return builder
                    .connectTcp(RSOCKET_HELLO_BACKEND, 9001)
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
