package com.learnux.ui;

import com.learnux.service.ServiceException;
import com.learnux.service.UsuarioService;
import com.learnux.service.UsuarioService.LoginResultado;

import javax.swing.*;
import javax.swing.border.EmptyBorder;
import java.awt.*;
import java.util.Random;

public class LoginPanel extends JPanel {

    private static final Color BG       = new Color(8,  10,  18);
    private static final Color CARD_BG  = UiUtil.BG_CARD;
    private static final Color TOGGLE_BG= UiUtil.BG_HDR;
    private static final Color BORDER   = new Color(69, 71,  90);
    private static final Color TEXT     = UiUtil.TEXT;
    private static final Color SUB      = UiUtil.OVERLAY;
    private static final Color ACCENT   = UiUtil.BLUE;
    private static final Color GREEN    = UiUtil.GREEN;
    private static final Color PINK     = UiUtil.RED;

    // ── Matrix ────────────────────────────────────────────────────
    private static final String CHARS =
        "01アイウエカキクコサシスタチツテトナニヌネノハヒフヘホ∑∆Ω≡λ╔╗╚╝║═<>/[]{}#$%";
    private static final int CELL = 15;
    private int    cols, rows;
    private int[]  heads, tailLen;
    private char[][] grid;
    private final Random rng = new Random();

    // ── Form refs ────────────────────────────────────────────────
    private final JTextField       txtNombre;
    private final JLabel           lblMensaje;
    private final JLabel           lblSubtitulo;
    private final JButton          btnAccion;
    private final MainFrame        ventanaPrincipal;
    private final UsuarioService   usuarioService = new UsuarioService();
    private final boolean[]        registroMode   = {false};

