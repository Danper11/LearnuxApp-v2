package com.learnux.dao;

import com.learnux.models.Usuario;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;

public class UsuarioDao {

    /**
     * Busca un usuario activo por nombre usando la función f_buscar_usuario.
     * Toda la validación vive en la BD, el DAO solo mapea el resultado.
     */
    public Usuario getUsuarioByNombre(String nombreUsuario) {
        String sql = "SELECT ret_id_usuario, ret_nombre_usuario, ret_fecha_creacion "
                   + "FROM learnux.f_buscar_usuario(?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, nombreUsuario);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return new Usuario(
                        rs.getInt("ret_id_usuario"),
                        rs.getString("ret_nombre_usuario"),
                        rs.getTimestamp("ret_fecha_creacion")
                    );
                }
            }
        } catch (SQLException e) {
            System.err.println("Error buscando usuario: " + e.getMessage());
        }
        return null;
    }

    public String getPasswordHash(int idUsuario) {
        String sql = "SELECT password_hash FROM learnux.usuario WHERE id_usuario = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getString("password_hash");
            }
        } catch (SQLException e) {
            System.err.println("Error obteniendo password_hash: " + e.getMessage());
        }
        return null;
    }

    public void setPasswordHash(int idUsuario, String hash) {
        String sql = "UPDATE learnux.usuario SET password_hash = ? WHERE id_usuario = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, hash);
            ps.setInt(2, idUsuario);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("Error actualizando password_hash: " + e.getMessage());
        }
    }

    /**
     * Registra un usuario nuevo usando el procedure sp_registrar_usuario.
     * El procedure aplica la transacción, valida longitud mínima y
     * desbloquea el nivel 1 automáticamente.
     */
    public boolean registrarNuevoUsuario(String nombreUsuario) {
        String sql = "CALL learnux.sp_registrar_usuario(?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, nombreUsuario);
            ps.setNull(2, Types.VARCHAR);
            ps.execute();
            return true;

        } catch (SQLException e) {
            System.err.println("Error registrando usuario: " + e.getMessage());
            return false;
        }
    }
}
