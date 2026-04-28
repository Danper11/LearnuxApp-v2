/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.learnux.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 *
 * @author dan
 */
public class DatabaseConnection {

    private static String url;
    private static String user;
    private static String password;

    static {
        // 1. Variable de entorno DATABASE_URL (Railway / Render la inyectan automáticamente)
        String dbEnv = System.getenv("DATABASE_URL");
        if (dbEnv != null) {
            try {
                java.net.URI uri  = new java.net.URI(dbEnv);
                String[] creds   = uri.getUserInfo().split(":");
                int port          = uri.getPort() == -1 ? 5432 : uri.getPort();
                url      = "jdbc:postgresql://" + uri.getHost() + ":" + port + uri.getPath();
                user     = creds[0];
                password = creds[1];
            } catch (Exception e) {
                System.err.println("DATABASE_URL inválida: " + e.getMessage());
            }
        }

        // 2. Archivo de propiedades local (desarrollo)
        if (url == null) {
            java.util.Properties props = new java.util.Properties();
            try (java.io.InputStream in = DatabaseConnection.class.getResourceAsStream("/learnux.properties")) {
                if (in != null) {
                    props.load(in);
                    url      = props.getProperty("db.url");
                    user     = props.getProperty("db.user");
                    password = props.getProperty("db.password");
                }
            } catch (java.io.IOException e) {
                System.err.println("No se pudo cargar learnux.properties.");
            }
        }

        // 3. Valores por defecto (local sin configuración)
        if (url == null)      url      = "jdbc:postgresql://localhost:5432/learnux_db";
        if (user == null)     user     = "postgres";
        if (password == null) password = "danper.exe";
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(url, user, password);
    }
}
