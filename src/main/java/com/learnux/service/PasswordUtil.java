package com.learnux.service;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import java.security.SecureRandom;
import java.util.Base64;

public class PasswordUtil {

    private static final int    ITERATIONS = 120_000;
    private static final int    KEY_BITS   = 256;
    private static final String ALGO       = "PBKDF2WithHmacSHA256";

    /** Devuelve "iterations:salt:hash" listo para guardar en BD. */
    public static String hash(String password) {
        byte[] salt = new byte[16];
        new SecureRandom().nextBytes(salt);
        byte[] key = derive(password.toCharArray(), salt, ITERATIONS, KEY_BITS);
        return ITERATIONS + ":" + b64(salt) + ":" + b64(key);
    }

    /** Comparación en tiempo constante para evitar timing attacks. */
    public static boolean verify(String password, String stored) {
        String[] p = stored.split(":");
        if (p.length != 3) return false;
        byte[] salt     = Base64.getDecoder().decode(p[1]);
        byte[] expected = Base64.getDecoder().decode(p[2]);
        byte[] actual   = derive(password.toCharArray(), salt, Integer.parseInt(p[0]), expected.length * 8);
        int diff = actual.length ^ expected.length;
        for (int i = 0; i < Math.min(actual.length, expected.length); i++) diff |= actual[i] ^ expected[i];
        return diff == 0;
    }

    private static byte[] derive(char[] pwd, byte[] salt, int iter, int keyBits) {
        try {
            return SecretKeyFactory.getInstance(ALGO)
                    .generateSecret(new PBEKeySpec(pwd, salt, iter, keyBits))
                    .getEncoded();
        } catch (Exception e) {
            throw new RuntimeException("Error en hashing de contraseña", e);
        }
    }

    private static String b64(byte[] data) { return Base64.getEncoder().encodeToString(data); }
}
