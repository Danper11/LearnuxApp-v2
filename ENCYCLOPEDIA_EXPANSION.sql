-- ============================================================
-- ENCYCLOPEDIA_EXPANSION.sql
-- Actualización masiva de banderas y descripciones pro.
-- ============================================================

SET session_replication_role = 'replica';

BEGIN;

-- 1. LIMPIEZA DE BANDERAS ACTUALES PARA EVITAR DUPLICADOS
TRUNCATE learnux.opciones_comando RESTART IDENTITY CASCADE;

-- 2. ENRIQUECIMIENTO DE DESCRIPCIONES (HTML para la UI)
UPDATE learnux.comandos SET descripcion = '<b>ls (List)</b>: El comando más usado. Permite ver qué hay dentro de una carpeta.<br><br><b>💡 Contexto:</b> En Linux, "todo es un archivo". <b>ls</b> es tu forma de confirmar que lo que hiciste (crear, mover, borrar) realmente sucedió.<br><br><b>⚠️ Nota:</b> Si ves archivos que empiezan con ".", no los borres a menos que sepas qué haces; son configuraciones críticas del sistema.' WHERE comando_nombre = 'ls';

UPDATE learnux.comandos SET descripcion = '<b>cp (Copy)</b>: Duplica la información.<br><br><b>💡 Contexto:</b> A diferencia de Windows, <b>cp</b> no pregunta nada por defecto. Si el destino ya existe, lo sobrescribirá sin avisar.<br><br><b>🚀 Tip:</b> Siempre usa <b>-i</b> (interactivo) si tienes miedo de perder un archivo importante al copiar.' WHERE comando_nombre = 'cp';

UPDATE learnux.comandos SET descripcion = '<b>mv (Move)</b>: El comando de doble propósito: mover y renombrar.<br><br><b>💡 Contexto:</b> En Linux no existe un comando "rename". Renombrar es simplemente "mover" un archivo a la misma carpeta pero con otro nombre.<br><br><b>📂 Ejemplo:</b> <i>mv viejo.txt nuevo.txt</i>' WHERE comando_nombre = 'mv';

UPDATE learnux.comandos SET descripcion = '<b>grep</b>: El buscador de agujas en pajares.<br><br><b>💡 Contexto:</b> Imagina un log de 1 millón de líneas. <b>grep</b> lo lee en milisegundos para encontrarte ese único error que buscas.<br><br><b>🛡️ Pro:</b> Es el mejor amigo del administrador para auditar accesos sospechosos en el servidor.' WHERE comando_nombre = 'grep';

UPDATE learnux.comandos SET descripcion = '<b>find</b>: El explorador incansable.<br><br><b>💡 Contexto:</b> A diferencia de <i>ls</i>, <b>find</b> busca profundamente en todo el árbol de directorios basándose en nombre, tamaño, fecha o dueños.' WHERE comando_nombre = 'find';

UPDATE learnux.comandos SET descripcion = '<b>tar (Tape Archiver)</b>: El empaquetador universal.<br><br><b>💡 Contexto:</b> Se originó para guardar datos en cintas magnéticas, hoy es el estándar para comprimir software (.tar.gz).<br><br><b>📦 Regla mnemotécnica:</b> c=Create (crear), x=eXtract (extraer).' WHERE comando_nombre = 'tar';

-- 3. INSERCIÓN MASIVA DE BANDERAS (Flags)

-- Flags de ls (ID 1)
INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='ls'), '-l', 'Formato largo: muestra permisos, dueño, tamaño y fecha.', 'ls -l'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='ls'), '-a', 'All: muestra archivos ocultos (los que empiezan con punto).', 'ls -a'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='ls'), '-h', 'Human-readable: muestra tamaños en KB, MB, GB en lugar de bytes.', 'ls -lh'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='ls'), '-t', 'Time: ordena por fecha de modificación (más nuevos arriba).', 'ls -lt'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='ls'), '-S', 'Size: ordena por tamaño de archivo (más pesados arriba).', 'ls -lS'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='ls'), '-r', 'Reverse: invierte el orden de la lista.', 'ls -ltr'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='ls'), '-R', 'Recursive: muestra también el contenido de todas las subcarpetas.', 'ls -R'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='ls'), '-1', 'Single column: muestra un archivo por línea (ideal para scripts).', 'ls -1');

-- Flags de cp (ID 2)
INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='cp'), '-r', 'Recursive: necesario para copiar carpetas completas.', 'cp -r carpeta/ destino/'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='cp'), '-i', 'Interactive: pregunta antes de sobrescribir archivos.', 'cp -i nota.txt backup/'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='cp'), '-v', 'Verbose: explica qué está haciendo en cada momento.', 'cp -rv fotos/ usb/'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='cp'), '-p', 'Preserve: mantiene los permisos y fechas originales del archivo.', 'cp -p script.sh /tmp/'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='cp'), '-u', 'Update: solo copia si el origen es más nuevo que el destino.', 'cp -u config.conf /backup/');

