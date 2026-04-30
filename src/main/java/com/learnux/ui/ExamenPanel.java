package com.learnux.ui;

import com.learnux.models.Ejercicio;
import com.learnux.models.Usuario;
import com.learnux.service.NivelService;
import com.learnux.service.ServiceException;

import javax.swing.*;
import javax.swing.border.EmptyBorder;
import java.awt.*;
import java.util.*;
import java.util.List;

/**
 * Examen cronometrado (10 min) con 5 preguntas de distintos niveles.
 * Sin pistas. Al final muestra tabla de resultados con respuestas correctas.
 */
public class ExamenPanel extends JPanel {

    private static final Color BG      = UiUtil.BG_DARK;
    private static final Color BG_CARD = UiUtil.BG_CARD;
    private static final Color BG_HDR  = UiUtil.BG_HDR;
    private static final Color TEXT    = UiUtil.TEXT;
    private static final Color SUB     = UiUtil.OVERLAY;
    private static final Color ACCENT  = UiUtil.BLUE;
    private static final Color GREEN   = UiUtil.GREEN;
    private static final Color YELLOW  = UiUtil.YELLOW;
    private static final Color PINK    = UiUtil.RED;

    // Niveles de los que se extrae 1 ejercicio cada uno
    private static final int[] NIVELES_EXAMEN = {1, 4, 7, 11, 15};
    private static final int TIEMPO_TOTAL_SEG = 600; // 10 minutos

    private final Usuario      usuario;
    private final Runnable     onCerrar;
    private final NivelService nivelService = new NivelService();

    private List<Ejercicio> ejercicios   = new ArrayList<>();
    private int[]           respuestas   = new int[NIVELES_EXAMEN.length]; // puntuación por ejercicio
    private String[]        dadoTexto    = new String[NIVELES_EXAMEN.length];
    private int             indice       = 0;
    private int             aciertos     = 0;
    private int             segundosLeft = TIEMPO_TOTAL_SEG;

    private JLabel  lblTimer;
    private JLabel  lblProgreso;
    private JLabel  lblPregunta;
    private JPanel  panelRespuesta;
    private JButton btnResponder;
    private JLabel  lblFeedback;
    private String  respuestaSeleccionada;

    private javax.swing.Timer countdown;

    public ExamenPanel(Usuario usuario, Runnable onCerrar) {
        this.usuario  = usuario;
        this.onCerrar = onCerrar;
        setBackground(BG);
        setLayout(new BorderLayout());
        cargarEjerciciosYComenzar();
    }

    // ── Carga ejercicios ──────────────────────────────────────────

    private void cargarEjerciciosYComenzar() {
        for (int idNivel : NIVELES_EXAMEN) {
            try {
                List<Ejercicio> lista = nivelService.getEjerciciosPorId(idNivel);
                if (lista.isEmpty()) continue;
                Ejercicio candidato = lista.stream()
                    .filter(e -> "MULTIPLE_CHOICE".equals(e.getTipo()) || "FILL_BLANK".equals(e.getTipo()))
                    .findFirst()
                    .orElseGet(() -> lista.stream()
                        .filter(e -> "TYPE_COMMAND".equals(e.getTipo()) || esArrastradoSimple(e))
                        .findFirst()
                        .orElse(lista.get(0)));
                ejercicios.add(candidato);
            } catch (ServiceException ignored) {}
        }

        if (ejercicios.isEmpty()) {
            JLabel err = new JLabel("No se pudieron cargar los ejercicios del examen.", SwingConstants.CENTER);
            err.setForeground(PINK);
            err.setFont(new Font("Monospaced", Font.BOLD, 16));
            add(err, BorderLayout.CENTER);
            return;
        }

        dadoTexto = new String[ejercicios.size()];
        respuestas = new int[ejercicios.size()];
        construirUI();
        mostrarIntroExamen();
    }

    private boolean esArrastradoSimple(Ejercicio e) {
        String rc = e.getRespuestaCorrecta();
        return rc != null && !rc.startsWith("{") && !rc.startsWith("[") && !rc.contains(" ");
    }

    // ── UI base ───────────────────────────────────────────────────

