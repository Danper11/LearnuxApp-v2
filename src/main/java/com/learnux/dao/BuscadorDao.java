package com.learnux.dao;

import com.learnux.models.Comando;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Llama a la función learnux.f_buscar_comando(p_nombre)
 * para buscar comandos por nombre parcial.
 */
public class BuscadorDao {

    public List<Comando> buscarPorNombre(String nombre) {
        List<Comando> lista = new ArrayList<>();
        String sql = "SELECT ret_id_comando, ret_comando_nombre, ret_descripcion, " +
                     "ret_sintaxis, ret_dificultad, ret_categoria " +
                     "FROM learnux.f_buscar_comando(?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, nombre);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    // Usamos id_categoria = 0 porque la búsqueda devuelve
                    // el nombre de categoría en ret_categoria, no el id
                    Comando c = new Comando(
                        rs.getInt("ret_id_comando"),
                        0,
                        rs.getString("ret_comando_nombre"),
                        rs.getString("ret_descripcion"),
                        rs.getString("ret_sintaxis"),
                        rs.getString("ret_dificultad")
                    );
                    lista.add(c);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error en búsqueda: " + e.getMessage());
        }
        return lista;
    }
}
