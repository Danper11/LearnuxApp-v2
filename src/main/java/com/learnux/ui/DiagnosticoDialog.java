package com.learnux.ui;

import javax.swing.*;
import javax.swing.border.EmptyBorder;
import java.awt.*;

/**
 * Diálogo de diagnóstico inicial: 5 preguntas sobre experiencia con Linux.
 * Al final muestra un perfil simple con una breve explicación. Se invoca
 * una sola vez cuando un usuario nuevo entra al juego por primera vez.
 */
public class DiagnosticoDialog extends JDialog {

    private static final Color BG      = UiUtil.BG_DARK;
    private static final Color BG_CARD = UiUtil.BG_CARD;
    private static final Color BG_HDR  = UiUtil.BG_HDR;
    private static final Color TEXT    = UiUtil.TEXT;
    private static final Color SUB     = UiUtil.OVERLAY;
    private static final Color ACCENT  = UiUtil.BLUE;
    private static final Color GREEN   = UiUtil.GREEN;
    private static final Color YELLOW  = UiUtil.YELLOW;
    private static final Color ORANGE  = UiUtil.ORANGE;
    private static final Color PINK    = UiUtil.RED;

    private static final Object[][] PREGUNTAS = {
        {
            "¿Cuánta experiencia tienes usando una terminal o línea de comandos?",
            new String[]{
                "a)  Nunca he abierto una terminal en mi vida",
                "b)  La he abierto pero no sé qué escribir",
                "c)  Conozco algunos comandos básicos como ls o cd",
                "d)  La uso regularmente en mi trabajo o proyectos"
            }
        },
        {
            "¿Sabes qué hace el comando `ls` y cómo usarlo con banderas?",
            new String[]{
                "a)  No conozco ese comando",
                "b)  Sé que existe pero no lo he usado",
                "c)  Sé que lista archivos; conozco ls -l o ls -a",
                "d)  Lo uso con múltiples banderas como ls -lah, ls -lt, ls -R"
            }
        },
        {
            "¿Puedes crear directorios y navegar entre ellos desde la terminal?",
            new String[]{
                "a)  No sé cómo hacer eso",
                "b)  Conozco mkdir y cd pero los confundo",
                "c)  Los uso bien; sé las rutas relativas (.. y ~)",
                "d)  Los uso con fluidez incluyendo rutas absolutas y relativas"
            }
        },
        {
            "¿Sabes gestionar permisos de archivos en Linux?",
            new String[]{
                "a)  ¿Permisos? No sé a qué te refieres",
                "b)  Sé que existen r, w, x pero no sé configurarlos",
                "c)  Conozco chmod básico (ej: chmod +x script.sh)",
                "d)  Manejo permisos numéricos (755, 644) y simbólicos (u+x, o-r)"
            }
        },
        {
            "¿Has usado herramientas avanzadas como grep, find, tar o awk?",
            new String[]{
                "a)  Nunca he escuchado esas palabras",
                "b)  Las he visto mencionadas pero nunca las usé",
                "c)  Uso grep y find ocasionalmente para buscar cosas",
                "d)  Las uso regularmente combinadas con pipes en mis scripts"
            }
        },
    };

    private final int[] respuestas = new int[PREGUNTAS.length];
    private int puntoTotal = 0;

    private final JPanel contenedor;

    public DiagnosticoDialog(Frame parent) {
        super(parent, "Diagnóstico inicial — LearnUX", true);

        setUndecorated(true);
        setResizable(false);
        setDefaultCloseOperation(DO_NOTHING_ON_CLOSE); // debe completar el diagnóstico
        ajustarABoundsDe(parent);
        if (parent != null) {
            parent.addComponentListener(new java.awt.event.ComponentAdapter() {
                @Override public void componentResized(java.awt.event.ComponentEvent e) { ajustarABoundsDe(parent); }
                @Override public void componentMoved  (java.awt.event.ComponentEvent e) { ajustarABoundsDe(parent); }
            });
        }

        JPanel root = new JPanel(new BorderLayout());
        root.setBackground(BG);
        root.add(construirHeader(), BorderLayout.NORTH);

        contenedor = new JPanel(new BorderLayout());
        contenedor.setBackground(BG);
        root.add(contenedor, BorderLayout.CENTER);

        setContentPane(root);
        mostrarIntro();
    }

