package com.kaiten.mcp.hello;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.Mockito.when;
import static org.mockito.Mockito.doThrow;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(HelloController.class)
class HelloControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private HelloService helloService;

    @Test
    @DisplayName("GET /hello/{name} returns greeting")
    void greetingShouldReturnMessage() throws Exception {
        when(helloService.greet("Иван")).thenReturn(new Greeting("Hello, Иван"));

        mockMvc.perform(get("/hello/Иван"))
                .andExpect(status().isOk())
                .andExpect(content().contentType("application/json"))
                .andExpect(jsonPath("$.message").value("Hello, Иван"));
    }

    @Test
    @DisplayName("GET /hello returns name missing error")
    void missingNameReturns400() throws Exception {
        mockMvc.perform(get("/hello"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("name missing"));
    }

    @Test
    @DisplayName("GET /hello with too long name returns 400")
    void tooLongNameReturns400() throws Exception {
        String longName = "a".repeat(300);
        doThrow(new IllegalArgumentException("name too long"))
            .when(helloService).greet(longName);

        mockMvc.perform(get("/hello/" + longName))
                .andExpect(status().isBadRequest());
    }
}
