package org.feuyeux.http.exception;


import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(value = HttpStatus.BAD_REQUEST)
public class Hello400Exception extends HelloException {
    public Hello400Exception() {
        super();
    }
}