    private void construirUI() {
        // Header
        JPanel header = new JPanel(new BorderLayout());
        header.setBackground(BG_HDR);
        header.setBorder(new EmptyBorder(12, 18, 12, 18));

        JButton btnSalir = new JButton("← Salir");
        btnSalir.setFont(new Font("Monospaced", Font.PLAIN, 13));
        btnSalir.setBackground(BG_CARD);
        btnSalir.setForeground(SUB);
        btnSalir.setBorderPainted(false);
        btnSalir.setFocusPainted(false);
        btnSalir.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        btnSalir.addActionListener(e -> confirmarSalida());

        JLabel lblTitulo = new JLabel("🎓  Examen Final — LearnUX");
        lblTitulo.setFont(new Font("Monospaced", Font.BOLD, 18));
        lblTitulo.setForeground(YELLOW);

        lblTimer = new JLabel("10:00");
        lblTimer.setFont(new Font("Monospaced", Font.BOLD, 18));
        lblTimer.setForeground(GREEN);

        lblProgreso = new JLabel("");
        lblProgreso.setFont(new Font("Monospaced", Font.PLAIN, 14));
        lblProgreso.setForeground(SUB);

        JPanel eastHdr = new JPanel(new FlowLayout(FlowLayout.RIGHT, 18, 0));
        eastHdr.setBackground(BG_HDR);
        eastHdr.add(lblProgreso);
        eastHdr.add(lblTimer);

        JPanel westHdr = new JPanel(new FlowLayout(FlowLayout.LEFT, 12, 0));
        westHdr.setBackground(BG_HDR);
        westHdr.add(btnSalir);
        westHdr.add(lblTitulo);

        header.add(westHdr, BorderLayout.WEST);
        header.add(eastHdr, BorderLayout.EAST);
        add(header, BorderLayout.NORTH);

        // Centro
        JPanel centro = new JPanel();
        centro.setLayout(new BoxLayout(centro, BoxLayout.Y_AXIS));
        centro.setBackground(BG);
        centro.setBorder(new EmptyBorder(20, 30, 10, 30));

        lblPregunta = new JLabel(" ");
        lblPregunta.setFont(new Font("Monospaced", Font.PLAIN, 17));
        lblPregunta.setForeground(TEXT);
        lblPregunta.setAlignmentX(Component.LEFT_ALIGNMENT);
        centro.add(lblPregunta);
        centro.add(Box.createVerticalStrut(18));

        panelRespuesta = new JPanel();
        panelRespuesta.setBackground(BG);
        panelRespuesta.setAlignmentX(Component.LEFT_ALIGNMENT);
        panelRespuesta.setMaximumSize(new Dimension(Integer.MAX_VALUE, 300));
        centro.add(panelRespuesta);
        centro.add(Box.createVerticalStrut(12));

        lblFeedback = new JLabel(" ");
        lblFeedback.setFont(new Font("Monospaced", Font.BOLD, 18));
        lblFeedback.setAlignmentX(Component.LEFT_ALIGNMENT);
        centro.add(lblFeedback);

        add(centro, BorderLayout.CENTER);

        // Footer (sin botón de pista)
        JPanel footer = new JPanel(new BorderLayout());
        footer.setBackground(BG_HDR);
        footer.setBorder(new EmptyBorder(10, 18, 10, 18));

        JLabel instruccion = new JLabel("⚠  Examen oficial — sin pistas disponibles");
        instruccion.setFont(new Font("Monospaced", Font.PLAIN, 13));
        instruccion.setForeground(YELLOW);

        btnResponder = boton("Responder", ACCENT);
        btnResponder.addActionListener(e -> onResponder());

        footer.add(instruccion,  BorderLayout.WEST);
        footer.add(btnResponder, BorderLayout.EAST);
        add(footer, BorderLayout.SOUTH);
    }

    // ── Intro del examen ──────────────────────────────────────────

