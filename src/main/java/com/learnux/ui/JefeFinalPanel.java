package com.learnux.ui;

import com.learnux.models.Usuario;
import com.learnux.service.ProgresoService;

import javax.swing.*;
import javax.swing.border.EmptyBorder;
import java.awt.*;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.util.List;

public class JefeFinalPanel extends JPanel {

    private static final Color BG      = new Color(30,  30,  46);
    private static final Color BG_CARD = new Color(49,  50,  68);
    private static final Color BG_HDR  = new Color(24,  24,  37);
    private static final Color TEXT    = new Color(205, 214, 244);
    private static final Color SUB     = new Color(108, 112, 134);
    private static final Color ACCENT  = new Color(137, 180, 250);
    private static final Color GREEN   = new Color(166, 227, 161);
    private static final Color YELLOW  = new Color(249, 226, 175);
    private static final Color PINK    = new Color(243, 139, 168);
    private static final Color ORANGE  = new Color(250, 179, 135);

    private record BossEj(String pregunta, String respuesta, String[] opciones, String pista) {}

    private record BossData(
        String emoji, String nombre, String escenario, String contexto,
        Color color, BossEj[] ejercicios
    ) {}

    private static final BossData[] BOSSES = {
        new BossData(
            "🗄", "El Guardián del Sistema de Archivos",
            "Tu primer servidor de producción — sin guía, sin documentación",
            "El administrador anterior dejó el servidor desordenado y se fue sin explicaciones. " +
            "Con los fundamentos que dominas, demuestra que puedes orientarte en cualquier sistema Linux " +
            "y realizar operaciones básicas sin perder la calma.",
            GREEN,
            new BossEj[]{
                new BossEj(
                    "Acabas de conectarte por SSH al servidor. ¿Qué comando escribes primero para saber exactamente en qué ruta del sistema de archivos te encuentras?",
                    "pwd",
                    new String[]{"pwd", "cd", "ls", "dir"},
                    "Print Working Directory — imprime el directorio de trabajo actual"
                ),
                new BossEj(
                    "Necesitas ver TODOS los archivos del directorio actual, incluyendo los ocultos (los que comienzan con punto), con detalles de permisos, propietario y tamaño.",
                    "ls -la",
                    new String[]{"ls", "ls -l", "ls -la", "dir -all"},
                    "-l muestra detalles, -a incluye archivos ocultos"
                ),
                new BossEj(
                    "Hay un archivo llamado /etc/hostname que guarda el nombre del servidor. ¿Qué comando muestra su contenido en pantalla?",
                    "cat /etc/hostname",
                    new String[]{"cat /etc/hostname", "ls /etc/hostname", "pwd /etc/hostname", "type /etc/hostname"},
                    "cat concatena y muestra el contenido de archivos"
                ),
                new BossEj(
                    "La aplicación necesita el directorio /apps/web/logs pero ninguno de esos subdirectorios existe todavía. ¿Qué comando lo crea todo de una sola vez?",
                    "mkdir -p /apps/web/logs",
                    new String[]{"mkdir /apps/web/logs", "mkdir -p /apps/web/logs", "touch -d /apps/web/logs", "mkdirs /apps/web/logs"},
                    "La bandera -p (parents) crea todos los directorios intermedios"
                )
            }
        ),
        new BossData(
            "🔍", "El Rastreador de Procesos",
            "Servidor lento, proceso fantasma y permisos incorrectos",
            "Un usuario reporta que el servidor está inutilizable. Hay un proceso desconocido " +
            "consumiendo el CPU, un archivo de configuración con permisos incorrectos que bloquea " +
            "el acceso, y un archivo crítico perdido en el sistema de archivos. Usa tus habilidades " +
            "intermedias para resolver la crisis.",
            YELLOW,
            new BossEj[]{
                new BossEj(
                    "El archivo nginx.conf está en algún lugar del sistema pero no sabes dónde. ¿Qué comando lo busca en todo el sistema de archivos por su nombre exacto?",
                    "find / -name nginx.conf",
                    new String[]{"locate nginx.conf", "find / -name nginx.conf", "search -f nginx.conf /", "grep -r nginx.conf /"},
                    "find [directorio_base] -name [nombre] busca archivos por nombre"
                ),
                new BossEj(
                    "El archivo config.sh necesita permisos exclusivos para el propietario: lectura, escritura y ejecución. Sin acceso para grupo ni otros. ¿Qué comando usas?",
                    "chmod 700 config.sh",
                    new String[]{"chmod 644 config.sh", "chmod 777 config.sh", "chmod 700 config.sh", "chmod 755 config.sh"},
                    "7=rwx (4+2+1). Los tres dígitos son: propietario, grupo, otros"
                ),
                new BossEj(
                    "Necesitas identificar el proceso que consume más recursos. ¿Qué comando muestra TODOS los procesos en ejecución con información completa (usuario, PID, CPU, memoria)?",
                    "ps aux",
                    new String[]{"ps", "ps aux", "top --all", "proc -lista"},
                    "a=todos usuarios, u=formato extendido, x=incluye procesos sin terminal"
                ),
                new BossEj(
                    "Identificaste el proceso problemático: tiene PID 8080 y está completamente colgado. ¿Qué comando usas para terminarlo de forma forzada e inmediata?",
                    "kill -9 8080",
                    new String[]{"kill 8080", "stop 8080", "kill -9 8080", "taskkill 8080"},
                    "La señal -9 (SIGKILL) fuerza la terminación sin posibilidad de ignorarla"
                )
            }
        ),
        new BossData(
            "📊", "El Analizador de Logs",
            "Miles de líneas de logs críticos — el servidor habla, tú debes escuchar",
            "El servidor de producción lleva semanas generando logs de error que nadie ha revisado. " +
            "Hay patrones de fallo que se repiten, un script de despliegue sin permisos y un archivo " +
            "de log que crece en tiempo real. Tus herramientas de procesamiento de texto son la clave " +
            "para encontrar la verdad entre miles de líneas.",
            ORANGE,
            new BossEj[]{
                new BossEj(
                    "Necesitas extraer todas las líneas que contienen la palabra 'ERROR' del archivo application.log para analizarlas. ¿Qué comando usas?",
                    "grep \"ERROR\" application.log",
                    new String[]{"find \"ERROR\" application.log", "grep \"ERROR\" application.log", "cat application.log | search ERROR", "awk '/ERROR/' application.log"},
                    "grep busca patrones de texto en archivos línea por línea"
                ),
                new BossEj(
                    "Quieres monitorear en tiempo real el archivo /var/log/syslog mientras el sistema escribe en él, viendo las últimas 50 líneas. ¿Qué comando usas?",
                    "tail -f -n 50 /var/log/syslog",
                    new String[]{"head -50 /var/log/syslog", "tail -50 /var/log/syslog", "tail -f -n 50 /var/log/syslog", "watch -n1 tail /var/log/syslog"},
                    "-f sigue el archivo en tiempo real, -n especifica el número de líneas iniciales"
                ),
                new BossEj(
                    "Quieres saber cuántas veces aparece exactamente la palabra 'timeout' en errors.log usando tuberías. ¿Cómo encadenas los comandos?",
                    "grep \"timeout\" errors.log | wc -l",
                    new String[]{"grep timeout errors.log", "count \"timeout\" errors.log", "grep \"timeout\" errors.log | wc -l", "wc -l \"timeout\" errors.log"},
                    "Usa | para pasar la salida de grep a wc -l (word count, líneas)"
                ),
                new BossEj(
                    "El script deploy.sh necesita permisos de ejecución para que el sistema CI/CD pueda lanzarlo. Escribe el comando exacto para otorgárselos.",
                    "chmod +x deploy.sh",
                    null,
                    "+x agrega el bit de ejecución al archivo para todos los roles"
                )
            }
        ),
        new BossData(
            "🏗", "El Arquitecto de la Infraestructura",
            "Emergencia de producción — el servidor principal falla y eres el único disponible",
            "¡Alerta crítica! El servidor principal lleva 3 minutos fuera de línea. El equipo está " +
            "de vacaciones y tú eres el único ingeniería disponible. Tienes que diagnosticar " +
            "rápidamente el estado del sistema, identificar el problema y tomar acciones de " +
            "emergencia. Cada segundo cuenta. Demuestra que eres el Arquitecto que este sistema necesita.",
            PINK,
            new BossEj[]{
                new BossEj(
                    "Lo primero: verificar el espacio en disco. ¿Qué comando muestra el espacio de TODOS los sistemas de archivos montados en formato legible para humanos?",
                    "df -h",
                    new String[]{"du -h /", "df -h", "disk --human-readable", "mount -l --size"},
                    "df = disk filesystem, -h = human readable (KB, MB, GB)"
                ),
                new BossEj(
                    "El disco está bien. ¿Será la RAM? ¿Qué comando muestra la memoria RAM total, usada y disponible del sistema en formato legible?",
                    "free -h",
                    new String[]{"ram -status", "memory --show", "free -h", "cat /proc/meminfo"},
                    "free muestra el uso de memoria física y de intercambio"
                ),
                new BossEj(
                    "Antes de reiniciar, necesitas hacer un backup de emergencia del directorio /var/data/ comprimido en un archivo llamado emergency.tar.gz. ¿Qué comando usas?",
                    "tar -czf emergency.tar.gz /var/data/",
                    new String[]{"zip -r emergency.tar.gz /var/data/", "tar -czf emergency.tar.gz /var/data/", "gzip -r /var/data/", "compress /var/data/ emergency.tar.gz"},
                    "c=crear archivo, z=comprimir con gzip, f=nombre del archivo de salida"
                ),
                new BossEj(
                    "Sospechas de una conexión extraña. Escribe el comando para ver TODOS los puertos en escucha y conexiones de red activas en el sistema.",
                    "ss -tuln",
                    null,
                    "ss reemplaza a netstat. -t=TCP, -u=UDP, -l=listening, -n=numérico"
                )
            }
        )
    };

