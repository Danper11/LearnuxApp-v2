package com.learnux.models;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Ejercicio {

    private int     idEjercicio;
    private int     idNivel;
    private Integer idComando;
    private String  tipo;
    private String  pregunta;
    private String  respuestaCorrecta;
    private String  opcionesJson;
    private String  pista;
    private int     orden;
    private String  salidaSimulada;

    public Ejercicio(int idEjercicio, int idNivel, Integer idComando,
                     String tipo, String pregunta, String respuestaCorrecta,
                     String opcionesJson, String pista, int orden, String salidaSimulada) {
        this.idEjercicio       = idEjercicio;
        this.idNivel           = idNivel;
        this.idComando         = idComando;
        this.tipo              = tipo;
        this.pregunta          = pregunta;
        this.respuestaCorrecta = respuestaCorrecta;
        this.opcionesJson      = opcionesJson;
        this.pista             = pista;
        this.orden             = orden;
        this.salidaSimulada    = salidaSimulada;
    }

    /** Parsea opciones_json como lista de strings (para arrays JSON). */
    public java.util.List<String> getOpciones() {
        return com.learnux.ui.UiUtil.parseJsonArray(opcionesJson);
    }

    public boolean esCorrecta(String respuesta) {
        if (respuesta == null || respuestaCorrecta == null) return false;
        return respuesta.trim().equalsIgnoreCase(respuestaCorrecta.trim());
    }

    public int     getIdEjercicio()       { return idEjercicio; }
    public int     getIdNivel()           { return idNivel; }
    public Integer getIdComando()         { return idComando; }
    public String  getTipo()              { return tipo; }
    public String  getPregunta()          { return pregunta; }
    public String  getRespuestaCorrecta() { return respuestaCorrecta; }
    public String  getOpcionesJson()      { return opcionesJson; }
    public String  getPista()             { return pista; }
    public int     getOrden()             { return orden; }
    public String  getSalidaSimulada()    { return salidaSimulada; }
}
