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
        Map<String, String> nextHeaders = buildHeaders(headers);
        Request request = new Request.Builder()
                .headers(Headers.of(nextHeaders))
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

    private Map<String, String> buildHeaders(Map<String, String> headers) {
        Map<String, String> nextHeaders = new HashMap<>();
        fillHeader(headers, nextHeaders, "x-request-id");
        fillHeader(headers, nextHeaders, "x-b3-traceid");
        fillHeader(headers, nextHeaders, "x-b3-spanid");
        fillHeader(headers, nextHeaders, "x-b3-parentspanid");
        fillHeader(headers, nextHeaders, "x-b3-sampled");
        fillHeader(headers, nextHeaders, "x-b3-flags");
        fillHeader(headers, nextHeaders, "x-ot-span-context");
        return nextHeaders;
    }

    private void fillHeader(Map<String, String> headers, Map<String, String> nextHeaders, String key) {
        String value = headers.get(key);
        if (value != null) {
            nextHeaders.put(key, value);
        }
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