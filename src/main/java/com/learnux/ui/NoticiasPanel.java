package com.learnux.ui;

import javax.swing.*;
import javax.swing.border.EmptyBorder;
import java.awt.*;

public class NoticiasPanel extends JPanel {

    private static final Color BG      = UiUtil.BG_DARK;
    private static final Color BG_CARD = UiUtil.BG_CARD;
    private static final Color BG_HDR  = UiUtil.BG_HDR;
    private static final Color TEXT    = UiUtil.TEXT;
    private static final Color SUB     = UiUtil.OVERLAY;
    private static final Color ACCENT  = UiUtil.BLUE;
    private static final Color GREEN   = UiUtil.GREEN;
    private static final Color YELLOW  = UiUtil.YELLOW;
    private static final Color PURPLE  = UiUtil.MAUVE;
    private static final Color PINK    = UiUtil.RED;

    public NoticiasPanel() {
        setLayout(new BorderLayout());
        setBackground(BG);
        add(construirHeader(), BorderLayout.NORTH);
        add(construirContenido(), BorderLayout.CENTER);
    }

    private JPanel construirHeader() {
        JPanel h = new JPanel(new BorderLayout());
        h.setBackground(BG_HDR);
        h.setBorder(new EmptyBorder(14, 20, 14, 20));
        JLabel titulo = new JLabel("📰  Noticias & Actualizaciones");
        titulo.setFont(new Font("Monospaced", Font.BOLD, 18));
        titulo.setForeground(ACCENT);
        JLabel sub = new JLabel("Lo último de LearnUX");
        sub.setFont(new Font("Monospaced", Font.PLAIN, 13));
        sub.setForeground(SUB);
        h.add(titulo, BorderLayout.WEST);
        h.add(sub,    BorderLayout.EAST);
        return h;
    }

    private JScrollPane construirContenido() {
        JPanel panel = new JPanel();
        panel.setLayout(new BoxLayout(panel, BoxLayout.Y_AXIS));
        panel.setBackground(BG);
        panel.setBorder(new EmptyBorder(18, 24, 18, 24));

        // ── Noticias hardcoded ────────────────────────────────────
        Object[][] noticias = {
            {
                "🎉", "nuevo",
                "LearnUX v2.0 — Ejercicios interactivos en 5 tipos",
                "22 Abr 2026",
                PINK,
                "¡La nueva versión está aquí! Ahora contamos con cinco tipos de ejercicios: "
                + "arrastrar y soltar, opción múltiple, completar espacio, escribir comando y "
                + "terminal simulada. Además, sistema de vidas, rachas de aciertos y sonidos de feedback."
            },
            {
                "🎓", "nuevo",
                "Jefes Finales por Tier",
                "27 Abr 2026",
                YELLOW,
                "Cada tier ahora tiene un Jefe Final — un desafío que pone a prueba "
                + "todos los comandos aprendidos en situaciones reales de sysadmin. "
                + "24 niveles en 4 tiers: Fundamentos (1-6), Intermedio (7-12), "
                + "Avanzado (13-18) y Maestro (19-24)."
            },
            {
                "📚", null,
                "Enciclopedia de comandos actualizada — 20+ banderas nuevas",
                "15 Abr 2026",
                ACCENT,
                "Se han añadido más de 20 banderas documentadas con ejemplos de uso real para comandos "
                + "como grep, find, tar, chmod, ps, df y más. La enciclopedia ahora incluye casos "
                + "de uso concretos para cada bandera."
            },
            {
                "🎮", null,
                "20 niveles con progresión completa y sistema de puntos",
                "10 Abr 2026",
                GREEN,
                "LearnUX cuenta con 24 niveles organizados en 4 tiers: Fundamentos (1-5), "
                + "Intermedio (6-10), Avanzado (11-15) y Maestro (16-20). Cada nivel otorga puntos "
                + "de recompensa y desbloquea el siguiente al completarse."
            },
            {
                "🔥", null,
                "Sistema de gamificación: vidas, rachas y confetti",
                "5 Abr 2026",
                PURPLE,
                "Cada sesión de ejercicio ahora tiene 3 vidas, contador de racha de aciertos "
                + "consecutivos y animación de confetti al superar un nivel. Las respuestas "
                + "correctas e incorrectas tienen feedback de sonido sintetizado."
            },
            {
                "🐧", null,
                "¡Bienvenido a LearnUX!",
                "1 Abr 2026",
                SUB,
                "LearnUX nace como un proyecto para hacer el aprendizaje de Linux accesible "
                + "y entretenido. La terminal ya no da miedo cuando aprendes paso a paso con "
                + "ejercicios prácticos. ¡Comienza tu aventura en el mundo de la línea de comandos!"
            },
        };

        for (Object[] n : noticias) {
            panel.add(crearTarjetaNoticia(
                (String)n[0], (String)n[1], (String)n[2],
                (String)n[3], (Color)n[4],  (String)n[5]
            ));
            panel.add(Box.createVerticalStrut(14));
        }

        panel.add(Box.createVerticalGlue());

        JScrollPane scroll = new JScrollPane(panel);
        scroll.setBorder(null);
        scroll.getViewport().setBackground(BG);
        scroll.setHorizontalScrollBarPolicy(JScrollPane.HORIZONTAL_SCROLLBAR_NEVER);
        scroll.getVerticalScrollBar().setUnitIncrement(16);
        UiUtil.estilizarScroll(scroll);
        return scroll;
    }

