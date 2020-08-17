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
@SpringBootApplication
public class RequesterApplication {
    public static void main(String[] args) {
        SpringApplication.run(RequesterApplication.class);
    }
}

