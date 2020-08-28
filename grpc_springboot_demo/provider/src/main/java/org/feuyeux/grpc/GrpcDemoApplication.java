package org.feuyeux.grpc;

import io.grpc.*;
import org.lognet.springboot.grpc.GRpcGlobalInterceptor;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@ComponentScan("org.feuyeux.grpc")
public class GrpcDemoApplication {
    public static void main(String[] args) {
        SpringApplication.run(GrpcDemoApplication.class, args);
    }

    @Bean
    @GRpcGlobalInterceptor
    public ServerInterceptor globalSInterceptor() {
        return new ServerInterceptor() {
            @Override
            public <ReqT, RespT> ServerCall.Listener<ReqT> interceptCall(
                    ServerCall<ReqT, RespT> call,
                    Metadata headers,
                    ServerCallHandler<ReqT, RespT> next) {
                System.out.println(headers);
                return next.startCall(call, headers);
            }
        };
    }

    @Bean
    @GRpcGlobalInterceptor
    public ClientInterceptor globalCInterceptor() {
        return new ClientInterceptor() {
            @Override
            public <ReqT, RespT> ClientCall<ReqT, RespT> interceptCall(
                    MethodDescriptor<ReqT, RespT> methodDescriptor,
                    CallOptions callOptions,
                    Channel channel) {
                return new ForwardingClientCall.SimpleForwardingClientCall<ReqT, RespT>(channel.newCall(methodDescriptor, callOptions)) {
                    @Override
                    public void start(Listener<RespT> responseListener, Metadata headers) {
                        super.start(new ForwardingClientCallListener.SimpleForwardingClientCallListener<RespT>(responseListener) {
                            @Override
                            public void onHeaders(Metadata headers) {
                                System.out.println("header received from server:" + headers);
                                super.onHeaders(headers);
                            }
                        }, headers);
                    }
                };
            }
        };
    }
}
