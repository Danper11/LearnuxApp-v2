package com.learnux.ui;

import javax.swing.*;
import javax.swing.border.EmptyBorder;
import java.awt.*;

public class TutorialBienvenidaDialog extends JDialog {

    private static final Color BG      = new Color(30,  30,  46);
    private static final Color BG_CARD = new Color(24,  24,  37);
    private static final Color TEXT    = new Color(205, 214, 244);
    private static final Color SUB     = new Color(108, 112, 134);
    private static final Color ACCENT  = new Color(137, 180, 250);
    private static final Color GREEN   = new Color(166, 227, 161);
    private static final Color YELLOW  = new Color(249, 226, 175);
    private static final Color PURPLE  = new Color(203, 166, 247);
    private static final Color PINK    = new Color(243, 139, 168);

    private int paginaActual = 0;
    private final JPanel    contenidoPagina = new JPanel();
    private final JLabel[]  indicadores;
    private final JButton   btnAnterior;
    private final JButton   btnSiguiente;

    private record Pagina(String icono, String titulo, String[] puntos, Color color) {}

    private static final Pagina[] PAGINAS = {
        new Pagina("🐧", "¡Bienvenido a LearnUX!", new String[]{
            "LearnUX es un juego para aprender Linux de forma práctica y divertida.",
            "Aprenderás los comandos de la terminal paso a paso, con ejercicios interactivos.",
            "No necesitas experiencia previa: empezamos desde cero y llegarás muy lejos.",
            "Al terminar serás capaz de desenvolverte en cualquier terminal Linux con confianza."
        }, ACCENT),
        new Pagina("🌍", "¿Por qué aprender Linux?", new String[]{
            "Linux corre en el 96% de los servidores web del mundo, incluyendo Google y Amazon.",
            "Android — el sistema operativo más popular del planeta — está basado en Linux.",
            "Los 500 supercomputadores más potentes del mundo usan Linux sin excepción.",
            "La NASA, la Estación Espacial Internacional y la infraestructura crítica global dependen de Linux.",
            "Dominar Linux multiplica tus oportunidades laborales en cualquier área de tecnología."
        }, GREEN),
        new Pagina("⚡", "La terminal: tu superpoder", new String[]{
            "Con un solo comando haces en segundos lo que tomaría minutos con el ratón.",
            "Puedes automatizar tareas repetitivas con scripts y ahorrar horas de trabajo.",
            "Desarrolladores, sysadmins y hackers éticos usan la terminal como herramienta principal.",
            "Dominar la terminal te hace más valioso en cualquier equipo de tecnología del mundo.",
            "Lo que hoy parece extraño, mañana será tu segunda naturaleza natural."
        }, YELLOW),
        new Pagina("🎮", "Cómo funciona LearnUX", new String[]{
            "24 niveles organizados en 4 etapas: Fundamentos, Intermedio, Avanzado y Maestro.",
            "Cada nivel tiene ejercicios: arrastra chips, escribe comandos, selecciona opciones.",
            "Tienes vidas, rachas de aciertos y puntos para mantenerte siempre motivado.",
            "Al final de cada etapa te espera un JEFE FINAL: un reto práctico del mundo real.",
            "Explora la enciclopedia de comandos y sigue tu progreso con estadísticas detalladas."
        }, PURPLE),
        new Pagina("🚀", "¡Todo listo para empezar!", new String[]{
            "Dirígete a la pestaña «Niveles» y comienza desde el Nivel 1.",
            "Lee la descripción de cada nivel antes de lanzarte a los ejercicios.",
            "Usa la pista 💡 si te atascas, pero el reto es lo que hace que crezcas.",
            "Cada comando que aprendes hoy es una puerta que se abre en tu carrera.",
            "El trabajo duro de hoy crea al programador de mañana. ¡Tú puedes!"
        }, PINK)
    };

