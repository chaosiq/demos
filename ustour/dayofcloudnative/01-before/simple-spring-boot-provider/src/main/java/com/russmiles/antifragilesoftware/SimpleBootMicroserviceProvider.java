package com.russmiles.antifragilesoftware;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class SimpleBootMicroserviceProvider {

    private final Logger log = LoggerFactory.getLogger(this.getClass());

    @RequestMapping("/")
    public String home() {
        log.info("Root URL invoked");

        return this.toString() + " instance saying: Hello Microservice World\n";
    }

    public static void main(String[] args) {
        SpringApplication.run(SimpleBootMicroserviceProvider.class, args);
    }
}
