package org.feuyeux.http.exception;


import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(value = HttpStatus.INTERNAL_SERVER_ERROR )
public class Hello500Exception extends HelloException {
    public Hello500Exception() {
        super();
    }
    public Hello500Exception(Throwable cause) {
        super(cause);
    }
}
