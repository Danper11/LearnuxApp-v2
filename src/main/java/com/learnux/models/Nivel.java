package com.learnux.models;

public class Nivel {

    private int     idNivel;
    private int     numero;
    private String  nombre;
    private String  descripcion;
    private String  tipoEjercicio;
    private String  dificultad;
    private int     puntosParaPasar;
    private int     puntosRecompensa;
    // progreso del usuario
    private boolean completado;
    private int     puntosAcumulados;
    private boolean desbloqueado;

    public Nivel(int idNivel, int numero, String nombre, String descripcion,
                 String tipoEjercicio, String dificultad,
                 int puntosParaPasar, int puntosRecompensa,
                 boolean completado, int puntosAcumulados, boolean desbloqueado) {
        this.idNivel          = idNivel;
        this.numero           = numero;
        this.nombre           = nombre;
        this.descripcion      = descripcion;
        this.tipoEjercicio    = tipoEjercicio;
        this.dificultad       = dificultad;
        this.puntosParaPasar  = puntosParaPasar;
        this.puntosRecompensa = puntosRecompensa;
        this.completado       = completado;
        this.puntosAcumulados = puntosAcumulados;
        this.desbloqueado     = desbloqueado;
    }

    public int     getIdNivel()          { return idNivel; }
    public int     getNumero()           { return numero; }
    public String  getNombre()           { return nombre; }
    public String  getDescripcion()      { return descripcion; }
    public String  getTipoEjercicio()    { return tipoEjercicio; }
    public String  getDificultad()       { return dificultad; }
    public int     getPuntosParaPasar()  { return puntosParaPasar; }
    public int     getPuntosRecompensa() { return puntosRecompensa; }
    public boolean isCompletado()        { return completado; }
    public int     getPuntosAcumulados() { return puntosAcumulados; }
    public boolean isDesbloqueado()      { return desbloqueado; }
}
