#!/bin/bash
set -e

# Pantalla virtual (resolución igual al tamaño de la ventana de la app)
Xvfb :1 -screen 0 1360x840x24 -ac -noreset &
export DISPLAY=:1
sleep 1

# Gestor de ventanas mínimo (evita quirks de Swing sin WM)
fluxbox &
sleep 0.5

# Servidor VNC local (sin contraseña, solo escucha en localhost)
x11vnc -display :1 -nopw -listen localhost -rfbport 5900 -forever -quiet &
sleep 0.5

# noVNC: expone el escritorio virtual en el puerto que Railway asigna
PORT=${PORT:-8080}
websockify --web=/usr/share/novnc/ --wrap-mode=ignore "$PORT" localhost:5900 &

# Lanzar la aplicación (exec = este proceso ES el proceso principal del contenedor)
exec java -jar /app/app.jar
