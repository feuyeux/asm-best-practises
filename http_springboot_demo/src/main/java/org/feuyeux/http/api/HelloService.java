package org.feuyeux.http.api;

import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.io.IOException;

@Service
public class HelloService {
    private static final Logger LOGGER = LoggerFactory.getLogger(HelloService.class);
    private OkHttpClient client = new OkHttpClient();

    public String sayHello(String url) {
        Request request = new Request.Builder()
                .url(url)
                .build();
        try (Response response = client.newCall(request).execute()) {
            if (!response.isSuccessful()) throw new IOException("Unexpected code " + response);
            String result = response.body().string();
            LOGGER.info("url:{} result:{}", url, result);
            return mark() + result;
        } catch (IOException e) {
            LOGGER.error("", e);
            return "";
        }
    }

    public String sayBye(String url) {
        Request request = new Request.Builder()
                .url(url)
                .build();
        try (Response response = client.newCall(request).execute()) {
            if (!response.isSuccessful()) throw new IOException("Unexpected code " + response);
            String result = response.body().string();
            LOGGER.info("url:{} result:{}", url, result);
            return mark() + result;
        } catch (IOException e) {
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