    private void mostrarIntroExamen() {
        lblProgreso.setText("Preparado");
        lblPregunta.setText("<html><body style='width:680px'>"
            + "<b style='color:#89b4fa'>🎓 Instrucciones del Examen Final</b>"
            + "</body></html>");
        lblFeedback.setText(" ");
        btnResponder.setText("¡Comenzar examen!  →");
        btnResponder.setBackground(YELLOW);

        panelRespuesta.removeAll();
        panelRespuesta.setLayout(new BoxLayout(panelRespuesta, BoxLayout.Y_AXIS));
        panelRespuesta.setMaximumSize(new Dimension(Integer.MAX_VALUE, 360));

        String[][] reglas = {
            {"📋", ejercicios.size() + " preguntas de distintos niveles (Fundamentos → Avanzado)"},
            {"⏱",  "10 minutos en total para completar el examen"},
            {"🚫", "Sin pistas — pondrás a prueba tu conocimiento real"},
            {"📊", "Al final verás tu puntaje con la respuesta correcta de cada pregunta"},
            {"🎯", "Superar el 60% significa que tienes base sólida de Linux"},
        };

        for (String[] r : reglas) {
            JPanel fila = new JPanel(new FlowLayout(FlowLayout.LEFT, 10, 4));
            fila.setBackground(BG);
            fila.setAlignmentX(Component.LEFT_ALIGNMENT);
            fila.setMaximumSize(new Dimension(Integer.MAX_VALUE, 36));
            JLabel icon = new JLabel(r[0]);
            icon.setFont(new Font("Monospaced", Font.PLAIN, 18));
            JLabel txt = new JLabel(r[1]);
            txt.setFont(new Font("Monospaced", Font.PLAIN, 15));
            txt.setForeground(TEXT);
            fila.add(icon);
            fila.add(txt);
            panelRespuesta.add(fila);
        }

        panelRespuesta.revalidate();
        panelRespuesta.repaint();

        for (var l : btnResponder.getActionListeners()) btnResponder.removeActionListener(l);
        btnResponder.addActionListener(e -> {
            btnResponder.setBackground(ACCENT);
            for (var l2 : btnResponder.getActionListeners()) btnResponder.removeActionListener(l2);
            btnResponder.addActionListener(ev -> onResponder());
            iniciarCronometro();
            mostrarEjercicio();
        });
    }

    // ── Cronómetro ────────────────────────────────────────────────

    private void iniciarCronometro() {
        countdown = new javax.swing.Timer(1000, null);
        countdown.addActionListener(e -> {
            segundosLeft--;
            int mm = segundosLeft / 60;
            int ss = segundosLeft % 60;
            lblTimer.setText(String.format("%02d:%02d", mm, ss));
            if (segundosLeft <= 60) lblTimer.setForeground(PINK);
            else if (segundosLeft <= 180) lblTimer.setForeground(YELLOW);
            if (segundosLeft <= 0) {
                ((javax.swing.Timer) e.getSource()).stop();
                mostrarResultados();
            }
        });
        countdown.start();
    }

    // ── Ejercicio ─────────────────────────────────────────────────

    private void mostrarEjercicio() {
        if (indice >= ejercicios.size()) {
            if (countdown != null) countdown.stop();
            mostrarResultados();
            return;
        }

        Ejercicio ej = ejercicios.get(indice);
        respuestaSeleccionada = null;
        lblFeedback.setText(" ");
        lblProgreso.setText((indice + 1) + " / " + ejercicios.size());
        lblPregunta.setText("<html><body style='width:680px'>" + ej.getPregunta() + "</body></html>");
        btnResponder.setText("Responder");
        btnResponder.setBackground(ACCENT);
        btnResponder.setEnabled(true);

        construirPanelRespuesta(ej);
    }

    private void construirPanelRespuesta(Ejercicio ej) {
        panelRespuesta.removeAll();
        panelRespuesta.setMaximumSize(new Dimension(Integer.MAX_VALUE, 300));
        List<String> opciones = ej.getOpciones();

        switch (ej.getTipo()) {
            case "MULTIPLE_CHOICE" -> construirOpciones(opciones);
            case "FILL_BLANK"      -> construirCombo(opciones);
            case "DRAG_DROP"       -> {
                String rc = ej.getRespuestaCorrecta();
                if (rc != null && !rc.startsWith("{") && !rc.startsWith("[") && !rc.contains(" ")) {
                    construirOpciones(opciones); // trata drag-drop simple como MC
                } else {
                    construirTerminal(); // fallback
                }
            }
            default                -> construirTerminal();
        }

        panelRespuesta.revalidate();
        panelRespuesta.repaint();
    }