    private static final String[] TIER_NAMES = {"", "Fundamentos", "Intermedio", "Avanzado", "Maestro"};
    private static final Color[]  TIER_COLORS = {BG, GREEN, YELLOW, ORANGE, PINK};

    private final Usuario          usuario;
    private final int              tier;
    private final int              idNivel;
    private final Runnable         onCerrar;
    private final BossData         boss;
    private final ProgresoService  progresoService = new ProgresoService();

    private int    indice    = 0;
    private int    aciertos  = 0;
    private int    bossHp    = 100;
    private String respuestaSeleccionada;

    private JLabel     lblPregunta;
    private JPanel     panelRespuesta;
    private JLabel     lblFeedback;
    private JButton    btnAccion;
    private JProgressBar barBossHp;
    private JLabel     lblHpTexto;

    public JefeFinalPanel(Usuario usuario, int tier, int idNivel, Runnable onCerrar) {
        this.usuario  = usuario;
        this.tier     = Math.max(1, Math.min(4, tier));
        this.idNivel  = idNivel;
        this.onCerrar = onCerrar;
        this.boss     = BOSSES[this.tier - 1];
        setBackground(BG);
        setLayout(new BorderLayout());
        mostrarIntro();
    }

    private void mostrarIntro() {
        removeAll();
        setLayout(new BorderLayout());

        Color tierColor = TIER_COLORS[tier];

        JPanel header = new JPanel();
        header.setLayout(new BoxLayout(header, BoxLayout.Y_AXIS));
        header.setBackground(new Color(15, 15, 28));
        header.setBorder(new EmptyBorder(28, 36, 22, 36));

        JLabel lblTierTag = new JLabel("── TIER " + tier + " · " + TIER_NAMES[tier].toUpperCase() + " ──");
        lblTierTag.setFont(new Font("Monospaced", Font.BOLD, 13));
        lblTierTag.setForeground(tierColor);
        lblTierTag.setAlignmentX(Component.CENTER_ALIGNMENT);

        JLabel lblEmoji = new JLabel(boss.emoji());
        lblEmoji.setFont(new Font("Monospaced", Font.PLAIN, 62));
        lblEmoji.setAlignmentX(Component.CENTER_ALIGNMENT);

        JLabel lblTitulo = new JLabel("⚔  JEFE FINAL");
        lblTitulo.setFont(new Font("Monospaced", Font.BOLD, 28));
        lblTitulo.setForeground(tierColor);
        lblTitulo.setAlignmentX(Component.CENTER_ALIGNMENT);

        JLabel lblNombre = new JLabel(boss.nombre());
        lblNombre.setFont(new Font("Monospaced", Font.PLAIN, 17));
        lblNombre.setForeground(TEXT);
        lblNombre.setAlignmentX(Component.CENTER_ALIGNMENT);

        header.add(lblTierTag);
        header.add(Box.createVerticalStrut(14));
        header.add(lblEmoji);
        header.add(Box.createVerticalStrut(8));
        header.add(lblTitulo);
        header.add(Box.createVerticalStrut(6));
        header.add(lblNombre);
        add(header, BorderLayout.NORTH);

        JPanel cuerpo = new JPanel();
        cuerpo.setLayout(new BoxLayout(cuerpo, BoxLayout.Y_AXIS));
        cuerpo.setBackground(BG);
        cuerpo.setBorder(new EmptyBorder(24, 50, 24, 50));

        JPanel escenarioCard = new JPanel(new BorderLayout(0, 8));
        escenarioCard.setBackground(new Color(38, 30, 55));
        escenarioCard.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createMatteBorder(0, 3, 0, 0, tierColor),
            new EmptyBorder(14, 18, 14, 18)));
        escenarioCard.setAlignmentX(Component.LEFT_ALIGNMENT);
        escenarioCard.setMaximumSize(new Dimension(Integer.MAX_VALUE, 9999));

        JLabel lblEscTitle = new JLabel("🎯  Escenario");
        lblEscTitle.setFont(new Font("Monospaced", Font.BOLD, 15));
        lblEscTitle.setForeground(tierColor);

        JLabel lblEscenario = new JLabel("<html><body style='width:540px; font-size:13px; line-height:1.7'>"
            + "<b>" + boss.escenario() + "</b></body></html>");
        lblEscenario.setFont(new Font("Monospaced", Font.BOLD, 14));
        lblEscenario.setForeground(TEXT);

        escenarioCard.add(lblEscTitle,  BorderLayout.NORTH);
        escenarioCard.add(lblEscenario, BorderLayout.CENTER);
        cuerpo.add(escenarioCard);
        cuerpo.add(Box.createVerticalStrut(16));

        JLabel lblCtx = new JLabel("<html><body style='width:580px; line-height:1.65'>"
            + boss.contexto() + "</body></html>");
        lblCtx.setFont(new Font("Monospaced", Font.PLAIN, 14));
        lblCtx.setForeground(new Color(160, 165, 190));
        lblCtx.setAlignmentX(Component.LEFT_ALIGNMENT);
        cuerpo.add(lblCtx);
        cuerpo.add(Box.createVerticalStrut(22));

        JPanel infoRow = new JPanel(new FlowLayout(FlowLayout.LEFT, 20, 0));
        infoRow.setBackground(BG);
        infoRow.setAlignmentX(Component.LEFT_ALIGNMENT);

        for (String[] info : new String[][]{
            {"📋", boss.ejercicios().length + " desafíos"},
            {"⚔",  "Supera 3 de " + boss.ejercicios().length + " para conquistarlo"},
            {"💡", "Sin pistas automáticas — confía en tu conocimiento"}
        }) {
            JPanel item = new JPanel(new FlowLayout(FlowLayout.LEFT, 6, 0));
            item.setBackground(BG);
            JLabel ic  = new JLabel(info[0]);
            ic.setFont(new Font("Monospaced", Font.PLAIN, 16));
            JLabel txt = new JLabel(info[1]);
            txt.setFont(new Font("Monospaced", Font.PLAIN, 14));
            txt.setForeground(SUB);
            item.add(ic); item.add(txt);
            infoRow.add(item);
        }
        cuerpo.add(infoRow);

        add(cuerpo, BorderLayout.CENTER);

        JPanel footer = new JPanel(new FlowLayout(FlowLayout.CENTER, 0, 14));
        footer.setBackground(BG_HDR);

        JButton btnCerrar = boton("← Volver a niveles", new Color(60, 60, 80), SUB);
        btnCerrar.addActionListener(e -> { if (onCerrar != null) onCerrar.run(); });

        JButton btnComenzar = boton("⚔  ¡Comenzar el desafío!", tierColor, BG);
        btnComenzar.addActionListener(e -> construirPantallaEjercicios());

        footer.add(btnCerrar);
        footer.add(Box.createHorizontalStrut(18));
        footer.add(btnComenzar);
        add(footer, BorderLayout.SOUTH);

        revalidate();
        repaint();
    }

    private void construirPantallaEjercicios() {
        removeAll();
        setLayout(new BorderLayout());

        Color tierColor = TIER_COLORS[tier];

        JPanel header = new JPanel(new BorderLayout());
        header.setBackground(BG_HDR);
        header.setBorder(new EmptyBorder(10, 18, 10, 18));

        JLabel lblTitulo = new JLabel(boss.emoji() + "  " + boss.nombre() + "  ·  Tier " + tier);
        lblTitulo.setFont(new Font("Monospaced", Font.BOLD, 16));
        lblTitulo.setForeground(tierColor);

        barBossHp = new JProgressBar(0, 100);
        barBossHp.setValue(bossHp);
        barBossHp.setStringPainted(true);
        barBossHp.setString("  Jefe HP: " + bossHp + "%");
        barBossHp.setForeground(tierColor);
        barBossHp.setBackground(new Color(40, 40, 60));
        barBossHp.setBorderPainted(false);
        barBossHp.setFont(new Font("Monospaced", Font.BOLD, 12));
        barBossHp.setPreferredSize(new Dimension(220, 22));

        lblHpTexto = new JLabel("HP del jefe");
        lblHpTexto.setFont(new Font("Monospaced", Font.PLAIN, 12));
        lblHpTexto.setForeground(SUB);

        JPanel hpPanel = new JPanel(new FlowLayout(FlowLayout.RIGHT, 8, 0));
        hpPanel.setBackground(BG_HDR);
        hpPanel.add(lblHpTexto);
        hpPanel.add(barBossHp);

        header.add(lblTitulo, BorderLayout.WEST);
        header.add(hpPanel,   BorderLayout.EAST);
        add(header, BorderLayout.NORTH);

        JPanel centro = new JPanel();
        centro.setLayout(new BoxLayout(centro, BoxLayout.Y_AXIS));
        centro.setBackground(BG);
        centro.setBorder(new EmptyBorder(20, 28, 10, 28));

        lblPregunta = new JLabel();
        lblPregunta.setFont(new Font("Monospaced", Font.PLAIN, 17));
        lblPregunta.setForeground(TEXT);
        lblPregunta.setAlignmentX(Component.LEFT_ALIGNMENT);
        centro.add(lblPregunta);
        centro.add(Box.createVerticalStrut(18));

        panelRespuesta = new JPanel();
        panelRespuesta.setBackground(BG);
        panelRespuesta.setAlignmentX(Component.LEFT_ALIGNMENT);
        panelRespuesta.setMaximumSize(new Dimension(Integer.MAX_VALUE, 280));
        centro.add(panelRespuesta);
        centro.add(Box.createVerticalStrut(12));

        lblFeedback = new JLabel(" ");
        lblFeedback.setFont(new Font("Monospaced", Font.BOLD, 18));
        lblFeedback.setAlignmentX(Component.LEFT_ALIGNMENT);
        centro.add(lblFeedback);

        add(centro, BorderLayout.CENTER);

        JPanel footer = new JPanel(new BorderLayout());
        footer.setBackground(BG_HDR);
        footer.setBorder(new EmptyBorder(10, 18, 10, 18));

        JLabel lblNumero = new JLabel();
        lblNumero.setFont(new Font("Monospaced", Font.PLAIN, 13));
        lblNumero.setForeground(SUB);
        footer.add(lblNumero, BorderLayout.WEST);

        btnAccion = boton("Responder", ACCENT, BG);
        btnAccion.addActionListener(e -> onAccion());
        footer.add(btnAccion, BorderLayout.EAST);

        add(footer, BorderLayout.SOUTH);

        mostrarEjercicio();
        revalidate();
        repaint();
    }

    private void mostrarEjercicio() {
        if (indice >= boss.ejercicios().length) {
            mostrarResultado();
            return;
        }

        BossEj ej = boss.ejercicios()[indice];
        respuestaSeleccionada = null;
        lblFeedback.setText(" ");
        lblPregunta.setText("<html><body style='width:620px'>"
            + "<span style='color:#6c7086; font-size:11px'>DESAFÍO " + (indice + 1) + " / " + boss.ejercicios().length + "</span><br><br>"
            + ej.pregunta() + "</body></html>");

        btnAccion.setText("Responder");
        btnAccion.setBackground(ACCENT);
        btnAccion.setEnabled(true);
        for (var l : btnAccion.getActionListeners()) btnAccion.removeActionListener(l);
        btnAccion.addActionListener(e -> onAccion());

        panelRespuesta.removeAll();
        if (ej.opciones() != null) {
            construirOpciones(ej.opciones());
        } else {
            construirTerminal();
        }
        panelRespuesta.revalidate();
        panelRespuesta.repaint();
    }

    private void construirOpciones(String[] opciones) {
        panelRespuesta.setLayout(new GridLayout(0, 2, 10, 8));
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

    private void construirTerminal() {
        panelRespuesta.setLayout(new BorderLayout(0, 4));

        JLabel prompt = new JLabel("$");
        prompt.setFont(new Font("Monospaced", Font.BOLD, 20));
        prompt.setForeground(GREEN);
        prompt.setBorder(new EmptyBorder(0, 0, 0, 6));

        JTextField campo = new JTextField();
        campo.setFont(new Font("Monospaced", Font.PLAIN, 17));
        campo.setBackground(new Color(20, 22, 38));
        campo.setForeground(GREEN);
        campo.setCaretColor(GREEN);
        campo.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createLineBorder(new Color(69, 71, 90)),
            new EmptyBorder(10, 10, 10, 10)));
        campo.getDocument().addDocumentListener(new javax.swing.event.DocumentListener() {
            public void changedUpdate(javax.swing.event.DocumentEvent e) { respuestaSeleccionada = campo.getText(); }
            public void insertUpdate(javax.swing.event.DocumentEvent e)  { respuestaSeleccionada = campo.getText(); }
            public void removeUpdate(javax.swing.event.DocumentEvent e)  { respuestaSeleccionada = campo.getText(); }
        });
        campo.addActionListener(e -> onAccion());

        JPanel inputRow = new JPanel(new BorderLayout(8, 0));
        inputRow.setBackground(BG);
        inputRow.add(prompt, BorderLayout.WEST);
        inputRow.add(campo,  BorderLayout.CENTER);
        panelRespuesta.add(inputRow, BorderLayout.CENTER);
    }

    private void onAccion() {
        if ("Siguiente →".equals(btnAccion.getText())) {
            indice++;
            mostrarEjercicio();
            return;
        }
        if ("Ver resultado →".equals(btnAccion.getText())) {
            mostrarResultado();
            return;
        }

        if (respuestaSeleccionada == null || respuestaSeleccionada.isBlank()) {
            lblFeedback.setForeground(YELLOW);
            lblFeedback.setText("⚠  Selecciona o escribe una respuesta antes de continuar.");
            return;
        }

        BossEj ej = boss.ejercicios()[indice];
        boolean ok = ej.respuesta().trim().equalsIgnoreCase(respuestaSeleccionada.trim());

        if (ok) {
            aciertos++;
            bossHp = Math.max(0, 100 - (aciertos * (100 / boss.ejercicios().length)));
            barBossHp.setValue(bossHp);
            barBossHp.setString("  Jefe HP: " + bossHp + "%");
            lblFeedback.setForeground(GREEN);
            lblFeedback.setText("⚔  ¡Impacto! El jefe pierde HP.");
            SoundPlayer.playCorrect();
            bloquearRespuestas(ej.respuesta());
            btnAccion.setText(indice < boss.ejercicios().length - 1 ? "Siguiente →" : "Ver resultado →");
            btnAccion.setBackground(GREEN);
        } else {
            lblFeedback.setForeground(PINK);
            lblFeedback.setText("✘  " + ej.pista());
            SoundPlayer.playWrong();
        }
    }

    private void bloquearRespuestas(String respuestaCorrecta) {
        for (Component c : panelRespuesta.getComponents()) {
            if (c instanceof JToggleButton btn) {
                boolean esCorrecta = btn.getText().equalsIgnoreCase(respuestaCorrecta);
                if (esCorrecta) {
                    btn.setBackground(new Color(25, 60, 35));
                    btn.setForeground(GREEN);
                    btn.setBorder(BorderFactory.createCompoundBorder(
                        BorderFactory.createLineBorder(GREEN, 2), new EmptyBorder(10, 14, 10, 14)));
                }
                btn.setEnabled(false);
            } else if (c instanceof JPanel inner) {
                for (Component ic : inner.getComponents()) ic.setEnabled(false);
            }
        }
    }

    private void mostrarResultado() {
        boolean victoria = aciertos >= 3;

        if (victoria) {
            progresoService.completarNivelBoss(usuario.getIdUsuario(), idNivel);
            SoundPlayer.playLevelPass();
        } else {
            SoundPlayer.playWrong();
        }

        removeAll();
        setLayout(new BorderLayout());

        Color tierColor = TIER_COLORS[tier];

        JPanel banner = new JPanel();
        banner.setLayout(new BoxLayout(banner, BoxLayout.Y_AXIS));
        banner.setBackground(victoria ? new Color(14, 28, 46) : new Color(46, 16, 28));
        banner.setBorder(new EmptyBorder(36, 40, 28, 40));

        JLabel lblIco = new JLabel(victoria ? "🏆" : "💀", SwingConstants.CENTER);
        lblIco.setFont(new Font("Monospaced", Font.PLAIN, 58));
        lblIco.setAlignmentX(Component.CENTER_ALIGNMENT);

        JLabel lblTitulo = new JLabel(victoria
            ? "¡TIER " + tier + " CONQUISTADO!"
            : "El jefe te ha vencido esta vez...");
        lblTitulo.setFont(new Font("Monospaced", Font.BOLD, 26));
        lblTitulo.setForeground(victoria ? tierColor : PINK);
        lblTitulo.setAlignmentX(Component.CENTER_ALIGNMENT);

        JLabel lblScore = new JLabel(aciertos + " de " + boss.ejercicios().length + " desafíos superados");
        lblScore.setFont(new Font("Monospaced", Font.PLAIN, 15));
        lblScore.setForeground(SUB);
        lblScore.setAlignmentX(Component.CENTER_ALIGNMENT);

        JProgressBar barScore = new JProgressBar(0, boss.ejercicios().length);
        barScore.setValue(0);
        barScore.setStringPainted(false);
        barScore.setForeground(victoria ? tierColor : PINK);
        barScore.setBackground(new Color(38, 38, 58));
        barScore.setBorderPainted(false);
        barScore.setMaximumSize(new Dimension(400, 20));
        barScore.setAlignmentX(Component.CENTER_ALIGNMENT);

        banner.add(lblIco);
        banner.add(Box.createVerticalStrut(10));
        banner.add(lblTitulo);
        banner.add(Box.createVerticalStrut(8));
        banner.add(lblScore);
        banner.add(Box.createVerticalStrut(14));
        banner.add(barScore);
        add(banner, BorderLayout.NORTH);

        JPanel cuerpo = new JPanel();
        cuerpo.setLayout(new BoxLayout(cuerpo, BoxLayout.Y_AXIS));
        cuerpo.setBackground(BG_CARD);
        cuerpo.setBorder(new EmptyBorder(30, 60, 30, 60));

        if (victoria) {
            JLabel badge = new JLabel("🎖  Etapa «" + TIER_NAMES[tier] + "» dominada — Tier " + tier + " / 4");
            badge.setFont(new Font("Monospaced", Font.BOLD, 16));
            badge.setForeground(tierColor);
            badge.setAlignmentX(Component.CENTER_ALIGNMENT);
            cuerpo.add(badge);
            cuerpo.add(Box.createVerticalStrut(16));

            String msg = switch (tier) {
                case 1 -> "Has demostrado que puedes orientarte en cualquier sistema Linux. Los fundamentos son tuyas — ahora el mundo intermedio te espera.";
                case 2 -> "Procesos, permisos y búsquedas bajo control. Ya tienes el perfil de un técnico de sistemas capaz de resolver incidencias reales.";
                case 3 -> "Logs, tuberías y scripts: el stack del ingeniero DevOps está en tus manos. La infraestructura avanzada ya no tiene secretos para ti.";
                case 4 -> "Has completado los 4 tiers de LearnUX. Eres el Arquitecto. Cualquier servidor, cualquier terminal, cualquier reto: tú puedes con todo.";
                default -> "Nivel completado.";
            };

            JLabel lblMsg = new JLabel("<html><body style='width:520px; text-align:center; line-height:1.7'>" + msg + "</body></html>");
            lblMsg.setFont(new Font("Monospaced", Font.PLAIN, 15));
            lblMsg.setForeground(TEXT);
            lblMsg.setAlignmentX(Component.CENTER_ALIGNMENT);
            cuerpo.add(lblMsg);
        } else {
            JLabel lblConsejo = new JLabel("<html><body style='width:520px; text-align:center; line-height:1.7'>"
                + "No te desanimes. Cada error es una lección. Repasa los niveles del Tier "
                + tier + " y vuelve a enfrentar al jefe cuando te sientas más seguro. "
                + "Los mejores administradores de sistemas fallaron muchas veces antes de dominar la terminal."
                + "</body></html>");
            lblConsejo.setFont(new Font("Monospaced", Font.PLAIN, 15));
            lblConsejo.setForeground(new Color(160, 165, 190));
            lblConsejo.setAlignmentX(Component.CENTER_ALIGNMENT);
            cuerpo.add(lblConsejo);
        }

        add(cuerpo, BorderLayout.CENTER);

        JPanel footer = new JPanel(new FlowLayout(FlowLayout.CENTER, 18, 16));
        footer.setBackground(BG_HDR);

        JButton btnVolver = boton("← Volver a niveles", new Color(60, 60, 80), TEXT);
        btnVolver.addActionListener(e -> { if (onCerrar != null) onCerrar.run(); });
        footer.add(btnVolver);

        if (!victoria) {
            JButton btnReintentar = boton("↺  Reintentar jefe", tierColor, BG);
            btnReintentar.addActionListener(e -> {
                indice   = 0;
                aciertos = 0;
                bossHp   = 100;
                mostrarIntro();
            });
            footer.add(btnReintentar);
        }

        add(footer, BorderLayout.SOUTH);

        revalidate();
        repaint();

        int[] f = {0};
        javax.swing.Timer anim = new javax.swing.Timer(20, null);
        anim.addActionListener(e -> {
            f[0] = Math.min(f[0] + 1, aciertos);
            barScore.setValue(f[0]);
            if (f[0] >= aciertos) ((javax.swing.Timer) e.getSource()).stop();
        });
        anim.start();
    }

    private JButton boton(String texto, Color bg, Color fg) {
        JButton btn = new JButton(texto);
        btn.setFont(new Font("Monospaced", Font.BOLD, 16));
        btn.setBackground(bg);
        btn.setForeground(fg);
        btn.setBorderPainted(false);
        btn.setFocusPainted(false);
        btn.setBorder(new EmptyBorder(10, 24, 10, 24));
        btn.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        return btn;
    }
}
