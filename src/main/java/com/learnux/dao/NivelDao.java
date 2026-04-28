package com.learnux.dao;

import com.learnux.models.Nivel;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NivelDao {

    public List<Nivel> getNivelesConProgreso(int idUsuario) {
        List<Nivel> lista = new ArrayList<>();
        String sql = "SELECT ret_id_nivel, ret_numero, ret_nombre, ret_descripcion, "
                   + "ret_tipo_ejercicio, ret_dificultad, ret_puntos_para_pasar, "
                   + "ret_puntos_recompensa, ret_completado, ret_puntos_acumulados, "
                   + "ret_desbloqueado "
                   + "FROM learnux.f_get_niveles_con_progreso(?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(new Nivel(
                        rs.getInt("ret_id_nivel"),
                        rs.getInt("ret_numero"),
                        rs.getString("ret_nombre"),
                        rs.getString("ret_descripcion"),
                        rs.getString("ret_tipo_ejercicio"),
                        rs.getString("ret_dificultad"),
                        rs.getInt("ret_puntos_para_pasar"),
                        rs.getInt("ret_puntos_recompensa"),
                        rs.getBoolean("ret_completado"),
                        rs.getInt("ret_puntos_acumulados"),
                        rs.getBoolean("ret_desbloqueado")
                    ));
                }
            }
        } catch (SQLException e) {
            System.err.println("NivelDao.getNivelesConProgreso: " + e.getMessage());
        }
        return lista;
    }

}
