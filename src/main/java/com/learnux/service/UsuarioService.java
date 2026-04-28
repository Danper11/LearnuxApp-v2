package com.learnux.service;

import com.learnux.dao.UsuarioDao;
import com.learnux.models.Usuario;

public class UsuarioService {

    private final UsuarioDao usuarioDao = new UsuarioDao();

    public static class LoginResultado {
        public final Usuario usuario;
        public final boolean esNuevo;        // true = cuenta recién creada
        public final boolean primerPassword; // true = primera vez usando contraseña

        public LoginResultado(Usuario usuario, boolean esNuevo, boolean primerPassword) {
            this.usuario        = usuario;
            this.esNuevo        = esNuevo;
            this.primerPassword = primerPassword;
        }
    }

    /** Inicia sesión verificando contraseña. Si el usuario no tiene contraseña aún, la establece. */
    public LoginResultado entrar(String nombre, String password) throws ServiceException {
        String n = validarNombre(nombre);
        validarPassword(password);

        Usuario usuario = usuarioDao.getUsuarioByNombre(n);
        if (usuario == null)
            throw new ServiceException("Usuario \"" + n + "\" no encontrado. ¿Aún no tienes cuenta? Usa «Registrarse».");

        String hash = usuarioDao.getPasswordHash(usuario.getIdUsuario());
        if (hash == null) {
            // Cuenta existente sin contraseña: la establece ahora
            usuarioDao.setPasswordHash(usuario.getIdUsuario(), PasswordUtil.hash(password));
            return new LoginResultado(usuario, false, true);
        }
        if (!PasswordUtil.verify(password, hash))
            throw new ServiceException("Contraseña incorrecta.");

        return new LoginResultado(usuario, false, false);
    }

    /** Crea una cuenta nueva con contraseña. */
    public LoginResultado registrar(String nombre, String password) throws ServiceException {
        String n = validarNombre(nombre);
        validarPassword(password);

        if (usuarioDao.getUsuarioByNombre(n) != null)
            throw new ServiceException("El nombre \"" + n + "\" ya está en uso. ¿Ya tienes cuenta? Usa «Entrar».");
        if (!usuarioDao.registrarNuevoUsuario(n))
            throw new ServiceException("No se pudo crear la cuenta. Intenta de nuevo.");

        Usuario usuario = usuarioDao.getUsuarioByNombre(n);
        if (usuario == null)
            throw new ServiceException("Error inesperado al recuperar el usuario.");

        usuarioDao.setPasswordHash(usuario.getIdUsuario(), PasswordUtil.hash(password));
        return new LoginResultado(usuario, true, false);
    }

    private String validarNombre(String nombre) throws ServiceException {
        String n = nombre == null ? "" : nombre.trim();
        if (n.length() < 3)
            throw new ServiceException("El nombre debe tener al menos 3 caracteres.");
        return n;
    }

    private void validarPassword(String password) throws ServiceException {
        if (password == null || password.length() < 4)
            throw new ServiceException("La contraseña debe tener al menos 4 caracteres.");
    }
}
