package com.learnux.service;

import com.learnux.dao.BuscadorDao;
import com.learnux.dao.CategoriaDao;
import com.learnux.dao.ComandoDao;
import com.learnux.dao.OpcionComandoDao;
import com.learnux.models.Categoria;
import com.learnux.models.Comando;
import com.learnux.models.OpcionComando;

import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Lógica de negocio para comandos, categorías y sus opciones.
 * Centraliza validaciones y reglas de presentación.
 */
public class ComandoService {

    private final CategoriaDao   categoriaDao   = new CategoriaDao();
    private final ComandoDao     comandoDao     = new ComandoDao();
    private final BuscadorDao    buscadorDao    = new BuscadorDao();
    private final OpcionComandoDao opcionDao    = new OpcionComandoDao();

    public List<Comando> getComandosDeNivel(int idNivel) {
        try {
            return comandoDao.getComandosDeNivel(idNivel);
        } catch (Exception e) {
            System.err.println("ComandoService.getComandosDeNivel: " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /**
     * Devuelve todas las categorías disponibles.
     * Retorna lista vacía en lugar de null ante cualquier fallo.
     */
    public List<Categoria> getCategorias() {
        try {
            return categoriaDao.getAllCategorias();
        } catch (Exception e) {
            System.err.println("ComandoService.getCategorias: " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /**
     * Devuelve los comandos de una categoría específica.
     *
     * @throws ServiceException si el id de categoría no es válido
     */
    private static final Map<String, Integer> DIF_ORDER =
        Map.of("principiante", 1, "intermedio", 2, "avanzado", 3);

    private List<Comando> porDificultad(List<Comando> lista) {
        return lista.stream()
            .sorted(Comparator.comparingInt(c ->
                DIF_ORDER.getOrDefault(
                    c.getDificultadNivel() != null ? c.getDificultadNivel().toLowerCase() : "", 4)))
            .collect(Collectors.toList());
    }

    public List<Comando> getAllComandos() throws ServiceException {
        try {
            return porDificultad(comandoDao.getAllComandos());
        } catch (Exception e) {
            throw new ServiceException("Error al cargar todos los comandos.", e);
        }
    }

    public List<Comando> getComandosPorCategoria(int idCategoria) throws ServiceException {
        if (idCategoria <= 0) {
            throw new ServiceException("Categoría no válida.");
        }
        try {
            return porDificultad(comandoDao.getComandosPorCategoria(idCategoria));
        } catch (Exception e) {
            throw new ServiceException("Error al cargar los comandos.", e);
        }
    }

    public List<Comando> buscarComandos(String texto) throws ServiceException {
        if (texto == null || texto.trim().length() < 1) {
            return Collections.emptyList();
        }
        try {
            return porDificultad(buscadorDao.buscarPorNombre(texto.trim()));
        } catch (Exception e) {
            throw new ServiceException("Error al buscar comandos.", e);
        }
    }

    /**
     * Devuelve las banderas/opciones de un comando concreto.
     */
    public List<OpcionComando> getOpciones(int idComando) {
        try {
            return opcionDao.getOpcionesPorComando(idComando);
        } catch (Exception e) {
            System.err.println("ComandoService.getOpciones: " + e.getMessage());
            return Collections.emptyList();
        }
    }
}