    private JPanel crearTarjetaNoticia(String icon, String badge, String titulo,
                                       String fecha, Color accent, String cuerpo) {
        JPanel card = new JPanel(new BorderLayout(14, 0));
        card.setBackground(BG_CARD);
        card.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createMatteBorder(0, 4, 0, 0, accent),
            new EmptyBorder(16, 18, 16, 18)));
        card.setAlignmentX(Component.LEFT_ALIGNMENT);
        card.setMaximumSize(new Dimension(Integer.MAX_VALUE, 9999));

        // Icono
        JLabel lblIcon = new JLabel(icon);
        lblIcon.setFont(new Font("Monospaced", Font.PLAIN, 28));
        lblIcon.setVerticalAlignment(SwingConstants.TOP);

        // Contenido derecho
        JPanel derecha = new JPanel();
        derecha.setLayout(new BoxLayout(derecha, BoxLayout.Y_AXIS));
        derecha.setBackground(BG_CARD);

        // Fila título + badge + fecha
        JPanel fila = new JPanel(new BorderLayout(8, 0));
        fila.setBackground(BG_CARD);
        fila.setAlignmentX(Component.LEFT_ALIGNMENT);
        fila.setMaximumSize(new Dimension(Integer.MAX_VALUE, 28));

        JPanel tituloRow = new JPanel(new FlowLayout(FlowLayout.LEFT, 8, 0));
        tituloRow.setBackground(BG_CARD);

        JLabel lblT = new JLabel(titulo);
        lblT.setFont(new Font("Monospaced", Font.BOLD, 16));
        lblT.setForeground(TEXT);
        tituloRow.add(lblT);

        if (badge != null) {
            JLabel lblBadge = new JLabel("  ● NUEVO  ");
            lblBadge.setFont(new Font("Monospaced", Font.BOLD, 11));
            lblBadge.setForeground(BG);
            lblBadge.setBackground(PINK);
            lblBadge.setOpaque(true);
            lblBadge.setBorder(new EmptyBorder(2, 4, 2, 4));
            tituloRow.add(lblBadge);
        }

        JLabel lblFecha = new JLabel(fecha + "  ");
        lblFecha.setFont(new Font("Monospaced", Font.PLAIN, 12));
        lblFecha.setForeground(SUB);

        fila.add(tituloRow, BorderLayout.CENTER);
        fila.add(lblFecha,  BorderLayout.EAST);
        derecha.add(fila);
        derecha.add(Box.createVerticalStrut(8));

        JLabel lblCuerpo = new JLabel("<html><body style='width:680px; line-height:1.5'>"
            + cuerpo + "</body></html>");
        lblCuerpo.setFont(new Font("Monospaced", Font.PLAIN, 14));
        lblCuerpo.setForeground(new Color(170, 175, 200));
        lblCuerpo.setAlignmentX(Component.LEFT_ALIGNMENT);
        derecha.add(lblCuerpo);

        card.add(lblIcon,  BorderLayout.WEST);
        card.add(derecha,  BorderLayout.CENTER);
        return card;
    }
}
