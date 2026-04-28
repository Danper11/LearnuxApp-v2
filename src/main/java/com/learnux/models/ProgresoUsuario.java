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
public class ProgresoUsuario {

    private int idUsuario;
    private int idComando;
    private boolean dominado;
    private int vecesPracticado;
    private Timestamp ultimaPractica;

    public ProgresoUsuario(int idUsuario, int idComando, boolean dominado, int vecesPracticado, Timestamp ultimaPractica) {
        this.idUsuario = idUsuario;
        this.idComando = idComando;
        this.dominado = dominado;
        this.vecesPracticado = vecesPracticado;
        this.ultimaPractica = ultimaPractica;
    }

    public int getIdUsuario() {
        return idUsuario;
    }

    public int getIdComando() {
        return idComando;
    }

    public boolean isDominado() {
        return dominado;
    }

    public int getVecesPracticado() {
        return vecesPracticado;
    }

    public Timestamp getUltimaPractica() {
        return ultimaPractica;
    }
}
