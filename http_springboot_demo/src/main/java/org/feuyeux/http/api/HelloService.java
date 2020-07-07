package org.feuyeux.http.api;

import okhttp3.Headers;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.io.IOException;

@Service
public class HelloService {
    private static final Logger LOGGER = LoggerFactory.getLogger(HelloService.class);
    private OkHttpClient client = new OkHttpClient();
    private static String  HTTP_HELLO_BACKEND = System.getenv("HTTP_HELLO_BACKEND");
    public String sayHello(@PathVariable String msg) throws IOException{
        String url = "http://" + HTTP_HELLO_BACKEND + ":8001/hello/" + msg;
        Request request = new Request.Builder()
                .url(url)
                .build();
        try (Response response = client.newCall(request).execute()) {
            if (!response.isSuccessful()) throw new IOException("Unexpected code " + response);
            String result = response.body().string();
            LOGGER.info("{} {}", HTTP_HELLO_BACKEND, result);
            return result;
        }
    }
    @GetMapping(path = "/bye")
    public String sayBye() throws IOException {
        String url = "http://" + HTTP_HELLO_BACKEND + ":8001/bye";
        Request request = new Request.Builder()
                .url(url)
                .build();
        try (Response response = client.newCall(request).execute()) {
            if (!response.isSuccessful()) throw new IOException("Unexpected code " + response);
            String result = response.body().string();
            LOGGER.info("{} {}", HTTP_HELLO_BACKEND, result);
            return result;
        }
    }
}