    public LoginPanel(MainFrame ventanaPrincipal) {
        this.ventanaPrincipal = ventanaPrincipal;
        setBackground(BG);
        setLayout(new GridBagLayout());

        // ── Tarjeta central ──────────────────────────────────────
        JPanel card = new JPanel();
        card.setLayout(new BoxLayout(card, BoxLayout.Y_AXIS));
        card.setBackground(CARD_BG);
        card.setOpaque(true);
        card.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createLineBorder(ACCENT, 1),
            new EmptyBorder(48, 64, 48, 64)));

        // ── Título ───────────────────────────────────────────────
        JLabel titulo = new JLabel("🐧  LearnUX");
        titulo.setFont(UiUtil.FONT_TITLE);
        titulo.setForeground(TEXT);
        titulo.setHorizontalAlignment(SwingConstants.CENTER);
        titulo.setAlignmentX(Component.CENTER_ALIGNMENT);
        titulo.setMaximumSize(new Dimension(Integer.MAX_VALUE, 56));

        JSeparator sep = new JSeparator();
        sep.setForeground(BORDER);
        sep.setMaximumSize(new Dimension(Integer.MAX_VALUE, 1));
        sep.setAlignmentX(Component.CENTER_ALIGNMENT);

        // ── Segmented toggle: Entrar | Registrarse ───────────────
        JPanel toggle = new JPanel(new GridLayout(1, 2, 0, 0));
        toggle.setBackground(TOGGLE_BG);
        toggle.setBorder(BorderFactory.createLineBorder(BORDER));
        toggle.setMaximumSize(new Dimension(Integer.MAX_VALUE, 48));
        toggle.setAlignmentX(Component.CENTER_ALIGNMENT);

        JButton btnTabEntrar   = tabBtn("🔑  Entrar");
        JButton btnTabRegistro = tabBtn("✨  Registrarse");
        toggle.add(btnTabEntrar);
        toggle.add(btnTabRegistro);

        // ── Subtítulo dinámico ───────────────────────────────────
        lblSubtitulo = new JLabel(" ");
        lblSubtitulo.setFont(new Font("Monospaced", Font.PLAIN, 14));
        lblSubtitulo.setForeground(SUB);
        lblSubtitulo.setHorizontalAlignment(SwingConstants.CENTER);
        lblSubtitulo.setAlignmentX(Component.CENTER_ALIGNMENT);
        lblSubtitulo.setMaximumSize(new Dimension(Integer.MAX_VALUE, 22));

        // ── Campo ────────────────────────────────────────────────
        JLabel lblCampo = new JLabel("Nombre de usuario");
        lblCampo.setFont(new Font("Monospaced", Font.PLAIN, 14));
        lblCampo.setForeground(SUB);
        lblCampo.setHorizontalAlignment(SwingConstants.CENTER);
        lblCampo.setAlignmentX(Component.CENTER_ALIGNMENT);
        lblCampo.setMaximumSize(new Dimension(Integer.MAX_VALUE, 22));

        txtNombre = new JTextField(20);
        txtNombre.setFont(new Font("Monospaced", Font.PLAIN, 18));
        txtNombre.setBackground(new Color(25, 28, 48));
        txtNombre.setForeground(TEXT);
        txtNombre.setCaretColor(ACCENT);
        txtNombre.setHorizontalAlignment(SwingConstants.CENTER);
        txtNombre.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createLineBorder(BORDER),
            new EmptyBorder(12, 16, 12, 16)));
        txtNombre.setMaximumSize(new Dimension(Integer.MAX_VALUE, 54));
        txtNombre.setAlignmentX(Component.CENTER_ALIGNMENT);

        // ── Botón de acción ──────────────────────────────────────
        btnAccion = new JButton("→  Entrar");
        btnAccion.setFont(new Font("Monospaced", Font.BOLD, 18));
        btnAccion.setBackground(ACCENT);
        btnAccion.setForeground(BG);
        btnAccion.setBorderPainted(false);
        btnAccion.setFocusPainted(false);
        btnAccion.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        btnAccion.setBorder(new EmptyBorder(14, 0, 14, 0));
        btnAccion.setMaximumSize(new Dimension(Integer.MAX_VALUE, 58));
        btnAccion.setAlignmentX(Component.CENTER_ALIGNMENT);

        // ── Mensaje de estado ────────────────────────────────────
        lblMensaje = new JLabel(" ");
        lblMensaje.setFont(new Font("Monospaced", Font.PLAIN, 14));
        lblMensaje.setHorizontalAlignment(SwingConstants.CENTER);
        lblMensaje.setAlignmentX(Component.CENTER_ALIGNMENT);
        lblMensaje.setMaximumSize(new Dimension(Integer.MAX_VALUE, 36));

        // ── Montaje ──────────────────────────────────────────────
        card.add(titulo);
        card.add(Box.createVerticalStrut(26));
        card.add(sep);
        card.add(Box.createVerticalStrut(28));
        card.add(toggle);
        card.add(Box.createVerticalStrut(16));
        card.add(lblSubtitulo);
        card.add(Box.createVerticalStrut(28));
        card.add(lblCampo);
        card.add(Box.createVerticalStrut(8));
        card.add(txtNombre);
        card.add(Box.createVerticalStrut(20));
        card.add(btnAccion);
        card.add(Box.createVerticalStrut(14));
        card.add(lblMensaje);

        card.setPreferredSize(new Dimension(560, card.getPreferredSize().height));
        add(card);

        // ── Toggle logic ─────────────────────────────────────────
        Runnable syncUI = () -> {
            lblMensaje.setText(" ");
            if (!registroMode[0]) {
                btnTabEntrar.setBackground(ACCENT);    btnTabEntrar.setForeground(BG);
                btnTabRegistro.setBackground(TOGGLE_BG); btnTabRegistro.setForeground(SUB);
                lblSubtitulo.setText("¡Hola de nuevo! Ingresa tu nombre para continuar");
                btnAccion.setText("→  Entrar");
                btnAccion.setBackground(ACCENT);
            } else {
                btnTabEntrar.setBackground(TOGGLE_BG);  btnTabEntrar.setForeground(SUB);
                btnTabRegistro.setBackground(GREEN);   btnTabRegistro.setForeground(BG);
                lblSubtitulo.setText("Crea tu cuenta y empieza a aprender Linux");
                btnAccion.setText("✨  Crear cuenta");
                btnAccion.setBackground(GREEN);
            }
        };
        syncUI.run();

        btnTabEntrar.addActionListener(e -> {
            registroMode[0] = false; syncUI.run(); txtNombre.requestFocus();
        });
        btnTabRegistro.addActionListener(e -> {
            registroMode[0] = true; syncUI.run(); txtNombre.requestFocus();
        });

        // ── Animación matrix ─────────────────────────────────────
        new Timer(50, e -> { tick(); repaint(); }).start();

        btnAccion.addActionListener(e -> manejarAccion());
        txtNombre.addActionListener(e -> manejarAccion());
    }

    // ── Helpers UI ───────────────────────────────────────────────

    private JButton tabBtn(String texto) {
        JButton b = new JButton(texto);
        b.setFont(new Font("Monospaced", Font.BOLD, 15));
        b.setBorderPainted(false);
        b.setFocusPainted(false);
        b.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        return b;
    }

    // ── Matrix ───────────────────────────────────────────────────

    @Override
    protected void paintComponent(Graphics g) {
        super.paintComponent(g);
        if (getWidth() == 0 || getHeight() == 0) return;

        int nC = getWidth()  / CELL;
        int nR = getHeight() / CELL + 12;
        if (cols != nC || rows != nR) init(nC, nR);

        Graphics2D g2 = (Graphics2D) g.create();
        g2.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING,
                            RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
        g2.setFont(new Font("Monospaced", Font.BOLD, 13));
        int ascent = g2.getFontMetrics().getAscent();

        for (int c = 0; c < cols; c++) {
            int head = heads[c], tail = tailLen[c];
            for (int r = Math.max(0, head - tail); r <= head && r < rows; r++) {
                int d = head - r;
                Color col = d == 0 ? new Color(230, 245, 255) :
                            d == 1 ? ACCENT :
                            d <= 3 ? new Color(70, 115, 195) :
                            d <= 6 ? new Color(32,  60, 120) :
                                     new Color(15,  28,  65);
                g2.setColor(col);
                g2.drawString(String.valueOf(grid[c][r]), c * CELL, r * CELL + ascent);
            }
        }
        g2.dispose();
    }

    private void init(int nC, int nR) {
        cols = nC; rows = nR;
        heads = new int[cols]; tailLen = new int[cols]; grid = new char[cols][rows];
        for (int c = 0; c < cols; c++) {
            heads[c]   = -rng.nextInt(rows);
            tailLen[c] = 8 + rng.nextInt(16);
            for (int r = 0; r < rows; r++) grid[c][r] = randomChar();
        }
    }

    private void tick() {
        if (cols == 0) return;
        for (int c = 0; c < cols; c++) {
            if (rng.nextInt(6) == 0) grid[c][rng.nextInt(rows)] = randomChar();
            heads[c]++;
            if (heads[c] - tailLen[c] > rows) {
                heads[c]   = -rng.nextInt(rows / 3 + 1);
                tailLen[c] = 8 + rng.nextInt(16);
            }
        }
    }

    private char randomChar() { return CHARS.charAt(rng.nextInt(CHARS.length())); }

    // ── Lógica ───────────────────────────────────────────────────

    private void manejarAccion() {
        String nombre = txtNombre.getText().trim();
        btnAccion.setEnabled(false);
        try {
            LoginResultado res;
            String msg;
            if (!registroMode[0]) {
                res = usuarioService.entrar(nombre);
                msg = "✔ Bienvenido de vuelta, " + res.usuario.getNombreUsuario() + "!";
            } else {
                res = usuarioService.registrar(nombre);
                msg = "✔ ¡Cuenta creada! Bienvenido, " + res.usuario.getNombreUsuario() + "!";
            }
            mostrarExito(msg);
            Timer t = new Timer(800, e -> ventanaPrincipal.mostrarPanelPrincipal(res.usuario, res.esNuevo));
            t.setRepeats(false);
            t.start();
        } catch (ServiceException e) {
            mostrarError(e.getMessage());
            btnAccion.setEnabled(true);
        }
    }

    private void mostrarError(String msg)  { lblMensaje.setForeground(PINK);  lblMensaje.setText(msg); }
    private void mostrarExito(String msg)  { lblMensaje.setForeground(GREEN); lblMensaje.setText(msg); }
}
