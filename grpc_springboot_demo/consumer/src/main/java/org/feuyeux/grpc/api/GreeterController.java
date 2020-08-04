/**
 *
 */
package org.feuyeux.grpc.api;

import com.google.common.util.concurrent.ListenableFuture;
import com.google.protobuf.Empty;
import io.grpc.ManagedChannel;
import io.grpc.ManagedChannelBuilder;
import org.feuyeux.grpc.proto.GreeterGrpc;
import org.feuyeux.grpc.proto.HelloReply;
import org.feuyeux.grpc.proto.HelloRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutionException;

@RestController
public class GreeterController {
    private static final Logger LOGGER = LoggerFactory.getLogger(GreeterController.class);
    private Map<String, GreeterGrpc.GreeterFutureStub> map = new ConcurrentHashMap<>();

    @GetMapping(path = "/hello/{msg}")
    public String sayHello(@PathVariable String msg, @RequestParam String host, @RequestParam int port) {
        LOGGER.info("sayHello received message: {}", msg);
        final GreeterGrpc.GreeterFutureStub stub = getGreeterFutureStub(host, port);
        ListenableFuture<HelloReply> future = stub.sayHello(HelloRequest.newBuilder().setName(msg).build());
        try {
            return future.get().getReply();
        } catch (InterruptedException | ExecutionException e) {
            LOGGER.error("", e);
            return "ERROR";
        }
    }

    @GetMapping("bye")
    public String sayBye(@RequestParam(name = "host") String host, @RequestParam(name = "port") int port) {
        final GreeterGrpc.GreeterFutureStub stub = getGreeterFutureStub(host, port);
        ListenableFuture<HelloReply> future = stub.sayBye(Empty.newBuilder().build());
        try {
            return future.get().getReply();
        } catch (InterruptedException | ExecutionException e) {
            LOGGER.error("", e);
            return "ERROR";
        }
    }

    private GreeterGrpc.GreeterFutureStub getGreeterFutureStub(@RequestParam String host, @RequestParam int port) {
        String key = host + ":" + port;
        GreeterGrpc.GreeterFutureStub stub = map.get(key);
        if (stub == null) {
            LOGGER.info("Init stub for {}", key);
            synchronized (map) {
                final ManagedChannel channel = ManagedChannelBuilder.forAddress(host, port)
                        .usePlaintext()
                        .build();
                stub = GreeterGrpc.newFutureStub(channel);
                map.put(key, stub);
            }
        }
        return stub;
    }
}
