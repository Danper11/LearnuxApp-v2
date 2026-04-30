package com.learnux.ui;

import com.learnux.models.Nivel;
import com.learnux.models.Usuario;
import com.learnux.service.NivelService;

import javax.swing.*;
import javax.swing.border.EmptyBorder;
import java.awt.*;
import java.util.ArrayList;
import java.util.List;

public class NivelesPanel extends JPanel {

    private static final Color BG      = UiUtil.BG_DARK;
    private static final Color BG_CARD = UiUtil.BG_CARD;
    private static final Color BG_HDR  = UiUtil.BG_HDR;
    private static final Color TEXT    = UiUtil.TEXT;
    private static final Color SUB     = UiUtil.OVERLAY;
    private static final Color ACCENT  = UiUtil.BLUE;
    private static final Color GREEN   = UiUtil.GREEN;
    private static final Color PINK    = UiUtil.RED;
    private static final Color YELLOW  = UiUtil.YELLOW;
    private static final Color ORANGE  = new Color(250, 179, 135);

    private static final Color ACCENT_DIM = new Color(60, 85, 140);

    private final NivelService nivelService = new NivelService();
    private final Usuario      usuario;
    private       JPanel       contenido;

    private final List<JPanel>       glowCards   = new ArrayList<>();
    private       javax.swing.Timer  glowTimer;
    private       boolean            glowBright  = true;

    public NivelesPanel(Usuario usuario) {
        this.usuario = usuario;
        setLayout(new BorderLayout());
        setBackground(BG);
        add(construirHeader(), BorderLayout.NORTH);

        contenido = new JPanel();
        contenido.setLayout(new BoxLayout(contenido, BoxLayout.Y_AXIS));
        contenido.setBackground(BG);
        contenido.setBorder(new EmptyBorder(16, 16, 16, 16));

        JScrollPane scroll = new JScrollPane(contenido);
        scroll.setBorder(null);
        scroll.getViewport().setBackground(BG);
        scroll.getVerticalScrollBar().setUnitIncrement(12);
        UiUtil.estilizarScroll(scroll);
        add(scroll, BorderLayout.CENTER);
    }

    private JPanel construirHeader() {
        JPanel h = new JPanel(new BorderLayout());
        h.setBackground(BG_HDR);
        h.setBorder(new EmptyBorder(12, 20, 12, 20));

        JLabel titulo = new JLabel("🎮  Niveles");
        titulo.setFont(new Font("Monospaced", Font.BOLD, 19));
        titulo.setForeground(ACCENT);

        JPanel east = new JPanel(new java.awt.FlowLayout(java.awt.FlowLayout.RIGHT, 14, 0));
        east.setBackground(BG_HDR);

        JLabel sub = new JLabel("Completa cada nivel para desbloquear el siguiente");
        sub.setFont(new Font("Monospaced", Font.PLAIN, 13));
        sub.setForeground(SUB);

        east.add(sub);
        h.add(titulo, BorderLayout.WEST);
        h.add(east,   BorderLayout.EAST);
        return h;
    }

    public void cargarNiveles() {
        List<Nivel> niveles = nivelService.getNivelesConProgreso(usuario.getIdUsuario());
        contenido.removeAll();
        glowCards.clear();
        if (glowTimer != null) { glowTimer.stop(); glowTimer = null; }

record TierDef(String icon, String label, int from, int to, Color color) {}
        TierDef[] tiers = {
            new TierDef("🟢", "Fundamentos", 1,  6,  GREEN),
            new TierDef("🟡", "Intermedio",  7, 12, YELLOW),
            new TierDef("🟠", "Avanzado",    13, 18, ORANGE),
            new TierDef("🔴", "Maestro",    19, 24, PINK)
        };

        for (TierDef tier : tiers) {
            List<Nivel> group = niveles.stream()
                .filter(n -> n.getNumero() >= tier.from() && n.getNumero() <= tier.to())
                .toList();
            if (group.isEmpty()) continue;

            contenido.add(tierHeader(tier.icon(), tier.label(), tier.from(), tier.to(), tier.color()));
            contenido.add(Box.createVerticalStrut(8));

            JPanel subGrid = new JPanel(new GridLayout(0, 3, 12, 12));
            subGrid.setBackground(BG);
            subGrid.setMaximumSize(new Dimension(Integer.MAX_VALUE, 9999));
            subGrid.setAlignmentX(Component.LEFT_ALIGNMENT);
            for (Nivel n : group) subGrid.add(crearTarjeta(n));

            contenido.add(subGrid);
            contenido.add(Box.createVerticalStrut(22));
        }

        contenido.revalidate();
        contenido.repaint();

        if (!glowCards.isEmpty()) {
            glowTimer = new javax.swing.Timer(900, e -> {
                glowBright = !glowBright;
                Color col = glowBright ? ACCENT : ACCENT_DIM;
                for (JPanel card : glowCards) {
                    card.setBorder(BorderFactory.createCompoundBorder(
                        BorderFactory.createLineBorder(col, 2),
                        new EmptyBorder(12, 12, 12, 12)));
                    card.repaint();
                }
            });
            glowTimer.start();
        }

    }

