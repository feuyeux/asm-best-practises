package org.feuyeux.grpc;

import io.grpc.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static org.feuyeux.grpc.Constants.contextKeys;
import static org.feuyeux.grpc.Constants.tracingKeys;

public class HelloServerInterceptor implements ServerInterceptor {
    private static final Logger LOGGER = LoggerFactory.getLogger(HelloServerInterceptor.class);

    @Override
    public <ReqT, RespT> ServerCall.Listener<ReqT> interceptCall(
            ServerCall<ReqT, RespT> call,
            final Metadata requestHeaders,
            ServerCallHandler<ReqT, RespT> next) {
        Context current = Context.current();
        LOGGER.info("Context:{}", current.toString());
        for (int i = 0; i < tracingKeys.size(); i++) {
            Metadata.Key<String> tracingKey = tracingKeys.get(i);
            String metadata = requestHeaders.get(tracingKey);
            Context.Key<String> key = contextKeys.get(i);
            LOGGER.info("Save to context {}:{}", key, metadata);
            if (metadata != null) {
                current = current.withValue(key, metadata);
            }
        }
        return Contexts.interceptCall(current, call, requestHeaders, next);
    }
}