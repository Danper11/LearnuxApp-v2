package com.learnux.ui;

import javax.swing.*;
import javax.swing.plaf.basic.BasicScrollBarUI;
import java.awt.*;

public class UiUtil {

    // ── Paleta Catppuccin Mocha ──────────────────────────────────
    public static final Color BG_DARK  = new Color(30,  30,  46);
    public static final Color BG_CARD  = new Color(49,  50,  68);
    public static final Color BG_HDR   = new Color(24,  24,  37);
    public static final Color TEXT     = new Color(205, 214, 244);
    public static final Color SUBTEXT  = new Color(166, 173, 200);
    public static final Color OVERLAY  = new Color(108, 112, 134);
    public static final Color ACCENT   = new Color(180, 190, 254); // Lavender
    public static final Color BLUE     = new Color(137, 180, 250);
    public static final Color GREEN    = new Color(166, 227, 161);
    public static final Color YELLOW   = new Color(249, 226, 175);
    public static final Color RED      = new Color(243, 139, 168);
    public static final Color PINK     = new Color(245, 194, 231);
    public static final Color MAUVE    = new Color(203, 166, 247);

    // ── Fuentes Pro (Más grandes para legibilidad) ──────────────
    public static final Font FONT_TITLE = new Font("Monospaced", Font.BOLD, 32);
    public static final Font FONT_SUB   = new Font("Monospaced", Font.BOLD, 22);
    public static final Font FONT_REG   = new Font("Monospaced", Font.PLAIN, 18);
    public static final Font FONT_SMALL = new Font("Monospaced", Font.PLAIN, 15);
    public static final Font FONT_MONO  = new Font("Monospaced", Font.PLAIN, 20);

    private static final Color THUMB     = new Color(75, 78, 105);
    private static final Color THUMB_HOV = new Color(100, 104, 136);
    private static final Color TRACK     = new Color(24, 24, 37);

    public static void estilizarScroll(JScrollPane scroll) {
        aplicar(scroll.getVerticalScrollBar(),   false);
        aplicar(scroll.getHorizontalScrollBar(), true);
    }

    private static void aplicar(JScrollBar bar, boolean horizontal) {
        bar.setPreferredSize(new Dimension(horizontal ? 0 : 6, horizontal ? 6 : 0));
        bar.setUI(new BasicScrollBarUI() {
            @Override protected void configureScrollBarColors() {
                thumbColor = THUMB;
                trackColor = TRACK;
            }
            @Override protected JButton createDecreaseButton(int o) { return zeroBtn(); }
            @Override protected JButton createIncreaseButton(int o) { return zeroBtn(); }
            private JButton zeroBtn() {
                JButton b = new JButton();
                b.setPreferredSize(new Dimension(0, 0));
                b.setMinimumSize(new Dimension(0, 0));
                b.setMaximumSize(new Dimension(0, 0));
                return b;
            }
            @Override protected void paintThumb(Graphics g, JComponent c, Rectangle r) {
                if (r.width < 2 || r.height < 2) return;
                Graphics2D g2 = (Graphics2D) g.create();
                g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
                g2.setColor(isDragging ? THUMB_HOV : THUMB);
                g2.fillRoundRect(r.x + 1, r.y + 2, r.width - 2, r.height - 4, 6, 6);
                g2.dispose();
            }
            @Override protected void paintTrack(Graphics g, JComponent c, Rectangle r) {
                g.setColor(TRACK);
                g.fillRect(r.x, r.y, r.width, r.height);
            }
        });
    }

    /** Helper para parsear arrays JSON básicos ["a", "b"] sin librerías externas. */
    public static java.util.List<String> parseJsonArray(String json) {
        java.util.List<String> list = new java.util.ArrayList<>();
        if (json == null || json.isBlank()) return list;
        java.util.regex.Matcher m = java.util.regex.Pattern.compile("\"((?:[^\"\\\\]|\\\\.)*)\"").matcher(json);
        while (m.find()) list.add(m.group(1).replace("\\\"", "\""));
        return list;
    }

    /** Helper para parsear objetos JSON básicos {"a":"b"} sin librerías externas. */
    public static java.util.Map<String, String> parseJsonObjeto(String json) {
        java.util.Map<String, String> map = new java.util.LinkedHashMap<>();
        if (json == null || json.isBlank()) return map;
        java.util.regex.Matcher m = java.util.regex.Pattern.compile("\"((?:[^\"\\\\]|\\\\.)*?)\"\\s*:\\s*\"((?:[^\"\\\\]|\\\\.)*?)\"").matcher(json);
        while (m.find()) map.put(m.group(1), m.group(2));
        return map;
    }

    /** Resalta un componente (usualmente un JPanel) con un color de error temporal. */
    public static void marcarError(JPanel panel) {
        Color original = panel.getBackground();
        panel.setBackground(new Color(243, 139, 168, 80)); // RED con transparencia
        javax.swing.Timer t = new javax.swing.Timer(600, e -> panel.setBackground(original));
        t.setRepeats(false);
        t.start();
    }
}
