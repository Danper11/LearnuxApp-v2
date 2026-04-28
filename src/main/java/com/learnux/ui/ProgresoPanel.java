package com.learnux.ui;

import com.learnux.models.Nivel;
import com.learnux.models.Usuario;
import com.learnux.service.NivelService;

import javax.swing.*;
import javax.swing.border.EmptyBorder;
import javax.swing.table.DefaultTableCellRenderer;
import javax.swing.table.DefaultTableModel;
import java.awt.*;
import java.util.List;

public class ProgresoPanel extends JPanel {

    private static final Color BG_DARK  = new Color(30,  30,  46);
    private static final Color BG_PANEL = new Color(24,  24,  37);
    private static final Color BG_CARD  = new Color(49,  50,  68);
    private static final Color TEXT_MAIN= new Color(205, 214, 244);
    private static final Color TEXT_SUB = new Color(108, 112, 134);
    private static final Color GREEN    = new Color(166, 227, 161);
    private static final Color PINK     = new Color(243, 139, 168);
    private static final Color ACCENT   = new Color(137, 180, 250);
    private static final Color YELLOW   = new Color(249, 226, 175);
    private static final Color PURPLE   = new Color(203, 166, 247);

    private static final int TOTAL_NIVELES = 24;

    private final NivelService   nivelService   = new NivelService();
    private final Usuario        usuario;

    private JPanel           panelTarjetas;
    private DefaultTableModel tablaModelo;
    private JProgressBar     barraGeneral;
    private JLabel           lblPct;

    public ProgresoPanel(Usuario usuario) {
        this.usuario = usuario;
        setLayout(new BorderLayout(0, 10));
        setBackground(BG_DARK);
        setBorder(new EmptyBorder(14, 14, 14, 14));

        add(construirEncabezado(), BorderLayout.NORTH);
        add(construirTabla(),      BorderLayout.CENTER);

        cargarDatos();
    }

    // ── Carga / refresca todos los datos ─────────────────────────
    public void cargarDatos() {
        List<Nivel> niveles = nivelService.getNivelesConProgreso(usuario.getIdUsuario());

        long completados  = niveles.stream().filter(Nivel::isCompletado).count();
        int  puntosTotal  = niveles.stream()
                                   .filter(Nivel::isCompletado)
                                   .mapToInt(Nivel::getPuntosRecompensa)
                                   .sum();
        String siguienteNombre = niveles.stream()
            .filter(n -> n.isDesbloqueado() && !n.isCompletado())
            .findFirst()
            .map(Nivel::getNombre)
            .orElse(completados == TOTAL_NIVELES ? "¡Todo completado! 🎉" : "—");

        int pct = (int) (completados * 100L / TOTAL_NIVELES);

        // Tarjetas
        panelTarjetas.removeAll();
        final JLabel[] refs = {null, null};
        panelTarjetas.add(tarjeta("Niveles completados", "0 / " + TOTAL_NIVELES, ACCENT, l -> refs[0] = l));
        panelTarjetas.add(tarjeta("Puntos ganados",      "0 pts",                GREEN, l -> refs[1] = l));
        panelTarjetas.add(tarjeta("Siguiente nivel",     siguienteNombre,        PURPLE));
        panelTarjetas.revalidate();
        panelTarjetas.repaint();

        // Barra de progreso global — empieza en 0 y se anima
        barraGeneral.setValue(0);
        barraGeneral.setString("  Progreso general:  0%");

        // Animar contadores y barra (~600 ms, 30 ticks a 20 ms)
        final long completadosFinal = completados;
        final int  puntosF = puntosTotal;
        final int  pctF    = pct;
        int[] tick = {0};
        new javax.swing.Timer(20, null) {{
            addActionListener(e -> {
                tick[0]++;
                float t = Math.min(1f, tick[0] / 30f);
                if (refs[0] != null) refs[0].setText((long)(completadosFinal * t) + " / " + TOTAL_NIVELES);
                if (refs[1] != null) refs[1].setText((int)(puntosF * t) + " pts");
                int v = (int)(pctF * t);
                barraGeneral.setValue(v);
                barraGeneral.setString("  Progreso general:  " + v + "%");
                if (t >= 1f) ((javax.swing.Timer) e.getSource()).stop();
            });
            start();
        }};

        // Tabla de niveles
        tablaModelo.setRowCount(0);
        for (Nivel n : niveles) {
            String estado;
            if (n.isCompletado())        estado = "✔  Completado";
            else if (n.isDesbloqueado()) estado = "▶  En juego";
            else                         estado = "🔒  Bloqueado";

            int acum   = n.getPuntosAcumulados();
            int target = n.getPuntosParaPasar() > 0 ? n.getPuntosParaPasar() : 100;
            String pts = acum + " / " + target + " pts";

            tablaModelo.addRow(new Object[]{
                "#" + n.getNumero(),
                n.getNombre(),
                badgeDif(n.getDificultad()),
                estado,
                pts
            });
        }
    }

