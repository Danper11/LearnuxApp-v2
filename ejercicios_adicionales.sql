-- ============================================================
-- ejercicios_adicionales.sql
-- Añade 2 ejercicios extra por nivel (niveles 1–20) para
-- alcanzar 5 ejercicios por nivel. IDs desde 200 en adelante.
-- ============================================================
SET search_path TO learnux;

-- ── NIVEL 1 — ls (DRAG_DROP) ──────────────────────────────────
INSERT INTO learnux.ejercicios
  (id_ejercicio, id_nivel, id_comando, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden, activo)
VALUES
  (200, 1, 1, 'DRAG_DROP',
   '¿Qué bandera de ls ordena los archivos del más reciente al más antiguo?',
   '-t',
   '["−t", "−r", "−s", "−a"]',
   't de "time": ordena por fecha de modificación.',
   4, true),

  (201, 1, 1, 'MULTIPLE_CHOICE',
   '¿Cuál de los siguientes comandos muestra los archivos de /etc ordenados por tamaño (mayor a menor)?',
   'ls -lS /etc',
   '["ls -lS /etc", "ls -lt /etc", "ls -lh /etc", "ls -R /etc"]',
   'S de "Size": ordena por tamaño de archivo.',
   5, true);

-- ── NIVEL 2 — pwd / cd (DRAG_DROP) ───────────────────────────
INSERT INTO learnux.ejercicios
  (id_ejercicio, id_nivel, id_comando, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden, activo)
VALUES
  (202, 2, 21, 'DRAG_DROP',
   '¿Qué símbolo representa el directorio HOME del usuario en Linux?',
   '~',
   '["~", "..", "/", "$HOME"]',
   'Es el símbolo tilde, siempre apunta a /home/tuusuario.',
   3, true),

  (203, 2, 21, 'TYPE_COMMAND',
   'Escribe el comando para volver al directorio HOME sin importar dónde estés.',
   'cd ~',
   NULL,
   'cd seguido del símbolo que representa HOME.',
   4, true);

-- ── NIVEL 3 — mkdir (DRAG_DROP) ──────────────────────────────
INSERT INTO learnux.ejercicios
  (id_ejercicio, id_nivel, id_comando, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden, activo)
VALUES
  (204, 3, 3, 'MULTIPLE_CHOICE',
   '¿Qué hace mkdir -v al crear un directorio?',
   'Muestra un mensaje por cada directorio creado',
   '["Muestra un mensaje por cada directorio creado", "Crea los directorios padre automáticamente", "Crea el directorio con permisos especiales", "Crea el directorio en modo silencioso"]',
   'v de verbose: muestra lo que está haciendo.',
   4, true),

  (205, 3, 3, 'TYPE_COMMAND',
   'Escribe el comando para crear tres directorios a la vez: config, logs y tmp.',
   'mkdir config logs tmp',
   NULL,
   'mkdir acepta múltiples nombres de directorio separados por espacios.',
   5, true);

-- ── NIVEL 4 — cp / mv (DRAG_DROP) ────────────────────────────
INSERT INTO learnux.ejercicios
  (id_ejercicio, id_nivel, id_comando, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden, activo)
VALUES
  (206, 4, 2, 'MULTIPLE_CHOICE',
   '¿Qué hace la bandera -n en el comando mv?',
   'No sobreescribe el archivo destino si ya existe',
   '["No sobreescribe el archivo destino si ya existe", "Mueve sin confirmación", "Crea el directorio destino si no existe", "Mueve en modo recursivo"]',
   '-n de "no-clobber": protege archivos existentes.',
   4, true),

  (207, 4, 2, 'TYPE_COMMAND',
   'Escribe el comando para copiar archivo.txt al directorio /tmp mostrando el progreso en pantalla.',
   'cp -v archivo.txt /tmp',
   NULL,
   'La bandera -v (verbose) muestra cada operación que realiza.',
   5, true);

