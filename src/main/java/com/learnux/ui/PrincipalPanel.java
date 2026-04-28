package com.learnux.ui;

import com.learnux.models.Categoria;
import com.learnux.models.Comando;
import com.learnux.models.OpcionComando;
import com.learnux.models.Usuario;
import com.learnux.service.ComandoService;
import com.learnux.service.ServiceException;

import javax.swing.*;
import javax.swing.border.EmptyBorder;
import javax.swing.event.DocumentEvent;
import javax.swing.event.DocumentListener;
import javax.swing.table.DefaultTableModel;
import java.awt.*;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

public class PrincipalPanel extends JPanel {

    private static final Color BG_DARK  = UiUtil.BG_DARK;
    private static final Color BG_PANEL = UiUtil.BG_HDR;
    private static final Color BG_CARD  = UiUtil.BG_CARD;
    private static final Color BG_CODE  = new Color(20,  22,  38);
    private static final Color TEXT_MAIN= UiUtil.TEXT;
    private static final Color TEXT_SUB = UiUtil.SUBTEXT;
    private static final Color ACCENT   = UiUtil.BLUE;
    private static final Color GREEN    = UiUtil.GREEN;
    private static final Color YELLOW   = UiUtil.YELLOW;
    private static final Color PURPLE   = UiUtil.MAUVE;
    private static final Color PINK     = UiUtil.RED;

    private final ComandoService comandoService = new ComandoService();
    private final Usuario        usuario;

    private List<Comando> comandosActuales  = Collections.emptyList();
    private List<Comando> comandosFiltrados = Collections.emptyList();

    private ProgresoPanel  progresoPanel;
    private NivelesPanel   nivelesPanel;

    // Filtros
    private JComboBox<Categoria> cmbCategorias;
    private JComboBox<String>    cmbNivel;
    private JTextField           txtBuscar;
    private DefaultTableModel    tablaModelo;
    private JTable               tablaComandos;

    // Detalle
    private JLabel  lblNombreCmd;
    private JLabel  lblDificultad;
    private JLabel  lblSintaxis;
    private JLabel  lblDescripcion;
    private JPanel  panelFlags;
    private JLabel  lblSinFlags;

    private JTabbedPane          tabs;
    private javax.swing.Timer   typingTimer;

    public PrincipalPanel(Usuario usuario) {
        this.usuario = usuario;
        setLayout(new BorderLayout());
        setBackground(BG_DARK);
        add(construirHeader(), BorderLayout.NORTH);
        add(construirTabs(),   BorderLayout.CENTER);
        add(construirFooter(), BorderLayout.SOUTH);
        cargarCategorias();
    }

    private JPanel construirHeader() {
        JPanel h = new JPanel(new BorderLayout());
        h.setBackground(BG_PANEL);
        h.setBorder(new EmptyBorder(14, 20, 14, 20));
        JLabel logo = new JLabel("🐧 LearnUX");
        logo.setFont(new Font("Monospaced", Font.BOLD, 20));
        logo.setForeground(TEXT_MAIN);
        JLabel bien = new JLabel("Hola, " + usuario.getNombreUsuario() + " 👋");
        bien.setFont(new Font("Monospaced", Font.PLAIN, 13));
        bien.setForeground(TEXT_SUB);
        h.add(logo, BorderLayout.WEST);
        h.add(bien, BorderLayout.EAST);
        return h;
    }

    private JTabbedPane construirTabs() {
        tabs = new JTabbedPane();
        tabs.setBackground(BG_DARK);
        tabs.setForeground(TEXT_MAIN);
        tabs.setFont(UiUtil.FONT_REG);

        tabs.addTab("  📰 Noticias  ", new NoticiasPanel());
        tabs.addTab("  🔍 Explorar  ", construirPanelExplorar());
        progresoPanel = new ProgresoPanel(usuario);
        tabs.addTab("  📊 Mi Progreso  ", progresoPanel);
        nivelesPanel = new NivelesPanel(usuario);
        tabs.addTab("  🎮 Niveles  ", nivelesPanel);
        EvaluacionPanel evaluacion = new EvaluacionPanel(nivelRec -> tabs.setSelectedIndex(3));
        tabs.addTab("  📝 Diagnóstico  ", evaluacion);

        tabs.addChangeListener(e -> {
            int idx = tabs.getSelectedIndex();
            if (idx == 2) progresoPanel.cargarDatos();
            if (idx == 3) nivelesPanel.cargarNiveles();
        });
        return tabs;
    }

