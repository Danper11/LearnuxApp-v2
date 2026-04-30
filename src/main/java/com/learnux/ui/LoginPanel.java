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

    // ── Matrix (estilo cmatrix) ──────────────────────────────────
    private static final String CHARS =
        "01アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン" +
        "ｦｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ" +
        "∑∆Ω≡λ╔╗╚╝║═<>/[]{}#$%&*+=?!@";
    private static final int CELL = 22;
    private static final Color MATRIX_HEAD  = new Color(230, 245, 255);
    private static final Color MATRIX_BRIGHT= new Color(120, 180, 255);
    private static final Color MATRIX_BASE  = new Color(60,  120, 220);
    private static final Color MATRIX_DIM   = new Color(15,   35,  90);
    private int    cols, rows;
    private int[]  heads, tailLen, speedDen, speedCnt;
    private char[][] grid;
    private final Random rng = new Random();
    private int frame = 0;

    // ── Form refs ────────────────────────────────────────────────
    private final JTextField       txtNombre;
    private final JPasswordField   txtPassword;
    private final JPasswordField   txtConfirm;
    private final JPanel           panelConfirm;
    private final JLabel           lblMensaje;
    private final JLabel           lblSubtitulo;
    private final JButton          btnAccion;
    private final JPanel           card;
    private final MainFrame        ventanaPrincipal;
    private final UsuarioService   usuarioService = new UsuarioService();
    private final boolean[]        registroMode   = {false};

    public LoginPanel(MainFrame ventanaPrincipal) {
        this.ventanaPrincipal = ventanaPrincipal;
        setBackground(BG);
        setLayout(new GridBagLayout());

        // ── Tarjeta central ──────────────────────────────────────
        card = new JPanel();
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

        // ── Campo nombre ─────────────────────────────────────────
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

        // ── Campo contraseña ─────────────────────────────────────
        JLabel lblPwd = new JLabel("Contraseña");
        lblPwd.setFont(new Font("Monospaced", Font.PLAIN, 14));
        lblPwd.setForeground(SUB);
        lblPwd.setHorizontalAlignment(SwingConstants.CENTER);
        lblPwd.setAlignmentX(Component.CENTER_ALIGNMENT);
        lblPwd.setMaximumSize(new Dimension(Integer.MAX_VALUE, 22));

        txtPassword = new JPasswordField(20);
        estilizarPasswordField(txtPassword);

        // ── Campo confirmar (solo en registro) ───────────────────
        JLabel lblConfirm = new JLabel("Confirmar contraseña");
        lblConfirm.setFont(new Font("Monospaced", Font.PLAIN, 14));
        lblConfirm.setForeground(SUB);
        lblConfirm.setHorizontalAlignment(SwingConstants.CENTER);
        lblConfirm.setAlignmentX(Component.CENTER_ALIGNMENT);
        lblConfirm.setMaximumSize(new Dimension(Integer.MAX_VALUE, 22));

        txtConfirm = new JPasswordField(20);
        estilizarPasswordField(txtConfirm);

        panelConfirm = new JPanel();
        panelConfirm.setLayout(new BoxLayout(panelConfirm, BoxLayout.Y_AXIS));
        panelConfirm.setOpaque(false);
        panelConfirm.setAlignmentX(Component.CENTER_ALIGNMENT);
        panelConfirm.add(Box.createVerticalStrut(14));
        panelConfirm.add(lblConfirm);
        panelConfirm.add(Box.createVerticalStrut(8));
        panelConfirm.add(txtConfirm);

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
        card.add(Box.createVerticalStrut(14));
        card.add(lblPwd);
        card.add(Box.createVerticalStrut(8));
        card.add(txtPassword);
        card.add(panelConfirm);
        card.add(Box.createVerticalStrut(20));
        card.add(btnAccion);
        card.add(Box.createVerticalStrut(14));
        card.add(lblMensaje);

        add(card);

        // ── Toggle logic ─────────────────────────────────────────
        Runnable syncUI = () -> {
            lblMensaje.setText(" ");
            if (!registroMode[0]) {
                btnTabEntrar.setBackground(ACCENT);      btnTabEntrar.setForeground(BG);
                btnTabRegistro.setBackground(TOGGLE_BG); btnTabRegistro.setForeground(SUB);
                lblSubtitulo.setText("¡Hola de nuevo! Ingresa tus datos para continuar");
                btnAccion.setText("→  Entrar");
                btnAccion.setBackground(ACCENT);
            } else {
                btnTabEntrar.setBackground(TOGGLE_BG);   btnTabEntrar.setForeground(SUB);
                btnTabRegistro.setBackground(GREEN);     btnTabRegistro.setForeground(BG);
                lblSubtitulo.setText("Crea tu cuenta y empieza a aprender Linux");
                btnAccion.setText("✨  Crear cuenta");
                btnAccion.setBackground(GREEN);
            }
            panelConfirm.setVisible(registroMode[0]);
            card.setPreferredSize(null);
            card.setPreferredSize(new Dimension(560, card.getPreferredSize().height));
            card.revalidate();
            repaint();
        };
        syncUI.run();

        btnTabEntrar.addActionListener(e -> {
            registroMode[0] = false; syncUI.run(); txtNombre.requestFocus();
        });
        btnTabRegistro.addActionListener(e -> {
            registroMode[0] = true; syncUI.run(); txtNombre.requestFocus();
        });

        // ── Animación matrix (≈25 fps) ───────────────────────────
        new Timer(40, e -> { tick(); repaint(); }).start();

        btnAccion.addActionListener(e -> manejarAccion());
        txtNombre.addActionListener(e -> manejarAccion());
        txtPassword.addActionListener(e -> manejarAccion());
        txtConfirm.addActionListener(e -> manejarAccion());
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

    private void estilizarPasswordField(JPasswordField f) {
        f.setFont(new Font("Monospaced", Font.PLAIN, 18));
        f.setBackground(new Color(25, 28, 48));
        f.setForeground(TEXT);
        f.setCaretColor(ACCENT);
        f.setEchoChar('●');
        f.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createLineBorder(BORDER),
            new EmptyBorder(12, 16, 12, 16)));
        f.setMaximumSize(new Dimension(Integer.MAX_VALUE, 54));
        f.setAlignmentX(Component.CENTER_ALIGNMENT);
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
        Font fontBold   = new Font("Monospaced", Font.BOLD,  19);
        Font fontPlain  = new Font("Monospaced", Font.PLAIN, 19);
        int ascent = g2.getFontMetrics(fontBold).getAscent();

        for (int c = 0; c < cols; c++) {
            int head = heads[c], tail = tailLen[c];
            for (int r = Math.max(0, head - tail); r <= head && r < rows; r++) {
                int d = head - r;
                Color col;
                Font  fnt;
                if (d == 0) {
                    col = MATRIX_HEAD;
                    fnt = fontBold;
                } else if (d == 1) {
                    col = MATRIX_BRIGHT;
                    fnt = fontBold;
                } else {
                    // Estela verde con desvanecimiento suave
                    float t = (float)(d - 1) / Math.max(1, tail - 1);  // 0 = recién dejado, 1 = final
                    if (t > 1f) t = 1f;
                    col = lerp(MATRIX_BASE, MATRIX_DIM, t);
                    if (d > tail - 4) {
                        // alpha en los últimos 4 caracteres para fundido a negro
                        int alpha = Math.max(0, 255 - (d - (tail - 4)) * 64);
                        col = new Color(col.getRed(), col.getGreen(), col.getBlue(), alpha);
                    }
                    fnt = fontPlain;
                }
                g2.setColor(col);
                g2.setFont(fnt);
                g2.drawString(String.valueOf(grid[c][r]), c * CELL, r * CELL + ascent);
            }
        }
        g2.dispose();
    }

    private static Color lerp(Color a, Color b, float t) {
        int r = (int)(a.getRed()   + (b.getRed()   - a.getRed())   * t);
        int g = (int)(a.getGreen() + (b.getGreen() - a.getGreen()) * t);
        int bl= (int)(a.getBlue()  + (b.getBlue()  - a.getBlue())  * t);
        return new Color(clamp(r), clamp(g), clamp(bl));
    }
    private static int clamp(int v) { return Math.max(0, Math.min(255, v)); }

    private void init(int nC, int nR) {
        cols = nC; rows = nR;
        heads    = new int[cols];
        tailLen  = new int[cols];
        speedDen = new int[cols];
        speedCnt = new int[cols];
        grid     = new char[cols][rows];
        for (int c = 0; c < cols; c++) {
            heads[c]   = -rng.nextInt(rows * 2);
            tailLen[c] = 10 + rng.nextInt(22);
            speedDen[c] = 1 + rng.nextInt(3);     // 1=rápida, 2=media, 3=lenta
            speedCnt[c] = rng.nextInt(speedDen[c]);
            for (int r = 0; r < rows; r++) grid[c][r] = randomChar();
        }
    }

    private void tick() {
        if (cols == 0) return;
        frame++;
        for (int c = 0; c < cols; c++) {
            // Mutación frecuente de glifos para sensación "viva"
            if (rng.nextInt(3) == 0) {
                int rr = rng.nextInt(rows);
                grid[c][rr] = randomChar();
            }
            // Avance según velocidad propia de la columna
            if (++speedCnt[c] >= speedDen[c]) {
                speedCnt[c] = 0;
                heads[c]++;
                // Renovar el glifo nuevo en la cabeza
                if (heads[c] >= 0 && heads[c] < rows) {
                    grid[c][heads[c]] = randomChar();
                }
                if (heads[c] - tailLen[c] > rows) {
                    heads[c]    = -rng.nextInt(rows / 2 + 1);
                    tailLen[c]  = 10 + rng.nextInt(22);
                    speedDen[c] = 1 + rng.nextInt(3);
                }
            }
        }
    }

    private char randomChar() { return CHARS.charAt(rng.nextInt(CHARS.length())); }

    // ── Lógica ───────────────────────────────────────────────────

    private void manejarAccion() {
        String nombre   = txtNombre.getText().trim();
        String password = new String(txtPassword.getPassword());
        btnAccion.setEnabled(false);
        try {
            LoginResultado res;
            String msg;
            if (!registroMode[0]) {
                res = usuarioService.entrar(nombre, password);
                msg = "✔ Bienvenido de vuelta, " + res.usuario.getNombreUsuario() + "!";
            } else {
                String confirm = new String(txtConfirm.getPassword());
                if (!password.equals(confirm)) {
                    mostrarError("Las contraseñas no coinciden.");
                    btnAccion.setEnabled(true);
                    return;
                }
                res = usuarioService.registrar(nombre, password);
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
