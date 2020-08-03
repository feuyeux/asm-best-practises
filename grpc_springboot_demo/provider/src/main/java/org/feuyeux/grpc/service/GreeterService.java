package org.feuyeux.grpc.service;

import com.google.common.util.concurrent.ListenableFuture;
import com.google.protobuf.Empty;
import io.grpc.ManagedChannel;
import io.grpc.ManagedChannelBuilder;
import org.feuyeux.grpc.proto.GreeterGrpc;
import org.feuyeux.grpc.proto.HelloReply;
import org.feuyeux.grpc.proto.HelloRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.concurrent.ExecutionException;

@Service
public class GreeterService {
    private static final Logger LOGGER = LoggerFactory.getLogger(GreeterService.class);

    public String sayHello(String address, String name) {
        final ManagedChannel channel = ManagedChannelBuilder.forAddress(address, 7001)
                .usePlaintext()
                .build();
        final GreeterGrpc.GreeterFutureStub stub = GreeterGrpc.newFutureStub(channel);
        ListenableFuture<HelloReply> future = stub.sayHello(HelloRequest.newBuilder().setName(name).build());
        try {
            return mark() + future.get().getReply();
        } catch (InterruptedException | ExecutionException e) {
            LOGGER.error("", e);
            return "";
        }
    }

    public String sayBye(String address) {
        final ManagedChannel channel = ManagedChannelBuilder.forAddress(address, 7001)
                .usePlaintext()
                .build();
        final GreeterGrpc.GreeterFutureStub stub = GreeterGrpc.newFutureStub(channel);
        ListenableFuture<HelloReply> future = stub.sayBye(Empty.newBuilder().build());
        try {
            return mark() + future.get().getReply();
        } catch (InterruptedException | ExecutionException e) {
            LOGGER.error("", e);
            return "";
        }
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
