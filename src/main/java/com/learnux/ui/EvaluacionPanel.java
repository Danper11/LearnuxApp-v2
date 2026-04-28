package com.learnux.ui;

import javax.swing.*;
import javax.swing.border.EmptyBorder;
import java.awt.*;
import java.util.function.Consumer;

/**
 * Panel de diagnóstico inicial: 5 preguntas de experiencia Linux
 * que generan un plan de estudio personalizado con recomendaciones de actividades.
 */
public class EvaluacionPanel extends JPanel {

    private static final Color BG      = new Color(30,  30,  46);
    private static final Color BG_CARD = new Color(49,  50,  68);
    private static final Color BG_HDR  = new Color(24,  24,  37);
    private static final Color TEXT    = new Color(205, 214, 244);
    private static final Color SUB     = new Color(108, 112, 134);
    private static final Color ACCENT  = new Color(137, 180, 250);
    private static final Color GREEN   = new Color(166, 227, 161);
    private static final Color YELLOW  = new Color(249, 226, 175);
    private static final Color PURPLE  = new Color(203, 166, 247);
    private static final Color PINK    = new Color(243, 139, 168);
    private static final Color ORANGE  = new Color(250, 179, 135);

    // Preguntas: {texto, opciones (a,b,c,d), puntos (0,1,2,3)}
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

    private final int[]      respuestas  = new int[PREGUNTAS.length];
    private final JButton[]  selBotones  = new JButton[4];
    private int              preguntaIdx = 0;
    private int              puntoTotal  = 0;

    // Panel central (se reemplaza en cada pantalla)
    private final JPanel contenedor;

    // Callback opcional: recibe el nivel recomendado
    private final Consumer<Integer> onNivelRecomendado;

    public EvaluacionPanel(Consumer<Integer> onNivelRecomendado) {
        this.onNivelRecomendado = onNivelRecomendado;
        setLayout(new BorderLayout());
        setBackground(BG);
        add(construirHeader(), BorderLayout.NORTH);

        contenedor = new JPanel(new CardLayout());
        contenedor.setBackground(BG);
        add(contenedor, BorderLayout.CENTER);

        mostrarIntro();
    }

    // ── Header ────────────────────────────────────────────────────

    private JPanel construirHeader() {
        JPanel h = new JPanel(new BorderLayout());
        h.setBackground(BG_HDR);
        h.setBorder(new EmptyBorder(14, 20, 14, 20));
        JLabel titulo = new JLabel("📝  Evaluación Diagnóstica");
        titulo.setFont(new Font("Monospaced", Font.BOLD, 18));
        titulo.setForeground(ACCENT);
        JLabel sub = new JLabel("Descubre tu nivel y recibe un plan personalizado");
        sub.setFont(new Font("Monospaced", Font.PLAIN, 13));
        sub.setForeground(SUB);
        h.add(titulo, BorderLayout.WEST);
        h.add(sub,    BorderLayout.EAST);
        return h;
    }

    // ── Pantalla de intro ─────────────────────────────────────────

