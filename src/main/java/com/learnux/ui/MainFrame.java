package com.learnux.ui;

import com.learnux.models.Usuario;

import javax.swing.*;
import java.awt.*;

/**
 * Ventana principal de la aplicación.
 * Coordina la navegación entre LoginPanel y PrincipalPanel.
 */
public class MainFrame extends JFrame {

    private final JPanel contenedor;
    private final CardLayout cardLayout;
    private JPanel ejercicioActual;

    public MainFrame() {
        setTitle("🐧 LearnUX — Aprende Linux");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setSize(1360, 840);
        setMinimumSize(new Dimension(1100, 680));
        setLocationRelativeTo(null);

        cardLayout = new CardLayout();
        contenedor = new JPanel(cardLayout);
        contenedor.setBackground(new Color(30, 30, 46));

        // Pantalla introductoria
        IntroPanel intro = new IntroPanel(this::mostrarLogin);
        contenedor.add(intro, "INTRO");

        // Pantalla de login
        LoginPanel login = new LoginPanel(this);
        contenedor.add(login, "LOGIN");

        add(contenedor);
        cardLayout.show(contenedor, "INTRO");
        
    }

    public void mostrarLogin() {
        com.learnux.service.NivelService.resetRepetidos();
        cardLayout.show(contenedor, "LOGIN");
    }

    public void mostrarExamenPanel(Usuario usuario) {
        ExamenPanel ep = new ExamenPanel(usuario, this::volverAPrincipal);
        mostrarEjercicioPanel(ep);
    }

    public void mostrarEjercicioPanel(JPanel panel) {
        if (ejercicioActual != null) contenedor.remove(ejercicioActual);
        ejercicioActual = panel;
        contenedor.add(panel, "EJERCICIO");
        cardLayout.show(contenedor, "EJERCICIO");
    }

    public void volverAPrincipal() {
        if (ejercicioActual != null) {
            contenedor.remove(ejercicioActual);
            ejercicioActual = null;
        }
        cardLayout.show(contenedor, "PRINCIPAL");
    }

    public void mostrarPanelPrincipal(Usuario usuario) {
        mostrarPanelPrincipal(usuario, false);
    }

    public void mostrarPanelPrincipal(Usuario usuario, boolean esNuevo) {
        PrincipalPanel principal = new PrincipalPanel(usuario);
        contenedor.add(principal, "PRINCIPAL");
        cardLayout.show(contenedor, "PRINCIPAL");

        final float[] alpha = {1.0f};
        JPanel overlay = new JPanel() {
            @Override protected void paintComponent(Graphics g) {
                Graphics2D g2 = (Graphics2D) g.create();
                g2.setComposite(AlphaComposite.SrcOver.derive(alpha[0]));
                g2.setColor(new Color(30, 30, 46));
                g2.fillRect(0, 0, getWidth(), getHeight());
                g2.dispose();
            }
        };
        overlay.setOpaque(false);
        overlay.setBounds(0, 0, getWidth(), getHeight());
        JLayeredPane layered = getLayeredPane();
        layered.add(overlay, JLayeredPane.POPUP_LAYER);

        javax.swing.Timer fade = new javax.swing.Timer(16, null);
        fade.addActionListener(e -> {
            alpha[0] -= 0.05f;
            if (alpha[0] <= 0f) {
                alpha[0] = 0f;
                ((javax.swing.Timer) e.getSource()).stop();
                layered.remove(overlay);
                layered.repaint();
                if (esNuevo) {
                    TutorialBienvenidaDialog dlg = new TutorialBienvenidaDialog(MainFrame.this);
                    dlg.setVisible(true);
                }
            } else {
                overlay.repaint();
            }
        });
        fade.start();
    }

    // ── Punto de entrada ──
    public static void main(String[] args) {
        // Look & Feel del sistema operativo
        try {
            UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
        } catch (Exception ignored) {}

        SwingUtilities.invokeLater(() -> {
            MainFrame frame = new MainFrame();
            frame.setVisible(true);
        });
    }
}
