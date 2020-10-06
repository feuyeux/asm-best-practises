package org.feuyeux.grpc;

import io.grpc.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.concurrent.Executor;

import static org.feuyeux.grpc.Constants.contextKeys;
import static org.feuyeux.grpc.Constants.tracingKeys;

public class HelloClientInterceptor implements ClientInterceptor {
    private static final Logger LOGGER = LoggerFactory.getLogger(HelloClientInterceptor.class);

    @Override
    public <ReqT, RespT> ClientCall<ReqT, RespT> interceptCall(MethodDescriptor<ReqT, RespT> method, CallOptions callOptions, Channel next) {
        return next.newCall(method, callOptions.withCallCredentials(new CallCredentials() {
            @Override
            public void applyRequestMetadata(RequestInfo requestInfo, Executor executor, MetadataApplier metadataApplier) {
                executor.execute(() -> {
                    try {
                        Metadata headers = new Metadata();
                        Context context = Context.current();
                        LOGGER.info("Context:{}",context.toString());
                        for (int i = 0; i < tracingKeys.size(); i++) {
                            String metadata = contextKeys.get(i).get(context);
                            Metadata.Key<String> key = tracingKeys.get(i);
                            LOGGER.info("Get from context {}:{}", key, metadata);
                            if (metadata != null) {
                                headers.put(key, metadata);
                            }
                        }
                        metadataApplier.apply(headers);
                    } catch (Throwable e) {
                        LOGGER.error("", e);
                    }
                });
            }

            @Override
            public void thisUsesUnstableApi() {
            }
        }));
    }
}