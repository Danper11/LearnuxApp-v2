package com.learnux.ui;

import com.learnux.models.Comando;
import com.learnux.models.Ejercicio;
import com.learnux.models.Nivel;
import com.learnux.models.Usuario;
import com.learnux.service.ComandoService;
import com.learnux.service.NivelService;
import com.learnux.service.ProgresoService;
import com.learnux.service.ServiceException;

import javax.swing.*;
import javax.swing.border.EmptyBorder;
import java.awt.*;
import java.awt.datatransfer.DataFlavor;
import java.awt.datatransfer.StringSelection;
import java.awt.datatransfer.Transferable;
import java.awt.dnd.*;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.event.MouseMotionAdapter;
import java.util.*;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

public class EjercicioPanel extends JPanel {

    // ── Paleta ────────────────────────────────────────────────────
    private static final Color BG       = UiUtil.BG_DARK;
    private static final Color BG_CARD  = UiUtil.BG_CARD;
    private static final Color BG_HDR   = UiUtil.BG_HDR;
    private static final Color BG_DROP  = new Color(38,  40,  60);
    private static final Color TEXT     = UiUtil.TEXT;
    private static final Color SUB      = UiUtil.OVERLAY;
    private static final Color ACCENT   = UiUtil.BLUE;
    private static final Color GREEN    = UiUtil.GREEN;
    private static final Color PINK     = UiUtil.RED;
    private static final Color YELLOW   = UiUtil.YELLOW;
    private static final Color MAUVE    = UiUtil.MAUVE;

    private final NivelService    nivelService    = new NivelService();
    private final ProgresoService progresoService = new ProgresoService();
    private final ComandoService  comandoService  = new ComandoService();
    private final Usuario         usuario;
    private final Nivel           nivel;
    private       List<Ejercicio> ejercicios;
    private       int             indice   = 0;
    private       int             aciertos = 0;

    private JLabel  lblProgreso;
    private JLabel  lblPregunta;
    private JPanel  panelRespuesta;
    private JButton btnPista;
    private JLabel  lblFeedback;
    private JButton btnAccion;
    private String  respuestaSeleccionada;

    // Estado para DRAG_DROP multi-par
    private final Map<JPanel, String>  ddExpected  = new LinkedHashMap<>();
    private final Map<JPanel, String>  ddPlaced    = new LinkedHashMap<>();
    private final Map<String, JButton> ddChips     = new LinkedHashMap<>();
    private final Map<JPanel, JLabel>  ddZonaLabel = new LinkedHashMap<>();
    private final Map<JPanel, JButton> ddZonaChip  = new LinkedHashMap<>();

    // Estado para DRAG_DROP ordenación
    private boolean                    ddEsOrden   = false;
    private final List<JPanel>         ddSlots         = new ArrayList<>();
    private final Map<JPanel, String>  ddSlotPlaced    = new LinkedHashMap<>();
    private final Map<JPanel, JLabel>  ddSlotLabel     = new LinkedHashMap<>();
    private final Map<JPanel, JButton> ddSlotChipBtn   = new LinkedHashMap<>();
    private final List<String>         ddOrdenExpected = new ArrayList<>();

    // Estado para DRAG_DROP multi-selección
    private boolean                    ddEsMultiSel      = false;
    private final Set<String>          ddMultiSelSelected = new LinkedHashSet<>();
    private final Set<String>          ddMultiSelExpected = new LinkedHashSet<>();
    private final Map<String, JButton> ddMultiSelChips    = new LinkedHashMap<>();

    private final Runnable onCerrar;
    private final Runnable onSuperado;
    private final Runnable onSiguiente;

    private static final String[] TODAS_LAS_FRASES = {
        "El trabajo duro de hoy crea al programador de mañana.",
        "¡El conocimiento de hoy es la habilidad de mañana!",
        "Cada comando que aprendes es una puerta que se abre.",
        "La terminal es tu aliada. ¡Sigue explorando!",
        "Un paso a la vez. ¡Vas muy bien!",
        "¡Los expertos fueron principiantes alguna vez!",
        "La perseverancia es la clave del dominio.",
        "¡Estás construyendo superpoderes digitales!",
        "Linux te espera con nuevos desafíos. ¡Tú puedes!",
        "¡Cada nivel superado te acerca a la maestría!",
        "El shell es tu lienzo. ¡Pinta con comandos!",
        "¡Brillante! El sistema te obedece.",
        "La automatización comienza con lo que aprendes ahora.",
        "¡Imparable! La terminal te pertenece.",
        "Un sysadmin se forma con cada ejercicio. ¡Tú lo estás logrando!",
        "¡Dominar la terminal te abre las puertas de cualquier servidor!",
        "La disciplina de hoy es la libertad de mañana.",
        "¡Cada línea que escribes te acerca a ser el profesional que quieres ser!",
        "No hay atajos al dominio, pero cada ejercicio es un paso real.",
        "¡El programador que serás mañana te agradecerá el esfuerzo de hoy!",
    };

    private static final String[] NOTICIAS_LINUX = {
        "📰 Linux cumple más de 33 años: el kernel que domina el mundo tiene más de 27 millones de líneas de código y crece cada día.",
        "📰 Más del 96% de los servidores web del planeta corren Linux. Los comandos que aprendes hoy son los que usan esos servidores.",
        "📰 Android — el sistema operativo más popular del mundo — está basado en el kernel de Linux. Aprender Linux es entender cómo funciona tu móvil.",
        "📰 Los 500 supercomputadores más potentes del planeta usan Linux como sistema operativo base. ¿Coincidencia? No existe tal cosa.",
        "📰 La Estación Espacial Internacional (ISS) ejecuta Linux para controlar sus sistemas críticos. ¡La terminal va incluso al espacio!",
        "📰 Netflix, Amazon, Google y Meta basan su infraestructura en Linux. Dominar la terminal te abre la puerta a estas empresas.",
        "📰 El kernel de Linux tiene más de 4,000 contribuidores activos de todo el mundo. Tú también puedes contribuir algún día.",
        "📰 Docker, Kubernetes y todo el ecosistema de contenedores moderno nacieron sobre bases sólidas de Linux y sus herramientas.",
        "📰 Linus Torvalds creó Linux en 1991 como proyecto personal universitario. Hoy lo usa más de la mitad del mundo.",
        "📰 El salario promedio de un administrador de sistemas Linux supera los 80,000 USD anuales en el mercado internacional.",
    };

    private static final java.util.List<String> colaFrases = new java.util.ArrayList<>(java.util.Arrays.asList(TODAS_LAS_FRASES));
    static { java.util.Collections.shuffle(colaFrases, new java.util.Random()); }
    private static int noticiaIdx = 0;
    private static final java.util.Random RND = new java.util.Random();

    private static String siguienteFrase() {
        if (colaFrases.isEmpty()) {
            String noticia = NOTICIAS_LINUX[noticiaIdx++ % NOTICIAS_LINUX.length];
            java.util.List<String> recarga = new java.util.ArrayList<>(java.util.Arrays.asList(TODAS_LAS_FRASES));
            java.util.Collections.shuffle(recarga, RND);
            colaFrases.addAll(recarga);
            return noticia;
        }
        return colaFrases.remove(0);
    }

    // ── Racha de aciertos ─────────────────────────────────────────
    private int    racha    = 0;
    private JLabel lblRacha;

    // ── Vidas ─────────────────────────────────────────────────────
    private int    vidas    = 3;
    private JLabel lblVidas;

    // ── Fallos en el ejercicio actual (para auto-pista) ───────────
    private int    fallosEjercicio = 0;

    // ── Transición fade ───────────────────────────────────────────
    private float  fadeAlpha = 0f;

    public EjercicioPanel(Usuario usuario, Nivel nivel, Runnable onCerrar) {
        this(usuario, nivel, onCerrar, null, null);
    }

    public EjercicioPanel(Usuario usuario, Nivel nivel, Runnable onCerrar, Runnable onSuperado) {
        this(usuario, nivel, onCerrar, onSuperado, null);
    }

