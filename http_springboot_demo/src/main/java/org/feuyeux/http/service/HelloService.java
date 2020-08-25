package org.feuyeux.http.service;

import okhttp3.Headers;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@Service
public class HelloService {
    private static final Logger LOGGER = LoggerFactory.getLogger(HelloService.class);
    private final OkHttpClient client = new OkHttpClient();

    public String sayHello(String url, Map<String, String> headers) {
        Map<String, String> tracingHeaders = buildTracingHeaders(headers,
                "x-request-id",
                "x-b3-traceid",
                "x-b3-spanid",
                "x-b3-parentspanid",
                "x-b3-sampled",
                "x-b3-flags",
                "x-ot-span-context");
        Request request = new Request.Builder()
                //propagate tracing headers
                .headers(Headers.of(tracingHeaders))
                .url(url)
                .build();
        try (Response response = client.newCall(request).execute()) {
            if (!response.isSuccessful()) throw new IOException("Unexpected code " + response);
            String result = response.body().string();
            LOGGER.info("url:{} result:{}", url, result);
            return mark() + result;
        } catch (IOException e) {
            LOGGER.error("", e);
            return mark();
        }
    }

    private Map<String, String> buildTracingHeaders(Map<String, String> headers, String... keys) {
        Map<String, String> nextHeaders = new HashMap<>();
        for (String key : keys) {
            String value = headers.get(key);
            if (value != null) {
                nextHeaders.put(key, value);
            }
        }
        return nextHeaders;
    }

    public void logHeaders(Map<String, String> headers) {
        headers.forEach((key, value) -> LOGGER.info("H {}={}", key, value));
    }

    public String sayBye(String url, Map<String, String> headers) {
        logHeaders(headers);
        Request request = new Request.Builder()
                .headers(Headers.of(headers))
                .url(url)
                .build();
        try (Response response = client.newCall(request).execute()) {
            if (!response.isSuccessful()) throw new IOException("Unexpected code " + response);
            String result = response.body().string();
            LOGGER.info("url:{} result:{}", url, result);
            return mark() + result;
        } catch (IOException e) {
            LOGGER.error("", e);
            return mark();
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