    // ── Encabezado: tarjetas + barra general ─────────────────────
    private JPanel construirEncabezado() {
        JPanel enc = new JPanel();
        enc.setLayout(new BoxLayout(enc, BoxLayout.Y_AXIS));
        enc.setBackground(BG_DARK);

        // Fila de tarjetas
        panelTarjetas = new JPanel(new GridLayout(1, 3, 10, 0));
        panelTarjetas.setBackground(BG_DARK);
        panelTarjetas.setMaximumSize(new Dimension(Integer.MAX_VALUE, 90));
        enc.add(panelTarjetas);
        enc.add(Box.createVerticalStrut(12));

        // Barra de progreso global
        barraGeneral = new JProgressBar(0, 100);
        barraGeneral.setValue(0);
        barraGeneral.setStringPainted(true);
        barraGeneral.setString("  Progreso general:  0%");
        barraGeneral.setForeground(ACCENT);
        barraGeneral.setBackground(BG_PANEL);
        barraGeneral.setBorderPainted(false);
        barraGeneral.setFont(new Font("Monospaced", Font.BOLD, 13));
        barraGeneral.setPreferredSize(new Dimension(0, 28));
        barraGeneral.setMaximumSize(new Dimension(Integer.MAX_VALUE, 28));

        lblPct = new JLabel();  // no se usa visualmente, la barra ya tiene string

        JPanel barraWrap = new JPanel(new BorderLayout());
        barraWrap.setBackground(BG_DARK);
        barraWrap.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createLineBorder(new Color(69, 71, 90)),
            new EmptyBorder(0, 0, 0, 0)));
        barraWrap.add(barraGeneral);
        enc.add(barraWrap);

        return enc;
    }

    // ── Tarjeta de estadística ────────────────────────────────────
    private JPanel tarjeta(String titulo, String valor, Color colorValor) {
        return tarjeta(titulo, valor, colorValor, null);
    }

    private JPanel tarjeta(String titulo, String valor, Color colorValor,
                           java.util.function.Consumer<JLabel> labelRef) {
        JPanel card = new JPanel(new GridBagLayout());
        card.setBackground(BG_PANEL);
        card.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createLineBorder(BG_CARD),
            new EmptyBorder(10, 14, 10, 14)));
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.gridx = 0; gbc.gridy = 0;
        JLabel lblValor = new JLabel(valor, SwingConstants.CENTER);
        lblValor.setFont(new Font("Monospaced", Font.BOLD, 18));
        lblValor.setForeground(colorValor);
        if (labelRef != null) labelRef.accept(lblValor);
        card.add(lblValor, gbc);
        gbc.gridy = 1;
        JLabel lblTitulo = new JLabel(titulo, SwingConstants.CENTER);
        lblTitulo.setFont(new Font("Monospaced", Font.PLAIN, 12));
        lblTitulo.setForeground(TEXT_SUB);
        card.add(lblTitulo, gbc);
        return card;
    }

    // ── Tabla de niveles ──────────────────────────────────────────
    private JScrollPane construirTabla() {
        tablaModelo = new DefaultTableModel(
            new String[]{"#", "Nombre", "Dificultad", "Estado", "Puntos"}, 0
        ) {
            @Override public boolean isCellEditable(int r, int c) { return false; }
        };

        JTable tabla = new JTable(tablaModelo);
        tabla.setFont(new Font("Monospaced", Font.PLAIN, 14));
        tabla.setBackground(BG_CARD);
        tabla.setForeground(TEXT_MAIN);
        tabla.setSelectionBackground(new Color(69, 71, 90));
        tabla.setSelectionForeground(ACCENT);
        tabla.setGridColor(BG_DARK);
        tabla.setRowHeight(32);
        tabla.getTableHeader().setBackground(BG_PANEL);
        tabla.getTableHeader().setForeground(TEXT_SUB);
        tabla.getTableHeader().setFont(new Font("Monospaced", Font.BOLD, 13));
        tabla.setShowVerticalLines(false);

        // Columna "#" — estrecha
        tabla.getColumnModel().getColumn(0).setMaxWidth(44);
        tabla.getColumnModel().getColumn(0).setPreferredWidth(44);

        // Columna Estado — color según valor
        tabla.getColumnModel().getColumn(3).setCellRenderer(new DefaultTableCellRenderer() {
            @Override
            public Component getTableCellRendererComponent(JTable t, Object val,
                    boolean sel, boolean foc, int row, int col) {
                super.getTableCellRendererComponent(t, val, sel, foc, row, col);
                setOpaque(true);
                setBackground(sel ? new Color(69, 71, 90) : BG_CARD);
                String txt = val != null ? val.toString() : "";
                if      (txt.startsWith("✔")) setForeground(GREEN);
                else if (txt.startsWith("▶")) setForeground(YELLOW);
                else                          setForeground(TEXT_SUB);
                setFont(new Font("Monospaced", Font.BOLD, 13));
                return this;
            }
        });

        // Columna Dificultad — color
        tabla.getColumnModel().getColumn(2).setCellRenderer(new DefaultTableCellRenderer() {
            @Override
            public Component getTableCellRendererComponent(JTable t, Object val,
                    boolean sel, boolean foc, int row, int col) {
                super.getTableCellRendererComponent(t, val, sel, foc, row, col);
                setOpaque(true);
                setBackground(sel ? new Color(69, 71, 90) : BG_CARD);
                String txt = val != null ? val.toString() : "";
                if      (txt.contains("principiante")) setForeground(GREEN);
                else if (txt.contains("intermedio"))   setForeground(YELLOW);
                else if (txt.contains("avanzado"))     setForeground(PINK);
                else                                   setForeground(TEXT_SUB);
                setFont(new Font("Monospaced", Font.PLAIN, 13));
                return this;
            }
        });

        // Columna Puntos — subdued
        tabla.getColumnModel().getColumn(4).setCellRenderer(new DefaultTableCellRenderer() {
            @Override
            public Component getTableCellRendererComponent(JTable t, Object val,
                    boolean sel, boolean foc, int row, int col) {
                super.getTableCellRendererComponent(t, val, sel, foc, row, col);
                setOpaque(true);
                setBackground(sel ? new Color(69, 71, 90) : BG_CARD);
                setForeground(TEXT_SUB);
                setFont(new Font("Monospaced", Font.PLAIN, 13));
                return this;
            }
        });

        JScrollPane scroll = new JScrollPane(tabla);
        scroll.getViewport().setBackground(BG_CARD);
        scroll.setBorder(BorderFactory.createLineBorder(BG_CARD));
        UiUtil.estilizarScroll(scroll);
        return scroll;
    }

    // ── Helpers ──────────────────────────────────────────────────
    private String badgeDif(String dif) {
        if (dif == null) return "—";
        return switch (dif.toLowerCase()) {
            case "principiante" -> "🟢 principiante";
            case "intermedio"   -> "🟡 intermedio";
            case "avanzado"     -> "🔴 avanzado";
            default             -> dif;
        };
    }
}
