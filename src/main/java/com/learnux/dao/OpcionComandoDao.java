package com.learnux.dao;

import com.learnux.models.OpcionComando;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class OpcionComandoDao {


    public List<OpcionComando> getOpcionesPorComando(int idComando) {
        List<OpcionComando> lista = new ArrayList<>();
        String sql = "SELECT ret_id_opcion, ret_id_comando, ret_bandera, "
                   + "ret_descripcion, ret_ejemplo_uso "
                   + "FROM learnux.f_get_opciones_comando(?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idComando);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    lista.add(new OpcionComando(
                        rs.getInt("ret_id_opcion"),
                        rs.getInt("ret_id_comando"),
                        rs.getString("ret_bandera"),
                        rs.getString("ret_descripcion"),
                        rs.getString("ret_ejemplo_uso")
                    ));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error obteniendo opciones del comando: " + e.getMessage());
        }
        return lista;
    }
}
