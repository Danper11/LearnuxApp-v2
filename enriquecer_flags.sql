-- ============================================================
-- ENRIQUECIMIENTO DE FLAGS EN opciones_comando
-- Agrega/completa banderas para todos los comandos
-- ============================================================

-- cp (id=2) -----------------------------------------------
INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
  (2, '-r',  'Copia directorios completos de forma recursiva',         'cp -r proyectos/ backup/'),
  (2, '-i',  'Pide confirmación si el archivo destino ya existe',      'cp -i notas.txt /home/dan/'),
  (2, '-v',  'Muestra en pantalla cada archivo que se está copiando',  'cp -v *.txt /backup/'),
  (2, '-p',  'Preserva permisos, fechas y propietario del original',   'cp -p config.conf config.conf.bak');

-- mv (id=5) -----------------------------------------------
INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
  (5, '-i',  'Pide confirmación antes de sobrescribir un archivo',     'mv -i viejo.txt nuevo.txt'),
  (5, '-v',  'Muestra cada archivo que se mueve o renombra',           'mv -v *.log /var/log/old/'),
  (5, '-n',  'No sobrescribe archivos si el destino ya existe',        'mv -n foto.jpg /fotos/');

-- touch (id=7) --------------------------------------------
INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
  (7, '-t',  'Establece una fecha y hora específica (en vez de ahora)', 'touch -t 202501011200 archivo.txt'),
  (7, '-a',  'Solo actualiza la fecha de último acceso del archivo',   'touch -a log.txt'),
  (7, '-m',  'Solo actualiza la fecha de última modificación',         'touch -m log.txt');

-- pwd (id=8) -----------------------------------------------
INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
  (8, '-L',  'Muestra la ruta lógica (respeta los enlaces simbólicos)', 'pwd -L'),
  (8, '-P',  'Muestra la ruta física real (resuelve los symlinks)',     'pwd -P');

-- top (id=9) -----------------------------------------------
INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
  (9, '-n',  'Ejecuta top durante N ciclos y luego sale automáticamente', 'top -n 5'),
  (9, '-u',  'Muestra solo los procesos de un usuario concreto',          'top -u dan'),
  (9, '-d',  'Intervalo de refresco en segundos (por defecto 3s)',         'top -d 1');

-- cat (id=6) — ya tiene -n, se añaden más ------------------
INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
  (6, '-b',  'Numera solo las líneas no vacías',                        'cat -b script.sh'),
  (6, '-A',  'Muestra caracteres especiales: tabs (^I) y fin de línea', 'cat -A config.ini'),
  (6, '-s',  'Comprime múltiples líneas en blanco consecutivas en una', 'cat -s texto_largo.txt');

-- rm (id=4) — ya tiene -r y -f, se añaden más ---------------
INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
  (4, '-i',  'Pregunta confirmación antes de borrar cada archivo',      'rm -i *.bak'),
  (4, '-v',  'Muestra el nombre de cada archivo eliminado',             'rm -v /tmp/*.log');

-- mkdir (id=3) — ya tiene -p, se añaden más -----------------
INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
  (3, '-v',  'Muestra un mensaje por cada directorio creado',           'mkdir -v nueva_carpeta'),
  (3, '-m',  'Establece los permisos del directorio al crearlo',        'mkdir -m 755 publica');

-- grep (id=14) — ya tiene -i y -r, se añaden más ------------
INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
  (14, '-n', 'Muestra el número de línea de cada coincidencia encontrada', 'grep -n "ERROR" app.log'),
  (14, '-v', 'Invierte la búsqueda: muestra líneas que NO coinciden',       'grep -v "DEBUG" app.log'),
  (14, '-c', 'Cuenta cuántas líneas contienen la coincidencia',             'grep -c "warning" syslog'),
  (14, '-l', 'Muestra solo los nombres de archivos con coincidencias',      'grep -l "TODO" src/*.java'),
  (14, '-E', 'Activa expresiones regulares extendidas (regex)',             'grep -E "error|warn" log.txt');

-- find (id=15) — ya tiene -name y -type, se añaden más ------
INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
  (15, '-size',     'Filtra por tamaño: +Nc mayor, -Nc menor (k=KB, M=MB)',    'find /var -size +10M'),
  (15, '-mtime',    'Archivos modificados hace N días (-7 = últimos 7 días)',   'find . -mtime -7'),
  (15, '-exec',     'Ejecuta un comando sobre cada resultado encontrado',       'find . -name "*.log" -exec rm {} \\;'),
  (15, '-maxdepth', 'Limita la profundidad máxima de búsqueda en directorios', 'find . -maxdepth 2 -name "*.conf"');

