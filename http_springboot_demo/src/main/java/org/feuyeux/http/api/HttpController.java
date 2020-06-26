package org.feuyeux.http.api;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicLong;

@RestController
public class HttpController {
    private static final Logger LOGGER = LoggerFactory.getLogger(HttpController.class);
    private AtomicLong timeout = new AtomicLong();

    @GetMapping(path = "/hello/{msg}")
    public String sayHello(@PathVariable String msg) throws InterruptedException {
        String result = "Hola " + msg;
        long t = this.timeout.addAndGet(100);
        TimeUnit.MILLISECONDS.sleep(t);
        LOGGER.info("{}, {}ms", result, t);
        return result;
    }
}