    private void mostrarIntro() {
        JPanel intro = new JPanel();
        intro.setLayout(new BoxLayout(intro, BoxLayout.Y_AXIS));
        intro.setBackground(BG);
        intro.setBorder(new EmptyBorder(40, 80, 40, 80));

        JLabel icono = new JLabel("🧭", SwingConstants.CENTER);
        icono.setFont(new Font("Monospaced", Font.PLAIN, 60));
        icono.setAlignmentX(Component.CENTER_ALIGNMENT);

        JLabel titulo = new JLabel("¿Por dónde deberías empezar?");
        titulo.setFont(new Font("Monospaced", Font.BOLD, 26));
        titulo.setForeground(ACCENT);
        titulo.setAlignmentX(Component.CENTER_ALIGNMENT);

        JLabel desc = new JLabel("<html><body style='text-align:center; width:540px'>"
            + "Responde 5 preguntas rápidas sobre tu experiencia con Linux. "
            + "Al final recibirás un plan personalizado con las actividades "
            + "más adecuadas para tu nivel actual y cómo avanzar."
            + "</body></html>", SwingConstants.CENTER);
        desc.setFont(new Font("Monospaced", Font.PLAIN, 15));
        desc.setForeground(new Color(170, 175, 200));
        desc.setAlignmentX(Component.CENTER_ALIGNMENT);

        JLabel tiempo = new JLabel("⏱  Duración estimada: 2 minutos");
        tiempo.setFont(new Font("Monospaced", Font.PLAIN, 14));
        tiempo.setForeground(YELLOW);
        tiempo.setAlignmentX(Component.CENTER_ALIGNMENT);

        JButton btnStart = boton("  Iniciar evaluación  →  ", ACCENT);
        btnStart.setAlignmentX(Component.CENTER_ALIGNMENT);
        btnStart.addActionListener(e -> mostrarPregunta(0));

        intro.add(Box.createVerticalGlue());
        intro.add(icono);
        intro.add(Box.createVerticalStrut(16));
        intro.add(titulo);
        intro.add(Box.createVerticalStrut(12));
        intro.add(desc);
        intro.add(Box.createVerticalStrut(18));
        intro.add(tiempo);
        intro.add(Box.createVerticalStrut(32));
        intro.add(btnStart);
        intro.add(Box.createVerticalGlue());

        contenedor.removeAll();
        contenedor.add(intro);
        contenedor.revalidate();
        contenedor.repaint();
    }

    // ── Pantalla de pregunta ──────────────────────────────────────