-- chmod (id=12) — ya tiene -R, se añaden más ----------------
INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
  (12, '-v',  'Muestra cada archivo cuyos permisos se han cambiado',    'chmod -v 644 *.txt'),
  (12, '+x',  'Añade permiso de ejecución (sin cambiar el resto)',      'chmod +x script.sh'),
  (12, 'u+w', 'Da permiso de escritura solo al propietario (user)',     'chmod u+w informe.txt'),
  (12, 'o-r', 'Quita permiso de lectura a otros (others)',              'chmod o-r privado.conf');

-- df (id=10) — ya tiene -h, se añaden más -------------------
INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
  (10, '-T',  'Muestra el tipo de sistema de archivos (ext4, tmpfs…)',  'df -T'),
  (10, '-i',  'Muestra uso de inodos en lugar de espacio en bloques',   'df -i /home');

-- free (id=11) — ya tiene -h, se añaden más -----------------
INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
  (11, '-s',  'Refresca la pantalla cada N segundos de forma continua', 'free -h -s 2'),
  (11, '-t',  'Añade una fila con el total de RAM + swap combinados',   'free -t -h');

-- tar (id=16) — ya tiene -cvf y -xvf, se añaden más ---------
INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
  (16, '-z',  'Comprime o descomprime usando gzip (.tar.gz)',           'tar -czvf backup.tar.gz /docs'),
  (16, '-j',  'Comprime o descomprime usando bzip2 (.tar.bz2)',         'tar -cjvf backup.tar.bz2 /docs'),
  (16, '-t',  'Lista el contenido del archivo tar sin extraer nada',    'tar -tvf backup.tar'),
  (16, '-C',  'Extrae los archivos en el directorio indicado',          'tar -xvf backup.tar -C /destino/');

-- ps (id=20) — ya tiene -aux, se añaden más -----------------
INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
  (20, '-e',        'Muestra todos los procesos en ejecución del sistema',        'ps -e'),
  (20, '--forest',  'Muestra procesos en árbol mostrando la jerarquía padre-hijo','ps aux --forest'),
  (20, '-p',        'Muestra información solo del PID indicado',                  'ps -p 1234');

-- sudo (id=13) — ya tiene -u, se añaden más -----------------
INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
  (13, '-l',  'Lista los comandos que tienes permiso de ejecutar con sudo', 'sudo -l'),
  (13, '-s',  'Abre una shell como superusuario en el directorio actual',   'sudo -s'),
  (13, '-i',  'Inicia sesión interactiva completa como root (con su entorno)','sudo -i');

-- awk (id=17) — sin banderas todavía -------------------------
INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
  (17, '-F',  'Define el separador de campo al procesar líneas',            'awk -F: ''{print $1}'' /etc/passwd'),
  (17, '-v',  'Asigna un valor a una variable antes de ejecutar el script','awk -v n=5 ''NR<=n{print}'' datos.txt'),
  (17, '-f',  'Lee el programa awk desde un archivo externo en vez de inline','awk -f analisis.awk datos.txt');

-- sed (id=18) — sin banderas todavía -------------------------
INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
  (18, '-i',  'Modifica el archivo original directamente (in-place)',      'sed -i ''s/http/https/g'' config.txt'),
  (18, '-n',  'Suprime la salida; solo imprime lo que /p indique',         'sed -n ''5,10p'' archivo.txt'),
  (18, '-e',  'Permite encadenar múltiples expresiones en un solo comando','sed -e ''s/foo/bar/g'' -e ''s/baz/qux/g'' f.txt'),
  (18, '-E',  'Activa expresiones regulares extendidas (ERE)',             'sed -E ''s/(error|warn)/[!]/gi'' log.txt');

-- ln (id=19) — sin banderas todavía --------------------------
INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
  (19, '-s',  'Crea un enlace simbólico (acceso directo al archivo original)', 'ln -s /etc/nginx/sites-available/app /etc/nginx/sites-enabled/app'),
  (19, '-f',  'Sobreescribe el enlace destino si ya existe',                   'ln -sf /nueva/ruta/bin /usr/local/bin/app'),
  (19, '-v',  'Muestra en pantalla el nombre de cada enlace creado',           'ln -sv origen destino');
