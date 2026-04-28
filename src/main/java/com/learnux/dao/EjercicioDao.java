package com.learnux.dao;

import com.learnux.models.Ejercicio;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class EjercicioDao {

    public List<Ejercicio> getEjerciciosDeNivel(int idNivel) {
        List<Ejercicio> lista = new ArrayList<>();
        String sql = "SELECT ret_id_ejercicio, ret_id_nivel, ret_id_comando, ret_tipo, "
                   + "ret_pregunta, ret_respuesta_correcta, ret_opciones_json, "
                   + "ret_pista, ret_orden, ret_salida_simulada "
                   + "FROM learnux.f_get_ejercicios_nivel(?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, idNivel);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int idCmd = rs.getInt("ret_id_comando");
                    lista.add(new Ejercicio(
                        rs.getInt("ret_id_ejercicio"),
                        rs.getInt("ret_id_nivel"),
                        rs.wasNull() ? null : idCmd,
                        rs.getString("ret_tipo"),
                        rs.getString("ret_pregunta"),
                        rs.getString("ret_respuesta_correcta"),
                        rs.getString("ret_opciones_json"),
                        rs.getString("ret_pista"),
                        rs.getInt("ret_orden"),
                        rs.getString("ret_salida_simulada")
                    ));
                }
            }
        } catch (SQLException e) {
            System.err.println("EjercicioDao.getEjerciciosDeNivel: " + e.getMessage());
        }
        return lista;
    }

    public void registrarIntento(int idUsuario, int idEjercicio,
                                 String respuesta, Integer tiempoSeg) {
        String sql = "CALL learnux.sp_registrar_intento(?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, idUsuario);
            ps.setInt(2, idEjercicio);
            ps.setString(3, respuesta);
            if (tiempoSeg != null) ps.setInt(4, tiempoSeg);
            else                   ps.setNull(4, Types.INTEGER);
            ps.execute();
        } catch (SQLException e) {
            System.err.println("EjercicioDao.registrarIntento: " + e.getMessage());
        }
    }
}