    private JPanel tierHeader(String icon, String label, int from, int to, Color color) {
        JPanel h = new JPanel(new BorderLayout());
        h.setBackground(BG_HDR);
        h.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createMatteBorder(0, 3, 0, 0, color),
            new EmptyBorder(8, 14, 8, 14)));
        h.setMaximumSize(new Dimension(Integer.MAX_VALUE, 40));
        h.setAlignmentX(Component.LEFT_ALIGNMENT);

        int tierNum = (from - 1) / 5 + 1;
        JLabel lbl = new JLabel(icon + "  Tier " + tierNum + "  ·  " + label);
        lbl.setFont(UiUtil.FONT_SUB);
        lbl.setForeground(color);

        JLabel rng = new JLabel("Niveles " + from + "–" + to + "  ");
        rng.setFont(UiUtil.FONT_SMALL);
        rng.setForeground(SUB);

        h.add(lbl, BorderLayout.WEST);
        h.add(rng, BorderLayout.EAST);
        return h;
    }

    private JPanel crearTarjeta(Nivel nivel) {
        boolean bloqueado  = !nivel.isDesbloqueado();
        boolean completado = nivel.isCompletado();
        boolean activo     = !bloqueado && !completado;

        JPanel card = new JPanel(new BorderLayout(0, 6));
        card.setBackground(bloqueado ? new Color(35, 35, 50) : BG_CARD);
        card.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createLineBorder(
                completado ? new Color(80, 130, 80) :
                bloqueado  ? new Color(55, 55, 70)  :
                             ACCENT),
            new EmptyBorder(12, 12, 12, 12)));

        if (activo) glowCards.add(card);

        JLabel lblNum = new JLabel(tipoIcono(nivel.getTipoEjercicio()) + "  #" + nivel.getNumero());
        lblNum.setFont(UiUtil.FONT_SUB);
        lblNum.setForeground(bloqueado ? SUB : ACCENT);

        JLabel lblNombre = new JLabel("<html><b>" + nivel.getNombre() + "</b></html>");
        lblNombre.setFont(UiUtil.FONT_REG);
        lblNombre.setForeground(bloqueado ? SUB : TEXT);

        JLabel lblDif = new JLabel(badgeDif(nivel.getDificultad()) +
            "   " + nivel.getPuntosRecompensa() + " pts");
        lblDif.setFont(new Font("Monospaced", Font.PLAIN, 10));
        lblDif.setForeground(SUB);

        // Barra binaria: llena si el nivel está completado, vacía si no.
        JProgressBar barra = new JProgressBar(0, 1);
        barra.setValue(completado ? 1 : 0);
        barra.setStringPainted(false);
        barra.setBackground(BG_HDR);
        barra.setForeground(completado ? GREEN : ACCENT);
        barra.setBorderPainted(false);
        barra.setPreferredSize(new Dimension(0, 4));

        String estadoTxt = completado ? "✔ Completado" : bloqueado ? "🔒 Bloqueado" : "▶ Jugar";
        Color  estadoCol = completado ? GREEN : bloqueado ? SUB : YELLOW;
        JLabel lblEstado = new JLabel(estadoTxt);
        lblEstado.setFont(UiUtil.FONT_SUB);
        lblEstado.setForeground(estadoCol);

        JPanel top = new JPanel(new BorderLayout());
        top.setBackground(card.getBackground());
        top.add(lblNum,    BorderLayout.WEST);
        top.add(lblEstado, BorderLayout.EAST);

        JPanel mid = new JPanel();
        mid.setLayout(new BoxLayout(mid, BoxLayout.Y_AXIS));
        mid.setBackground(card.getBackground());
        mid.add(lblNombre);
        mid.add(Box.createVerticalStrut(4));
        mid.add(lblDif);
        mid.add(Box.createVerticalStrut(6));
        mid.add(barra);

        card.add(top, BorderLayout.NORTH);
        card.add(mid, BorderLayout.CENTER);

        if (!bloqueado) {
            card.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
            card.addMouseListener(new java.awt.event.MouseAdapter() {
                @Override public void mouseClicked(java.awt.event.MouseEvent e) {
                    abrirNivel(nivel);
                }
                @Override public void mouseEntered(java.awt.event.MouseEvent e) {
                    card.setBorder(BorderFactory.createCompoundBorder(
                        BorderFactory.createLineBorder(ACCENT, 2),
                        new EmptyBorder(12, 12, 12, 12)));
                }
                @Override public void mouseExited(java.awt.event.MouseEvent e) {
                    card.setBorder(BorderFactory.createCompoundBorder(
                        BorderFactory.createLineBorder(
                            completado ? new Color(80, 130, 80) :
                            activo     ? (glowBright ? ACCENT : ACCENT_DIM) :
                                         new Color(69, 71, 90)),
                        new EmptyBorder(12, 12, 12, 12)));
                }
            });
        }
        return card;
    }

    private void abrirNivel(Nivel nivel) {
        MainFrame frame = (MainFrame) SwingUtilities.getWindowAncestor(this);

        if (esJefeFinal(nivel.getNumero())) {
            int tier = (nivel.getNumero() - 1) / 6 + 1;
            JefeFinalPanel boss = new JefeFinalPanel(usuario, tier, nivel.getIdNivel(), () -> {
                frame.volverAPrincipal();
                cargarNiveles();
            });
            frame.mostrarEjercicioPanel(boss);
            return;
        }

        EjercicioPanel ep = new EjercicioPanel(
            usuario, nivel,
            () -> { // onCerrar
                frame.volverAPrincipal();
                cargarNiveles();
            },
            null, // onSuperado
            () -> { // onSiguiente
                // Verificar dinámicamente si el siguiente nivel se desbloqueó tras completar este
                List<Nivel> sigNiveles = nivelService.getNivelesConProgreso(usuario.getIdUsuario());
                sigNiveles.stream()
                    .filter(n -> n.getNumero() == nivel.getNumero() + 1 && n.isDesbloqueado())
                    .findFirst()
                    .ifPresentOrElse(
                        this::abrirNivel,
                        () -> {
                            frame.volverAPrincipal();
                            cargarNiveles();
                        }
                    );
            }
        );
        frame.mostrarEjercicioPanel(ep);
    }

    private void jugarSiguienteNivel(int numNivel) {
        List<Nivel> niveles = nivelService.getNivelesConProgreso(usuario.getIdUsuario());
        niveles.stream()
            .filter(n -> n.getNumero() == numNivel && n.isDesbloqueado())
            .findFirst()
            .ifPresentOrElse(
                this::abrirNivel,
                () -> {
                    MainFrame frame = (MainFrame) SwingUtilities.getWindowAncestor(this);
                    if (frame != null) frame.volverAPrincipal();
                    cargarNiveles();
                }
            );
    }

    private boolean esJefeFinal(int numNivel) {
        return numNivel == 6 || numNivel == 12 || numNivel == 18 || numNivel == 24;
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

    private String badgeDif(String dif) {
        if (dif == null) return "";
        return switch (dif.toLowerCase()) {
            case "principiante" -> "🟢";
            case "intermedio"   -> "🟡";
            case "avanzado"     -> "🔴";
            default -> dif;
        };
    }
}

