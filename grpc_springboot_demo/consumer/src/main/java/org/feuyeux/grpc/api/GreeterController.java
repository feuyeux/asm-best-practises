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
import org.springframework.web.bind.annotation.RestController;

import java.util.concurrent.ExecutionException;

@RestController
public class GreeterController {
    private static final Logger LOGGER = LoggerFactory.getLogger(GreeterController.class);
    private static String GRPC_PROVIDER_HOST;

    static {
        GRPC_PROVIDER_HOST = System.getenv("GRPC_PROVIDER_HOST");
        if (GRPC_PROVIDER_HOST == null || GRPC_PROVIDER_HOST.isEmpty()) {
            GRPC_PROVIDER_HOST = "provider";
        }
        LOGGER.info("GRPC_PROVIDER_HOST={}", GRPC_PROVIDER_HOST);
    }

    @GetMapping(path = "/hello/{msg}")
    public String sayHello(@PathVariable String msg) {
        LOGGER.info("GRPC_PROVIDER_HOST={}, sayHello received message: {}", GRPC_PROVIDER_HOST, msg);
        final ManagedChannel channel = ManagedChannelBuilder.forAddress(GRPC_PROVIDER_HOST, 6565)
                .usePlaintext()
                .build();
        final GreeterGrpc.GreeterFutureStub stub = GreeterGrpc.newFutureStub(channel);
        ListenableFuture<HelloReply> future = stub.sayHello(HelloRequest.newBuilder().setName(msg).build());
        try {
            return future.get().getReply();
        } catch (InterruptedException | ExecutionException e) {
            LOGGER.error("", e);
            return "ERROR";
        }
    }

    @GetMapping("bye")
    public String sayBye() {
        LOGGER.info("GRPC_PROVIDER_HOST={}, sayBye received message", GRPC_PROVIDER_HOST);
        final ManagedChannel channel = ManagedChannelBuilder.forAddress(GRPC_PROVIDER_HOST, 6565)
                .usePlaintext()
                .build();
        final GreeterGrpc.GreeterFutureStub stub = GreeterGrpc.newFutureStub(channel);
        ListenableFuture<HelloReply> future = stub.sayBye(Empty.newBuilder().build());
        try {
            return future.get().getReply();
        } catch (InterruptedException | ExecutionException e) {
            LOGGER.error("", e);
            return "ERROR";
        }
    }
}
