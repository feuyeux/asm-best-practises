package org.feuyeux.rsocket;

import lombok.extern.slf4j.Slf4j;
import org.feuyeux.rsocket.pojo.HelloResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

/**
 * @author feuyeux@gmail.com
 */
@Slf4j
@RestController
public class HelloController {
    @Autowired
    private HelloRSocketAdapter helloRSocketAdapter;

    @GetMapping("hello/{msg}")
    Mono<HelloResponse> getHello(@PathVariable String msg) {
        return helloRSocketAdapter.getHello(msg);
    }
}
