package org.feuyeux.http.exception;


import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(value = HttpStatus.SERVICE_UNAVAILABLE)
public class Hello503Exception extends HelloException {
    public Hello503Exception() {
        super();
    }
}
