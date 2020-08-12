package org.feuyeux.http.service;

import io.netty.buffer.ByteBufAllocator;
import io.netty.buffer.CompositeByteBuf;
import io.netty.buffer.Unpooled;
import io.rsocket.metadata.CompositeMetadataFlyweight;
import io.rsocket.util.ByteBufPayload;
import lombok.extern.slf4j.Slf4j;
import org.feuyeux.http.pojo.HelloRequest;
import org.feuyeux.http.pojo.HelloResponse;
import org.springframework.messaging.rsocket.RSocketRequester;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import reactor.core.publisher.Mono;

import javax.annotation.PostConstruct;

@Slf4j
@Service
public class HelloService {
    public static final String MESSAGE_X_ORG_FEUYEUX_RSOCKET_META = "message/x.org.feuyeux.rsocket.meta";
    private static String RSOCKET_HELLO_BACKEND = System.getenv("RSOCKET_HELLO_BACKEND");
    private RSocketRequester rSocketRequester;

    @PostConstruct
    public void init() {
        if (!StringUtils.isEmpty(RSOCKET_HELLO_BACKEND)) {
            rSocketRequester = RSocketRequester.builder()
                    .connectTcp(RSOCKET_HELLO_BACKEND, 9001)
                    .block();
        }
    }

    public void metaData(String metaMessage) {
        CompositeByteBuf metadataByteBuf = ByteBufAllocator.DEFAULT.compositeBuffer();
        CompositeMetadataFlyweight.encodeAndAddMetadata(
                metadataByteBuf,
                ByteBufAllocator.DEFAULT,
                MESSAGE_X_ORG_FEUYEUX_RSOCKET_META,
                ByteBufAllocator.DEFAULT.buffer().writeBytes(metaMessage.getBytes()));
        rSocketRequester.rsocket()
                .metadataPush(ByteBufPayload.create(Unpooled.EMPTY_BUFFER, metadataByteBuf))
                .block();
    }

    public Mono<HelloResponse> sayHello(HelloRequest helloRequest) {
        return rSocketRequester
                .route("hello")
                .data(helloRequest)
                .retrieveMono(HelloResponse.class)
                .doOnNext(response -> log.info("<< [Request-Response] response:{}", response.getValue()))
                .map(helloResponse -> {
                    helloResponse.setValue(mark() + helloResponse.getValue());
                    return helloResponse;
                });
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