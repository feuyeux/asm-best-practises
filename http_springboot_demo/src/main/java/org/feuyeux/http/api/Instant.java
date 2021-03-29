package org.feuyeux.http.api;

public class Instant {
    static Message version1 = new Message("Hello", "Bye bye");
    static Message version2 = new Message("Bonjour", "Au revoir");
    static Message version3 = new Message("Hola", "Adióbais");
}
record Message(String hello, String bye) {
}