-- ── NIVEL 5 — cat / rm (DRAG_DROP) ───────────────────────────
INSERT INTO learnux.ejercicios
  (id_ejercicio, id_nivel, id_comando, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden, activo)
VALUES
  (208, 5, 7, 'DRAG_DROP',
   '¿Qué comando crea un archivo vacío si no existe?',
   'touch',
   '["touch", "cat", "echo", "mkdir"]',
   'touch actualiza timestamps o crea el archivo si no existe.',
   4, true),

  (209, 5, 6, 'TYPE_COMMAND',
   'Escribe el comando para ver el contenido de /etc/hostname.',
   'cat /etc/hostname',
   NULL,
   'cat + ruta del archivo. /etc/hostname contiene el nombre del equipo.',
   5, true);

-- ── NIVEL 6 — ls opciones múltiples (MULTIPLE_CHOICE) ────────
INSERT INTO learnux.ejercicios
  (id_ejercicio, id_nivel, id_comando, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden, activo)
VALUES
  (210, 6, 1, 'MULTIPLE_CHOICE',
   '¿Qué combinación de banderas muestra todos los archivos (incluidos ocultos) ordenados del más nuevo al más antiguo?',
   'ls -alt',
   '["ls -alt", "ls -alS", "ls -alh", "ls -alR"]',
   '-a todos, -l detalles, -t ordenado por tiempo.',
   4, true),

  (211, 6, 1, 'TYPE_COMMAND',
   'Escribe el comando para listar solo los directorios en /var (pista: usa ls con grep).',
   'ls -l /var | grep ^d',
   NULL,
   'Combina ls -l con grep ^d (las líneas de directorio empiezan con d).',
   5, true);

-- ── NIVEL 7 — cp/mv opciones múltiples (MULTIPLE_CHOICE) ─────
INSERT INTO learnux.ejercicios
  (id_ejercicio, id_nivel, id_comando, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden, activo)
VALUES
  (212, 7, 2, 'MULTIPLE_CHOICE',
   '¿Qué hace cp -p al copiar un archivo?',
   'Preserva permisos, dueño y marcas de tiempo del original',
   '["Preserva permisos, dueño y marcas de tiempo del original", "Copia en modo recursivo", "Fuerza la copia sin preguntar", "Copia mostrando progreso"]',
   '-p de "preserve": mantiene los metadatos del archivo.',
   4, true),

  (213, 7, 5, 'TYPE_COMMAND',
   'Escribe el comando para mover todos los archivos .log de la carpeta actual al directorio /var/logs.',
   'mv *.log /var/logs',
   NULL,
   'mv + comodín *.log + directorio destino.',
   5, true);

-- ── NIVEL 8 — rm opciones múltiples (MULTIPLE_CHOICE) ────────
INSERT INTO learnux.ejercicios
  (id_ejercicio, id_nivel, id_comando, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden, activo)
VALUES
  (214, 8, 4, 'MULTIPLE_CHOICE',
   '¿Cuál es la forma MÁS SEGURA de borrar un directorio con contenido?',
   'rm -ri /tmp/carpeta',
   '["rm -ri /tmp/carpeta", "rm -rf /tmp/carpeta", "rm -r /tmp/carpeta", "rm -f /tmp/carpeta"]',
   '-r recursivo, -i interactivo (pide confirmación en cada paso).',
   4, true),

  (215, 8, 4, 'FILL_BLANK',
   'Completa: rm ___ *.bak (borrar todos los archivos .bak mostrando cada uno que borra)',
   '-v',
   '["-v", "-f", "-i", "-r"]',
   'v de verbose: muestra qué está borrando.',
   5, true);

-- ── NIVEL 9 — touch / cat (MULTIPLE_CHOICE) ──────────────────
INSERT INTO learnux.ejercicios
  (id_ejercicio, id_nivel, id_comando, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden, activo)