    public EjercicioPanel(Usuario usuario, Nivel nivel, Runnable onCerrar, Runnable onSuperado, Runnable onSiguiente) {
        this.usuario     = usuario;
        this.nivel       = nivel;
        this.onCerrar    = onCerrar;
        this.onSuperado  = onSuperado;
        this.onSiguiente = onSiguiente;

        setBackground(BG);
        setLayout(new BorderLayout());

        try {
            ejercicios = nivelService.getEjercicios(nivel);
        } catch (ServiceException e) {
            JOptionPane.showMessageDialog(null, e.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
            if (onCerrar != null) onCerrar.run();
            return;
        }

        construirUI();
        mostrarIntroduccion();
    }

    // ── UI base ───────────────────────────────────────────────────

    private void construirUI() {
        // Header
        JPanel header = new JPanel(new BorderLayout());
        header.setBackground(BG_HDR);
        header.setBorder(new EmptyBorder(12, 18, 12, 18));
        JLabel lblTitulo = new JLabel(tipoIcono(nivel.getTipoEjercicio()) + "  " + nivel.getNombre());
        lblTitulo.setFont(new Font("Monospaced", Font.BOLD, 18));
        lblTitulo.setForeground(ACCENT);

        lblRacha = new JLabel("");
        lblRacha.setFont(new Font("Monospaced", Font.BOLD, 15));
        lblRacha.setForeground(YELLOW);

        lblProgreso = new JLabel();
        lblProgreso.setFont(new Font("Monospaced", Font.PLAIN, 15));
        lblProgreso.setForeground(SUB);

        lblVidas = new JLabel();
        lblVidas.setFont(new Font("Monospaced", Font.BOLD, 17));
        actualizarVidas();

        // Botón para volver a selección de niveles
        JButton btnVolver = new JButton("← Niveles");
        btnVolver.setFont(new Font("Monospaced", Font.PLAIN, 13));
        btnVolver.setBackground(BG_CARD);
        btnVolver.setForeground(SUB);
        btnVolver.setBorderPainted(false);
        btnVolver.setFocusPainted(false);
        btnVolver.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        btnVolver.addActionListener(e -> {
            if (onCerrar != null) onCerrar.run();
        });

        JPanel eastHdr = new JPanel(new FlowLayout(FlowLayout.RIGHT, 14, 0));
        eastHdr.setBackground(BG_HDR);
        eastHdr.add(lblVidas);
        eastHdr.add(lblRacha);
        eastHdr.add(lblProgreso);

        JPanel westHdr = new JPanel(new FlowLayout(FlowLayout.LEFT, 14, 0));
        westHdr.setBackground(BG_HDR);
        westHdr.add(btnVolver);
        westHdr.add(lblTitulo);

        header.add(westHdr, BorderLayout.WEST);
        header.add(eastHdr, BorderLayout.EAST);
        add(header, BorderLayout.NORTH);

        // Centro
        JPanel centro = new JPanel();
        centro.setLayout(new BoxLayout(centro, BoxLayout.Y_AXIS));
        centro.setBackground(BG);
        centro.setBorder(new EmptyBorder(20, 26, 10, 26));

        lblPregunta = new JLabel();
        lblPregunta.setFont(UiUtil.FONT_SUB);
        lblPregunta.setForeground(TEXT);
        lblPregunta.setAlignmentX(Component.LEFT_ALIGNMENT);
        centro.add(lblPregunta);
        centro.add(Box.createVerticalStrut(18));

        panelRespuesta = new JPanel();
        panelRespuesta.setBackground(BG);
        panelRespuesta.setAlignmentX(Component.LEFT_ALIGNMENT);
        panelRespuesta.setMaximumSize(new Dimension(Integer.MAX_VALUE, 320));
        centro.add(panelRespuesta);
        centro.add(Box.createVerticalStrut(12));

        lblFeedback = new JLabel(" ");
        lblFeedback.setFont(new Font("Monospaced", Font.BOLD, 19));
        lblFeedback.setAlignmentX(Component.LEFT_ALIGNMENT);
        centro.add(lblFeedback);

        add(centro, BorderLayout.CENTER);

        // Footer
        JPanel footer = new JPanel(new BorderLayout());
        footer.setBackground(BG_HDR);
        footer.setBorder(new EmptyBorder(10, 18, 10, 18));

        btnPista = new JButton("💡 Pista");
        btnPista.setFont(new Font("Monospaced", Font.PLAIN, 15));
        btnPista.setBackground(BG_CARD);
        btnPista.setForeground(YELLOW);
        btnPista.setBorderPainted(false);
        btnPista.setFocusPainted(false);
        btnPista.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        btnPista.addActionListener(e -> mostrarPista());

        btnAccion = boton("Responder", ACCENT);
        btnAccion.addActionListener(e -> onAccion());

        footer.add(btnPista,  BorderLayout.WEST);
        footer.add(btnAccion, BorderLayout.EAST);
        add(footer, BorderLayout.SOUTH);
    }

    // ── Flujo ─────────────────────────────────────────────────────

    private void mostrarIntroduccion() {
        List<Comando> comandos = comandoService.getComandosDeNivel(nivel.getIdNivel());

        racha = 0;
        actualizarRacha();
        actualizarVidas();
        lblProgreso.setText("Introducción");
        lblFeedback.setText(" ");
        btnPista.setEnabled(false);
        btnAccion.setText("¡Comenzar!  →");
        btnAccion.setBackground(GREEN);

        lblPregunta.setText("<html><body style='width:580px'>"
            + "<b style='color:#cba6f7; font-size:14px'>  #" + nivel.getNumero() + "</b>"
            + "  &nbsp; <span style='color:#6c7086; font-size:12px'>"
            + badgeDificultad(nivel.getDificultad())
            + " &nbsp; " + tipoNombre(nivel.getTipoEjercicio()) + "</span>"
            + "</body></html>");

        panelRespuesta.removeAll();
        panelRespuesta.setLayout(new BorderLayout(0, 0));
        panelRespuesta.setMaximumSize(new Dimension(Integer.MAX_VALUE, 430));

        JPanel contenido = new JPanel();
        contenido.setLayout(new BoxLayout(contenido, BoxLayout.Y_AXIS));
        contenido.setBackground(BG);
        contenido.setBorder(new EmptyBorder(4, 0, 10, 0));

        JPanel descCard = new JPanel(new BorderLayout(0, 8));
        descCard.setBackground(new Color(33, 34, 52));
        descCard.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createMatteBorder(0, 3, 0, 0, ACCENT),
            new EmptyBorder(14, 18, 14, 18)));
        descCard.setAlignmentX(Component.LEFT_ALIGNMENT);
        descCard.setMaximumSize(new Dimension(Integer.MAX_VALUE, 9999));

        JLabel descTitle = new JLabel("📖  Descripción del nivel");
        descTitle.setFont(new Font("Monospaced", Font.BOLD, 15));
        descTitle.setForeground(ACCENT);

        JLabel descLabel = new JLabel("<html><body style='width:520px; line-height:1.6'>"
            + nivel.getDescripcion() + "</body></html>");
        descLabel.setFont(new Font("Monospaced", Font.PLAIN, 15));
        descLabel.setForeground(TEXT);

        descCard.add(descTitle, BorderLayout.NORTH);
        descCard.add(descLabel, BorderLayout.CENTER);
        contenido.add(descCard);

        if (!comandos.isEmpty()) {
            contenido.add(Box.createVerticalStrut(14));

            JLabel lblCmdTitle = new JLabel("  📚  Comandos en este nivel:");
            lblCmdTitle.setFont(new Font("Monospaced", Font.BOLD, 15));
            lblCmdTitle.setForeground(SUB);
            lblCmdTitle.setAlignmentX(Component.LEFT_ALIGNMENT);
            contenido.add(lblCmdTitle);
            contenido.add(Box.createVerticalStrut(7));

            for (Comando cmd : comandos) {
                var opciones = comandoService.getOpciones(cmd.getIdComando());
                JPanel tarjeta = construirTarjetaComando(cmd, opciones);
                tarjeta.setAlignmentX(Component.LEFT_ALIGNMENT);
                contenido.add(tarjeta);
                contenido.add(Box.createVerticalStrut(6));
            }
        }

        contenido.add(Box.createVerticalGlue());

        JScrollPane scroll = new JScrollPane(contenido);
        scroll.setBorder(null);
        scroll.getViewport().setBackground(BG);
        scroll.setHorizontalScrollBarPolicy(JScrollPane.HORIZONTAL_SCROLLBAR_NEVER);
        scroll.getVerticalScrollBar().setUnitIncrement(14);
        UiUtil.estilizarScroll(scroll);

        panelRespuesta.add(scroll, BorderLayout.CENTER);
        panelRespuesta.revalidate();
        panelRespuesta.repaint();

