/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.learnux.models;

/**
 *
 * @author dan
 */
public class OpcionComando {

    private int idOpcion;
    private int idComando;
    private String bandera;
    private String descripcion;
    private String ejemploUso;

    public OpcionComando(int idOpcion, int idComando, String bandera, String descripcion, String ejemploUso) {
        this.idOpcion = idOpcion;
        this.idComando = idComando;
        this.bandera = bandera;
        this.descripcion = descripcion;
        this.ejemploUso = ejemploUso;
    }

    public int getIdOpcion() {
        return idOpcion;
    }

    public int getIdComando() {
        return idComando;
    }

    public String getBandera() {
        return bandera;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public String getEjemploUso() {
        return ejemploUso;
    }
}