    private void construirOpciones(List<String> opciones) {
        panelRespuesta.setLayout(new GridLayout(0, 1, 0, 8));
        ButtonGroup grupo = new ButtonGroup();
        for (String op : opciones) {
            JToggleButton btn = new JToggleButton(op);
            btn.setFont(new Font("Monospaced", Font.PLAIN, 15));
            btn.setBackground(BG_CARD);
            btn.setForeground(TEXT);
            btn.setBorderPainted(true);
            btn.setBorder(BorderFactory.createCompoundBorder(
                BorderFactory.createLineBorder(new Color(69, 71, 90)),
                new EmptyBorder(10, 14, 10, 14)));
            btn.setFocusPainted(false);
            btn.setHorizontalAlignment(SwingConstants.LEFT);
            btn.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
            btn.addItemListener(e -> {
                if (btn.isSelected()) {
                    respuestaSeleccionada = op;
                    btn.setBackground(new Color(50, 70, 110));
                    btn.setForeground(ACCENT);
                    btn.setBorder(BorderFactory.createCompoundBorder(
                        BorderFactory.createLineBorder(ACCENT), new EmptyBorder(10, 14, 10, 14)));
                } else {
                    btn.setBackground(BG_CARD);
                    btn.setForeground(TEXT);
                    btn.setBorder(BorderFactory.createCompoundBorder(
                        BorderFactory.createLineBorder(new Color(69, 71, 90)), new EmptyBorder(10, 14, 10, 14)));
                }
            });
            grupo.add(btn);
            panelRespuesta.add(btn);
        }
    }

    private void construirCombo(List<String> opciones) {
        panelRespuesta.setLayout(new FlowLayout(FlowLayout.LEFT, 0, 0));
        JComboBox<String> combo = new JComboBox<>(opciones.toArray(new String[0]));
        combo.setFont(new Font("Monospaced", Font.PLAIN, 16));
        combo.setBackground(BG_CARD);
        combo.setForeground(TEXT);
        combo.setPreferredSize(new Dimension(340, 38));
        combo.addActionListener(e -> respuestaSeleccionada = (String) combo.getSelectedItem());
        respuestaSeleccionada = opciones.isEmpty() ? null : opciones.get(0);
        panelRespuesta.add(combo);
    }

