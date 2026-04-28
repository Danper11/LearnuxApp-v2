/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.learnux.models;

/**
 *
 * @author dan
 */
public class Comando {

    private int idComando;
    private int idCategoria;
    private String comandoNombre;
    private String descripcion;
    private String sintaxis;
    private String dificultadNivel;

    public Comando(int idComando, int idCategoria, String comandoNombre, String descripcion, String sintaxis, String dificultadNivel) {
        this.idComando = idComando;
        this.idCategoria = idCategoria;
        this.comandoNombre = comandoNombre;
        this.descripcion = descripcion;
        this.sintaxis = sintaxis;
        this.dificultadNivel = dificultadNivel;
    }

    public int getIdComando() {
        return idComando;
    }

    public int getIdCategoria() {
        return idCategoria;
    }

    public String getComandoNombre() {
        return comandoNombre;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public String getSintaxis() {
        return sintaxis;
    }

    public String getDificultadNivel() {
        return dificultadNivel;
    }
}