VALUES
  (216, 9, 7, 'MULTIPLE_CHOICE',
   'Quieres que un archivo tenga como fecha de modificación el 1 de enero de 2025 a las 12:00. ¿Qué comando usas?',
   'touch -t 202501011200 archivo.txt',
   '["touch -t 202501011200 archivo.txt", "touch -d 2025-01-01 archivo.txt", "touch -m 202501011200 archivo.txt", "touch -a 202501011200 archivo.txt"]',
   '-t permite especificar la fecha exacta en formato [[CC]YY]MMDDhhmm.',
   4, true),

  (217, 9, 6, 'TYPE_COMMAND',
   'Escribe el comando para unir el contenido de a.txt y b.txt en un nuevo archivo llamado combinado.txt.',
   'cat a.txt b.txt > combinado.txt',
   NULL,
   'cat acepta múltiples archivos y el > redirige la salida a un archivo nuevo.',
   5, true);

-- ── NIVEL 10 — grep (MULTIPLE_CHOICE) ────────────────────────
INSERT INTO learnux.ejercicios
  (id_ejercicio, id_nivel, id_comando, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden, activo)
VALUES
  (218, 10, 14, 'MULTIPLE_CHOICE',
   '¿Qué hace grep -l "error" /var/log/*.log?',
   'Muestra solo los nombres de archivos que contienen "error"',
   '["Muestra solo los nombres de archivos que contienen \"error\"", "Cuenta cuántas veces aparece \"error\"", "Muestra líneas con \"error\" y número de línea", "Busca \"error\" recursivamente en subdirectorios"]',
   '-l de "files with matches": lista solo los nombres de archivo, no las líneas.',
   4, true),

  (219, 10, 14, 'TYPE_COMMAND',
   'Escribe el comando para buscar líneas que NO contengan la palabra "ok" en resultado.txt.',
   'grep -v "ok" resultado.txt',
   NULL,
   '-v invierte la búsqueda: muestra las líneas que NO coinciden.',
   5, true);

-- ── NIVEL 11 — FILL_BLANK ─────────────────────────────────────
INSERT INTO learnux.ejercicios
  (id_ejercicio, id_nivel, id_comando, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden, activo)
VALUES
  (220, 11, 5, 'FILL_BLANK',
   'Completa: mv ___ viejo.txt nuevo.txt (renombrar sin sobreescribir si ya existe nuevo.txt)',
   '-n',
   '["-n", "-i", "-v", "-f"]',
   '-n de no-clobber: no sobreescribe archivos que ya existen.',
   4, true),

  (221, 11, 7, 'FILL_BLANK',
   'Completa: touch ___ archivo.txt (actualizar solo la fecha de acceso, no la de modificación)',
   '-a',
   '["-a", "-m", "-t", "-c"]',
   '-a de "access": actualiza solo la marca de tiempo de acceso.',
   5, true);

-- ── NIVEL 12 — FILL_BLANK ─────────────────────────────────────
INSERT INTO learnux.ejercicios
  (id_ejercicio, id_nivel, id_comando, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden, activo)
VALUES
  (222, 12, 14, 'FILL_BLANK',
   'Completa: grep ___ "TODO" /home/dan/proyecto (busca recursivamente y muestra solo los nombres de archivos)',
   '-rl',
   '["-rl", "-rc", "-ri", "-rn"]',
   'Necesitas -r (recursivo) y -l (solo nombres de archivo).',
   4, true),

  (223, 12, 12, 'FILL_BLANK',
   'Completa: chmod ___ deploy.sh (dar permiso de ejecución solo al dueño, sin tocar grupo y otros)',
   'u+x',
   '["u+x", "+x", "755", "o+x"]',
   'u = user (dueño), + = añadir, x = execute.',
   5, true);

-- ── NIVEL 13 — TYPE_COMMAND ───────────────────────────────────
INSERT INTO learnux.ejercicios
  (id_ejercicio, id_nivel, id_comando, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden, activo)