    private JSplitPane construirPanelExplorar() {
        JSplitPane split = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT,
                construirIzquierdo(), construirDetalle());
        split.setDividerLocation(310);
        split.setDividerSize(4);
        split.setBorder(null);
        split.setBackground(BG_DARK);
        return split;
    }

    // ── Panel izquierdo: filtros + tabla ─────────────────────────

    private JPanel construirIzquierdo() {
        JPanel panel = new JPanel(new BorderLayout(0, 8));
        panel.setBackground(BG_DARK);
        panel.setBorder(new EmptyBorder(14, 14, 14, 7));

        JPanel filtros = new JPanel();
        filtros.setLayout(new BoxLayout(filtros, BoxLayout.Y_AXIS));
        filtros.setBackground(BG_DARK);

        filtros.add(etiqueta("Buscar:"));
        filtros.add(Box.createVerticalStrut(3));
        txtBuscar = new JTextField();
        txtBuscar.setFont(UiUtil.FONT_REG);
        txtBuscar.setBackground(BG_CARD);
        txtBuscar.setForeground(TEXT_MAIN);
        txtBuscar.setCaretColor(Color.WHITE);
        txtBuscar.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createLineBorder(new Color(69, 71, 90)),
            new EmptyBorder(6, 8, 6, 8)));
        txtBuscar.setMaximumSize(new Dimension(Integer.MAX_VALUE, 36));
        txtBuscar.setAlignmentX(Component.LEFT_ALIGNMENT);
        txtBuscar.getDocument().addDocumentListener(new DocumentListener() {
            public void insertUpdate(DocumentEvent e)  { onBuscar(); }
            public void removeUpdate(DocumentEvent e)  { onBuscar(); }
            public void changedUpdate(DocumentEvent e) { onBuscar(); }
        });
        filtros.add(txtBuscar);
        filtros.add(Box.createVerticalStrut(8));

        filtros.add(etiqueta("Categoría:"));
        filtros.add(Box.createVerticalStrut(3));
        cmbCategorias = new JComboBox<>();
        estilizarCombo(cmbCategorias);
        cmbCategorias.addActionListener(e -> cargarComandos());
        filtros.add(cmbCategorias);
        filtros.add(Box.createVerticalStrut(8));

        filtros.add(etiqueta("Nivel:"));
        filtros.add(Box.createVerticalStrut(3));
        cmbNivel = new JComboBox<>(new String[]{
            "Todos", "🟢 principiante", "🟡 intermedio", "🔴 avanzado"});
        estilizarCombo(cmbNivel);
        cmbNivel.addActionListener(e -> aplicarFiltroNivel());
        filtros.add(cmbNivel);
        filtros.add(Box.createVerticalStrut(10));

        tablaModelo = new DefaultTableModel(new String[]{"Comando", "Nivel"}, 0) {
            public boolean isCellEditable(int r, int c) { return false; }
        };
        tablaComandos = new JTable(tablaModelo);
        tablaComandos.setFont(new Font("Monospaced", Font.PLAIN, 15));
        tablaComandos.setBackground(BG_CARD);
        tablaComandos.setForeground(TEXT_MAIN);
        tablaComandos.setSelectionBackground(new Color(69, 71, 90));
        tablaComandos.setSelectionForeground(ACCENT);
        tablaComandos.setGridColor(BG_DARK);
        tablaComandos.setRowHeight(34);
        tablaComandos.getTableHeader().setBackground(BG_PANEL);
        tablaComandos.getTableHeader().setForeground(TEXT_SUB);
        tablaComandos.getTableHeader().setFont(new Font("Monospaced", Font.BOLD, 13));
        tablaComandos.getSelectionModel().addListSelectionListener(e -> {
            if (!e.getValueIsAdjusting()) mostrarDetalle();
        });

        JScrollPane scroll = new JScrollPane(tablaComandos);
        scroll.getViewport().setBackground(BG_CARD);
        scroll.setBorder(BorderFactory.createLineBorder(new Color(69, 71, 90)));
        UiUtil.estilizarScroll(scroll);

        panel.add(filtros, BorderLayout.NORTH);
        panel.add(scroll,  BorderLayout.CENTER);
        return panel;
    }

    // ── Panel derecho: almanaque enriquecido ─────────────────────

    private JPanel construirDetalle() {
        JPanel panel = new JPanel(new BorderLayout(0, 0));
        panel.setBackground(BG_DARK);
        panel.setBorder(new EmptyBorder(14, 7, 14, 14));

        // Header: $ nombre + [dificultad]
        JPanel headerCmd = new JPanel(new BorderLayout());
        headerCmd.setBackground(BG_PANEL);
        headerCmd.setBorder(new EmptyBorder(12, 16, 12, 16));
        lblNombreCmd = new JLabel("← Selecciona un comando");
        lblNombreCmd.setFont(new Font("Monospaced", Font.BOLD, 21));
        lblNombreCmd.setForeground(ACCENT);
        lblDificultad = new JLabel("");
        lblDificultad.setFont(new Font("Monospaced", Font.PLAIN, 14));
        lblDificultad.setForeground(PURPLE);
        headerCmd.add(lblNombreCmd,  BorderLayout.CENTER);
        headerCmd.add(lblDificultad, BorderLayout.EAST);
        panel.add(headerCmd, BorderLayout.NORTH);

        // Contenido scrollable
        JPanel contenido = new JPanel();
        contenido.setLayout(new BoxLayout(contenido, BoxLayout.Y_AXIS));
        contenido.setBackground(BG_DARK);
        contenido.setBorder(new EmptyBorder(12, 0, 12, 0));

        // ── SINTAXIS ──────────────────────────────────────────────
        contenido.add(seccionLabel("SINTAXIS"));
        contenido.add(Box.createVerticalStrut(4));

        JPanel sintCard = new JPanel(new BorderLayout());
        sintCard.setBackground(BG_CODE);
        sintCard.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createLineBorder(new Color(69, 71, 90)),
            new EmptyBorder(11, 14, 11, 14)));
        sintCard.setAlignmentX(Component.LEFT_ALIGNMENT);
        sintCard.setMaximumSize(new Dimension(Integer.MAX_VALUE, 52));
        lblSintaxis = new JLabel(" ");
        lblSintaxis.setFont(new Font("Monospaced", Font.BOLD, 18));
        lblSintaxis.setForeground(new Color(245, 194, 231));
        sintCard.add(lblSintaxis, BorderLayout.CENTER);
        contenido.add(sintCard);
        contenido.add(Box.createVerticalStrut(12));

        // ── DESCRIPCIÓN ───────────────────────────────────────────
        contenido.add(seccionLabel("DESCRIPCIÓN"));
        contenido.add(Box.createVerticalStrut(4));

        JPanel descCard = new JPanel(new BorderLayout());
        descCard.setBackground(BG_CARD);
        descCard.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createLineBorder(new Color(69, 71, 90)),
            new EmptyBorder(12, 14, 12, 14)));
        descCard.setAlignmentX(Component.LEFT_ALIGNMENT);
        descCard.setMaximumSize(new Dimension(Integer.MAX_VALUE, 9999));
        lblDescripcion = new JLabel("<html><body style='width:360px'> </body></html>");
        lblDescripcion.setFont(new Font("Monospaced", Font.PLAIN, 15));
        lblDescripcion.setForeground(TEXT_MAIN);
        descCard.add(lblDescripcion, BorderLayout.CENTER);
        contenido.add(descCard);
        contenido.add(Box.createVerticalStrut(16));

        // ── BANDERAS & CASOS DE USO ───────────────────────────────
        contenido.add(seccionLabel("🚩  BANDERAS & CASOS DE USO"));
        contenido.add(Box.createVerticalStrut(6));

        panelFlags = new JPanel();
        panelFlags.setLayout(new BoxLayout(panelFlags, BoxLayout.Y_AXIS));
        panelFlags.setBackground(BG_DARK);
        panelFlags.setAlignmentX(Component.LEFT_ALIGNMENT);

        lblSinFlags = new JLabel("  Sin banderas registradas para este comando.");
        lblSinFlags.setFont(new Font("Monospaced", Font.ITALIC, 14));
        lblSinFlags.setForeground(TEXT_SUB);
        lblSinFlags.setAlignmentX(Component.LEFT_ALIGNMENT);
        panelFlags.add(lblSinFlags);

        contenido.add(panelFlags);
        contenido.add(Box.createVerticalGlue());

        JScrollPane scroll = new JScrollPane(contenido);
        scroll.setBorder(null);
        scroll.getViewport().setBackground(BG_DARK);
        scroll.setHorizontalScrollBarPolicy(JScrollPane.HORIZONTAL_SCROLLBAR_NEVER);
        scroll.getVerticalScrollBar().setUnitIncrement(16);
        UiUtil.estilizarScroll(scroll);
        panel.add(scroll, BorderLayout.CENTER);

        return panel;
    }

    private JLabel seccionLabel(String texto) {
        JLabel lbl = new JLabel(texto);
        lbl.setFont(new Font("Monospaced", Font.BOLD, 13));
        lbl.setForeground(TEXT_SUB);
        lbl.setAlignmentX(Component.LEFT_ALIGNMENT);
        return lbl;
    }

    private JPanel construirCardFlag(OpcionComando op) {
        JPanel card = new JPanel(new BorderLayout(12, 0));
        card.setBackground(BG_CARD);
        card.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createMatteBorder(0, 3, 0, 0, YELLOW),
            new EmptyBorder(11, 12, 11, 12)));
        card.setAlignmentX(Component.LEFT_ALIGNMENT);
        card.setMaximumSize(new Dimension(Integer.MAX_VALUE, 9999));

        // Bandera
        JLabel lblBandera = new JLabel(op.getBandera());
        lblBandera.setFont(new Font("Monospaced", Font.BOLD, 18));
        lblBandera.setForeground(YELLOW);
        lblBandera.setPreferredSize(new Dimension(84, 20));
        lblBandera.setVerticalAlignment(SwingConstants.TOP);

        // Descripción + ejemplo
        JPanel derecha = new JPanel();
        derecha.setLayout(new BoxLayout(derecha, BoxLayout.Y_AXIS));
        derecha.setBackground(BG_CARD);

        JLabel lblDesc = new JLabel("<html><body style='width:310px'>" + op.getDescripcion() + "</body></html>");
        lblDesc.setFont(new Font("Monospaced", Font.PLAIN, 15));
        lblDesc.setForeground(TEXT_MAIN);
        lblDesc.setAlignmentX(Component.LEFT_ALIGNMENT);
        derecha.add(lblDesc);

        if (op.getEjemploUso() != null && !op.getEjemploUso().isBlank()) {
            derecha.add(Box.createVerticalStrut(5));
            JLabel lblEjemplo = new JLabel("↳  $ " + op.getEjemploUso());
            lblEjemplo.setFont(new Font("Monospaced", Font.BOLD, 14));
            lblEjemplo.setForeground(ACCENT);
            lblEjemplo.setAlignmentX(Component.LEFT_ALIGNMENT);
            derecha.add(lblEjemplo);
        }

        card.add(lblBandera, BorderLayout.WEST);
        card.add(derecha,    BorderLayout.CENTER);
        return card;
    }

    private JPanel construirFooter() {
        JPanel f = new JPanel(new FlowLayout(FlowLayout.LEFT));
        f.setBackground(BG_PANEL);
        f.setBorder(new EmptyBorder(4, 14, 4, 14));
        JLabel hint = new JLabel("💡 Selecciona un comando para ver su sintaxis, descripción y todas sus banderas con ejemplos de uso");
        hint.setFont(new Font("Monospaced", Font.PLAIN, 13));
        hint.setForeground(TEXT_SUB);
        f.add(hint);
        return f;
    }

    // ── Lógica ───────────────────────────────────────────────────

    private void cargarCategorias() {
        List<Categoria> cats = comandoService.getCategorias();
        cmbCategorias.removeAllItems();
        cmbCategorias.addItem(new Categoria(0, "📋  Todos los comandos", ""));
        cats.forEach(cmbCategorias::addItem);
        cargarComandos();
    }

    private void cargarComandos() {
        Categoria cat = (Categoria) cmbCategorias.getSelectedItem();
        if (cat == null) return;
        try {
            if (cat.getIdCategoria() == 0) {
                comandosActuales = comandoService.getAllComandos();
            } else {
                comandosActuales = comandoService.getComandosPorCategoria(cat.getIdCategoria());
            }
            comandosFiltrados = comandosActuales;
            aplicarFiltroNivel();
            limpiarDetalle();
        } catch (ServiceException e) {
            JOptionPane.showMessageDialog(this, e.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void onBuscar() {
        String texto = txtBuscar.getText().trim();
        if (texto.isBlank()) { cargarComandos(); return; }
        try {
            comandosActuales  = comandoService.buscarComandos(texto);
            comandosFiltrados = comandosActuales;
            aplicarFiltroNivel();
        } catch (ServiceException e) {
            JOptionPane.showMessageDialog(this, e.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void aplicarFiltroNivel() {
        String sel = (String) cmbNivel.getSelectedItem();
        if (sel == null || sel.equals("Todos")) {
            comandosFiltrados = comandosActuales;
        } else {
            String limpio = sel.replace("🟢 ","").replace("🟡 ","").replace("🔴 ","");
            comandosFiltrados = comandosActuales.stream()
                .filter(c -> limpio.equalsIgnoreCase(c.getDificultadNivel()))
                .collect(Collectors.toList());
        }
        refrescarTabla();
    }

    private void refrescarTabla() {
        tablaModelo.setRowCount(0);
        comandosFiltrados.forEach(cmd ->
            tablaModelo.addRow(new Object[]{
                cmd.getComandoNombre(),
                badgeDificultad(cmd.getDificultadNivel())
            })
        );
        limpiarDetalle();
    }

    private void mostrarDetalle() {
        int fila = tablaComandos.getSelectedRow();
        if (fila < 0 || fila >= comandosFiltrados.size()) return;
        Comando cmd = comandosFiltrados.get(fila);

        // Typing animation for command name
        if (typingTimer != null) typingTimer.stop();
        String fullName = "$ " + cmd.getComandoNombre();
        int[] idx = {1};
        lblNombreCmd.setText("$ ");
        typingTimer = new javax.swing.Timer(38, null);
        typingTimer.addActionListener(e -> {
            idx[0]++;
            lblNombreCmd.setText(fullName.substring(0, Math.min(idx[0], fullName.length())));
            if (idx[0] >= fullName.length()) ((javax.swing.Timer) e.getSource()).stop();
        });
        typingTimer.start();

        lblDificultad.setText("  [" + cmd.getDificultadNivel() + "]  ");
        lblSintaxis.setText(cmd.getSintaxis() != null ? cmd.getSintaxis() : "—");
        lblDescripcion.setText("<html><body style='width:360px'>"
            + (cmd.getDescripcion() != null ? cmd.getDescripcion() : "—")
            + "</body></html>");

        // Reconstruir flags
        panelFlags.removeAll();
        List<OpcionComando> opciones = comandoService.getOpciones(cmd.getIdComando());
        if (opciones.isEmpty()) {
            panelFlags.add(lblSinFlags);
        } else {
            for (OpcionComando op : opciones) {
                panelFlags.add(construirCardFlag(op));
                panelFlags.add(Box.createVerticalStrut(6));
            }
        }
        panelFlags.revalidate();
        panelFlags.repaint();
    }

    private void limpiarDetalle() {
        if (typingTimer != null) { typingTimer.stop(); typingTimer = null; }
        lblNombreCmd.setText("← Selecciona un comando");
        lblDificultad.setText("");
        lblSintaxis.setText(" ");
        lblDescripcion.setText("<html><body style='width:360px'> </body></html>");
        panelFlags.removeAll();
        panelFlags.add(lblSinFlags);
        panelFlags.revalidate();
        panelFlags.repaint();
    }

    // ── Helpers ──────────────────────────────────────────────────

    private JLabel etiqueta(String texto) {
        JLabel lbl = new JLabel(texto);
        lbl.setFont(new Font("Monospaced", Font.PLAIN, 13));
        lbl.setForeground(TEXT_SUB);
        lbl.setAlignmentX(Component.LEFT_ALIGNMENT);
        return lbl;
    }

    private void estilizarCombo(JComboBox<?> combo) {
        combo.setFont(new Font("Monospaced", Font.PLAIN, 15));
        combo.setBackground(BG_CARD);
        combo.setForeground(TEXT_MAIN);
        combo.setMaximumSize(new Dimension(Integer.MAX_VALUE, 36));
        combo.setAlignmentX(Component.LEFT_ALIGNMENT);
    }

    private String badgeDificultad(String nivel) {
        if (nivel == null) return "—";
        return switch (nivel.toLowerCase()) {
            case "principiante" -> "🟢 " + nivel;
            case "intermedio"   -> "🟡 " + nivel;
            case "avanzado"     -> "🔴 " + nivel;
            default -> nivel;
        };
    }
}