    private JPanel construirHeader() {
        JPanel h = new JPanel(new BorderLayout(20, 4));
        h.setBackground(BG_HDR);
        h.setBorder(new EmptyBorder(14, 24, 14, 24));
        JLabel titulo = new JLabel("📝  Diagnóstico Inicial");
        titulo.setFont(new Font("Monospaced", Font.BOLD, 22));
        titulo.setForeground(ACCENT);
        JLabel sub = new JLabel("Cuéntanos qué tanto sabes de Linux para conocer tu nivel");
        sub.setFont(new Font("Monospaced", Font.PLAIN, 14));
        sub.setForeground(SUB);
        h.add(titulo, BorderLayout.WEST);
        h.add(sub,    BorderLayout.EAST);
        return h;
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

    private JScrollPane envolverEnScroll(JPanel panel) {
        JScrollPane sc = new JScrollPane(panel,
            JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED,
            JScrollPane.HORIZONTAL_SCROLLBAR_NEVER);
        sc.setBorder(null);
        sc.getViewport().setBackground(BG);
        sc.getVerticalScrollBar().setUnitIncrement(16);
        UiUtil.estilizarScroll(sc);
        return sc;
    }

    // ── Intro ────────────────────────────────────────────────────

    private void mostrarIntro() {
        JPanel intro = new JPanel();
        intro.setLayout(new BoxLayout(intro, BoxLayout.Y_AXIS));
        intro.setBackground(BG);
        intro.setBorder(new EmptyBorder(28, 40, 28, 40));

        int w = Math.max(getWidth(), 560);
        boolean compacto = w < 900;
        int wrap = Math.max(320, (int)(w * 0.74));

        JLabel icono = new JLabel("🧭", SwingConstants.CENTER);
        icono.setFont(new Font("Monospaced", Font.PLAIN, compacto ? 64 : 84));
        icono.setAlignmentX(Component.CENTER_ALIGNMENT);

        JLabel titulo = new JLabel("¿Por dónde estás partiendo?", SwingConstants.CENTER);
        titulo.setFont(new Font("Monospaced", Font.BOLD, compacto ? 24 : 30));
        titulo.setForeground(ACCENT);
        titulo.setAlignmentX(Component.CENTER_ALIGNMENT);

        JLabel desc = new JLabel("<html><body style='text-align:center; width:" + wrap + "px; line-height:1.6'>"
            + "Antes de comenzar, responde 5 preguntas rápidas sobre tu experiencia con Linux. "
            + "Es solo para que tengas una idea clara de tu nivel de partida — el juego siempre "
            + "comienza desde el Nivel 1, no te preocupes."
            + "</body></html>", SwingConstants.CENTER);
        desc.setFont(new Font("Monospaced", Font.PLAIN, compacto ? 15 : 17));
        desc.setForeground(new Color(170, 175, 200));
        desc.setAlignmentX(Component.CENTER_ALIGNMENT);

        JLabel tiempo = new JLabel("⏱   Duración estimada: 1 minuto", SwingConstants.CENTER);
        tiempo.setFont(new Font("Monospaced", Font.PLAIN, compacto ? 14 : 16));
        tiempo.setForeground(YELLOW);
        tiempo.setAlignmentX(Component.CENTER_ALIGNMENT);

        JButton btnStart = boton("  Comenzar diagnóstico  →  ", ACCENT);
        btnStart.setAlignmentX(Component.CENTER_ALIGNMENT);
        btnStart.addActionListener(e -> mostrarPregunta(0));

        intro.add(Box.createVerticalGlue());
        intro.add(icono);
        intro.add(Box.createVerticalStrut(compacto ? 14 : 20));
        intro.add(titulo);
        intro.add(Box.createVerticalStrut(compacto ? 14 : 18));
        intro.add(desc);
        intro.add(Box.createVerticalStrut(compacto ? 18 : 24));
        intro.add(tiempo);
        intro.add(Box.createVerticalStrut(compacto ? 24 : 36));
        intro.add(btnStart);
        intro.add(Box.createVerticalGlue());

        contenedor.removeAll();
        contenedor.add(envolverEnScroll(intro), BorderLayout.CENTER);
        contenedor.revalidate();
        contenedor.repaint();
    }

    // ── Pregunta ─────────────────────────────────────────────────

    private void mostrarPregunta(int idx) {
        String preguntaTxt  = (String)   PREGUNTAS[idx][0];
        String[] opciones   = (String[]) PREGUNTAS[idx][1];

        int w = Math.max(getWidth(), 560);
        boolean compacto = w < 900;
        int wrap = Math.max(320, (int)(w * 0.74));

        JPanel panel = new JPanel();
        panel.setLayout(new BoxLayout(panel, BoxLayout.Y_AXIS));
        panel.setBackground(BG);
        panel.setBorder(new EmptyBorder(22, compacto ? 28 : 56, 22, compacto ? 28 : 56));

        // Progreso
        JLabel lblProg = new JLabel("Pregunta " + (idx + 1) + " de " + PREGUNTAS.length);
        lblProg.setFont(new Font("Monospaced", Font.PLAIN, 14));
        lblProg.setForeground(SUB);
        lblProg.setAlignmentX(Component.LEFT_ALIGNMENT);
        panel.add(lblProg);
        panel.add(Box.createVerticalStrut(6));

        JProgressBar barra = new JProgressBar(0, PREGUNTAS.length);
        barra.setValue(idx);
        barra.setForeground(ACCENT);
        barra.setBackground(BG_CARD);
        barra.setBorderPainted(false);
        barra.setMaximumSize(new Dimension(Integer.MAX_VALUE, 6));
        barra.setAlignmentX(Component.LEFT_ALIGNMENT);
        panel.add(barra);
        panel.add(Box.createVerticalStrut(34));

        // Pregunta
        JLabel lblP = new JLabel("<html><body style='width:" + wrap + "px; line-height:1.5'>" + preguntaTxt + "</body></html>");
        lblP.setFont(new Font("Monospaced", Font.BOLD, compacto ? 18 : 22));
        lblP.setForeground(TEXT);
        lblP.setAlignmentX(Component.LEFT_ALIGNMENT);
        panel.add(lblP);
        panel.add(Box.createVerticalStrut(compacto ? 18 : 26));

        // Opciones
        final int[] seleccion = {-1};
        JButton[] botones = new JButton[4];
        for (int i = 0; i < 4; i++) {
            final int opcion = i;
            JButton btn = new JButton(opciones[i]);
            btn.setFont(new Font("Monospaced", Font.PLAIN, compacto ? 14 : 17));
            btn.setBackground(BG_CARD);
            btn.setForeground(TEXT);
            btn.setBorderPainted(true);
            btn.setBorder(BorderFactory.createCompoundBorder(
                BorderFactory.createLineBorder(new Color(69, 71, 90)),
                new EmptyBorder(compacto ? 12 : 14, 18, compacto ? 12 : 14, 18)));
            btn.setFocusPainted(false);
            btn.setHorizontalAlignment(SwingConstants.LEFT);
            btn.setAlignmentX(Component.LEFT_ALIGNMENT);
            btn.setMaximumSize(new Dimension(Integer.MAX_VALUE, 9999));
            btn.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
            btn.addActionListener(e -> {
                seleccion[0] = opcion;
                for (JButton b : botones) {
                    b.setBackground(BG_CARD);
                    b.setForeground(TEXT);
                    b.setBorder(BorderFactory.createCompoundBorder(
                        BorderFactory.createLineBorder(new Color(69, 71, 90)),
                        new EmptyBorder(compacto ? 12 : 14, 18, compacto ? 12 : 14, 18)));
                }
                btn.setBackground(new Color(50, 70, 110));
                btn.setForeground(ACCENT);
                btn.setBorder(BorderFactory.createCompoundBorder(
                    BorderFactory.createLineBorder(ACCENT, 2),
                    new EmptyBorder(16, 22, 16, 22)));
            });
            btn.addMouseListener(new java.awt.event.MouseAdapter() {
                @Override public void mouseEntered(java.awt.event.MouseEvent e) {
                    if (seleccion[0] != opcion) btn.setBackground(new Color(60, 62, 82));
                }
                @Override public void mouseExited(java.awt.event.MouseEvent e) {
                    if (seleccion[0] != opcion) btn.setBackground(BG_CARD);
                }
            });
            botones[i] = btn;
            panel.add(btn);
            panel.add(Box.createVerticalStrut(10));
        }

        panel.add(Box.createVerticalStrut(20));

        JLabel lblError = new JLabel(" ");
        lblError.setFont(new Font("Monospaced", Font.PLAIN, 15));
        lblError.setForeground(PINK);
        lblError.setAlignmentX(Component.LEFT_ALIGNMENT);
        panel.add(lblError);
        panel.add(Box.createVerticalStrut(10));

        boolean esUltima = (idx == PREGUNTAS.length - 1);
        JButton btnSig = boton(esUltima ? "Ver mi nivel  →" : "Siguiente  →", ACCENT);
        btnSig.setAlignmentX(Component.LEFT_ALIGNMENT);
        btnSig.addActionListener(e -> {
            if (seleccion[0] < 0) {
                lblError.setText("⚠   Selecciona una opción antes de continuar.");
                return;
            }
            respuestas[idx] = seleccion[0];
            if (esUltima) calcularResultado();
            else mostrarPregunta(idx + 1);
        });
        panel.add(btnSig);
        panel.add(Box.createVerticalGlue());

        contenedor.removeAll();
        contenedor.add(envolverEnScroll(panel), BorderLayout.CENTER);
        contenedor.revalidate();
        contenedor.repaint();
    }

    // ── Resultado ────────────────────────────────────────────────

    private void calcularResultado() {
        puntoTotal = 0;
        for (int r : respuestas) puntoTotal += r;

        String  perfil;
        Color   color;
        String  mensaje;

        if (puntoTotal <= 3) {
            perfil  = "🟢  Principiante absoluto";
            color   = GREEN;
            mensaje = "Estás partiendo desde cero — y eso está perfecto. LearnUX está hecho exactamente para ti. "
                    + "Empieza con calma desde el Nivel 1, lee con atención cada introducción y deja que la terminal "
                    + "deje de darte miedo. ¡Disfruta el viaje!";
        } else if (puntoTotal <= 6) {
            perfil  = "🟡  Intermedio bajo";
            color   = YELLOW;
            mensaje = "Conoces algunos comandos básicos pero todavía hay mucho margen de mejora. "
                    + "Los primeros niveles te van a parecer familiares — aprovéchalos para consolidar lo que ya sabes "
                    + "antes de entrar a las banderas avanzadas. ¡Disfruta la experiencia!";
        } else if (puntoTotal <= 9) {
            perfil  = "🟠  Intermedio";
            color   = ORANGE;
            mensaje = "Te defiendes bien en la terminal: conoces los comandos esenciales y sabes moverte por el sistema. "
                    + "Lo que viene es perfeccionar las banderas y entrar al mundo de grep, find y los pipes. "
                    + "¡Te va a encantar!";
        } else {
            perfil  = "🔴  Avanzado";
            color   = PINK;
            mensaje = "Ya tienes mano firme en la terminal. LearnUX te servirá para llenar los huecos, descubrir banderas "
                    + "que no conocías y enfrentarte a los retos de los Jefes Finales. Disfrutarás especialmente los Tier 3 "
                    + "y 4. ¡Adelante!";
        }

        mostrarResultado(perfil, color, mensaje);
    }

    private void mostrarResultado(String perfil, Color color, String mensaje) {
        int w = Math.max(getWidth(), 560);
        boolean compacto = w < 900;
        int wrap = Math.max(320, (int)(w * 0.74));

        JPanel panel = new JPanel();
        panel.setLayout(new BoxLayout(panel, BoxLayout.Y_AXIS));
        panel.setBackground(BG);
        panel.setBorder(new EmptyBorder(28, compacto ? 32 : 60, 24, compacto ? 32 : 60));

        JLabel icono = new JLabel("📊", SwingConstants.CENTER);
        icono.setFont(new Font("Monospaced", Font.PLAIN, compacto ? 60 : 78));
        icono.setAlignmentX(Component.CENTER_ALIGNMENT);

        JLabel lblPerfilTit = new JLabel("Tu nivel:", SwingConstants.CENTER);
        lblPerfilTit.setFont(new Font("Monospaced", Font.PLAIN, compacto ? 14 : 17));
        lblPerfilTit.setForeground(SUB);
        lblPerfilTit.setAlignmentX(Component.CENTER_ALIGNMENT);

        JLabel lblPerfil = new JLabel(perfil, SwingConstants.CENTER);
        lblPerfil.setFont(new Font("Monospaced", Font.BOLD, compacto ? 24 : 30));
        lblPerfil.setForeground(color);
        lblPerfil.setAlignmentX(Component.CENTER_ALIGNMENT);

        JLabel lblMsg = new JLabel("<html><body style='text-align:center; width:" + wrap + "px; line-height:1.7'>"
            + mensaje + "</body></html>", SwingConstants.CENTER);
        lblMsg.setFont(new Font("Monospaced", Font.PLAIN, compacto ? 15 : 17));
        lblMsg.setForeground(TEXT);
        lblMsg.setAlignmentX(Component.CENTER_ALIGNMENT);

        JButton btnIr = boton("¡Empezar a jugar!  🚀", GREEN);
        btnIr.setAlignmentX(Component.CENTER_ALIGNMENT);
        btnIr.addActionListener(e -> dispose());

        panel.add(Box.createVerticalGlue());
        panel.add(icono);
        panel.add(Box.createVerticalStrut(compacto ? 14 : 18));
        panel.add(lblPerfilTit);
        panel.add(Box.createVerticalStrut(8));
        panel.add(lblPerfil);
        panel.add(Box.createVerticalStrut(compacto ? 22 : 30));
        panel.add(lblMsg);
        panel.add(Box.createVerticalStrut(compacto ? 28 : 40));
        panel.add(btnIr);
        panel.add(Box.createVerticalGlue());

        contenedor.removeAll();
        contenedor.add(envolverEnScroll(panel), BorderLayout.CENTER);
        contenedor.revalidate();
        contenedor.repaint();
    }

    private JButton boton(String texto, Color color) {
        JButton btn = new JButton(texto);
        btn.setFont(new Font("Monospaced", Font.BOLD, 17));
        btn.setBackground(color);
        btn.setForeground(BG);
        btn.setBorderPainted(false);
        btn.setFocusPainted(false);
        btn.setBorder(new EmptyBorder(12, 28, 12, 28));
        btn.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        return btn;
    }
}
