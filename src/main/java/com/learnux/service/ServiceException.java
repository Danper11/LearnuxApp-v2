package com.learnux.service;

/**
 * Excepción de negocio con mensaje listo para mostrarse en la UI.
 * Los servicios la lanzan cuando una regla de negocio falla;
 * los paneles la capturan y muestran el mensaje directamente.
 */
public class ServiceException extends Exception {

    public ServiceException(String mensaje) {
        super(mensaje);
    }

    public ServiceException(String mensaje, Throwable causa) {
        super(mensaje, causa);
    }
}
