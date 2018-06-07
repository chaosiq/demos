package io.chaosiq.demo;

import org.springframework.stereotype.Service;

@Service
public class HelloService {

    public String hello() {
        return "Simple Boot Service Alive!";
    }
}

