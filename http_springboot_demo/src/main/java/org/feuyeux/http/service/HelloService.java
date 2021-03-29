package org.feuyeux.http.service;

import okhttp3.*;
import org.feuyeux.http.exception.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@Service
public class HelloService {
    private static final Logger LOGGER = LoggerFactory.getLogger(HelloService.class);
    private static String HOST;
    private final OkHttpClient client = new OkHttpClient();

    static {
        String HOSTNAME = System.getenv("HOSTNAME");
        if (HOSTNAME != null) {
            String[] ss = HOSTNAME.split("-");
            HOST = ss[0];
        }
    }

    public String sayHello(String url, Map<String, String> headers) throws HelloException, IOException {
        Map<String, String> tracingHeaders = buildTracingHeaders(headers);
        Request request = new Request.Builder()
                //propagate tracing headers
                .headers(Headers.of(tracingHeaders))
                .url(url)
                .build();
        try (Response response = client.newCall(request).execute()) {
            return handleResponse(url, response);
        }
    }

    private String handleResponse(String url, Response response) throws HelloException, IOException {
        if (response.isSuccessful()) {
            ResponseBody body = response.body();
            if (body == null) {
                return "???";
            }
            String result = body.string();
            LOGGER.info("url:{} result:{}", url, result);
            return result;
        } else {
            LOGGER.info("url:{} error code:{}", url, response.code());
            if (response.code() == HttpStatus.NOT_FOUND.value()) {
                throw new Hello404Exception();
            }
            if (response.code() == HttpStatus.BAD_REQUEST.value()) {
                throw new Hello400Exception();
            }
            if (response.code() == HttpStatus.INTERNAL_SERVER_ERROR.value()) {
                throw new Hello500Exception();
            }
            if (response.code() == HttpStatus.SERVICE_UNAVAILABLE.value()) {
                throw new Hello503Exception();
            }
            throw new HelloException();
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
            return handleResponse(url, response);
        } catch (IOException e) {
            LOGGER.error("", e);
            return markIp() + "<";
        }
    }

    public String markIp() {
        String localIp = Networking.getLocalIp();
        if (localIp == null) {
            return "";
        }
        return "@" + HOST + ":" + localIp;
    }

    private Map<String, String> buildTracingHeaders(Map<String, String> headers) {
        return buildTracingHeaders(headers,
                "x-request-id",
                "x-b3-traceid",
                "x-b3-spanid",
                "x-b3-parentspanid",
                "x-b3-sampled",
                "x-b3-flags",
                "x-ot-span-context");
    }
}

