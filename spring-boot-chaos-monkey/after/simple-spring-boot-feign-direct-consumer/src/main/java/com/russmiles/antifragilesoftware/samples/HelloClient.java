package com.russmiles.antifragilesoftware.samples;

import org.springframework.cloud.netflix.feign.FeignClient;
import static org.springframework.web.bind.annotation.RequestMethod.GET;
import org.springframework.web.bind.annotation.RequestMapping;

@FeignClient(name = "${consumed.microservice.name}", url = "${consumed.microservice.url}")
interface HelloClient {
    @RequestMapping(value = "/", method = GET)
    String hello();
}