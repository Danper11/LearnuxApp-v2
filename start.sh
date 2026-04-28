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

# Pantalla virtual
Xvfb :1 -screen 0 1360x840x24 -ac -noreset &
export DISPLAY=:1
sleep 2

# Gestor de ventanas
fluxbox &
sleep 0.5

# Servidor VNC
x11vnc -display :1 -nopw -listen localhost -rfbport 5900 -forever -quiet &
sleep 0.5

# noVNC
PORT=${PORT:-8080}
websockify --web=/usr/share/novnc/ --wrap-mode=ignore "$PORT" localhost:5900 &
sleep 0.5

# Lanzar app — se reinicia automáticamente si se cierra
echo "=== Iniciando LearnUX ==="
while true; do
    java -Djava.awt.headless=false -jar /app/app.jar 2>&1
    echo "=== Java termino con codigo: $? — reiniciando en 3s ==="
    sleep 3
done
