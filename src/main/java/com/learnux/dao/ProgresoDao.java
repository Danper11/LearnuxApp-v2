/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.learnux.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

/**
 *
 * @author dan
 */
public class ProgresoDao {

    /**
     * Marca un nivel boss como completado directamente en progreso_nivel.
     * Esto dispara el trigger fn_avanzar_nivel_usuario que desbloquea el siguiente nivel.
     */
    public void completarNivelBoss(int idUsuario, int idNivel) {
        String sql = """
            INSERT INTO learnux.progreso_nivel
                (id_usuario, id_nivel, completado, fecha_completado, puntos_acumulados, intentos_totales)
            VALUES (?, ?, TRUE, CURRENT_TIMESTAMP, 100, 4)
            ON CONFLICT (id_usuario, id_nivel) DO UPDATE
                SET completado       = TRUE,
                    fecha_completado = CURRENT_TIMESTAMP
            """;

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, idUsuario);
            ps.setInt(2, idNivel);
            ps.execute();

        } catch (SQLException e) {
            System.err.println("ProgresoDao.completarNivelBoss: " + e.getMessage());
        }
    }

    public void registrarPractica(int idUsuario, int idComando, boolean marcarDominado) {
        String sql = "CALL learnux.sp_actualizar_progreso(?, ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, idUsuario);
            ps.setInt(2, idComando);
            ps.setBoolean(3, marcarDominado);
            ps.execute();

        } catch (SQLException e) {
            System.err.println("Error updating progress: " + e.getMessage());
        }
    }
}
