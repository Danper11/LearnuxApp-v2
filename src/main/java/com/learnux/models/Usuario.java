/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.learnux.models;

import java.sql.Timestamp;

/**
 *
 * @author dan
 */
public class Usuario {

    private int idUsuario;
    private String nombreUsuario;
    private Timestamp fechaCreacion;

    public Usuario(int idUsuario, String nombreUsuario, Timestamp fechaCreacion) {
        this.idUsuario = idUsuario;
        this.nombreUsuario = nombreUsuario;
        this.fechaCreacion = fechaCreacion;
    }

    public int getIdUsuario() {
        return idUsuario;
    }

    public String getNombreUsuario() {
        return nombreUsuario;
    }

    public Timestamp getFechaCreacion() {
        return fechaCreacion;
    }
}