-- Flags de mv (ID 5)
INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='mv'), '-i', 'Interactive: pregunta antes de sobrescribir.', 'mv -i dato.txt destino/'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='mv'), '-n', 'No-clobber: no sobrescribe nunca un archivo existente.', 'mv -n archivo.txt backup/'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='mv'), '-v', 'Verbose: muestra el nombre del archivo mientras se mueve.', 'mv -v old.txt new.txt');

-- Flags de rm (ID 4)
INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='rm'), '-r', 'Recursive: borra carpetas y todo su contenido.', 'rm -r carpeta_vieja/'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='rm'), '-f', 'Force: borra sin preguntar y no da error si el archivo no existe.', 'rm -f archivo_fantasma'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='rm'), '-i', 'Interactive: pide confirmación antes de cada borrado.', 'rm -i *.jpg'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='rm'), '-v', 'Verbose: confirma qué archivos han sido eliminados.', 'rm -rv /tmp/cache/*');

-- Flags de grep (ID 14)
INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='grep'), '-i', 'Ignore-case: busca sin importar mayúsculas o minúsculas.', 'grep -i "error" log.txt'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='grep'), '-v', 'Invert-match: muestra las líneas que NO contienen el patrón.', 'grep -v "INFO" app.log'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='grep'), '-r', 'Recursive: busca dentro de todos los archivos de una carpeta.', 'grep -r "TODO" ./src'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='grep'), '-n', 'Line-number: muestra el número de línea de cada coincidencia.', 'grep -n "main" programa.c'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='grep'), '-c', 'Count: solo dice cuántas veces aparece la palabra.', 'grep -c "warning" sys.log'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='grep'), '-l', 'Files-with-matches: solo muestra los nombres de los archivos que contienen el texto.', 'grep -l "password" /etc/*');

-- Flags de tar (ID 16)
INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='tar'), '-c', 'Create: crea un nuevo archivo de archivo (empaquetar).', 'tar -cvf backup.tar docs/'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='tar'), '-x', 'eXtract: extrae el contenido de un archivo .tar.', 'tar -xvf backup.tar'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='tar'), '-z', 'gzip: comprime el archivo usando el algoritmo gzip (.tar.gz).', 'tar -czvf web.tar.gz /var/www'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='tar'), '-j', 'bzip2: compresión más lenta pero más eficiente (.tar.bz2).', 'tar -cjvf data.tar.bz2 /data'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='tar'), '-f', 'File: indica el nombre del archivo a manejar (siempre al final de las flags).', 'tar -f mi_archivo.tar'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='tar'), '-t', 'List: lista el contenido del archivo sin extraerlo.', 'tar -tf pack.tar');

-- Flags de chmod (ID 12)
INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='chmod'), '-R', 'Recursive: cambia permisos a carpetas y subcarpetas.', 'chmod -R 755 /var/www'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='chmod'), '+x', 'Añade permiso de ejecución.', 'chmod +x script.sh'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='chmod'), 'u+s', 'SetUID: permite ejecutar con privilegios del dueño.', 'chmod u+s binario');

-- Flags de df (ID 10)
INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='df'), '-h', 'Human-readable: muestra el espacio en GB y MB.', 'df -h'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='df'), '-T', 'Type: muestra el tipo de sistema de archivos (ext4, vfat, etc).', 'df -T'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='df'), '-i', 'Inodes: muestra el uso de inodos (útil si hay espacio pero no puedes crear archivos).', 'df -i');

-- Flags de ps (ID 20)
INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='ps'), 'aux', 'Muestra todos los procesos de todos los usuarios con detalle.', 'ps aux'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='ps'), '-ef', 'Formato estándar de sistema para ver todos los procesos.', 'ps -ef'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='ps'), '--forest', 'Muestra procesos en estructura de árbol (quién creó a quién).', 'ps aux --forest');

-- Flags de find (ID 15)
INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='find'), '-name', 'Busca por nombre exacto.', 'find . -name "*.log"'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='find'), '-type', 'Busca por tipo (f=archivo, d=directorio).', 'find /var -type d'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='find'), '-size', 'Busca por tamaño (+100M = más de 100MB).', 'find / -size +1G'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='find'), '-mtime', 'Busca por días desde la última modificación.', 'find . -mtime -7'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='find'), '-exec', 'Ejecuta un comando sobre cada resultado encontrado.', 'find . -name "*.tmp" -exec rm {} \;');

-- Flags de mkdir (ID 3)
INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='mkdir'), '-p', 'Parents: crea directorios padres si no existen sin dar error.', 'mkdir -p a/b/c'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='mkdir'), '-v', 'Verbose: imprime un mensaje por cada directorio creado.', 'mkdir -v nueva_carpeta');

COMMIT;
SET session_replication_role = 'origin';
