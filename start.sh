#!/bin/bash

# Redirigir la raíz "/" a vnc.html
echo '<meta http-equiv="refresh" content="0; url=/vnc.html">' > /usr/share/novnc/index.html

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

# Lanzar app y mostrar cualquier error en los logs
echo "=== Iniciando LearnUX ==="
java -jar /app/app.jar 2>&1
echo "=== Java termino con codigo: $? ==="

# Mantener el contenedor vivo para que se puedan leer los logs
tail -f /dev/null
