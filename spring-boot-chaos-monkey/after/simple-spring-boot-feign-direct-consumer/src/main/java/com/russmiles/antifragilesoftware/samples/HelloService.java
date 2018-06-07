package com.russmiles.antifragilesoftware.samples;

import com.netflix.hystrix.contrib.javanica.annotation.HystrixCommand;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class HelloService {

    @Autowired
    private HelloClient consumedService;


    @HystrixCommand(fallbackMethod = "getBackupHello")
    public String goAndSayHello() {
        return consumedService.hello();
    }

    String getBackupHello() {
        return "Hmm, no one available to say hello just yet ... maybe try later?";
    }
}