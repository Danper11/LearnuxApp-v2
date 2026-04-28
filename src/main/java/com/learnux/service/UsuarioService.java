package com.learnux.service;

import com.learnux.dao.UsuarioDao;
import com.learnux.models.Usuario;

/**
 * Lógica de negocio relacionada con usuarios.
 * Único punto de entrada para login y registro.
 */
public class UsuarioService {

    private final UsuarioDao usuarioDao = new UsuarioDao();

    // ── Resultado del inicio de sesión ────────────────────────────
    public static class LoginResultado {
        public final Usuario usuario;
        public final boolean esNuevo;  // true = recién registrado

        public LoginResultado(Usuario usuario, boolean esNuevo) {
            this.usuario = usuario;
            this.esNuevo = esNuevo;
        }
    }

    /** Solo inicia sesión; error si el usuario no existe. */
    public LoginResultado entrar(String nombre) throws ServiceException {
        String n = validar(nombre);
        Usuario usuario = usuarioDao.getUsuarioByNombre(n);
        if (usuario == null)
            throw new ServiceException("Usuario \"" + n + "\" no encontrado. ¿Aún no tienes cuenta? Usa «Registrarse».");
        return new LoginResultado(usuario, false);
    }

    /** Solo crea cuenta nueva; error si el nombre ya existe. */
    public LoginResultado registrar(String nombre) throws ServiceException {
        String n = validar(nombre);
        if (usuarioDao.getUsuarioByNombre(n) != null)
            throw new ServiceException("El nombre \"" + n + "\" ya está en uso. ¿Ya tienes cuenta? Usa «Entrar».");
        if (!usuarioDao.registrarNuevoUsuario(n))
            throw new ServiceException("No se pudo crear la cuenta. Intenta de nuevo.");
        Usuario usuario = usuarioDao.getUsuarioByNombre(n);
        if (usuario == null)
            throw new ServiceException("Error inesperado al recuperar el usuario.");
        return new LoginResultado(usuario, true);
    }

    /** Busca al usuario por nombre; si no existe lo registra automáticamente. */
    public LoginResultado iniciarSesion(String nombre) throws ServiceException {
        String n = validar(nombre);
        Usuario usuario = usuarioDao.getUsuarioByNombre(n);
        if (usuario != null) return new LoginResultado(usuario, false);
        if (!usuarioDao.registrarNuevoUsuario(n))
            throw new ServiceException("No se pudo registrar \"" + n + "\". Intenta de nuevo.");
        usuario = usuarioDao.getUsuarioByNombre(n);
        if (usuario == null)
            throw new ServiceException("Error inesperado al recuperar el usuario.");
        return new LoginResultado(usuario, true);
    }

    private String validar(String nombre) throws ServiceException {
        String n = nombre == null ? "" : nombre.trim();
        if (n.length() < 3)
            throw new ServiceException("El nombre debe tener al menos 3 caracteres.");
        return n;
    }
}
