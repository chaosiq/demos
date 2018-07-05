package com.example.frontend;

import static junit.framework.TestCase.assertTrue;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.method;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.boot.test.autoconfigure.web.client.RestClientTest;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.client.MockRestServiceServer;

@RunWith(SpringRunner.class)
@SpringBootTest
@RestClientTest(BackendService.class)
@EnableConfigurationProperties(BackendService.BackendProperties.class)
public class BackendServiceTests {

    @Autowired
    private BackendService backendService;

    @Autowired
    private MockRestServiceServer server;
    
    @Before
    public void setup() {
    }

    @Test
    public void canMultiplyTwoNumbers() throws Exception {
        server.expect(requestTo("/multiply?a=6&b=7"))
                .andExpect(method(HttpMethod.GET))
                .andRespond(withSuccess("42", MediaType.TEXT_PLAIN));
            
        String result = backendService.multiply(6, 7);

        server.verify();

        assertTrue(result.equals("42"));
    }
}