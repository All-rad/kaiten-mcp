package com.kaiten.mcp.hello;

import org.springframework.stereotype.Service;

@Service
public class HelloService {
    public Greeting greet(String name) {
        if (name == null || name.isBlank()) {
            throw new IllegalArgumentException("name missing");
        }
        if (name.length() > 256) {
            throw new IllegalArgumentException("name too long");
        }
        return new Greeting(String.format("Hello, %s", name));
    }
}
