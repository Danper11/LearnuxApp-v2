package com.learnux.ui;

import javax.swing.*;
import javax.swing.border.EmptyBorder;
import java.awt.*;

public class TutorialBienvenidaDialog extends JDialog {

    private static final Color BG      = UiUtil.BG_DARK;
    private static final Color BG_CARD = UiUtil.BG_HDR;
    private static final Color TEXT    = UiUtil.TEXT;
    private static final Color SUB     = UiUtil.OVERLAY;
    private static final Color ACCENT  = UiUtil.BLUE;
    private static final Color GREEN   = UiUtil.GREEN;
    private static final Color YELLOW  = UiUtil.YELLOW;
    private static final Color PURPLE  = UiUtil.MAUVE;
    private static final Color PINK    = UiUtil.RED;

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
            "Lo que hoy parece extraño, mañana será tu segunda naturaleza."
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
            "Si fallas dos veces el mismo ejercicio, la pista se mostrará automáticamente.",
            "Cada comando que aprendes hoy es una puerta que se abre en tu carrera.",
            "El trabajo duro de hoy crea al programador de mañana. ¡Tú puedes!"
        }, PINK)
    };

    public TutorialBienvenidaDialog(Frame parent) {
        super(parent, "¡Bienvenido a LearnUX! — Tutorial rápido", true);

        // ── Se incrusta exactamente sobre el área de contenido del padre ──
        setUndecorated(true);
        setResizable(false);
        setDefaultCloseOperation(DO_NOTHING_ON_CLOSE);
        ajustarABoundsDe(parent);
        if (parent != null) {
            parent.addComponentListener(new java.awt.event.ComponentAdapter() {
                @Override public void componentResized(java.awt.event.ComponentEvent e) { ajustarABoundsDe(parent); }
                @Override public void componentMoved  (java.awt.event.ComponentEvent e) { ajustarABoundsDe(parent); }
            });
        }

        JPanel root = new JPanel(new BorderLayout());
        root.setBackground(BG);

        contenidoPagina.setBackground(BG);
        JScrollPane scroll = new JScrollPane(contenidoPagina,
            JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED,
            JScrollPane.HORIZONTAL_SCROLLBAR_NEVER);
        scroll.setBorder(null);
        scroll.getViewport().setBackground(BG);
        scroll.getVerticalScrollBar().setUnitIncrement(16);
        UiUtil.estilizarScroll(scroll);
        root.add(scroll, BorderLayout.CENTER);

        indicadores = new JLabel[PAGINAS.length];
        JPanel indicRow = new JPanel(new FlowLayout(FlowLayout.CENTER, 16, 0));
        indicRow.setBackground(BG_CARD);
        for (int i = 0; i < PAGINAS.length; i++) {
            indicadores[i] = new JLabel("●");
            indicadores[i].setFont(new Font("Monospaced", Font.PLAIN, 22));
            indicRow.add(indicadores[i]);
        }

        btnAnterior  = navBoton("←  Anterior", UiUtil.BG_CARD, SUB);
        btnSiguiente = navBoton("Siguiente  →", ACCENT, BG);

        JPanel footer = new JPanel(new BorderLayout(0, 0));
        footer.setBackground(BG_CARD);
        footer.setBorder(new EmptyBorder(14, 24, 16, 24));
        footer.add(btnAnterior,  BorderLayout.WEST);
        footer.add(indicRow,     BorderLayout.CENTER);
        footer.add(btnSiguiente, BorderLayout.EAST);

        root.add(footer, BorderLayout.SOUTH);

        btnAnterior.addActionListener(e  -> cambiarPagina(-1));
        btnSiguiente.addActionListener(e -> {
            if (paginaActual == PAGINAS.length - 1) dispose();
            else cambiarPagina(1);
        });

        // Re-render pagina al cambiar tamaño para que el wrap se ajuste
        addComponentListener(new java.awt.event.ComponentAdapter() {
            @Override public void componentResized(java.awt.event.ComponentEvent e) {
                mostrarPagina(paginaActual);
            }
        });

        setContentPane(root);
        mostrarPagina(0);
    }

    private void ajustarABoundsDe(Frame parent) {
        try {
            if (parent != null && parent.isShowing()) {
                Container content = ((JFrame) parent).getContentPane();
                Point loc = content.getLocationOnScreen();
                Dimension d = content.getSize();
                setBounds(loc.x, loc.y, d.width, d.height);
            } else {
                setSize(1100, 720);
                setLocationRelativeTo(null);
            }
        } catch (Exception ex) {
            setSize(1100, 720);
            setLocationRelativeTo(null);
        }
    }

    private void mostrarPagina(int idx) {
        Pagina p = PAGINAS[idx];
        int w = Math.max(getWidth(), 560);
        boolean compacto = w < 900;

        contenidoPagina.removeAll();
        contenidoPagina.setLayout(new BoxLayout(contenidoPagina, BoxLayout.Y_AXIS));
        contenidoPagina.setBorder(new EmptyBorder(
            compacto ? 22 : 32,
            compacto ? 28 : 56,
            20,
            compacto ? 28 : 56));

        JLabel icono = new JLabel(p.icono(), SwingConstants.CENTER);
        icono.setFont(new Font("Monospaced", Font.PLAIN, compacto ? 64 : 84));
        icono.setAlignmentX(Component.CENTER_ALIGNMENT);

        JLabel titulo = new JLabel(p.titulo(), SwingConstants.CENTER);
        titulo.setFont(new Font("Monospaced", Font.BOLD, compacto ? 24 : 30));
        titulo.setForeground(p.color());
        titulo.setAlignmentX(Component.CENTER_ALIGNMENT);
        titulo.setMaximumSize(new Dimension(Integer.MAX_VALUE, titulo.getPreferredSize().height));

        JSeparator sep = new JSeparator();
        sep.setForeground(new Color(55, 58, 80));
        sep.setMaximumSize(new Dimension(Integer.MAX_VALUE, 1));

        contenidoPagina.add(Box.createVerticalStrut(8));
        contenidoPagina.add(icono);
        contenidoPagina.add(Box.createVerticalStrut(compacto ? 12 : 18));
        contenidoPagina.add(titulo);
        contenidoPagina.add(Box.createVerticalStrut(compacto ? 18 : 24));
        contenidoPagina.add(sep);
        contenidoPagina.add(Box.createVerticalStrut(compacto ? 18 : 26));

        // Ancho de wrap dinámico: ~80% del ancho útil del diálogo
        int wrap = Math.max(320, (int)(w * 0.78));

        for (String punto : p.puntos()) {
            JPanel fila = new JPanel(new BorderLayout(14, 0));
            fila.setBackground(BG);
            fila.setAlignmentX(Component.LEFT_ALIGNMENT);

            JLabel bullet = new JLabel("▸");
            bullet.setFont(new Font("Monospaced", Font.BOLD, compacto ? 18 : 20));
            bullet.setForeground(p.color());
            bullet.setPreferredSize(new Dimension(22, 26));

            JLabel txt = new JLabel("<html><body style='width:" + wrap + "px; line-height:1.5'>" + punto + "</body></html>");
            txt.setFont(new Font("Monospaced", Font.PLAIN, compacto ? 15 : 17));
            txt.setForeground(TEXT);

            fila.add(bullet, BorderLayout.WEST);
            fila.add(txt,    BorderLayout.CENTER);
            fila.setMaximumSize(new Dimension(Integer.MAX_VALUE, fila.getPreferredSize().height));
            contenidoPagina.add(fila);
            contenidoPagina.add(Box.createVerticalStrut(10));
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
        btn.setFont(new Font("Monospaced", Font.BOLD, 16));
        btn.setBackground(bg);
        btn.setForeground(fg);
        btn.setBorderPainted(false);
        btn.setFocusPainted(false);
        btn.setBorder(new EmptyBorder(10, 22, 10, 22));
        btn.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        return btn;
    }
}
