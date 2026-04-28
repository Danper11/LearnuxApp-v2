package com.learnux.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Consulta el progreso de un usuario usando:
 *   - learnux.f_resumen_progreso(id_usuario)  → detalle por comando
 *   - learnux.vista_resumen_progreso           → totales generales
 */
public class ResumenDao {

    // ── Fila de detalle ──────────────────────────────────────────
    public static class FilaProgreso {
        public String  comando;
        public String  dificultad;
        public boolean dominado;
        public int     veces;
        public String  ultimaPractica;

        public FilaProgreso(String comando, String dificultad,
                            boolean dominado, int veces, String ultimaPractica) {
            this.comando        = comando;
            this.dificultad     = dificultad;
            this.dominado       = dominado;
            this.veces          = veces;
            this.ultimaPractica = ultimaPractica;
        }
    }

    // ── Totales generales ────────────────────────────────────────
    public static class Resumen {
        public int    totalPracticados;
        public int    totalDominados;
        public String ultimaActividad;

        public Resumen(int totalPracticados, int totalDominados, String ultimaActividad) {
            this.totalPracticados = totalPracticados;
            this.totalDominados   = totalDominados;
            this.ultimaActividad  = ultimaActividad;
        }
    }

    /**
     * Detalle de cada comando practicado por el usuario.
     * Llama a f_resumen_progreso(p_id_usuario).
     */
    public List<FilaProgreso> getDetalle(int idUsuario) {
        List<FilaProgreso> lista = new ArrayList<>();
        String sql = "SELECT ret_comando, ret_dificultad, ret_dominado, " +
                     "ret_veces, ret_ultima " +
                     "FROM learnux.f_resumen_progreso(?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, idUsuario);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Timestamp ts = rs.getTimestamp("ret_ultima");
                    String fecha = ts != null
                        ? ts.toLocalDateTime().toLocalDate().toString()
                        : "—";

                    lista.add(new FilaProgreso(
                        rs.getString("ret_comando"),
                        rs.getString("ret_dificultad"),
                        rs.getBoolean("ret_dominado"),
                        rs.getInt("ret_veces"),
                        fecha
                    ));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error obteniendo detalle: " + e.getMessage());
        }
        return lista;
    }

    /**
     * Totales generales del usuario desde vista_resumen_progreso.
     */
    public Resumen getResumen(String nombreUsuario) {
        String sql = "SELECT total_practicados, total_dominados, ultima_actividad " +
                     "FROM learnux.vista_resumen_progreso " +
                     "WHERE nombre_usuario = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, nombreUsuario);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Timestamp ts = rs.getTimestamp("ultima_actividad");
                    String fecha = ts != null
                        ? ts.toLocalDateTime().toLocalDate().toString()
                        : "Sin actividad";

                    return new Resumen(
                        rs.getInt("total_practicados"),
                        rs.getInt("total_dominados"),
                        fecha
                    );
                }
            }
        } catch (SQLException e) {
            System.err.println("Error obteniendo resumen: " + e.getMessage());
        }
        return new Resumen(0, 0, "Sin actividad");
    }
}