VALUES
  (224, 13, 14, 'TYPE_COMMAND',
   'Escribe el comando para buscar recursivamente la palabra "password" (sin distinguir mayúsculas) en /etc y mostrar solo los nombres de archivos.',
   'grep -ril "password" /etc',
   NULL,
   'Combina -r (recursivo), -i (ignore case) y -l (solo nombres de archivo).',
   4, true),

  (225, 13, 12, 'TYPE_COMMAND',
   'Escribe el comando para quitar el permiso de lectura a otros (o) en el archivo secreto.txt.',
   'chmod o-r secreto.txt',
   NULL,
   'o = others (otros), - = quitar, r = read.',
   5, true);

-- ── NIVEL 14 — TYPE_COMMAND (find) ───────────────────────────
INSERT INTO learnux.ejercicios
  (id_ejercicio, id_nivel, id_comando, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden, activo)
VALUES
  (226, 14, 15, 'TYPE_COMMAND',
   'Escribe el comando para encontrar archivos modificados en las últimas 24 horas dentro de /home.',
   'find /home -mtime -1',
   NULL,
   '-mtime -1 significa "modificado hace menos de 1 día (24 horas)".',
   4, true),

  (227, 14, 15, 'TYPE_COMMAND',
   'Escribe el comando para buscar archivos mayores de 100MB en /var.',
   'find /var -size +100M',
   NULL,
   '-size +100M: archivos de más de 100 megabytes.',
   5, true);

-- ── NIVEL 15 — TYPE_COMMAND (grep) ───────────────────────────
INSERT INTO learnux.ejercicios
  (id_ejercicio, id_nivel, id_comando, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden, activo)
VALUES
  (228, 15, 14, 'TYPE_COMMAND',
   'Escribe el comando para mostrar las 3 líneas de contexto ANTES de cada coincidencia de "FATAL" en app.log.',
   'grep -B 3 "FATAL" app.log',
   NULL,
   '-B N muestra N líneas Antes (Before) de la coincidencia.',
   4, true),

  (229, 15, 14, 'TYPE_COMMAND',
   'Escribe el comando para buscar líneas que empiecen con "ERROR" en syslog.',
   'grep "^ERROR" /var/log/syslog',
   NULL,
   '^ en regex significa "inicio de línea".',
   5, true);

-- ── NIVEL 16 — TERMINAL_SIM (pwd/ls) ─────────────────────────
INSERT INTO learnux.ejercicios
  (id_ejercicio, id_nivel, id_comando, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden, activo, salida_simulada)
VALUES
  (230, 16, 20, 'TERMINAL_SIM',
   'Quieres ver todos los procesos del sistema con su usuario, PID, CPU y memoria. ¿Qué comando escribes?',
   'ps aux',
   NULL,
   'ps aux: a=todos los usuarios, u=formato orientado a usuario, x=incluye procesos sin terminal.',
   4, true,
   'dan@learnux:~$ '),

  (231, 16, 9, 'TERMINAL_SIM',
   'Quieres monitorear el proceso con PID 1234 durante 5 iteraciones sin interacción. ¿Qué comando usas?',
   'top -n 5 -p 1234',
   NULL,
   '-n N: número de iteraciones, -p PID: monitorear proceso específico.',
   5, true,
   'dan@learnux:~$ ps aux | grep 1234\ndan   1234  0.5  1.2  12345  6789 pts/0  S  10:00  0:00 python app.py\ndan@learnux:~$ ');

-- ── NIVEL 17 — TERMINAL_SIM ───────────────────────────────────
INSERT INTO learnux.ejercicios
  (id_ejercicio, id_nivel, id_comando, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden, activo, salida_simulada)
VALUES
  (232, 17, 10, 'TERMINAL_SIM',
   'Quieres ver el espacio disponible en todos los discos en formato legible (GB, MB). ¿Qué comando usas?',
   'df -h',
   NULL,
   '-h de "human-readable": muestra en KB/MB/GB.',
   4, true,
   'dan@learnux:~$ '),

  (233, 17, 11, 'TERMINAL_SIM',
   'Quieres ver el uso de memoria RAM y swap mostrando totales al final. ¿Qué comando escribes?',
   'free -ht',
   NULL,
   '-h legible, -t muestra totales de RAM + swap al final.',
   5, true,
   'dan@learnux:~$ free -h\n              total  usada  libre\nMem:          7.7G   3.2G   4.5G\nSwap:         2.0G   0.0G   2.0G\ndan@learnux:~$ ');

