package org.feuyeux.grpc;

import io.grpc.*;
import org.lognet.springboot.grpc.GRpcGlobalInterceptor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@ComponentScan("org.feuyeux.grpc")
public class GrpcDemoApplication {
    private static final Logger LOGGER = LoggerFactory.getLogger(GrpcDemoApplication.class);

    public static void main(String[] args) {
        SpringApplication.run(GrpcDemoApplication.class, args);
    }

    private static final Metadata.Key<String> x_request_id = Metadata.Key.of("x-request-id", Metadata.ASCII_STRING_MARSHALLER);
    private static final Metadata.Key<String> x_b3_traceid = Metadata.Key.of("x-b3-traceid", Metadata.ASCII_STRING_MARSHALLER);
    private static final Metadata.Key<String> x_b3_spanid = Metadata.Key.of("x-b3-spanid", Metadata.ASCII_STRING_MARSHALLER);
    private static final Metadata.Key<String> x_b3_parentspanid = Metadata.Key.of("x-b3-parentspanid", Metadata.ASCII_STRING_MARSHALLER);
    private static final Metadata.Key<String> x_b3_sampled = Metadata.Key.of("x-b3-sampled", Metadata.ASCII_STRING_MARSHALLER);
    private static final Metadata.Key<String> x_b3_flags = Metadata.Key.of("x-b3-flags", Metadata.ASCII_STRING_MARSHALLER);
    private static final Metadata.Key<String> x_ot_span_context = Metadata.Key.of("x-ot-span-context", Metadata.ASCII_STRING_MARSHALLER);

    @Bean
    @GRpcGlobalInterceptor
    public ServerInterceptor globalSInterceptor() {
        return new ServerInterceptor() {
            @Override
            public <ReqT, RespT> ServerCall.Listener<ReqT> interceptCall(
                    ServerCall<ReqT, RespT> call,
                    Metadata headers,
                    ServerCallHandler<ReqT, RespT> next) {
                LOGGER.info("ServerInterceptor HEADERS:{}", headers);
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
                        LOGGER.info("ClientInterceptor HEADERS:{}", headers);
                        Metadata tracingHeaders = new Metadata();
                        tracingHeaders.put(x_request_id, headers.get(x_request_id));
                        tracingHeaders.put(x_b3_traceid, headers.get(x_b3_traceid));
                        tracingHeaders.put(x_b3_spanid, headers.get(x_b3_traceid));
                        tracingHeaders.put(x_b3_parentspanid, headers.get(x_b3_traceid));
                        tracingHeaders.put(x_b3_sampled, headers.get(x_b3_traceid));
                        tracingHeaders.put(x_b3_flags, headers.get(x_b3_traceid));
                        tracingHeaders.put(x_ot_span_context, headers.get(x_b3_traceid));
                        super.start(new ForwardingClientCallListener.SimpleForwardingClientCallListener<RespT>(responseListener) {
                            @Override
                            public void onHeaders(Metadata headers) {
                                super.onHeaders(headers);
                            }
                        }, tracingHeaders);
                    }
                };
            }
        };
    }
}
