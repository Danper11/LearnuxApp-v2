package com.learnux.ui;

import javax.swing.*;
import javax.swing.border.EmptyBorder;
import java.awt.*;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;

public class IntroPanel extends JPanel {

    private static final Color BG      = UiUtil.BG_DARK;
    private static final Color BG_CARD = UiUtil.BG_CARD;
    private static final Color BG_HDR  = UiUtil.BG_HDR;
    private static final Color SUB     = UiUtil.OVERLAY;
    private static final Color ACCENT  = UiUtil.BLUE;
    private static final Color GREEN   = UiUtil.GREEN;
    private static final Color YELLOW  = UiUtil.YELLOW;
    private static final Color PURPLE  = UiUtil.MAUVE;

    private final Runnable       onComenzar;
    private       JLabel         lblTitulo;
    private       JLabel         lblPunto;
    private       javax.swing.Timer typingTimer;
    private       javax.swing.Timer dotsTimer;
    private static final String  FULL_TITLE = "LearnUX";

    public IntroPanel(Runnable onComenzar) {
        this.onComenzar = onComenzar;
        setLayout(new BorderLayout());
        setBackground(BG);
        add(construirCentro(), BorderLayout.CENTER);
        add(construirFooter(), BorderLayout.SOUTH);
        iniciarAnimaciones();
    }

    // ── Centro ────────────────────────────────────────────────────

    private JPanel construirCentro() {
        JPanel centro = new JPanel();
        centro.setLayout(new BoxLayout(centro, BoxLayout.Y_AXIS));
        centro.setBackground(BG);
        centro.setBorder(new EmptyBorder(50, 100, 40, 100));

        // ── Logo ────────────────────────────────────────────────
        JPanel logoRow = new JPanel(new FlowLayout(FlowLayout.CENTER, 8, 0));
        logoRow.setBackground(BG);
        logoRow.setAlignmentX(Component.CENTER_ALIGNMENT);

        JLabel lblPinguin = new JLabel("🐧");
        lblPinguin.setFont(new Font("Monospaced", Font.PLAIN, 54));

        lblTitulo = new JLabel("");
        lblTitulo.setFont(new Font("Monospaced", Font.BOLD, 54));
        lblTitulo.setForeground(ACCENT);

        lblPunto = new JLabel("_");
        lblPunto.setFont(new Font("Monospaced", Font.BOLD, 54));
        lblPunto.setForeground(ACCENT);

        logoRow.add(lblPinguin);
        logoRow.add(lblTitulo);
        logoRow.add(lblPunto);
        centro.add(logoRow);
        centro.add(Box.createVerticalStrut(10));

        // ── Tagline ──────────────────────────────────────────────
        JLabel tagline = new JLabel("Aprende Linux de forma interactiva y gamificada");
        tagline.setFont(new Font("Monospaced", Font.PLAIN, 17));
        tagline.setForeground(SUB);
        tagline.setAlignmentX(Component.CENTER_ALIGNMENT);
        centro.add(tagline);
        centro.add(Box.createVerticalStrut(38));

        // ── Feature cards ────────────────────────────────────────
        Object[][] features = {
            {"🎮", "24 Niveles", "Desde fundamentos hasta nivel maestro, con progresión desbloqueada.", ACCENT},
            {"📚", "Enciclopedia", "Todos los comandos Linux con sintaxis, descripción y banderas de uso.", PURPLE},
            {"📊", "Tu progreso", "Estadísticas detalladas: aciertos, rachas y comandos dominados.", GREEN},
            {"🔥", "Gamificado",  "Vidas, racha de aciertos y puntos para mantenerte siempre motivado.", YELLOW},
        };

        JPanel grid = new JPanel(new GridLayout(2, 2, 14, 14));
        grid.setBackground(BG);
        grid.setMaximumSize(new Dimension(820, 220));
        grid.setAlignmentX(Component.CENTER_ALIGNMENT);

        for (Object[] f : features) {
            grid.add(crearCard((String)f[0], (String)f[1], (String)f[2], (Color)f[3]));
        }
        centro.add(grid);
        centro.add(Box.createVerticalStrut(36));

        // ── Botón Comenzar ───────────────────────────────────────
        JButton btnComenzar = crearBotonComenzar();
        btnComenzar.setAlignmentX(Component.CENTER_ALIGNMENT);
        centro.add(btnComenzar);
        centro.add(Box.createVerticalStrut(18));

        // ── Indicador animado ────────────────────────────────────
        JLabel lblDots = new JLabel("● ○ ○");
        lblDots.setFont(new Font("Monospaced", Font.PLAIN, 13));
        lblDots.setForeground(new Color(70, 74, 100));
        lblDots.setAlignmentX(Component.CENTER_ALIGNMENT);
        centro.add(lblDots);

        dotsTimer = new javax.swing.Timer(700, null);
        String[] dotPats = {"● ○ ○", "○ ● ○", "○ ○ ●"};
        int[] di = {0};
        dotsTimer.addActionListener(e -> {
            di[0] = (di[0] + 1) % 3;
            lblDots.setText(dotPats[di[0]]);
        });
        dotsTimer.start();

        return centro;
    }