    private void mostrarPregunta(int idx) {
        preguntaIdx = idx;
        String preguntaTxt  = (String)   PREGUNTAS[idx][0];
        String[] opciones   = (String[]) PREGUNTAS[idx][1];

        JPanel panel = new JPanel();
        panel.setLayout(new BoxLayout(panel, BoxLayout.Y_AXIS));
        panel.setBackground(BG);
        panel.setBorder(new EmptyBorder(30, 60, 30, 60));

        // Progreso
        JPanel progresoRow = new JPanel(new FlowLayout(FlowLayout.LEFT, 0, 0));
        progresoRow.setBackground(BG);
        progresoRow.setAlignmentX(Component.LEFT_ALIGNMENT);
        JLabel lblProg = new JLabel("Pregunta " + (idx + 1) + " de " + PREGUNTAS.length);
        lblProg.setFont(new Font("Monospaced", Font.PLAIN, 14));
        lblProg.setForeground(SUB);
        progresoRow.add(lblProg);
        panel.add(progresoRow);
        panel.add(Box.createVerticalStrut(4));

        JProgressBar barra = new JProgressBar(0, PREGUNTAS.length);
        barra.setValue(idx);
        barra.setForeground(ACCENT);
        barra.setBackground(BG_CARD);
        barra.setBorderPainted(false);
        barra.setMaximumSize(new Dimension(Integer.MAX_VALUE, 5));
        barra.setAlignmentX(Component.LEFT_ALIGNMENT);
        panel.add(barra);
        panel.add(Box.createVerticalStrut(24));

        // Pregunta
        JLabel lblP = new JLabel("<html><body style='width:640px; line-height:1.5'>" + preguntaTxt + "</body></html>");
        lblP.setFont(new Font("Monospaced", Font.BOLD, 18));
        lblP.setForeground(TEXT);
        lblP.setAlignmentX(Component.LEFT_ALIGNMENT);
        panel.add(lblP);
        panel.add(Box.createVerticalStrut(20));

        // Opciones
        final int[] seleccion = {-1};
        JButton[] botones = new JButton[4];
        for (int i = 0; i < 4; i++) {
            final int opcion = i;
            JButton btn = new JButton(opciones[i]);
            btn.setFont(new Font("Monospaced", Font.PLAIN, 15));
            btn.setBackground(BG_CARD);
            btn.setForeground(TEXT);
            btn.setBorderPainted(true);
            btn.setBorder(BorderFactory.createCompoundBorder(
                BorderFactory.createLineBorder(new Color(69, 71, 90)),
                new EmptyBorder(12, 18, 12, 18)));
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
                        new EmptyBorder(12, 18, 12, 18)));
                }
                btn.setBackground(new Color(50, 70, 110));
                btn.setForeground(ACCENT);
                btn.setBorder(BorderFactory.createCompoundBorder(
                    BorderFactory.createLineBorder(ACCENT, 2),
                    new EmptyBorder(12, 18, 12, 18)));
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
            panel.add(Box.createVerticalStrut(8));
        }

        panel.add(Box.createVerticalStrut(16));

        // Botón Siguiente
        JLabel lblError = new JLabel(" ");
        lblError.setFont(new Font("Monospaced", Font.PLAIN, 13));
        lblError.setForeground(PINK);
        lblError.setAlignmentX(Component.LEFT_ALIGNMENT);
        panel.add(lblError);
        panel.add(Box.createVerticalStrut(8));

        boolean esUltima = (idx == PREGUNTAS.length - 1);
        JButton btnSig = boton(esUltima ? "Ver mi plan  →" : "Siguiente  →", ACCENT);
        btnSig.setAlignmentX(Component.LEFT_ALIGNMENT);
        btnSig.addActionListener(e -> {
            if (seleccion[0] < 0) {
                lblError.setText("⚠  Selecciona una opción antes de continuar.");
                return;
            }
            respuestas[idx] = seleccion[0];
            if (esUltima) {
                calcularResultado();
            } else {
                mostrarPregunta(idx + 1);
            }
        });
        panel.add(btnSig);
        panel.add(Box.createVerticalGlue());

        contenedor.removeAll();
        contenedor.add(panel);
        contenedor.revalidate();
        contenedor.repaint();
    }

    // ── Cálculo y resultado ───────────────────────────────────────

    private void calcularResultado() {
        puntoTotal = 0;
        for (int r : respuestas) puntoTotal += r;

        int nivelRec;
        String perfil;
        Color perfilColor;
        String[][] actividades;

        if (puntoTotal <= 3) {
            nivelRec    = 1;
            perfil      = "🟢 Principiante absoluto";
            perfilColor = GREEN;
            actividades = new String[][]{
                {"Nivel 1 — ls: listar archivos",         "Empieza conociendo el comando más básico de Linux.", "green"},
                {"Nivel 2 — pwd: ¿dónde estás?",          "Aprende a ubicarte en el sistema de archivos.",      "green"},
                {"Nivel 3 — mkdir: crear directorios",     "Organiza tus archivos desde la terminal.",           "green"},
                {"Enciclopedia → Categoría: Manejo de archivos", "Repasa ls, cp, mv, rm antes de los ejercicios.", "accent"},
            };
        } else if (puntoTotal <= 6) {
            nivelRec    = 3;
            perfil      = "🟡 Intermedio bajo";
            perfilColor = YELLOW;
            actividades = new String[][]{
                {"Nivel 3 — mkdir/rutas",                   "Consolida el manejo de directorios.",                    "yellow"},
                {"Nivel 4 — cp y mv: mover y copiar",       "Practica operaciones fundamentales con archivos.",       "yellow"},
                {"Nivel 6 — ls avanzado: banderas útiles",  "Opciones como -lh, -lt y -R serán tus aliadas.",         "yellow"},
                {"Enciclopedia → Busca: chmod, grep",        "Prepárate para los niveles intermedios.",                "accent"},
            };
        } else if (puntoTotal <= 9) {
            nivelRec    = 6;
            perfil      = "🟠 Intermedio";
            perfilColor = ORANGE;
            actividades = new String[][]{
                {"Nivel 6-8 — Opciones múltiples",           "Demuestra que conoces las banderas correctas.",    "orange"},
                {"Nivel 10 — grep: buscar texto",            "Herramienta indispensable para administradores.",  "orange"},
                {"Nivel 11-12 — Completar espacios",         "Pon a prueba tu memoria de banderas.",             "orange"},
                {"Enciclopedia → Busca: find, tar",          "Prepárate para los niveles avanzados.",            "accent"},
            };
        } else {
            nivelRec    = 11;
            perfil      = "🔴 Avanzado";
            perfilColor = PINK;
            actividades = new String[][]{
                {"Nivel 13-15 — Escribir comandos",          "Escribe comandos completos sin ayuda visual.",      "pink"},
                {"Nivel 16-20 — Terminal simulada",          "Enfrenta escenarios reales de administración.",     "pink"},
                {"Examen Final",                             "Pon a prueba todo lo que sabes en 10 minutos.",     "accent"},
                {"Enciclopedia → Busca: awk, sed, tar",      "Perfecciona las herramientas de scripting.",        "accent"},
            };
        }

        mostrarResultado(perfil, perfilColor, nivelRec, actividades);
    }

    private void mostrarResultado(String perfil, Color perfilColor, int nivelRec,
                                  String[][] actividades) {
        JPanel panel = new JPanel();
        panel.setLayout(new BoxLayout(panel, BoxLayout.Y_AXIS));
        panel.setBackground(BG);
        panel.setBorder(new EmptyBorder(24, 60, 24, 60));

        // Banner
        JPanel banner = new JPanel();
        banner.setLayout(new BoxLayout(banner, BoxLayout.Y_AXIS));
        banner.setBackground(new Color(22, 28, 48));
        banner.setBorder(new EmptyBorder(22, 32, 22, 32));
        banner.setAlignmentX(Component.LEFT_ALIGNMENT);
        banner.setMaximumSize(new Dimension(Integer.MAX_VALUE, 9999));

        JLabel lblPerfil = new JLabel(perfil);
        lblPerfil.setFont(new Font("Monospaced", Font.BOLD, 22));
        lblPerfil.setForeground(perfilColor);
        lblPerfil.setAlignmentX(Component.LEFT_ALIGNMENT);

        JLabel lblPts = new JLabel("Puntaje diagnóstico: " + puntoTotal + " / " + (PREGUNTAS.length * 3)
            + "   ·   El juego siempre comienza desde el Nivel 1");
        lblPts.setFont(new Font("Monospaced", Font.PLAIN, 13));
        lblPts.setForeground(SUB);
        lblPts.setAlignmentX(Component.LEFT_ALIGNMENT);

        banner.add(lblPerfil);
        banner.add(Box.createVerticalStrut(8));
        banner.add(lblPts);

        panel.add(banner);
        panel.add(Box.createVerticalStrut(22));

        // Título actividades
        JLabel lblActTit = new JLabel("📋  Tu plan de estudio personalizado");
        lblActTit.setFont(new Font("Monospaced", Font.BOLD, 16));
        lblActTit.setForeground(TEXT);
        lblActTit.setAlignmentX(Component.LEFT_ALIGNMENT);
        panel.add(lblActTit);
        panel.add(Box.createVerticalStrut(10));

        for (String[] act : actividades) {
            panel.add(crearCardActividad(act[0], act[1], act[2]));
            panel.add(Box.createVerticalStrut(8));
        }

        panel.add(Box.createVerticalStrut(20));

        // Nota de relacionamiento entre actividades
        JPanel nota = new JPanel(new BorderLayout());
        nota.setBackground(new Color(33, 34, 52));
        nota.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createMatteBorder(0, 3, 0, 0, PURPLE),
            new EmptyBorder(12, 16, 12, 16)));
        nota.setAlignmentX(Component.LEFT_ALIGNMENT);
        nota.setMaximumSize(new Dimension(Integer.MAX_VALUE, 9999));

        JLabel lblNota = new JLabel("<html><body style='width:580px; line-height:1.6'>"
            + "<b style='color:#cba6f7'>💡 Cómo están relacionadas las actividades:</b><br>"
            + "Cada nivel construye sobre el anterior. Los comandos de manejo de archivos (Tier 1) "
            + "son la base para entender los permisos (Tier 2). Las búsquedas con grep y find (Tier 3) "
            + "se vuelven mucho más poderosas una vez dominas la redirección. "
            + "Los niveles de terminal simulada (Tier 4) integran todo lo anterior en escenarios reales."
            + "</body></html>");
        lblNota.setFont(new Font("Monospaced", Font.PLAIN, 13));
        lblNota.setForeground(new Color(170, 175, 200));
        nota.add(lblNota, BorderLayout.CENTER);
        panel.add(nota);
        panel.add(Box.createVerticalStrut(20));

        // Botones
        JPanel btnRow = new JPanel(new FlowLayout(FlowLayout.LEFT, 12, 0));
        btnRow.setBackground(BG);
        btnRow.setAlignmentX(Component.LEFT_ALIGNMENT);

        JButton btnIrNivel = boton("🎮  Ir a Niveles", GREEN);
        btnIrNivel.addActionListener(e -> {
            if (onNivelRecomendado != null) onNivelRecomendado.accept(nivelRec);
        });

        JButton btnRep = boton("↺  Repetir evaluación", BG_CARD);
        btnRep.setForeground(SUB);
        btnRep.addActionListener(e -> {
            for (int i = 0; i < respuestas.length; i++) respuestas[i] = 0;
            puntoTotal = 0;
            mostrarIntro();
        });

        btnRow.add(btnIrNivel);
        btnRow.add(btnRep);
        panel.add(btnRow);
        panel.add(Box.createVerticalGlue());

        JScrollPane scroll = new JScrollPane(panel);
        scroll.setBorder(null);
        scroll.getViewport().setBackground(BG);
        scroll.setHorizontalScrollBarPolicy(JScrollPane.HORIZONTAL_SCROLLBAR_NEVER);
        scroll.getVerticalScrollBar().setUnitIncrement(14);
        UiUtil.estilizarScroll(scroll);

        contenedor.removeAll();
        contenedor.add(scroll);
        contenedor.revalidate();
        contenedor.repaint();
    }

    private JPanel crearCardActividad(String titulo, String desc, String tipo) {
        Color accentCol = switch (tipo) {
            case "green"  -> GREEN;
            case "yellow" -> YELLOW;
            case "orange" -> ORANGE;
            case "pink"   -> PINK;
            default       -> ACCENT;
        };

        JPanel card = new JPanel(new BorderLayout(12, 0));
        card.setBackground(BG_CARD);
        card.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createMatteBorder(0, 3, 0, 0, accentCol),
            new EmptyBorder(12, 14, 12, 14)));
        card.setAlignmentX(Component.LEFT_ALIGNMENT);
        card.setMaximumSize(new Dimension(Integer.MAX_VALUE, 9999));

        JPanel texto = new JPanel();
        texto.setLayout(new BoxLayout(texto, BoxLayout.Y_AXIS));
        texto.setBackground(BG_CARD);

        JLabel lblT = new JLabel(titulo);
        lblT.setFont(new Font("Monospaced", Font.BOLD, 14));
        lblT.setForeground(accentCol);

        JLabel lblD = new JLabel(desc);
        lblD.setFont(new Font("Monospaced", Font.PLAIN, 13));
        lblD.setForeground(new Color(160, 165, 190));

        texto.add(lblT);
        texto.add(Box.createVerticalStrut(3));
        texto.add(lblD);

        card.add(texto, BorderLayout.CENTER);
        return card;
    }

    // ── Helper ────────────────────────────────────────────────────

    private JButton boton(String texto, Color color) {
        JButton btn = new JButton(texto);
        btn.setFont(new Font("Monospaced", Font.BOLD, 15));
        btn.setBackground(color);
        btn.setForeground(color.equals(BG_CARD) ? SUB : BG);
        btn.setBorderPainted(false);
        btn.setFocusPainted(false);
        btn.setBorder(new EmptyBorder(9, 20, 9, 20));
        btn.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        return btn;
    }

}
