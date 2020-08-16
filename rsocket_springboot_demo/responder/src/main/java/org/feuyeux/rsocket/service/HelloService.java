package org.feuyeux.rsocket.service;

import lombok.extern.slf4j.Slf4j;
import org.feuyeux.rsocket.pojo.HelloRequest;
import org.feuyeux.rsocket.pojo.HelloResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.rsocket.RSocketRequester;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

@Slf4j
@Service
public class HelloService {
    @Autowired
    private RSocketRequester rSocketRequester;

    public Mono<HelloResponse> sayHello(HelloRequest helloRequest) {
        return rSocketRequester
                .route("hello")
                .data(helloRequest)
                .retrieveMono(HelloResponse.class)
                .doOnNext(response -> log.info("<< [Request-Response] response:{}", response.getValue()))
                .map(helloResponse -> {
                    helloResponse.setValue(mark() + helloResponse.getValue());
                    return helloResponse;
                });
    }

    public String markIp() {
        String localIp = Networking.getLocalIp();
        if (localIp == null) {
            return "";
        }
        return "(" + localIp + ")";
    }

    private String mark() {
        String localIp = Networking.getLocalIp();
        if (localIp == null) {
            return "";
        }
        return "(" + localIp + ")<-";
    }
}