    private JPanel crearCard(String icon, String titulo, String desc, Color accentColor) {
        JPanel card = new JPanel(new BorderLayout(12, 0));
        card.setBackground(BG_CARD);
        card.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createMatteBorder(0, 3, 0, 0, accentColor),
            new EmptyBorder(16, 16, 16, 16)));

        JLabel lblIcon = new JLabel(icon);
        lblIcon.setFont(new Font("Monospaced", Font.PLAIN, 30));
        lblIcon.setVerticalAlignment(SwingConstants.TOP);

        JPanel texto = new JPanel();
        texto.setLayout(new BoxLayout(texto, BoxLayout.Y_AXIS));
        texto.setBackground(BG_CARD);

        JLabel lblT = new JLabel(titulo);
        lblT.setFont(new Font("Monospaced", Font.BOLD, 16));
        lblT.setForeground(accentColor);

        JLabel lblD = new JLabel("<html><body style='width:190px'>" + desc + "</body></html>");
        lblD.setFont(new Font("Monospaced", Font.PLAIN, 13));
        lblD.setForeground(new Color(160, 165, 190));

        texto.add(lblT);
        texto.add(Box.createVerticalStrut(5));
        texto.add(lblD);

        card.add(lblIcon, BorderLayout.WEST);
        card.add(texto,   BorderLayout.CENTER);
        return card;
    }

    private JButton crearBotonComenzar() {
        JButton btn = new JButton("  Empezar ahora  →  ");
        btn.setFont(new Font("Monospaced", Font.BOLD, 21));
        btn.setBackground(ACCENT);
        btn.setForeground(BG);
        btn.setBorderPainted(false);
        btn.setFocusPainted(false);
        btn.setBorder(new EmptyBorder(14, 44, 14, 44));
        btn.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));

        btn.addMouseListener(new MouseAdapter() {
            @Override public void mouseEntered(MouseEvent e) { btn.setBackground(new Color(160, 200, 255)); }
            @Override public void mouseExited(MouseEvent e)  { btn.setBackground(ACCENT); }
        });
        btn.addActionListener(e -> {
            if (typingTimer != null) typingTimer.stop();
            if (dotsTimer  != null) dotsTimer.stop();
            onComenzar.run();
        });
        return btn;
    }

    // ── Footer ────────────────────────────────────────────────────

    private JPanel construirFooter() {
        JPanel f = new JPanel(new FlowLayout(FlowLayout.CENTER));
        f.setBackground(BG_HDR);
        f.setBorder(new EmptyBorder(7, 14, 7, 14));
        JLabel lbl = new JLabel("LearnUX v2.0  ·  Aprende Linux paso a paso  ·  🐧 Proyecto educativo");
        lbl.setFont(new Font("Monospaced", Font.PLAIN, 12));
        lbl.setForeground(SUB);
        f.add(lbl);
        return f;
    }

    // ── Animación de typing ───────────────────────────────────────

    private void iniciarAnimaciones() {
        int[] idx = {0};
        typingTimer = new javax.swing.Timer(95, null);
        typingTimer.addActionListener(e -> {
            if (idx[0] < FULL_TITLE.length()) {
                lblTitulo.setText(FULL_TITLE.substring(0, idx[0] + 1));
                idx[0]++;
            } else {
                lblPunto.setText("");
                ((javax.swing.Timer) e.getSource()).stop();
            }
        });
        typingTimer.start();
    }
}
