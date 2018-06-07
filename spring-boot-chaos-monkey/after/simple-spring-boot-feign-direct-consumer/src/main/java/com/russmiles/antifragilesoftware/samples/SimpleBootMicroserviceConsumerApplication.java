package com.russmiles.antifragilesoftware.samples;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.feign.EnableFeignClients;
import org.springframework.cloud.client.circuitbreaker.EnableCircuitBreaker;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
@EnableFeignClients
@EnableCircuitBreaker
public class SimpleBootMicroserviceConsumerApplication {

    @Autowired
    private HelloService helloService;

    @RequestMapping("/")
    public String home() {
        return "Simple Boot Microservice Consumer Alive!";
    }

    @RequestMapping("/invokeConsumedService")
    public String invokeConsumedService() {
        return helloService.goAndSayHello();
    }

    public static void main(String[] args) {
        SpringApplication.run(SimpleBootMicroserviceConsumerApplication.class, args);
    }
}
