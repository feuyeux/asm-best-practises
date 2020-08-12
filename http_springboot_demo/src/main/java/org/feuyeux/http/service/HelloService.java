package org.feuyeux.http.service;

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
<<<<<<< HEAD:http_springboot_demo/src/main/java/org/feuyeux/http/api/HelloService.java
            return result;
=======
            return mark() + result;
>>>>>>> 9cc6f6c8a3798b3ed86027e67f5ade05b6a3ada3:http_springboot_demo/src/main/java/org/feuyeux/http/service/HelloService.java
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
<<<<<<< HEAD:http_springboot_demo/src/main/java/org/feuyeux/http/api/HelloService.java
            return result;
        } catch (IOException e) {
            LOGGER.error("", e);
            return "";
=======
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
>>>>>>> 9cc6f6c8a3798b3ed86027e67f5ade05b6a3ada3:http_springboot_demo/src/main/java/org/feuyeux/http/service/HelloService.java
        }
        return "(" + localIp + ")<-";
    }
}