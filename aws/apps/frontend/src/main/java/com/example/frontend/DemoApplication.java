package com.example.frontend;

import org.springframework.boot.SpringApplication;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;


@ResponseStatus(value = HttpStatus.INTERNAL_SERVER_ERROR)
class BoomFoundException extends RuntimeException{
}

@SpringBootApplication
@RestController
@EnableConfigurationProperties(BackendService.BackendProperties.class)
public class DemoApplication {
    @Autowired
    private BackendService backendService;

    @RequestMapping("/")
    public String home() {
        return "Simple Boot Microservice Consumer Alive!";
    }

    @RequestMapping(value="/multiply", method=RequestMethod.GET)
    public String multiply(@RequestParam(value="a") Integer a, @RequestParam(value="b") Integer b) {
        String response = backendService.multiply(a, b);
        if (response == null) {
            throw new BoomFoundException();
        }
        return response;
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
