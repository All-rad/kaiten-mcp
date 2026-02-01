package com.kaiten.mcp.hello;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertThrows;

class HelloValidationTest {

    private final HelloService helloService = new HelloService();

    @Test
    @DisplayName("Too long name triggers IllegalArgumentException")
    void tooLongName() {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < 300; i++) sb.append('a');
        String longName = sb.toString();
        assertThrows(IllegalArgumentException.class, () -> helloService.greet(longName));
    }

    @Test
    @DisplayName("Empty name triggers IllegalArgumentException with message 'name missing'")
    void emptyName() {
        assertThrows(IllegalArgumentException.class, () -> helloService.greet(""));
    }
}
