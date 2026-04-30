package com.learnux.service;

import com.learnux.dao.ProgresoDao;
import com.learnux.dao.ResumenDao;
import com.learnux.dao.ResumenDao.FilaProgreso;
import com.learnux.dao.ResumenDao.Resumen;

import java.util.Collections;
import java.util.List;

/**
 * Lógica de negocio para el progreso del usuario:
 * registro de prácticas, consulta de estadísticas y detalle.
 */
public class ProgresoService {

    private final ProgresoDao progresoDao = new ProgresoDao();
    private final ResumenDao  resumenDao  = new ResumenDao();


    public void completarNivelBoss(int idUsuario, int idNivel) {
        progresoDao.completarNivelBoss(idUsuario, idNivel);
    }

    public void registrarPractica(int idUsuario, int idComando, boolean dominado)
            throws ServiceException {
        if (idUsuario <= 0 || idComando <= 0) {
            throw new ServiceException("Datos de práctica no válidos.");
        }
        try {
            progresoDao.registrarPractica(idUsuario, idComando, dominado);
        } catch (Exception e) {
            throw new ServiceException("No se pudo guardar la práctica. Intenta de nuevo.", e);
        }
    }


    public Resumen getResumen(String nombreUsuario) {
        try {
            return resumenDao.getResumen(nombreUsuario);
        } catch (Exception e) {
            System.err.println("ProgresoService.getResumen: " + e.getMessage());
            return new Resumen(0, 0, "Sin actividad");
        }
    }

    public List<FilaProgreso> getDetalle(int idUsuario) {
        try {
            return resumenDao.getDetalle(idUsuario);
        } catch (Exception e) {
            System.err.println("ProgresoService.getDetalle: " + e.getMessage());
            return Collections.emptyList();
        }
    }
}
