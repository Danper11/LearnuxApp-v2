/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.learnux.dao;

import com.learnux.models.Comando;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author dan
 */
public class ComandoDao {

    public List<Comando> getComandosDeNivel(int idNivel) {
        List<Comando> lista = new ArrayList<>();
        String sql = "SELECT ret_id_comando, ret_nombre, ret_descripcion, ret_sintaxis, ret_dificultad "
                   + "FROM learnux.f_get_comandos_de_nivel(?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idNivel);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(new Comando(
                        rs.getInt("ret_id_comando"), 0,
                        rs.getString("ret_nombre"),
                        rs.getString("ret_descripcion"),
                        rs.getString("ret_sintaxis"),
                        rs.getString("ret_dificultad")
                    ));
                }
            }
        } catch (SQLException e) {
            System.err.println("ComandoDao.getComandosDeNivel: " + e.getMessage());
        }
        return lista;
    }

    public List<Comando> getAllComandos() {
        List<Comando> lista = new ArrayList<>();
        String sql = "SELECT id_comando, id_categoria, comando_nombre, descripcion, sintaxis, dificultad_nivel "
                   + "FROM learnux.comandos ORDER BY comando_nombre";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(new Comando(
                    rs.getInt("id_comando"),
                    rs.getInt("id_categoria"),
                    rs.getString("comando_nombre"),
                    rs.getString("descripcion"),
                    rs.getString("sintaxis"),
                    rs.getString("dificultad_nivel")
                ));
            }
        } catch (SQLException e) {
            System.err.println("ComandoDao.getAllComandos: " + e.getMessage());
        }
        return lista;
    }

    public List<Comando> getComandosPorCategoria(int idCategoria) {
        List<Comando> listaComandos = new ArrayList<>();
        // Note: Querying the PostgreSQL function exactly as if it were a table
        String sql = "SELECT * FROM learnux.f_ls_comandos_categoria(?)";

        try (Connection conn = DatabaseConnection.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idCategoria);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Comando comando = new Comando(
                            rs.getInt("ret_id_comando"),
                            rs.getInt("ret_id_categoria"),
                            rs.getString("ret_comando_nombre"),
                            rs.getString("ret_descripcion"),
                            rs.getString("ret_sintaxis"),
                            rs.getString("ret_dificultad")
                    );
                    listaComandos.add(comando);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error fetching commands: " + e.getMessage());
        }
        return listaComandos;
    }
}