-- ── NIVEL 18 — TERMINAL_SIM (grep avanzado) ──────────────────
INSERT INTO learnux.ejercicios
  (id_ejercicio, id_nivel, id_comando, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden, activo, salida_simulada)
VALUES
  (234, 18, 14, 'TERMINAL_SIM',
   'Quieres buscar la palabra "denied" en todos los logs de /var/log, mostrando el archivo y número de línea.',
   'grep -rn "denied" /var/log',
   NULL,
   '-r recursivo, -n muestra número de línea.',
   4, true,
   'dan@learnux:~$ '),

  (235, 18, 14, 'TERMINAL_SIM',
   'La siguiente salida fue producida por un comando grep. ¿Cuántas coincidencias había en total?',
   'grep -c "error" /var/log/syslog',
   NULL,
   '-c cuenta las coincidencias. La salida fue un número, no líneas.',
   5, true,
   '/var/log/syslog:47\ndan@learnux:~$ ');

-- ── NIVEL 19 — TERMINAL_SIM (chmod/permisos) ─────────────────
INSERT INTO learnux.ejercicios
  (id_ejercicio, id_nivel, id_comando, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden, activo, salida_simulada)
VALUES
  (236, 19, 12, 'TERMINAL_SIM',
   'Quieres hacer que todos los archivos .sh en /home/dan/scripts sean ejecutables para el dueño. ¿Qué comando usas?',
   'chmod u+x /home/dan/scripts/*.sh',
   NULL,
   'u+x añade ejecución al dueño. El comodín *.sh aplica a todos los scripts.',
   4, true,
   'dan@learnux:~$ ls -l /home/dan/scripts/\n-rw-r--r-- 1 dan dan 1024 ene 15 backup.sh\n-rw-r--r-- 1 dan dan  512 ene 15 deploy.sh\ndan@learnux:~$ '),

  (237, 19, 12, 'TERMINAL_SIM',
   'Tienes un directorio compartido /datos. Quieres que el grupo tenga permiso de escritura en él. ¿Qué comando usas?',
   'chmod g+w /datos',
   NULL,
   'g = group (grupo), +w = añadir escritura.',
   5, true,
   'dan@learnux:~$ ls -ld /datos\ndrwxr-xr-x 2 dan staff 4096 ene 15 /datos\ndan@learnux:~$ ');

-- ── NIVEL 20 — TERMINAL_SIM (find avanzado) ──────────────────
INSERT INTO learnux.ejercicios
  (id_ejercicio, id_nivel, id_comando, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden, activo, salida_simulada)
VALUES
  (238, 20, 15, 'TERMINAL_SIM',
   'Necesitas borrar todos los archivos .tmp dentro de /tmp que tengan más de 7 días. ¿Qué comando usas?',
   'find /tmp -name "*.tmp" -mtime +7 -delete',
   NULL,
   '-mtime +7 = más de 7 días, -delete los elimina directamente.',
   4, true,
   'root@learnux:~# find /tmp -name "*.tmp" | wc -l\n23\nroot@learnux:~# '),

  (239, 20, 16, 'TERMINAL_SIM',
   'Quieres crear un respaldo comprimido (gzip) de /etc llamado etc_backup.tar.gz. ¿Qué comando usas?',
   'tar -czf etc_backup.tar.gz /etc',
   NULL,
   '-c crear, -z comprimir con gzip, -f nombre del archivo, luego el origen.',
   5, true,
   'root@learnux:~# du -sh /etc\n14M    /etc\nroot@learnux:~# ');

-- ── Verificación (opcional) ───────────────────────────────────
-- SELECT id_nivel, COUNT(*) as total
-- FROM learnux.ejercicios
-- WHERE activo = true
-- GROUP BY id_nivel
-- ORDER BY id_nivel;