    public TutorialBienvenidaDialog(Frame parent) {
        super(parent, "¡Bienvenido a LearnUX! — Tutorial rápido", true);
        setSize(760, 560);
        setMinimumSize(new Dimension(760, 560));
        setLocationRelativeTo(parent);
        setDefaultCloseOperation(DISPOSE_ON_CLOSE);
        setResizable(false);

        JPanel root = new JPanel(new BorderLayout());
        root.setBackground(BG);

        contenidoPagina.setBackground(BG);
        root.add(contenidoPagina, BorderLayout.CENTER);

        indicadores = new JLabel[PAGINAS.length];
        JPanel indicRow = new JPanel(new FlowLayout(FlowLayout.CENTER, 10, 0));
        indicRow.setBackground(BG_CARD);
        for (int i = 0; i < PAGINAS.length; i++) {
            indicadores[i] = new JLabel("●");
            indicadores[i].setFont(new Font("Monospaced", Font.PLAIN, 13));
            indicRow.add(indicadores[i]);
        }

        btnAnterior  = navBoton("←  Anterior", new Color(49, 50, 68), SUB);
        btnSiguiente = navBoton("Siguiente  →", ACCENT, BG);

        JPanel footer = new JPanel(new BorderLayout(0, 0));
        footer.setBackground(BG_CARD);
        footer.setBorder(new EmptyBorder(10, 22, 14, 22));
        footer.add(btnAnterior,  BorderLayout.WEST);
        footer.add(indicRow,     BorderLayout.CENTER);
        footer.add(btnSiguiente, BorderLayout.EAST);

        root.add(footer, BorderLayout.SOUTH);

        btnAnterior.addActionListener(e  -> cambiarPagina(-1));
        btnSiguiente.addActionListener(e -> {
            if (paginaActual == PAGINAS.length - 1) dispose();
            else cambiarPagina(1);
        });

        mostrarPagina(0);
        setContentPane(root);
    }

    private void mostrarPagina(int idx) {
        Pagina p = PAGINAS[idx];
        contenidoPagina.removeAll();
        contenidoPagina.setLayout(new BoxLayout(contenidoPagina, BoxLayout.Y_AXIS));
        contenidoPagina.setBorder(new EmptyBorder(32, 54, 14, 54));

        JLabel icono = new JLabel(p.icono());
        icono.setFont(new Font("Monospaced", Font.PLAIN, 54));
        icono.setAlignmentX(Component.CENTER_ALIGNMENT);

        JLabel titulo = new JLabel(p.titulo());
        titulo.setFont(new Font("Monospaced", Font.BOLD, 21));
        titulo.setForeground(p.color());
        titulo.setAlignmentX(Component.CENTER_ALIGNMENT);

        JSeparator sep = new JSeparator();
        sep.setForeground(new Color(55, 58, 80));
        sep.setMaximumSize(new Dimension(Integer.MAX_VALUE, 1));

        contenidoPagina.add(icono);
        contenidoPagina.add(Box.createVerticalStrut(10));
        contenidoPagina.add(titulo);
        contenidoPagina.add(Box.createVerticalStrut(14));
        contenidoPagina.add(sep);
        contenidoPagina.add(Box.createVerticalStrut(16));

        for (String punto : p.puntos()) {
            JPanel fila = new JPanel(new BorderLayout(10, 0));
            fila.setBackground(BG);
            fila.setAlignmentX(Component.LEFT_ALIGNMENT);
            fila.setMaximumSize(new Dimension(Integer.MAX_VALUE, 28));

            JLabel bullet = new JLabel("▸");
            bullet.setFont(new Font("Monospaced", Font.BOLD, 14));
            bullet.setForeground(p.color());
            bullet.setPreferredSize(new Dimension(16, 22));

            JLabel txt = new JLabel(punto);
            txt.setFont(new Font("Monospaced", Font.PLAIN, 14));
            txt.setForeground(TEXT);

            fila.add(bullet, BorderLayout.WEST);
            fila.add(txt,    BorderLayout.CENTER);
            contenidoPagina.add(fila);
            contenidoPagina.add(Box.createVerticalStrut(7));
        }

        contenidoPagina.add(Box.createVerticalGlue());
        contenidoPagina.revalidate();
        contenidoPagina.repaint();

        for (int i = 0; i < indicadores.length; i++)
            indicadores[i].setForeground(i == idx ? p.color() : SUB);

        btnAnterior.setEnabled(idx > 0);
        btnAnterior.setForeground(idx > 0 ? TEXT : SUB);

        boolean ultimo = idx == PAGINAS.length - 1;
        btnSiguiente.setText(ultimo ? "¡Vamos a jugar!  🚀" : "Siguiente  →");
        btnSiguiente.setBackground(ultimo ? GREEN : ACCENT);
    }

    private void cambiarPagina(int delta) {
        paginaActual = Math.max(0, Math.min(PAGINAS.length - 1, paginaActual + delta));
        mostrarPagina(paginaActual);
    }

    private JButton navBoton(String texto, Color bg, Color fg) {
        JButton btn = new JButton(texto);
        btn.setFont(new Font("Monospaced", Font.BOLD, 14));
        btn.setBackground(bg);
        btn.setForeground(fg);
        btn.setBorderPainted(false);
        btn.setFocusPainted(false);
        btn.setBorder(new EmptyBorder(9, 20, 9, 20));
        btn.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        return btn;
    }
}