        for (var l : btnAccion.getActionListeners()) btnAccion.removeActionListener(l);
        btnAccion.addActionListener(e -> {
            btnAccion.setBackground(ACCENT);
            for (var l : btnAccion.getActionListeners()) btnAccion.removeActionListener(l);
            btnAccion.addActionListener(ev -> onAccion());
            mostrarEjercicio();
        });
    }

    private JPanel construirTarjetaComando(Comando cmd, List<com.learnux.models.OpcionComando> opciones) {
        JPanel card = new JPanel();
        card.setLayout(new BoxLayout(card, BoxLayout.Y_AXIS));
        card.setBackground(BG_CARD);
        card.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createLineBorder(new Color(69, 71, 90)),
            new EmptyBorder(10, 14, 10, 14)));
        card.setAlignmentX(Component.LEFT_ALIGNMENT);

        JPanel cabecera = new JPanel(new BorderLayout(10, 0));
        cabecera.setBackground(BG_CARD);
        cabecera.setAlignmentX(Component.LEFT_ALIGNMENT);
        cabecera.setMaximumSize(new Dimension(Integer.MAX_VALUE, 22));

        JLabel nombre = new JLabel("$ " + cmd.getComandoNombre());
        nombre.setFont(new Font("Monospaced", Font.BOLD, 19));
        nombre.setForeground(ACCENT);

        JLabel sint = new JLabel(cmd.getSintaxis() + "  ");
        sint.setFont(new Font("Monospaced", Font.PLAIN, 10));
        sint.setForeground(new Color(203, 166, 247));

        cabecera.add(nombre, BorderLayout.WEST);
        cabecera.add(sint,   BorderLayout.EAST);
        card.add(cabecera);
        card.add(Box.createVerticalStrut(4));

        JLabel desc = new JLabel("<html><body style='width:560px'>"
            + primeraSentencia(cmd.getDescripcion()) + "</body></html>");
        desc.setFont(new Font("Monospaced", Font.PLAIN, 17));
        desc.setForeground(TEXT);
        desc.setAlignmentX(Component.LEFT_ALIGNMENT);
        card.add(desc);

        if (!opciones.isEmpty()) {
            card.add(Box.createVerticalStrut(8));
            JLabel lblFlags = new JLabel("  Banderas:");
            lblFlags.setFont(new Font("Monospaced", Font.BOLD, 10));
            lblFlags.setForeground(SUB);
            lblFlags.setAlignmentX(Component.LEFT_ALIGNMENT);
            card.add(lblFlags);
            card.add(Box.createVerticalStrut(3));

            for (var op : opciones) {
                JPanel fila = new JPanel(new BorderLayout(8, 0));
                fila.setBackground(BG_CARD);
                fila.setAlignmentX(Component.LEFT_ALIGNMENT);
                fila.setMaximumSize(new Dimension(Integer.MAX_VALUE, 18));

                JLabel bandera = new JLabel(String.format("%-8s", op.getBandera()));
                bandera.setFont(new Font("Monospaced", Font.BOLD, 17));
                bandera.setForeground(YELLOW);
                bandera.setPreferredSize(new Dimension(70, 16));

                JLabel opDesc = new JLabel(op.getDescripcion());
                opDesc.setFont(new Font("Monospaced", Font.PLAIN, 17));
                opDesc.setForeground(new Color(180, 190, 210));

                fila.add(bandera, BorderLayout.WEST);
                fila.add(opDesc,  BorderLayout.CENTER);
                card.add(fila);
            }
        }

        return card;
    }

    private String primeraSentencia(String texto) {
        if (texto == null) return "";
        int punto = texto.indexOf('.');
        return (punto > 0) ? texto.substring(0, punto + 1) : texto;
    }

    private String badgeDificultad(String nivel) {
        if (nivel == null) return "";
        return switch (nivel.toLowerCase()) {
            case "principiante" -> "🟢 principiante";
            case "intermedio"   -> "🟡 intermedio";
            case "avanzado"     -> "🔴 avanzado";
            default -> nivel;
        };
    }

    private void mostrarEjercicio() {
        if (indice >= ejercicios.size()) { mostrarResultado(); return; }

        ddExpected.clear();
        ddPlaced.clear();
        ddChips.clear();
        ddZonaLabel.clear();
        ddZonaChip.clear();
        ddEsOrden = false;
        ddSlots.clear();
        ddSlotPlaced.clear();
        ddSlotLabel.clear();
        ddSlotChipBtn.clear();
        ddOrdenExpected.clear();
        ddEsMultiSel = false;
        ddMultiSelSelected.clear();
        ddMultiSelExpected.clear();
        ddMultiSelChips.clear();

        Ejercicio ej = ejercicios.get(indice);
        respuestaSeleccionada = null;
        fallosEjercicio = 0;
        lblFeedback.setText(" ");
        lblProgreso.setText((indice + 1) + " / " + ejercicios.size());
        lblPregunta.setText("<html><body style='width:580px'>" + ej.getPregunta() + "</body></html>");
        btnPista.setEnabled(ej.getPista() != null);
        btnAccion.setText("Responder");
        btnAccion.setBackground(ACCENT);
        btnAccion.setEnabled(true);

        construirPanelRespuesta(ej);
        panelRespuesta.revalidate();
        panelRespuesta.repaint();
    }

    private void construirPanelRespuesta(Ejercicio ej) {
        panelRespuesta.removeAll();
        List<String> opciones = ej.getOpciones();
        String tipo = ej.getTipo();

        // Forzar arco de dificultad: no terminal/teclado en niveles 1-12
        if (nivel.getNumero() <= 12 && (tipo.equals("TYPE_COMMAND") || tipo.equals("TERMINAL_SIM"))) {
            tipo = "MULTIPLE_CHOICE";
        }

        switch (tipo) {
            case "DRAG_DROP" -> {
                String rc = ej.getRespuestaCorrecta() == null ? "" : ej.getRespuestaCorrecta().trim();
                if      (rc.startsWith("{")) construirDragDropMulti(ej);
                else if (rc.startsWith("[")) construirDragDropMultiSelect(ej);
                else if (rc.contains(" "))   construirDragDropOrden(ej);
                else                         construirDragDrop(opciones);
            }
            case "MULTIPLE_CHOICE"              -> construirOpciones(opciones);
            case "FILL_BLANK"                   -> construirCombo(opciones);
            case "TYPE_COMMAND", "TERMINAL_SIM" -> construirTerminal(ej);
            default                             -> {
                if (opciones != null && !opciones.isEmpty()) construirOpciones(opciones);
                else construirTerminal(ej);
            }
        }
    }

    // ── DRAG_DROP simple ─────────────────────────────────────────

    private void construirDragDrop(List<String> opciones) {
        opciones = new ArrayList<>(opciones);
        Collections.shuffle(opciones);
        panelRespuesta.setLayout(new BorderLayout(0, 14));

        JPanel dropZone = new JPanel(new BorderLayout());
        dropZone.setPreferredSize(new Dimension(620, 76));
        dropZone.setMaximumSize(new Dimension(Integer.MAX_VALUE, 76));
        dropZone.setBackground(BG_DROP);
        dropZone.setBorder(BorderFactory.createDashedBorder(SUB, 2.0f, 6.0f, 3.0f, false));

        JLabel lblDrop = new JLabel("↓  Arrastra aquí, o haz clic en una opción", SwingConstants.CENTER);
        lblDrop.setFont(new Font("Monospaced", Font.PLAIN, 15));
        lblDrop.setForeground(SUB);
        dropZone.add(lblDrop, BorderLayout.CENTER);

        JButton chipZona = new JButton();
        chipZona.setFont(new Font("Monospaced", Font.BOLD, 17));
        chipZona.setBackground(new Color(45, 65, 105));
        chipZona.setForeground(ACCENT);
        chipZona.setBorderPainted(true);
        chipZona.setFocusPainted(false);
        chipZona.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createLineBorder(ACCENT, 1),
            new EmptyBorder(8, 24, 8, 24)));
        chipZona.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        chipZona.setToolTipText("Clic para cambiar respuesta");

        JPanel chips = new JPanel(new FlowLayout(FlowLayout.CENTER, 10, 6));
        chips.setBackground(BG);
        chips.setOpaque(true);

        new DropTarget(dropZone, DnDConstants.ACTION_COPY, new DropTargetAdapter() {
            @Override public void dragEnter(DropTargetDragEvent e) {
                e.acceptDrag(DnDConstants.ACTION_COPY);
                if (respuestaSeleccionada == null) {
                    dropZone.setBackground(new Color(44, 62, 98));
                    dropZone.setBorder(BorderFactory.createLineBorder(ACCENT, 2));
                }
            }
            @Override public void dragOver(DropTargetDragEvent e) { e.acceptDrag(DnDConstants.ACTION_COPY); }
            @Override public void dragExit(DropTargetEvent e) {
                if (respuestaSeleccionada == null) resetZona(dropZone);
            }
            @Override public void drop(DropTargetDropEvent e) {
                try {
                    e.acceptDrop(DnDConstants.ACTION_COPY);
                    String v = (String) e.getTransferable().getTransferData(DataFlavor.stringFlavor);
                    colocarEnZona(dropZone, lblDrop, chipZona, v, chips);
                    e.dropComplete(true);
                } catch (Exception ex) { e.dropComplete(false); }
            }
        });

        chipZona.addActionListener(e -> limpiarZona(dropZone, lblDrop, chipZona, chips));

        for (String op : opciones) {
            chips.add(crearChipSimple(op, dropZone, lblDrop, chipZona, chips));
        }

        panelRespuesta.add(dropZone, BorderLayout.NORTH);
        panelRespuesta.add(chips,    BorderLayout.CENTER);
    }

    private JButton crearChipSimple(String texto, JPanel dropZone, JLabel lblDrop, JButton chipZona, JPanel chips) {
        JButton chip = new JButton(texto);
        chip.setFont(new Font("Monospaced", Font.BOLD, 19));
        chip.setBackground(BG_CARD);
        chip.setForeground(TEXT);
        chip.setBorderPainted(false);
        chip.setFocusPainted(false);
        chip.setBorder(new EmptyBorder(9, 18, 9, 18));
        chip.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));

        chip.addActionListener(e -> colocarEnZona(dropZone, lblDrop, chipZona, texto, chips));

        chip.setTransferHandler(new TransferHandler() {
            @Override public int getSourceActions(JComponent c) { return COPY; }
            @Override protected Transferable createTransferable(JComponent c) { return new StringSelection(texto); }
        });
        chip.addMouseMotionListener(new MouseMotionAdapter() {
            @Override public void mouseDragged(MouseEvent e) {
                chip.getTransferHandler().exportAsDrag(chip, e, TransferHandler.COPY);
            }
        });
        chip.addMouseListener(new MouseAdapter() {
            @Override public void mouseEntered(MouseEvent e) {
                if (!texto.equals(respuestaSeleccionada)) chip.setBackground(new Color(65, 67, 90));
            }
            @Override public void mouseExited(MouseEvent e) {
                if (!texto.equals(respuestaSeleccionada)) chip.setBackground(BG_CARD);
            }
        });
        return chip;
    }

    private void colocarEnZona(JPanel dropZone, JLabel lblDrop, JButton chipZona, String valor, JPanel chips) {
        respuestaSeleccionada = valor;
        dropZone.remove(lblDrop);
        chipZona.setText(valor + "   ✕");
        boolean presente = false;
        for (Component c : dropZone.getComponents()) if (c == chipZona) { presente = true; break; }
        if (!presente) dropZone.add(chipZona, BorderLayout.CENTER);
        dropZone.setBackground(new Color(28, 48, 78));
        dropZone.setBorder(BorderFactory.createLineBorder(ACCENT, 2));
        dropZone.revalidate();
        dropZone.repaint();
        for (Component c : chips.getComponents()) {
            if (c instanceof JButton b) {
                boolean sel = b.getText().equals(valor);
                b.setBackground(sel ? new Color(55, 75, 120) : new Color(40, 41, 58));
                b.setForeground(sel ? ACCENT : SUB);
            }
        }
    }

    private void limpiarZona(JPanel dropZone, JLabel lblDrop, JButton chipZona, JPanel chips) {
        respuestaSeleccionada = null;
        dropZone.remove(chipZona);
        boolean presente = false;
        for (Component c : dropZone.getComponents()) if (c == lblDrop) { presente = true; break; }
        if (!presente) dropZone.add(lblDrop, BorderLayout.CENTER);
        resetZona(dropZone);
        dropZone.revalidate();
        dropZone.repaint();
        for (Component c : chips.getComponents()) {
            if (c instanceof JButton b) { b.setBackground(BG_CARD); b.setForeground(TEXT); }
        }
    }

    private void resetZona(JPanel zona) {
        zona.setBackground(BG_DROP);
        zona.setBorder(BorderFactory.createDashedBorder(SUB, 2.0f, 6.0f, 3.0f, false));
    }

    // ── DRAG_DROP multi-par ───────────────────────────────────────

    private void construirDragDropMulti(Ejercicio ej) {
        Map<String, String> pares = UiUtil.parseJsonObjeto(ej.getRespuestaCorrecta());
        List<String> opcionesChips = ej.getOpciones();

        boolean chipsAreKeys = !opcionesChips.isEmpty() && pares.containsKey(opcionesChips.get(0));

        panelRespuesta.setLayout(new BorderLayout(0, 12));

        JPanel pairsPanel = new JPanel(new GridLayout(pares.size(), 2, 10, 8));
        pairsPanel.setBackground(BG);

        JPanel chipsPool = new JPanel(new FlowLayout(FlowLayout.CENTER, 8, 6));
        chipsPool.setBackground(BG);

        for (String op : opcionesChips) {
            JButton btn = crearChipMulti(op);
            ddChips.put(op, btn);
            chipsPool.add(btn);
        }

        for (Map.Entry<String, String> par : pares.entrySet()) {
            String labelText    = chipsAreKeys ? par.getValue() : par.getKey();
            String expectedChip = chipsAreKeys ? par.getKey()   : par.getValue();

            JLabel lbl = new JLabel("<html><body style='width:240px'>" + labelText + "</body></html>");
            lbl.setFont(new Font("Monospaced", Font.PLAIN, 15));
            lbl.setForeground(TEXT);
            lbl.setOpaque(true);
            lbl.setBackground(BG_CARD);
            lbl.setBorder(BorderFactory.createCompoundBorder(
                BorderFactory.createLineBorder(new Color(69, 71, 90)),
                new EmptyBorder(8, 12, 8, 12)));

            JPanel dropZone = new JPanel(new BorderLayout());
            dropZone.setBackground(BG_DROP);
            dropZone.setMinimumSize(new Dimension(220, 44));
            dropZone.setPreferredSize(new Dimension(240, 44));
            dropZone.setBorder(BorderFactory.createDashedBorder(SUB, 2.0f, 5.0f, 3.0f, false));

            JLabel lblVacia = new JLabel("← arrastrar aquí", SwingConstants.CENTER);
            lblVacia.setFont(new Font("Monospaced", Font.PLAIN, 17));
            lblVacia.setForeground(SUB);
            dropZone.add(lblVacia, BorderLayout.CENTER);

            JButton chipEnZona = new JButton();
            chipEnZona.setFont(new Font("Monospaced", Font.BOLD, 18));
            chipEnZona.setBackground(new Color(45, 65, 105));
            chipEnZona.setForeground(ACCENT);
            chipEnZona.setBorderPainted(true);
            chipEnZona.setFocusPainted(false);
            chipEnZona.setBorder(BorderFactory.createCompoundBorder(
                BorderFactory.createLineBorder(ACCENT),
                new EmptyBorder(5, 12, 5, 12)));
            chipEnZona.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
            chipEnZona.setToolTipText("Clic para devolver al pool");

            ddExpected.put(dropZone, expectedChip);
            ddZonaLabel.put(dropZone, lblVacia);
            ddZonaChip.put(dropZone, chipEnZona);

            new DropTarget(dropZone, DnDConstants.ACTION_COPY, new DropTargetAdapter() {
                @Override public void dragEnter(DropTargetDragEvent e) {
                    e.acceptDrag(DnDConstants.ACTION_COPY);
                    if (!ddPlaced.containsKey(dropZone)) {
                        dropZone.setBackground(new Color(44, 62, 98));
                        dropZone.setBorder(BorderFactory.createLineBorder(ACCENT, 2));
                    }
                }
                @Override public void dragOver(DropTargetDragEvent e) { e.acceptDrag(DnDConstants.ACTION_COPY); }
                @Override public void dragExit(DropTargetEvent e) {
                    if (!ddPlaced.containsKey(dropZone)) resetZona(dropZone);
                }
                @Override public void drop(DropTargetDropEvent e) {
                    try {
                        e.acceptDrop(DnDConstants.ACTION_COPY);
                        String val = (String) e.getTransferable().getTransferData(DataFlavor.stringFlavor);
                        colocarMulti(dropZone, val, chipsPool);
                        e.dropComplete(true);
                    } catch (Exception ex) { e.dropComplete(false); }
                }
            });

            chipEnZona.addActionListener(e -> devolverAlPool(dropZone, chipsPool));

            chipEnZona.setTransferHandler(new TransferHandler() {
                @Override public int getSourceActions(JComponent c) { return COPY; }
                @Override protected Transferable createTransferable(JComponent c) {
                    String val = ddPlaced.get(dropZone);
                    if (val == null) return null;
                    devolverAlPool(dropZone, chipsPool);
                    return new StringSelection(val);
                }
            });
            chipEnZona.addMouseMotionListener(new MouseMotionAdapter() {
                @Override public void mouseDragged(MouseEvent e) {
                    if (ddPlaced.containsKey(dropZone))
                        chipEnZona.getTransferHandler().exportAsDrag(chipEnZona, e, TransferHandler.COPY);
                }
            });

            pairsPanel.add(lbl);
            pairsPanel.add(dropZone);
        }

        panelRespuesta.add(pairsPanel, BorderLayout.CENTER);
        panelRespuesta.add(chipsPool,  BorderLayout.SOUTH);
    }

    private JButton crearChipMulti(String texto) {
        JButton chip = new JButton(texto);
        chip.setFont(new Font("Monospaced", Font.BOLD, 18));
        chip.setBackground(BG_CARD);
        chip.setForeground(TEXT);
        chip.setBorderPainted(false);
        chip.setFocusPainted(false);
        chip.setBorder(new EmptyBorder(7, 14, 7, 14));
        chip.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        chip.setTransferHandler(new TransferHandler() {
            @Override public int getSourceActions(JComponent c) { return COPY; }
            @Override protected Transferable createTransferable(JComponent c) { return new StringSelection(texto); }
        });
        chip.addMouseMotionListener(new MouseMotionAdapter() {
            @Override public void mouseDragged(MouseEvent e) {
                chip.getTransferHandler().exportAsDrag(chip, e, TransferHandler.COPY);
            }
        });
        chip.addMouseListener(new MouseAdapter() {
            @Override public void mouseEntered(MouseEvent e) { chip.setBackground(new Color(65, 67, 90)); }
            @Override public void mouseExited(MouseEvent e)  { chip.setBackground(BG_CARD); }
        });
        return chip;
    }

    private void colocarMulti(JPanel dropZone, String valor, JPanel chipsPool) {
        if (ddPlaced.containsKey(dropZone)) devolverAlPool(dropZone, chipsPool);
        for (JPanel otra : new ArrayList<>(ddPlaced.keySet())) {
            if (valor.equals(ddPlaced.get(otra))) { devolverAlPool(otra, chipsPool); break; }
        }

        ddPlaced.put(dropZone, valor);
        JButton chipPool = ddChips.get(valor);
        if (chipPool != null) chipPool.setVisible(false);

        JLabel lblVacia   = ddZonaLabel.get(dropZone);
        JButton chipZona  = ddZonaChip.get(dropZone);
        dropZone.remove(lblVacia);
        chipZona.setText(valor + "  ✕");
        boolean presente = false;
        for (Component c : dropZone.getComponents()) if (c == chipZona) { presente = true; break; }
        if (!presente) dropZone.add(chipZona, BorderLayout.CENTER);

        dropZone.setBackground(new Color(28, 48, 78));
        dropZone.setBorder(BorderFactory.createLineBorder(ACCENT, 2));
        dropZone.revalidate();
        dropZone.repaint();
        chipsPool.revalidate();
        chipsPool.repaint();
    }

    private void devolverAlPool(JPanel dropZone, JPanel chipsPool) {
        String val = ddPlaced.remove(dropZone);
        if (val == null) return;

        JButton chipPool = ddChips.get(val);
        if (chipPool != null) chipPool.setVisible(true);

        JLabel  lblVacia  = ddZonaLabel.get(dropZone);
        JButton chipZona  = ddZonaChip.get(dropZone);
        dropZone.remove(chipZona);
        boolean presente = false;
        for (Component c : dropZone.getComponents()) if (c == lblVacia) { presente = true; break; }
        if (!presente) dropZone.add(lblVacia, BorderLayout.CENTER);
        resetZona(dropZone);
        dropZone.revalidate();
        dropZone.repaint();
        chipsPool.revalidate();
        chipsPool.repaint();
    }

    private void bloquearMultiZonas() {
        for (Map.Entry<JPanel, String> e : ddExpected.entrySet()) {
            JPanel  zona     = e.getKey();
            String  colocado = ddPlaced.getOrDefault(zona, "");
            boolean correcto = e.getValue().equalsIgnoreCase(colocado);
            zona.setBackground(correcto ? new Color(25, 60, 35) : new Color(65, 20, 30));
            zona.setBorder(BorderFactory.createLineBorder(correcto ? GREEN : PINK, 2));
            for (Component c : zona.getComponents()) if (c instanceof JButton b) b.setEnabled(false);
        }
        for (JButton btn : ddChips.values()) btn.setEnabled(false);
    }

    // ── DRAG_DROP ordenación ─────────────────────────────────────

    private void construirDragDropOrden(Ejercicio ej) {
        ddEsOrden = true;
        String[] tokens = ej.getRespuestaCorrecta().trim().split("\\s+");
        for (String t : tokens) ddOrdenExpected.add(t);
        List<String> chipTexts = ej.getOpciones().isEmpty()
                ? new ArrayList<>(ddOrdenExpected)
                : new ArrayList<>(ej.getOpciones());
        Collections.shuffle(chipTexts);

        panelRespuesta.setLayout(new BorderLayout(0, 14));

        JPanel slotsPanel = new JPanel(new FlowLayout(FlowLayout.CENTER, 16, 8));
        slotsPanel.setBackground(BG);

        JPanel chipsPool = new JPanel(new FlowLayout(FlowLayout.CENTER, 10, 8));
        chipsPool.setBackground(BG);

        for (String texto : chipTexts) {
            JButton chip = crearChipOrden(texto, chipsPool);
            ddMultiSelChips.put(texto, chip);
            chipsPool.add(chip);
        }

        for (int i = 0; i < tokens.length; i++) {
            JPanel slot = new JPanel(new BorderLayout());
            slot.setPreferredSize(new Dimension(130, 64));
            slot.setMinimumSize(new Dimension(130, 64));
            slot.setBackground(BG_DROP);
            slot.setBorder(BorderFactory.createCompoundBorder(
                BorderFactory.createDashedBorder(SUB, 2.0f, 5.0f, 3.0f, false),
                new EmptyBorder(2, 2, 2, 2)));

            JLabel lblNum = new JLabel(String.valueOf(i + 1), SwingConstants.CENTER);
            lblNum.setFont(new Font("Monospaced", Font.BOLD, 14));
            lblNum.setForeground(SUB);
            slot.add(lblNum, BorderLayout.CENTER);

            JButton chipEnSlot = new JButton();
            chipEnSlot.setFont(new Font("Monospaced", Font.BOLD, 18));
            chipEnSlot.setBackground(new Color(45, 65, 105));
            chipEnSlot.setForeground(ACCENT);
            chipEnSlot.setBorderPainted(true);
            chipEnSlot.setFocusPainted(false);
            chipEnSlot.setBorder(BorderFactory.createCompoundBorder(
                BorderFactory.createLineBorder(ACCENT),
                new EmptyBorder(4, 8, 4, 8)));
            chipEnSlot.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
            chipEnSlot.setToolTipText("Clic para devolver");
            chipEnSlot.addActionListener(e -> devolverSlotAlPool(slot, chipsPool));

            chipEnSlot.setTransferHandler(new TransferHandler() {
                @Override public int getSourceActions(JComponent c) { return COPY; }
                @Override protected Transferable createTransferable(JComponent c) {
                    String val = ddSlotPlaced.get(slot);
                    if (val == null) return null;
                    devolverSlotAlPool(slot, chipsPool);
                    return new StringSelection(val);
                }
            });
            chipEnSlot.addMouseMotionListener(new MouseMotionAdapter() {
                @Override public void mouseDragged(MouseEvent e) {
                    if (ddSlotPlaced.containsKey(slot))
                        chipEnSlot.getTransferHandler().exportAsDrag(chipEnSlot, e, TransferHandler.COPY);
                }
            });

            ddSlots.add(slot);
            ddSlotLabel.put(slot, lblNum);
            ddSlotChipBtn.put(slot, chipEnSlot);
            slotsPanel.add(slot);
        }

        // ── Un solo DropTarget en slotsPanel: detecta slot por coordenadas ──
        final JPanel[] hoveredSlot = {null};
        new DropTarget(slotsPanel, DnDConstants.ACTION_COPY, new DropTargetAdapter() {

            private JPanel slotEnPunto(Point p) {
                for (JPanel s : ddSlots) {
                    if (s.getBounds().contains(p)) return s;
                }
                return null;
            }

            private void resaltarSlot(JPanel target) {
                if (hoveredSlot[0] != null && hoveredSlot[0] != target)
                    resetSlot(hoveredSlot[0]);
                hoveredSlot[0] = target;
                if (target != null && !ddSlotPlaced.containsKey(target)) {
                    target.setBackground(new Color(44, 62, 98));
                    target.setBorder(BorderFactory.createCompoundBorder(
                        BorderFactory.createLineBorder(ACCENT, 2),
                        new EmptyBorder(2, 2, 2, 2)));
                }
            }

            @Override public void dragEnter(DropTargetDragEvent e) {
                e.acceptDrag(DnDConstants.ACTION_COPY);
                resaltarSlot(slotEnPunto(e.getLocation()));
            }
            @Override public void dragOver(DropTargetDragEvent e) {
                e.acceptDrag(DnDConstants.ACTION_COPY);
                resaltarSlot(slotEnPunto(e.getLocation()));
            }
            @Override public void dragExit(DropTargetEvent e) {
                if (hoveredSlot[0] != null) { resetSlot(hoveredSlot[0]); hoveredSlot[0] = null; }
            }
            @Override public void drop(DropTargetDropEvent e) {
                try {
                    e.acceptDrop(DnDConstants.ACTION_COPY);
                    if (hoveredSlot[0] != null) { resetSlot(hoveredSlot[0]); hoveredSlot[0] = null; }
                    String val = (String) e.getTransferable().getTransferData(DataFlavor.stringFlavor);
                    JPanel target = slotEnPunto(e.getLocation());
                    if (target != null) { colocarEnSlot(target, val, chipsPool); e.dropComplete(true); }
                    else e.dropComplete(false);
                } catch (Exception ex) { e.dropComplete(false); }
            }
        });

        panelRespuesta.add(slotsPanel, BorderLayout.CENTER);
        panelRespuesta.add(chipsPool,  BorderLayout.SOUTH);
    }

    private JButton crearChipOrden(String texto, JPanel chipsPool) {
        JButton chip = new JButton(texto);
        chip.setFont(new Font("Monospaced", Font.BOLD, 18));
        chip.setBackground(BG_CARD);
        chip.setForeground(TEXT);
        chip.setBorderPainted(false);
        chip.setFocusPainted(false);
        chip.setBorder(new EmptyBorder(7, 14, 7, 14));
        chip.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        chip.setTransferHandler(new TransferHandler() {
            @Override public int getSourceActions(JComponent c) { return COPY; }
            @Override protected Transferable createTransferable(JComponent c) { return new StringSelection(texto); }
        });
        chip.addMouseMotionListener(new MouseMotionAdapter() {
            @Override public void mouseDragged(MouseEvent e) {
                chip.getTransferHandler().exportAsDrag(chip, e, TransferHandler.COPY);
            }
        });
        chip.addMouseListener(new MouseAdapter() {
            @Override public void mouseEntered(MouseEvent e) { if (chip.isVisible()) chip.setBackground(new Color(65, 67, 90)); }
            @Override public void mouseExited(MouseEvent e)  { if (chip.isVisible()) chip.setBackground(BG_CARD); }
        });
        chip.addActionListener(e -> {
            for (JPanel slot : ddSlots) {
                if (!ddSlotPlaced.containsKey(slot)) {
                    colocarEnSlot(slot, texto, chipsPool);
                    return;
                }
            }
        });
        return chip;
    }

    private void colocarEnSlot(JPanel slot, String valor, JPanel chipsPool) {
        if (ddSlotPlaced.containsKey(slot)) devolverSlotAlPool(slot, chipsPool);
        for (JPanel otro : new ArrayList<>(ddSlotPlaced.keySet())) {
            if (valor.equals(ddSlotPlaced.get(otro))) { devolverSlotAlPool(otro, chipsPool); break; }
        }
        ddSlotPlaced.put(slot, valor);
        JButton chipPool = ddMultiSelChips.get(valor);
        if (chipPool != null) chipPool.setVisible(false);

        JLabel  lbl     = ddSlotLabel.get(slot);
        JButton chipBtn = ddSlotChipBtn.get(slot);
        slot.remove(lbl);
        chipBtn.setText(valor);
        boolean presente = false;
        for (Component c : slot.getComponents()) if (c == chipBtn) { presente = true; break; }
        if (!presente) slot.add(chipBtn, BorderLayout.CENTER);
        slot.setBackground(new Color(28, 48, 78));
        slot.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createLineBorder(ACCENT, 2),
            new EmptyBorder(2, 2, 2, 2)));
        slot.revalidate(); slot.repaint();
        chipsPool.revalidate(); chipsPool.repaint();
    }

    private void devolverSlotAlPool(JPanel slot, JPanel chipsPool) {
        String val = ddSlotPlaced.remove(slot);
        if (val == null) return;
        JButton chipPool = ddMultiSelChips.get(val);
        if (chipPool != null) chipPool.setVisible(true);
        JLabel  lbl     = ddSlotLabel.get(slot);
        JButton chipBtn = ddSlotChipBtn.get(slot);
        slot.remove(chipBtn);
        boolean presente = false;
        for (Component c : slot.getComponents()) if (c == lbl) { presente = true; break; }
        if (!presente) slot.add(lbl, BorderLayout.CENTER);
        resetSlot(slot);
        slot.revalidate(); slot.repaint();
        chipsPool.revalidate(); chipsPool.repaint();
    }

    private void resetSlot(JPanel slot) {
        slot.setBackground(BG_DROP);
        slot.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createDashedBorder(SUB, 2.0f, 5.0f, 3.0f, false),
            new EmptyBorder(2, 2, 2, 2)));
    }

    private void bloquearSlots() {
        for (int i = 0; i < ddSlots.size(); i++) {
            JPanel  slot     = ddSlots.get(i);
            String  colocado = ddSlotPlaced.getOrDefault(slot, "");
            boolean correcto = i < ddOrdenExpected.size() && ddOrdenExpected.get(i).equalsIgnoreCase(colocado);
            slot.setBackground(correcto ? new Color(25, 60, 35) : new Color(65, 20, 30));
            slot.setBorder(BorderFactory.createCompoundBorder(
                BorderFactory.createLineBorder(correcto ? GREEN : PINK, 2),
                new EmptyBorder(2, 2, 2, 2)));
            for (Component c : slot.getComponents()) if (c instanceof JButton b) b.setEnabled(false);
        }
        for (JButton btn : ddMultiSelChips.values()) btn.setEnabled(false);
    }

    // ── DRAG_DROP multi-selección ─────────────────────────────────

    private void construirDragDropMultiSelect(Ejercicio ej) {
        ddEsMultiSel = true;
        ddMultiSelExpected.addAll(UiUtil.parseJsonArray(ej.getRespuestaCorrecta()));
        List<String> opcionesTexts = ej.getOpciones().isEmpty()
                ? new ArrayList<>(ddMultiSelExpected)
                : new ArrayList<>(ej.getOpciones());

        panelRespuesta.setLayout(new BorderLayout(0, 10));

        JLabel instruccion = new JLabel("  Selecciona todas las opciones correctas (puedes elegir varias):");
        instruccion.setFont(new Font("Monospaced", Font.PLAIN, 17));
        instruccion.setForeground(SUB);

        JPanel togglesPanel = new JPanel(new FlowLayout(FlowLayout.CENTER, 8, 6));
        togglesPanel.setBackground(BG);

        for (String texto : opcionesTexts) {
            JButton btn = new JButton(texto);
            btn.setFont(new Font("Monospaced", Font.BOLD, 18));
            btn.setBackground(BG_CARD);
            btn.setForeground(TEXT);
            btn.setBorderPainted(true);
            btn.setBorder(BorderFactory.createCompoundBorder(
                BorderFactory.createLineBorder(new Color(69, 71, 90)),
                new EmptyBorder(8, 16, 8, 16)));
            btn.setFocusPainted(false);
            btn.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
            btn.addActionListener(e -> {
                if (ddMultiSelSelected.contains(texto)) {
                    ddMultiSelSelected.remove(texto);
                    btn.setBackground(BG_CARD);
                    btn.setForeground(TEXT);
                    btn.setBorder(BorderFactory.createCompoundBorder(
                        BorderFactory.createLineBorder(new Color(69, 71, 90)),
                        new EmptyBorder(8, 16, 8, 16)));
                } else {
                    ddMultiSelSelected.add(texto);
                    btn.setBackground(new Color(50, 70, 110));
                    btn.setForeground(ACCENT);
                    btn.setBorder(BorderFactory.createCompoundBorder(
                        BorderFactory.createLineBorder(ACCENT, 2),
                        new EmptyBorder(8, 16, 8, 16)));
                }
            });
            btn.addMouseListener(new MouseAdapter() {
                @Override public void mouseEntered(MouseEvent e) {
                    if (!ddMultiSelSelected.contains(texto)) btn.setBackground(new Color(65, 67, 90));
                }
                @Override public void mouseExited(MouseEvent e) {
                    if (!ddMultiSelSelected.contains(texto)) btn.setBackground(BG_CARD);
                }
            });
            ddMultiSelChips.put(texto, btn);
            togglesPanel.add(btn);
        }

        panelRespuesta.add(instruccion,   BorderLayout.NORTH);
        panelRespuesta.add(togglesPanel,  BorderLayout.CENTER);
    }

    private void bloquearMultiSel() {
        for (Map.Entry<String, JButton> e : ddMultiSelChips.entrySet()) {
            String  texto    = e.getKey();
            JButton btn      = e.getValue();
            boolean esperado = ddMultiSelExpected.contains(texto);
            boolean elegido  = ddMultiSelSelected.contains(texto);
            if (esperado && elegido) {
                btn.setBackground(new Color(25, 60, 35)); btn.setForeground(GREEN);
                btn.setBorder(BorderFactory.createCompoundBorder(
                    BorderFactory.createLineBorder(GREEN, 2), new EmptyBorder(8, 16, 8, 16)));
            } else if (esperado) {
                btn.setBackground(new Color(60, 50, 10)); btn.setForeground(YELLOW);
                btn.setBorder(BorderFactory.createCompoundBorder(
                    BorderFactory.createLineBorder(YELLOW, 2), new EmptyBorder(8, 16, 8, 16)));
            } else if (elegido) {
                btn.setBackground(new Color(65, 20, 30)); btn.setForeground(PINK);
                btn.setBorder(BorderFactory.createCompoundBorder(
                    BorderFactory.createLineBorder(PINK, 2), new EmptyBorder(8, 16, 8, 16)));
            }
            btn.setEnabled(false);
        }
    }

    // ── MULTIPLE_CHOICE ───────────────────────────────────────────

    private void construirOpciones(List<String> opciones) {
        panelRespuesta.setLayout(new GridLayout(0, 1, 0, 8));
        ButtonGroup grupo = new ButtonGroup();
        List<String> mezcladas = new ArrayList<>(opciones);
        Collections.shuffle(mezcladas);
        for (String op : mezcladas) {
            JToggleButton btn = new JToggleButton(op);
            btn.setFont(new Font("Monospaced", Font.PLAIN, 16));
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
            btn.addMouseListener(new MouseAdapter() {
                @Override public void mouseEntered(MouseEvent e) {
                    if (!btn.isSelected()) btn.setBackground(new Color(60, 62, 82));
                }
                @Override public void mouseExited(MouseEvent e) {
                    if (!btn.isSelected()) btn.setBackground(BG_CARD);
                }
            });

            grupo.add(btn);
            panelRespuesta.add(btn);
        }
    }

    // ── FILL_BLANK ────────────────────────────────────────────────

    private void construirCombo(List<String> opciones) {
        panelRespuesta.setLayout(new FlowLayout(FlowLayout.LEFT, 0, 0));
        List<String> mezcladas = new ArrayList<>(opciones);
        Collections.shuffle(mezcladas);
        JComboBox<String> combo = new JComboBox<>(mezcladas.toArray(new String[0]));
        combo.setFont(new Font("Monospaced", Font.PLAIN, 17));
        combo.setBackground(BG_CARD);
        combo.setForeground(TEXT);
        combo.setPreferredSize(new Dimension(340, 38));
        combo.addActionListener(e -> respuestaSeleccionada = (String) combo.getSelectedItem());
        respuestaSeleccionada = mezcladas.isEmpty() ? null : mezcladas.get(0);
        panelRespuesta.add(combo);
    }

    // ── TYPE_COMMAND / TERMINAL_SIM ───────────────────────────────

    private void construirTerminal(Ejercicio ej) {
        panelRespuesta.setLayout(new BorderLayout(0, 8));

        JPanel terminalBox = new JPanel();
        terminalBox.setLayout(new BoxLayout(terminalBox, BoxLayout.Y_AXIS));
        terminalBox.setBackground(new Color(10, 10, 16));
        terminalBox.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createLineBorder(new Color(69, 71, 90), 1),
            new EmptyBorder(12, 12, 12, 12)));

        if ("TERMINAL_SIM".equals(ej.getTipo()) && ej.getSalidaSimulada() != null) {
            JTextArea salida = new JTextArea(ej.getSalidaSimulada());
            salida.setFont(new Font("Monospaced", Font.PLAIN, 16));
            salida.setBackground(new Color(10, 10, 16));
            salida.setForeground(new Color(140, 140, 160));
            salida.setEditable(false);
            salida.setLineWrap(true);
            salida.setWrapStyleWord(true);
            terminalBox.add(salida);
            terminalBox.add(Box.createVerticalStrut(10));
        }

        JPanel inputRow = new JPanel(new BorderLayout(10, 0));
        inputRow.setBackground(new Color(10, 10, 16));
        inputRow.setMaximumSize(new Dimension(Integer.MAX_VALUE, 30));

        JLabel prompt = new JLabel("user@learnux:~$");
        prompt.setFont(new Font("Monospaced", Font.BOLD, 16));
        prompt.setForeground(GREEN);

        JTextField campo = new JTextField();
        campo.setFont(new Font("Monospaced", Font.PLAIN, 16));
        campo.setBackground(new Color(10, 10, 16));
        campo.setForeground(TEXT);
        campo.setCaretColor(ACCENT);
        campo.setBorder(null);
        campo.getDocument().addDocumentListener(new javax.swing.event.DocumentListener() {
            public void changedUpdate(javax.swing.event.DocumentEvent e) { respuestaSeleccionada = campo.getText(); }
            public void insertUpdate(javax.swing.event.DocumentEvent e)  { respuestaSeleccionada = campo.getText(); }
            public void removeUpdate(javax.swing.event.DocumentEvent e)  { respuestaSeleccionada = campo.getText(); }
        });
        campo.addActionListener(e -> onAccion());

        inputRow.add(prompt, BorderLayout.WEST);
        inputRow.add(campo,  BorderLayout.CENTER);
        terminalBox.add(inputRow);

        panelRespuesta.add(terminalBox, BorderLayout.CENTER);
        
        // Foco automático al campo
        SwingUtilities.invokeLater(() -> campo.requestFocusInWindow());
    }

    // ── Evaluación ────────────────────────────────────────────────

    private void onAccion() {
        if ("Siguiente →".equals(btnAccion.getText())) { indice++; transicionarEjercicio(); return; }
        if ("Finalizar".equals(btnAccion.getText()))   { mostrarResultado(); return; }

        Ejercicio ej = ejercicios.get(indice);
        boolean ok;

        if (!ddExpected.isEmpty()) {
            if (ddPlaced.size() < ddExpected.size()) {
                lblFeedback.setForeground(YELLOW);
                lblFeedback.setText("⚠  Arrastra todas las opciones antes de responder.");
                return;
            }
            boolean todoCorrecto = ddExpected.entrySet().stream()
                .allMatch(e -> e.getValue().equalsIgnoreCase(ddPlaced.getOrDefault(e.getKey(), "")));
            respuestaSeleccionada = todoCorrecto ? ej.getRespuestaCorrecta() : "__INCORRECTO__";
            ok = nivelService.registrarIntento(usuario.getIdUsuario(), ej, respuestaSeleccionada, null);
            lblFeedback.setForeground(ok ? GREEN : PINK);
            lblFeedback.setText(ok ? "✔  ¡Correcto! Todos los pares coinciden."
                                   : "✘  Algunos pares no coinciden, reintenta.");
            if (ok) {
                bloquearMultiZonas();
            } else {
                for (Map.Entry<JPanel, String> entry : ddExpected.entrySet()) {
                    JPanel zona = entry.getKey();
                    String colocado = ddPlaced.getOrDefault(zona, "");
                    if (!entry.getValue().equalsIgnoreCase(colocado)) {
                        UiUtil.marcarError(zona);
                    }
                }
            }

        } else if (ddEsOrden) {
            if (ddSlotPlaced.size() < ddSlots.size()) {
                lblFeedback.setForeground(YELLOW);
                lblFeedback.setText("⚠  Rellena todos los espacios antes de responder.");
                return;
            }
            boolean todoCorrecto = true;
            for (int i = 0; i < ddSlots.size(); i++) {
                String colocado = ddSlotPlaced.getOrDefault(ddSlots.get(i), "");
                if (!ddOrdenExpected.get(i).equalsIgnoreCase(colocado)) { todoCorrecto = false; break; }
            }
            String ordenado = ddSlots.stream()
                    .map(s -> ddSlotPlaced.getOrDefault(s, "")).collect(Collectors.joining(" "));
            respuestaSeleccionada = todoCorrecto ? ej.getRespuestaCorrecta() : ordenado;
            ok = nivelService.registrarIntento(usuario.getIdUsuario(), ej, respuestaSeleccionada, null);
            lblFeedback.setForeground(ok ? GREEN : PINK);
            lblFeedback.setText(ok ? "✔  ¡Correcto! Orden perfecto."
                                   : "✘  El orden no es correcto, reintenta.");
            if (ok) bloquearSlots();

        } else if (ddEsMultiSel) {
            if (ddMultiSelSelected.isEmpty()) {
                lblFeedback.setForeground(YELLOW);
                lblFeedback.setText("⚠  Selecciona al menos una opción.");
                return;
            }
            boolean todoCorrecto = ddMultiSelSelected.equals(ddMultiSelExpected);
            respuestaSeleccionada = todoCorrecto ? ej.getRespuestaCorrecta() : "__INCORRECTO__";
            ok = nivelService.registrarIntento(usuario.getIdUsuario(), ej, respuestaSeleccionada, null);
            lblFeedback.setForeground(ok ? GREEN : PINK);
            lblFeedback.setText(ok ? "✔  ¡Correcto! Selección perfecta."
                                   : "✘  Selección incorrecta, reintenta.");
            if (ok) bloquearMultiSel();

        } else {
            if (respuestaSeleccionada == null || respuestaSeleccionada.isBlank()) {
                lblFeedback.setForeground(YELLOW);
                lblFeedback.setText("⚠  Selecciona o escribe una respuesta.");
                return;
            }
            ok = nivelService.registrarIntento(usuario.getIdUsuario(), ej, respuestaSeleccionada, null);
            lblFeedback.setForeground(ok ? GREEN : PINK);
            lblFeedback.setText(ok ? "✔  ¡Correcto!" : "✘  Incorrecto, vuelve a intentarlo.");
            if (ok) bloquearOpciones(ej);
        }

        if (ok) {
            aciertos++;
            racha++;
            SoundPlayer.playCorrect();
            if (ej.getIdComando() != null) {
                try { progresoService.registrarPractica(usuario.getIdUsuario(), ej.getIdComando(), false); }
                catch (ServiceException ignored) {}
            }
            actualizarRacha();
            btnAccion.setText(indice < ejercicios.size() - 1 ? "Siguiente →" : "Finalizar");
            btnAccion.setBackground(GREEN);
        } else {
            racha = 0;
            vidas--;
            fallosEjercicio++;
            actualizarVidas();
            SoundPlayer.playWrong();
            shakeComponent(panelRespuesta);
            actualizarRacha();
            if (vidas <= 0) {
                lblFeedback.setText(lblFeedback.getText() + "   ☠  ¡Sin vidas!");
                btnAccion.setEnabled(false);
                javax.swing.Timer delay = new javax.swing.Timer(900, e -> {
                    ((javax.swing.Timer) e.getSource()).stop();
                    mostrarGameOver();
                });
                delay.setRepeats(false);
                delay.start();
            } else if (fallosEjercicio >= 2 && ej.getPista() != null) {
                lblFeedback.setForeground(YELLOW);
                lblFeedback.setText("💡 Pista: " + ej.getPista());
            }
            // btnAccion permanece "Responder" para reintentar
        }
    }

    private void bloquearOpciones(Ejercicio ej) {
        for (Component c : panelRespuesta.getComponents()) {
            if (c instanceof JToggleButton btn) {
                boolean esCorrecta  = btn.getText().equalsIgnoreCase(ej.getRespuestaCorrecta());
                boolean seleccionada = btn.isSelected();
                
                Color colorBorde = esCorrecta ? GREEN : (seleccionada ? PINK : new Color(69,71,90));
                int grosor = (esCorrecta || seleccionada) ? 2 : 1;
                
                btn.setBorder(BorderFactory.createCompoundBorder(
                    BorderFactory.createLineBorder(colorBorde, grosor),
                    new EmptyBorder(10, 14, 10, 14)));
                
                if (esCorrecta)        { btn.setBackground(new Color(30, 65, 40)); btn.setForeground(GREEN); }
                else if (seleccionada) { btn.setBackground(new Color(70, 25, 35)); btn.setForeground(PINK); }
                btn.setEnabled(false);
            } else if (c instanceof JPanel inner) {
                for (Component ic : inner.getComponents()) if (ic instanceof JButton b) b.setEnabled(false);
            }
        }
    }

    private void mostrarPista() {
        Ejercicio ej = ejercicios.get(indice);
        if (ej.getPista() != null) {
            lblFeedback.setForeground(YELLOW);
            lblFeedback.setText("💡 " + ej.getPista());
        }
    }

    // ── Resultado inline (sin JDialog) ────────────────────────────

    private void mostrarResultado() {
        int total = ejercicios.size();
        int pct   = total > 0 ? (aciertos * 100 / total) : 0;
        boolean paso = pct >= nivel.getPuntosParaPasar();

        if (paso && onSuperado != null) onSuperado.run();
        if (paso) SoundPlayer.playLevelPass(); else SoundPlayer.playWrong();

        // Reemplazar contenido del panel con la pantalla de resultado
        removeAll();
        setLayout(new BorderLayout());

        // ── Confetti ─────────────────────────────────────────────
        final int NC = paso ? 55 : 0;
        final float[][] pts = new float[NC][8];
        final Random rndC = new Random();
        if (paso) {
            Color[] cc = {GREEN, YELLOW, ACCENT, new Color(203,166,247), PINK};
            for (int i = 0; i < NC; i++) {
                pts[i][0] = rndC.nextInt(900);
                pts[i][1] = -rndC.nextInt(90);
                pts[i][2] = 4 + rndC.nextInt(7);
                pts[i][3] = 1.2f + rndC.nextFloat() * 2.2f;
                pts[i][4] = (rndC.nextFloat() - 0.5f) * 1.6f;
                Color c = cc[rndC.nextInt(cc.length)];
                pts[i][5] = c.getRed(); pts[i][6] = c.getGreen(); pts[i][7] = c.getBlue();
            }
        }

        // ── Banner superior ───────────────────────────────────────
        JPanel banner = new JPanel() {
            @Override protected void paintComponent(Graphics g) {
                super.paintComponent(g);
                if (NC == 0) return;
                Graphics2D g2 = (Graphics2D) g.create();
                for (float[] p : pts) {
                    g2.setColor(new Color((int)p[5], (int)p[6], (int)p[7], 210));
                    g2.fillRect((int)p[0], (int)p[1], (int)p[2], (int)p[2]);
                }
                g2.dispose();
            }
        };
        banner.setLayout(new BoxLayout(banner, BoxLayout.Y_AXIS));
        banner.setBackground(paso ? new Color(18, 30, 60) : new Color(48, 22, 34));
        banner.setBorder(new EmptyBorder(40, 30, 30, 30));

        JLabel icono = new JLabel(paso ? "🎉" : "📘", SwingConstants.CENTER);
        icono.setFont(new Font("Monospaced", Font.PLAIN, 54));
        icono.setAlignmentX(Component.CENTER_ALIGNMENT);

        JLabel tituloRes = new JLabel(paso ? "¡Nivel Superado!" : "Sigue Practicando");
        tituloRes.setFont(new Font("Monospaced", Font.BOLD, 42));
        tituloRes.setForeground(paso ? ACCENT : YELLOW);
        tituloRes.setAlignmentX(Component.CENTER_ALIGNMENT);

        JLabel nivelNombre = new JLabel(nivel.getNombre());
        nivelNombre.setFont(new Font("Monospaced", Font.PLAIN, 15));
        nivelNombre.setForeground(SUB);
        nivelNombre.setAlignmentX(Component.CENTER_ALIGNMENT);

        banner.add(icono);
        banner.add(Box.createVerticalStrut(10));
        banner.add(tituloRes);
        banner.add(Box.createVerticalStrut(6));
        banner.add(nivelNombre);
        add(banner, BorderLayout.NORTH);

        // ── Stats ─────────────────────────────────────────────────
        JPanel stats = new JPanel();
        stats.setLayout(new BoxLayout(stats, BoxLayout.Y_AXIS));
        stats.setBackground(BG_CARD);
        stats.setBorder(new EmptyBorder(40, 80, 40, 80));

        JLabel lblScore = new JLabel("Aciertos:  " + aciertos + " / " + total);
        lblScore.setFont(new Font("Monospaced", Font.BOLD, 22));
        lblScore.setForeground(TEXT);
        lblScore.setAlignmentX(Component.CENTER_ALIGNMENT);

        JProgressBar barra = new JProgressBar(0, total);
        barra.setValue(0);
        barra.setStringPainted(true);
        barra.setString("  " + aciertos + " / " + total);
        barra.setForeground(paso ? ACCENT : YELLOW);
        barra.setBackground(BG_HDR);
        barra.setBorderPainted(false);
        barra.setMaximumSize(new Dimension(Integer.MAX_VALUE, 32));
        barra.setAlignmentX(Component.LEFT_ALIGNMENT);
        barra.setFont(new Font("Monospaced", Font.BOLD, 16));

        JLabel lblExtra = new JLabel(
            paso ? "+" + nivel.getPuntosRecompensa() + " puntos ganados  ✔"
                 : "Necesitas completar todos los ejercicios para superar el nivel");
        lblExtra.setFont(new Font("Monospaced", Font.PLAIN, 16));
        lblExtra.setForeground(paso ? ACCENT : PINK);
        lblExtra.setAlignmentX(Component.CENTER_ALIGNMENT);

        stats.add(lblScore);
        stats.add(Box.createVerticalStrut(20));
        stats.add(barra);
        stats.add(Box.createVerticalStrut(16));
        stats.add(lblExtra);

        if (paso) {
            stats.add(Box.createVerticalStrut(22));
            JPanel fraseCard = new JPanel(new BorderLayout(10, 0));
            fraseCard.setBackground(new Color(38, 40, 62));
            fraseCard.setBorder(BorderFactory.createCompoundBorder(
                BorderFactory.createMatteBorder(0, 3, 0, 0, new Color(203, 166, 247)),
                new EmptyBorder(12, 16, 12, 16)));
            fraseCard.setAlignmentX(Component.LEFT_ALIGNMENT);
            fraseCard.setMaximumSize(new Dimension(Integer.MAX_VALUE, 9999));
            JLabel icFrase = new JLabel("✨");
            icFrase.setFont(new Font("Monospaced", Font.PLAIN, 22));
            JLabel lblFrase = new JLabel("<html><body style='width:480px'>"
                + siguienteFrase()
                + "</body></html>");
            lblFrase.setFont(new Font("Monospaced", Font.ITALIC, 15));
            lblFrase.setForeground(new Color(203, 166, 247));
            fraseCard.add(icFrase,  BorderLayout.WEST);
            fraseCard.add(lblFrase, BorderLayout.CENTER);
            stats.add(fraseCard);
        }

        add(stats, BorderLayout.CENTER);

        // ── Footer ────────────────────────────────────────────────
        JPanel footer = new JPanel(new FlowLayout(FlowLayout.CENTER, 20, 20));
        footer.setBackground(BG_HDR);

        JButton btnVolver = boton(paso ? "Volver a niveles" : "Volver al menú", new Color(69, 71, 90));
        btnVolver.setForeground(TEXT);
        btnVolver.addActionListener(e -> { if (onCerrar != null) onCerrar.run(); });
        footer.add(btnVolver);

        // Solo permitir avanzar al siguiente si se superó el nivel EN ESTA SESIÓN
        if (paso && onSiguiente != null) {
            JButton btnSig = boton("Siguiente Nivel  →", ACCENT);
            btnSig.addActionListener(e -> onSiguiente.run());
            footer.add(btnSig);
        }

        add(footer, BorderLayout.SOUTH);

        revalidate();
        repaint();

        // Animación de barra (de 0 a aciertos)
        int[] frame = {0};
        javax.swing.Timer anim = new javax.swing.Timer(120, null);
        anim.addActionListener(e -> {
            frame[0] = Math.min(frame[0] + 1, aciertos);
            barra.setValue(frame[0]);
            if (frame[0] >= aciertos) ((javax.swing.Timer) e.getSource()).stop();
        });
        anim.start();

        // Confetti
        if (NC > 0) {
            javax.swing.Timer confAnim = new javax.swing.Timer(30, null);
            confAnim.addActionListener(e -> {
                for (float[] p : pts) {
                    p[1] += p[3]; p[0] += p[4];
                    if (p[1] > banner.getHeight()) {
                        p[1] = -rndC.nextInt(30);
                        p[0] = rndC.nextInt(Math.max(1, banner.getWidth()));
                    }
                }
                banner.repaint();
            });
            confAnim.start();
        }
    }

    // ── Overlay fade (transición) ─────────────────────────────────

    @Override
    protected void paintChildren(Graphics g) {
        super.paintChildren(g);
        if (fadeAlpha > 0f) {
            Graphics2D g2 = (Graphics2D) g.create();
            g2.setComposite(AlphaComposite.SrcOver.derive(fadeAlpha));
            g2.setColor(BG);
            g2.fillRect(0, 0, getWidth(), getHeight());
            g2.dispose();
        }
    }

    private void transicionarEjercicio() {
        btnAccion.setEnabled(false);
        float[] a = {0f};
        javax.swing.Timer fadeOut = new javax.swing.Timer(14, null);
        fadeOut.addActionListener(e -> {
            a[0] = Math.min(a[0] + 0.18f, 1f);
            fadeAlpha = a[0];
            repaint();
            if (a[0] >= 1f) {
                ((javax.swing.Timer) e.getSource()).stop();
                mostrarEjercicio();
                javax.swing.Timer fadeIn = new javax.swing.Timer(14, null);
                fadeIn.addActionListener(ev -> {
                    a[0] = Math.max(a[0] - 0.18f, 0f);
                    fadeAlpha = a[0];
                    repaint();
                    if (a[0] <= 0f) {
                        fadeAlpha = 0f;
                        ((javax.swing.Timer) ev.getSource()).stop();
                    }
                });
                fadeIn.start();
            }
        });
        fadeOut.start();
    }

    // ── Vidas ─────────────────────────────────────────────────────

    private void actualizarVidas() {
        if (lblVidas == null) return;
        String llenas = "♥".repeat(Math.max(0, vidas));
        String vacias = "♡".repeat(Math.max(0, 3 - vidas));
        lblVidas.setText(llenas + vacias);
        lblVidas.setForeground(vidas > 1 ? PINK : new Color(230, 50, 50));
    }

    private void mostrarGameOver() {
        SoundPlayer.playGameOver();
        removeAll();
        setLayout(new BorderLayout());

        Ejercicio ejFallo = (indice < ejercicios.size()) ? ejercicios.get(indice) : null;

        JPanel centro = new JPanel();
        centro.setLayout(new BoxLayout(centro, BoxLayout.Y_AXIS));
        centro.setBackground(BG);
        centro.setBorder(new EmptyBorder(30, 80, 20, 80));

        JLabel icono = new JLabel("💔", SwingConstants.CENTER);
        icono.setFont(new Font("Monospaced", Font.PLAIN, 64));
        icono.setAlignmentX(Component.CENTER_ALIGNMENT);

        JLabel titulo = new JLabel("Sin vidas");
        titulo.setFont(new Font("Monospaced", Font.BOLD, 30));
        titulo.setForeground(PINK);
        titulo.setAlignmentX(Component.CENTER_ALIGNMENT);

        JLabel sub = new JLabel("Llegaste a " + aciertos + " acierto" + (aciertos != 1 ? "s" : "") + " antes de quedarte sin vidas.");
        sub.setFont(new Font("Monospaced", Font.PLAIN, 16));
        sub.setForeground(SUB);
        sub.setAlignmentX(Component.CENTER_ALIGNMENT);

        centro.add(icono);
        centro.add(Box.createVerticalStrut(14));
        centro.add(titulo);
        centro.add(Box.createVerticalStrut(8));
        centro.add(sub);
        centro.add(Box.createVerticalStrut(26));

        // ── Tarjeta con la respuesta correcta + explicación ─────
        if (ejFallo != null) {
            JPanel card = new JPanel();
            card.setLayout(new BoxLayout(card, BoxLayout.Y_AXIS));
            card.setBackground(BG_CARD);
            card.setBorder(BorderFactory.createCompoundBorder(
                BorderFactory.createMatteBorder(0, 4, 0, 0, GREEN),
                new EmptyBorder(18, 22, 18, 22)));
            card.setAlignmentX(Component.CENTER_ALIGNMENT);
            card.setMaximumSize(new Dimension(720, 9999));

            JLabel lblTit = new JLabel("📝  La respuesta correcta era:");
            lblTit.setFont(new Font("Monospaced", Font.BOLD, 16));
            lblTit.setForeground(SUB);
            lblTit.setAlignmentX(Component.LEFT_ALIGNMENT);

            JLabel lblResp = new JLabel("<html><body>" + ejFallo.getRespuestaCorrecta() + "</body></html>");
            lblResp.setFont(new Font("Monospaced", Font.BOLD, 22));
            lblResp.setForeground(GREEN);
            lblResp.setAlignmentX(Component.LEFT_ALIGNMENT);

            card.add(lblTit);
            card.add(Box.createVerticalStrut(8));
            card.add(lblResp);

            if (ejFallo.getPista() != null && !ejFallo.getPista().isBlank()) {
                JLabel lblExpTit = new JLabel("💡  Por qué:");
                lblExpTit.setFont(new Font("Monospaced", Font.BOLD, 16));
                lblExpTit.setForeground(SUB);
                lblExpTit.setAlignmentX(Component.LEFT_ALIGNMENT);

                JLabel lblExp = new JLabel("<html><body style='width:660px; line-height:1.5'>"
                    + ejFallo.getPista() + "</body></html>");
                lblExp.setFont(new Font("Monospaced", Font.PLAIN, 16));
                lblExp.setForeground(TEXT);
                lblExp.setAlignmentX(Component.LEFT_ALIGNMENT);

                card.add(Box.createVerticalStrut(14));
                card.add(lblExpTit);
                card.add(Box.createVerticalStrut(6));
                card.add(lblExp);
            }

            centro.add(card);
            centro.add(Box.createVerticalStrut(30));
        }

        JButton btnReintentar = boton("↺  Reintentar nivel", PINK);
        btnReintentar.setAlignmentX(Component.CENTER_ALIGNMENT);
        btnReintentar.addActionListener(e -> {
            indice   = 0;
            aciertos = 0;
            vidas    = 3;
            racha    = 0;
            fallosEjercicio = 0;
            removeAll();
            setLayout(new BorderLayout());
            construirUI();
            mostrarIntroduccion();
            revalidate();
            repaint();
        });

        JButton btnSalir = boton("← Volver a niveles", ACCENT);
        btnSalir.setAlignmentX(Component.CENTER_ALIGNMENT);
        btnSalir.addActionListener(e -> { if (onCerrar != null) onCerrar.run(); });

        JPanel botones = new JPanel(new FlowLayout(FlowLayout.CENTER, 20, 0));
        botones.setBackground(BG);
        botones.add(btnSalir);
        botones.add(btnReintentar);
        botones.setAlignmentX(Component.CENTER_ALIGNMENT);

        centro.add(botones);
        centro.add(Box.createVerticalGlue());

        JScrollPane scroll = new JScrollPane(centro);
        scroll.setBorder(null);
        scroll.getViewport().setBackground(BG);
        scroll.setHorizontalScrollBarPolicy(JScrollPane.HORIZONTAL_SCROLLBAR_NEVER);
        scroll.getVerticalScrollBar().setUnitIncrement(14);
        UiUtil.estilizarScroll(scroll);

        add(scroll, BorderLayout.CENTER);
        revalidate();
        repaint();
    }

    // ── Helpers ──────────────────────────────────────────────────

    private JButton boton(String texto, Color color) {
        JButton btn = new JButton(texto);
        btn.setFont(UiUtil.FONT_SUB);
        btn.setBackground(color);
        btn.setForeground(BG);
        btn.setBorderPainted(false);
        btn.setFocusPainted(false);
        btn.setBorder(new EmptyBorder(9, 22, 9, 22));
        btn.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        return btn;
    }

    private String tipoIcono(String tipo) {
        if (tipo == null) return "📝";
        return switch (tipo) {
            case "DRAG_DROP"       -> "🖱";
            case "MULTIPLE_CHOICE" -> "❓";
            case "FILL_BLANK"      -> "✏";
            case "TYPE_COMMAND"    -> "⌨";
            case "TERMINAL_SIM"    -> "💻";
            default                -> "📝";
        };
    }

    private String tipoNombre(String tipo) {
        if (tipo == null) return "";
        return switch (tipo) {
            case "DRAG_DROP"       -> "Arrastra y suelta";
            case "MULTIPLE_CHOICE" -> "Opción múltiple";
            case "FILL_BLANK"      -> "Completar espacio";
            case "TYPE_COMMAND"    -> "Escribir comando";
            case "TERMINAL_SIM"    -> "Terminal simulada";
            default                -> tipo;
        };
    }

    private void actualizarRacha() {
        if (lblRacha == null) return;
        lblRacha.setText(racha >= 2 ? "🔥 " + racha : "");
    }

    private void shakeComponent(Component c) {
        Point orig = c.getLocation();
        int[] offs = {-9, 9, -7, 7, -5, 5, -3, 3, -1, 1, 0};
        int[] f = {0};
        javax.swing.Timer t = new javax.swing.Timer(28, null);
        t.addActionListener(e -> {
            if (f[0] >= offs.length) {
                c.setLocation(orig);
                ((javax.swing.Timer) e.getSource()).stop();
                return;
            }
            c.setLocation(orig.x + offs[f[0]], orig.y);
            f[0]++;
        });
        t.start();
    }
}
