package com.kaiten.mcp.hello;

import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(produces = MediaType.APPLICATION_JSON_VALUE)
public class HelloController {

    private final HelloService helloService;

    public HelloController(HelloService helloService) {
        this.helloService = helloService;
    }

    @GetMapping("/hello/{name}")
    public Greeting hello(@PathVariable String name) {
        return helloService.greet(name);
    }

    @GetMapping("/hello")
    public void helloMissing() {
        throw new IllegalArgumentException("name missing");
    }
}
