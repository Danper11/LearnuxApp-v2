package com.learnux.dao;

import com.learnux.models.Categoria;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class CategoriaDao {

    /**
     * Devuelve todas las categorías usando la función f_get_todas_categorias.
     * El orden y el filtrado quedan en la BD.
     */
    public List<Categoria> getAllCategorias() {
        List<Categoria> lista = new ArrayList<>();
        String sql = "SELECT ret_id_categoria, ret_nombre, ret_descripcion "
                   + "FROM learnux.f_get_todas_categorias()";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                lista.add(new Categoria(
                    rs.getInt("ret_id_categoria"),
                    rs.getString("ret_nombre"),
                    rs.getString("ret_descripcion")
                ));
            }
        } catch (SQLException e) {
            System.err.println("Error obteniendo categorías: " + e.getMessage());
        }
        return lista;
    }
}
