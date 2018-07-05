package com.example.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class DemoApplication {

    @RequestMapping("/")
    public String home() {
        return "Simple Boot Microservice Backend Alive!";
    }

    @RequestMapping("/multiply")
    public String multiply(Integer a, Integer b) {
        Integer c = a * b;
        return c.toString();
    }

    @RequestMapping("/status")
    public String status() {
        return "OK";
    }

    @RequestMapping("/health")
    public String health() {
        return "OK";
    }

	public static void main(String[] args) {
		SpringApplication.run(DemoApplication.class, args);
	}
}
