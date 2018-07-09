package com.example.frontend;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

@Service
@Configuration
public class BackendService {
    @Autowired
    RestTemplate restTemplate;
    
    @Autowired
    private BackendProperties properties;
    
    @Autowired
    public BackendService(BackendProperties properties) {
        this.properties = properties;
    }

    @Bean
    public RestTemplate restTemplate(RestTemplateBuilder builder) {
        return builder
            .rootUri(properties.getUrl())
            .setConnectTimeout(500)
            .setReadTimeout(1000)
            .build();
    }

    @ConfigurationProperties(prefix="backend")
    public static class BackendProperties {
        private String url = "http://backend:8080";

        public String getUrl() {
            return url;
        }

        public void setUrl(String url) {
            this.url = url;
        }
    }

    public String multiply(Integer a, Integer b) {
        try {
            ResponseEntity<String> response = restTemplate.exchange(
                "/multiply?a={a}&b={b}",
                HttpMethod.GET,
                HttpEntity.EMPTY,
                String.class,
                a.toString(),
                b.toString()
            );
            return response.getBody();
        } catch (RestClientException e) {
            return null;
        }
    }
}
