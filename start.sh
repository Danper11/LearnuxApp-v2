#!/bin/bash

# Redirigir la raíz "/" a vnc.html
echo '<meta http-equiv="refresh" content="0; url=/vnc.html?autoconnect=1&resize=scale&show_dot=false">' > /usr/share/novnc/index.html

# ── Sembrar base de datos si está vacía ──────────────────────
if [ -n "$DATABASE_URL" ]; then
    echo "=== Verificando base de datos ==="
    # Espera hasta que la BD esté lista (máx 30s)
    for i in $(seq 1 10); do
        psql "$DATABASE_URL" -c "SELECT 1" &>/dev/null && break
        echo "Esperando BD... intento $i"
        sleep 3
    done

    SCHEMA_EXISTS=$(psql "$DATABASE_URL" -tAc \
        "SELECT 1 FROM information_schema.schemata WHERE schema_name='learnux'" 2>/dev/null)

    if [ "$SCHEMA_EXISTS" != "1" ]; then
        echo "=== Sembrando base de datos (primera vez) ==="
        # Limpia el comando \restrict de Railway y adapta owner al usuario actual
        grep -v '\\restrict' /app/learnux_dump.sql \
            | sed 's/OWNER TO postgres/OWNER TO current_user/g' \
            | psql "$DATABASE_URL" -v ON_ERROR_STOP=0 2>&1
        psql "$DATABASE_URL" -f /app/ejercicios_adicionales.sql -v ON_ERROR_STOP=0 2>&1
        psql "$DATABASE_URL" -f /app/enriquecer_flags.sql        -v ON_ERROR_STOP=0 2>&1
        echo "=== Siembra completada ==="
    else
        echo "=== Base de datos ya inicializada, omitiendo siembra ==="
    fi

    # Migración idempotente: columna de contraseñas
    psql "$DATABASE_URL" -c \
        "ALTER TABLE learnux.usuarios ADD COLUMN IF NOT EXISTS password_hash TEXT;" 2>&1
fi

# ── Pantalla virtual con espera explícita ──────────────────
# Resolución reducida a 1280x720x16 para usar menos RAM en plan free.
start_xvfb() {
    Xvfb :1 -screen 0 1366x768x16 -ac -noreset >/tmp/xvfb.log 2>&1 &
    XVFB_PID=$!
    export DISPLAY=:1
    # Espera hasta que el socket X11 exista (máx 15s)
    for i in $(seq 1 30); do
        if [ -S /tmp/.X11-unix/X1 ]; then
            echo "=== Xvfb listo (PID $XVFB_PID) ==="
            return 0
        fi
        sleep 0.5
    done
    echo "=== ERROR: Xvfb no respondió en 15s ==="
    echo "--- xvfb.log ---"
    cat /tmp/xvfb.log
    return 1
}

# Asegura Xvfb arriba antes de seguir
until start_xvfb; do
    echo "=== Reintentando Xvfb en 5s ==="
    sleep 5
done

# Gestor de ventanas — oculta toolbar/slit que tapaban botones del juego
mkdir -p /root/.fluxbox
cat > /root/.fluxbox/init <<'FBEOF'
session.screen0.toolbar.visible: false
session.screen0.toolbar.autoHide: true
session.screen0.slit.autoHide: true
session.screen0.slit.maxOver: false
session.screen0.allowRemoteActions: false
session.screen0.fullMaximization: true
FBEOF
fluxbox >/dev/null 2>&1 &
sleep 0.5

# Servidor VNC
x11vnc -display :1 -nopw -listen localhost -rfbport 5900 -forever -quiet >/tmp/x11vnc.log 2>&1 &
sleep 0.5

# noVNC
PORT=${PORT:-8080}
websockify --web=/usr/share/novnc/ --wrap-mode=ignore "$PORT" localhost:5900 >/tmp/websockify.log 2>&1 &
sleep 0.5

# Lanzar app — se reinicia automáticamente si se cierra.
# Antes de relanzar, verifica que Xvfb siga vivo; si murió, lo resucita.
echo "=== Iniciando LearnUX ==="
while true; do
    if ! kill -0 "$XVFB_PID" 2>/dev/null; then
        echo "=== Xvfb murió, relanzando ==="
        start_xvfb || { sleep 5; continue; }
    fi
    java -Djava.awt.headless=false -jar /app/app.jar 2>&1
    echo "=== Java termino con codigo: $? — reiniciando en 5s ==="
    sleep 5
done
