package org.feuyeux.grpc.service;

import io.grpc.stub.StreamObserver;
import org.feuyeux.grpc.proto.GreeterGrpc.GreeterImplBase;
import org.feuyeux.grpc.proto.HelloReply;
import org.feuyeux.grpc.proto.HelloRequest;
import org.lognet.springboot.grpc.GRpcService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.concurrent.TimeUnit;

@GRpcService
public class GreeterImpl extends GreeterImplBase {

    private static final Logger LOGGER = LoggerFactory.getLogger(GreeterImpl.class);

    @Override
    public void sayHello(HelloRequest request, StreamObserver<HelloReply> responseObserver) {
        long begin = System.currentTimeMillis();
        LOGGER.info("server received {}", request);
        try {
            TimeUnit.MILLISECONDS.sleep(500);
        } catch (InterruptedException e) {
            LOGGER.error("", e);
        }
        String message = "Hello " + request.getName() + "!";
        HelloReply helloReply = HelloReply.newBuilder().setReply(message).build();
        long end = System.currentTimeMillis();
        LOGGER.info("server responded {} elapse:{}ms", message, end - begin);
        responseObserver.onNext(helloReply);
        responseObserver.onCompleted();
    }

    @Override
    public void sayBye(com.google.protobuf.Empty request, StreamObserver<HelloReply> responseObserver) {
        long begin = System.currentTimeMillis();
        try {
            TimeUnit.MILLISECONDS.sleep(1500);
        } catch (InterruptedException e) {
            LOGGER.error("", e);
        }
        String message = "Bye bye!";
        HelloReply helloReply = HelloReply.newBuilder().setReply(message).build();
        long end = System.currentTimeMillis();
        LOGGER.info("server responded {} elapse:{}ms", message, end - begin);
        responseObserver.onNext(helloReply);
        responseObserver.onCompleted();
    }
}
