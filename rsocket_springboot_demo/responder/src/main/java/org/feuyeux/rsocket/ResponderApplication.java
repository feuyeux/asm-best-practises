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
}
