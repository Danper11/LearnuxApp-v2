package com.learnux.service;

import com.learnux.dao.EjercicioDao;
import com.learnux.dao.NivelDao;
import com.learnux.models.Ejercicio;
import com.learnux.models.Nivel;

import java.util.*;
import java.util.stream.Collectors;

public class NivelService {

    private final NivelDao nivelDao = new NivelDao();
    private final EjercicioDao ejercicioDao = new EjercicioDao();

    private static final Set<Integer> IDs_USADOS = new HashSet<>();

    public static void resetRepetidos() {
        IDs_USADOS.clear();
    }

    public List<Nivel> getNivelesConProgreso(int idUsuario) {
        try {
            return nivelDao.getNivelesConProgreso(idUsuario);
        } catch (Exception e) {
            return Collections.emptyList();
        }
    }

    public List<Ejercicio> getEjercicios(Nivel nivel) throws ServiceException {
        try {
            List<Ejercicio> todos = ejercicioDao.getEjerciciosDeNivel(nivel.getIdNivel());
            if (todos.isEmpty()) {
                throw new ServiceException("Nivel sin ejercicios.");
            }

            List<Ejercicio> disponibles = filtrarPorTier(todos, nivel.getNumero());
            
            if (nivel.getNumero() <= 12) {
                List<Ejercicio> noRepetidos = disponibles.stream()
                    .filter(e -> !IDs_USADOS.contains(e.getIdEjercicio()))
                    .collect(Collectors.toList());
                
                if (noRepetidos.size() >= 1) {
                    disponibles = noRepetidos;
                }
            }

            Collections.shuffle(disponibles);
            List<Ejercicio> seleccion = disponibles.subList(0, Math.min(4, disponibles.size()));
            
            if (nivel.getNumero() <= 12) {
                for (Ejercicio e : seleccion) IDs_USADOS.add(e.getIdEjercicio());
            }

            return seleccion;
        } catch (ServiceException e) {
            throw e;
        } catch (Exception e) {
            throw new ServiceException("Error al cargar ejercicios.", e);
        }
    }

    public List<Ejercicio> getEjerciciosPorId(int idNivel) throws ServiceException {
        try {
            List<Ejercicio> todos = ejercicioDao.getEjerciciosDeNivel(idNivel);
            if (todos.isEmpty()) {
                throw new ServiceException("Nivel sin ejercicios.");
            }
            List<Ejercicio> lista = new ArrayList<>(todos);
            Collections.shuffle(lista);
            return lista.subList(0, Math.min(4, lista.size()));
        } catch (ServiceException e) {
            throw e;
        } catch (Exception e) {
            throw new ServiceException("Error al cargar ejercicios.", e);
        }
    }

    public boolean registrarIntento(int idUsuario, Ejercicio ejercicio, String respuesta, Integer tiempoSeg) {
        boolean correcta = ejercicio.esCorrecta(respuesta);
        ejercicioDao.registrarIntento(idUsuario, ejercicio.getIdEjercicio(), respuesta, tiempoSeg);
        return correcta;
    }

    private List<Ejercicio> filtrarPorTier(List<Ejercicio> ejercicios, int numeroNivel) {
        if (permitirTerminalSim(numeroNivel)) {
            return new ArrayList<>(ejercicios);
        }
        List<Ejercicio> sinTerminal = ejercicios.stream()
            .filter(e -> !"TERMINAL_SIM".equals(e.getTipo()))
            .collect(Collectors.toCollection(ArrayList::new));
        return sinTerminal.isEmpty() ? new ArrayList<>(ejercicios) : sinTerminal;
    }

    private boolean permitirTerminalSim(int numeroNivel) {
        return numeroNivel == 6 || numeroNivel == 12 || numeroNivel >= 13;
    }
}