    private void construirTerminal() {
        panelRespuesta.setLayout(new BorderLayout(0, 8));
        JPanel inputRow = new JPanel(new BorderLayout(8, 0));
        inputRow.setBackground(BG);
        JLabel prompt = new JLabel("$");
        prompt.setFont(new Font("Monospaced", Font.BOLD, 18));
        prompt.setForeground(GREEN);
        prompt.setBorder(new EmptyBorder(0, 0, 0, 4));
        JTextField campo = new JTextField();
        campo.setFont(new Font("Monospaced", Font.PLAIN, 17));
        campo.setBackground(BG_CARD);
        campo.setForeground(GREEN);
        campo.setCaretColor(GREEN);
        campo.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createLineBorder(new Color(69, 71, 90)),
            new EmptyBorder(8, 10, 8, 10)));
        campo.getDocument().addDocumentListener(new javax.swing.event.DocumentListener() {
            public void changedUpdate(javax.swing.event.DocumentEvent e) { respuestaSeleccionada = campo.getText(); }
            public void insertUpdate(javax.swing.event.DocumentEvent e)  { respuestaSeleccionada = campo.getText(); }
            public void removeUpdate(javax.swing.event.DocumentEvent e)  { respuestaSeleccionada = campo.getText(); }
        });
        campo.addActionListener(e -> onResponder());
        inputRow.add(prompt, BorderLayout.WEST);
        inputRow.add(campo,  BorderLayout.CENTER);
        panelRespuesta.add(inputRow, BorderLayout.CENTER);
    }

    // ── Evaluación de respuesta ───────────────────────────────────

    private void onResponder() {
        if ("Siguiente →".equals(btnResponder.getText())) {
            indice++;
            mostrarEjercicio();
            return;
        }

        Ejercicio ej = ejercicios.get(indice);
        if (respuestaSeleccionada == null || respuestaSeleccionada.isBlank()) {
            lblFeedback.setForeground(YELLOW);
            lblFeedback.setText("⚠  Selecciona o escribe una respuesta.");
            return;
        }

        boolean ok = ej.esCorrecta(respuestaSeleccionada);
        dadoTexto[indice] = respuestaSeleccionada;
        if (ok) {
            aciertos++;
            respuestas[indice] = 1;
            lblFeedback.setForeground(GREEN);
            lblFeedback.setText("✔  ¡Correcto!");
            SoundPlayer.playCorrect();
        } else {
            respuestas[indice] = 0;
            lblFeedback.setForeground(PINK);
            lblFeedback.setText("✘  Incorrecto.");
            SoundPlayer.playWrong();
        }

        btnResponder.setText(indice < ejercicios.size() - 1 ? "Siguiente →" : "Ver resultados →");
        btnResponder.setBackground(ok ? GREEN : PINK);
        bloquearPanelRespuesta();
    }

    private void bloquearPanelRespuesta() {
        for (Component c : panelRespuesta.getComponents()) {
            c.setEnabled(false);
            if (c instanceof JPanel inner)
                for (Component ic : inner.getComponents()) ic.setEnabled(false);
        }
    }

    // ── Pantalla de resultados ────────────────────────────────────

    private void mostrarResultados() {
        if (countdown != null) countdown.stop();
        SoundPlayer.playLevelPass();

        int total = ejercicios.size();
        int pct   = total > 0 ? (aciertos * 100 / total) : 0;
        boolean aprobado = pct >= 60;

        removeAll();
        setLayout(new BorderLayout());

        // Banner
        JPanel banner = new JPanel();
        banner.setLayout(new BoxLayout(banner, BoxLayout.Y_AXIS));
        banner.setBackground(aprobado ? new Color(18, 30, 60) : new Color(48, 22, 34));
        banner.setBorder(new EmptyBorder(30, 40, 22, 40));

        JLabel icono = new JLabel(aprobado ? "🎓" : "📘", SwingConstants.CENTER);
        icono.setFont(new Font("Monospaced", Font.PLAIN, 50));
        icono.setAlignmentX(Component.CENTER_ALIGNMENT);

        JLabel titulo = new JLabel(aprobado ? "¡Examen aprobado!" : "Sigue practicando");
        titulo.setFont(new Font("Monospaced", Font.BOLD, 28));
        titulo.setForeground(aprobado ? GREEN : YELLOW);
        titulo.setAlignmentX(Component.CENTER_ALIGNMENT);

        JLabel lblPct = new JLabel(aciertos + " correctas de " + total + "  (" + pct + "%)");
        lblPct.setFont(new Font("Monospaced", Font.PLAIN, 15));
        lblPct.setForeground(SUB);
        lblPct.setAlignmentX(Component.CENTER_ALIGNMENT);

        JProgressBar barra = new JProgressBar(0, 100);
        barra.setValue(0);
        barra.setStringPainted(true);
        barra.setString("  " + pct + "%");
        barra.setForeground(aprobado ? GREEN : YELLOW);
        barra.setBackground(new Color(38, 38, 58));
        barra.setBorderPainted(false);
        barra.setMaximumSize(new Dimension(600, 28));
        barra.setAlignmentX(Component.CENTER_ALIGNMENT);
        barra.setFont(new Font("Monospaced", Font.BOLD, 14));

        banner.add(icono);
        banner.add(Box.createVerticalStrut(8));
        banner.add(titulo);
        banner.add(Box.createVerticalStrut(6));
        banner.add(lblPct);
        banner.add(Box.createVerticalStrut(14));
        banner.add(barra);
        add(banner, BorderLayout.NORTH);

        // Tabla de resultados
        JPanel tablaWrap = new JPanel();
        tablaWrap.setLayout(new BoxLayout(tablaWrap, BoxLayout.Y_AXIS));
        tablaWrap.setBackground(BG);
        tablaWrap.setBorder(new EmptyBorder(16, 30, 16, 30));

        JLabel lblTabTit = new JLabel("📋  Revisión detallada");
        lblTabTit.setFont(new Font("Monospaced", Font.BOLD, 15));
        lblTabTit.setForeground(ACCENT);
        lblTabTit.setAlignmentX(Component.LEFT_ALIGNMENT);
        tablaWrap.add(lblTabTit);
        tablaWrap.add(Box.createVerticalStrut(10));

        for (int i = 0; i < ejercicios.size(); i++) {
            Ejercicio ej  = ejercicios.get(i);
            boolean correcto = respuestas[i] == 1;
            String dado = dadoTexto[i] != null ? dadoTexto[i] : "(sin respuesta)";

            JPanel row = new JPanel(new BorderLayout(10, 0));
            row.setBackground(correcto ? new Color(22, 40, 28) : new Color(48, 22, 28));
            row.setBorder(BorderFactory.createCompoundBorder(
                BorderFactory.createLineBorder(correcto ? new Color(50, 100, 60) : new Color(100, 40, 50)),
                new EmptyBorder(10, 14, 10, 14)));
            row.setAlignmentX(Component.LEFT_ALIGNMENT);
            row.setMaximumSize(new Dimension(Integer.MAX_VALUE, 9999));

            JLabel icR = new JLabel(correcto ? "✔" : "✘");
            icR.setFont(new Font("Monospaced", Font.BOLD, 20));
            icR.setForeground(correcto ? GREEN : PINK);
            icR.setPreferredSize(new Dimension(28, 28));
            icR.setVerticalAlignment(SwingConstants.TOP);

            JPanel info = new JPanel();
            info.setLayout(new BoxLayout(info, BoxLayout.Y_AXIS));
            info.setBackground(row.getBackground());

            JLabel q = new JLabel("<html><body style='width:620px'>"
                + "<b>P" + (i+1) + ":</b> " + ej.getPregunta() + "</body></html>");
            q.setFont(new Font("Monospaced", Font.PLAIN, 13));
            q.setForeground(TEXT);

            JLabel tu = new JLabel("Tu respuesta:   " + dado);
            tu.setFont(new Font("Monospaced", Font.PLAIN, 12));
            tu.setForeground(correcto ? GREEN : PINK);

            JLabel cor = new JLabel("Respuesta correcta:   " + ej.getRespuestaCorrecta());
            cor.setFont(new Font("Monospaced", Font.BOLD, 12));
            cor.setForeground(correcto ? GREEN : YELLOW);

            info.add(q);
            info.add(Box.createVerticalStrut(5));
            info.add(tu);
            if (!correcto) {
                info.add(Box.createVerticalStrut(2));
                info.add(cor);
            }

            row.add(icR,  BorderLayout.WEST);
            row.add(info, BorderLayout.CENTER);
            tablaWrap.add(row);
            tablaWrap.add(Box.createVerticalStrut(8));
        }

        JScrollPane scrollTabla = new JScrollPane(tablaWrap);
        scrollTabla.setBorder(null);
        scrollTabla.getViewport().setBackground(BG);
        scrollTabla.getVerticalScrollBar().setUnitIncrement(12);
        UiUtil.estilizarScroll(scrollTabla);
        add(scrollTabla, BorderLayout.CENTER);

        // Footer
        JPanel footer = new JPanel(new FlowLayout(FlowLayout.CENTER, 16, 16));
        footer.setBackground(BG_HDR);

        JButton btnVolver = boton("← Volver al menú", ACCENT);
        btnVolver.addActionListener(e -> { if (onCerrar != null) onCerrar.run(); });
        footer.add(btnVolver);

        add(footer, BorderLayout.SOUTH);
        revalidate();
        repaint();

        // Animación barra
        int[] f = {0};
        javax.swing.Timer anim = new javax.swing.Timer(50, null);
        anim.addActionListener(e -> {
            f[0] = Math.min(f[0] + 2, pct);
            barra.setValue(f[0]);
            if (f[0] >= pct) ((javax.swing.Timer) e.getSource()).stop();
        });
        anim.start();
    }

    // ── Confirmación de salida ────────────────────────────────────

    private void confirmarSalida() {
        int r = JOptionPane.showConfirmDialog(this,
            "¿Seguro que quieres salir? El examen no se guardará.",
            "Salir del examen", JOptionPane.YES_NO_OPTION, JOptionPane.WARNING_MESSAGE);
        if (r == JOptionPane.YES_OPTION) {
            if (countdown != null) countdown.stop();
            if (onCerrar != null) onCerrar.run();
        }
    }

    // ── Helper ────────────────────────────────────────────────────

    private JButton boton(String texto, Color color) {
        JButton btn = new JButton(texto);
        btn.setFont(new Font("Monospaced", Font.BOLD, 18));
        btn.setBackground(color);
        btn.setForeground(BG);
        btn.setBorderPainted(false);
        btn.setFocusPainted(false);
        btn.setBorder(new EmptyBorder(9, 22, 9, 22));
        btn.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        return btn;
    }
}
