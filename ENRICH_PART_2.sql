-- ============================================================
-- ENRICH_PART_2.sql
-- Segunda oleada de enriquecimiento: cat, touch y monitoreo.
-- ============================================================

SET session_replication_role = 'replica';

BEGIN;

-- 1. CAT: De "ver texto" a "concatenador"
UPDATE learnux.comandos SET descripcion = '<b>cat (Concatenate)</b>: El gran visor de archivos.<br><br><b>💡 Contexto:</b> Su nombre viene de su capacidad para unir (concatenar) varios archivos en uno solo. Es ideal para leer archivos cortos rápidamente o para volcar contenido de un archivo a otro usando tuberías (pipes).<br><br><b>🚀 Tip:</b> Si quieres leer un archivo MUY largo, usa mejor el comando <i>less</i> para poder navegar con las flechas.' WHERE comando_nombre = 'cat';

INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='cat'), '-n', 'Number: numera todas las líneas de salida (útil para código).', 'cat -n script.sh'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='cat'), '-b', 'Number-nonblank: numera solo las líneas que no están vacías.', 'cat -b notas.txt'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='cat'), '-s', 'Squeeze-blank: comprime múltiples líneas vacías en una sola.', 'cat -s archivo.txt'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='cat'), '-e', 'Show-ends: muestra un símbolo $ al final de cada línea (detecta espacios ocultos).', 'cat -e config.conf');

-- 2. TOUCH: No solo crea archivos
UPDATE learnux.comandos SET descripcion = '<b>touch</b>: El guardián del tiempo.<br><br><b>💡 Contexto:</b> Aunque el 90% del tiempo lo usamos para crear archivos vacíos, su función técnica es cambiar los "timestamps" (fechas) de los archivos.<br><br><b>⚙️ Utilidad:</b> Es crucial en sistemas de backup y compilación (como <i>make</i>) para engañar al sistema haciéndole creer que un archivo ha sido modificado recientemente.' WHERE comando_nombre = 'touch';

INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='touch'), '-a', 'Access-time: cambia solo la hora en que el archivo fue leído por última vez.', 'touch -a archivo.txt'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='touch'), '-m', 'Modification-time: cambia solo la hora en que el archivo fue escrito.', 'touch -m reporte.pdf'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='touch'), '-c', 'No-create: actualiza la fecha pero NO crea el archivo si no existe.', 'touch -c manual.txt'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='touch'), '-t', 'Timestamp: permite poner una fecha y hora exacta (formato [[CC]YY]MMDDhhmm).', 'touch -t 202401011200 old.txt'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='touch'), '-r', 'Reference: copia la fecha y hora de OTRO archivo.', 'touch -r original.jpg copia.jpg');

-- 3. PWD y CD: Los comandos de orientación
UPDATE learnux.comandos SET descripcion = '<b>pwd (Print Working Directory)</b>: ¿Dónde estoy?.<br><br><b>💡 Contexto:</b> En una interfaz gráfica siempre ves la carpeta, en la terminal es fácil "perderse" tras varios saltos. <b>pwd</b> te da la ruta absoluta completa.' WHERE comando_nombre = 'pwd';

INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='pwd'), '-P', 'Physical: muestra la ruta real, evitando enlaces simbólicos.', 'pwd -P'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='pwd'), '-L', 'Logical: muestra la ruta incluyendo los enlaces (comportamiento por defecto).', 'pwd -L');

INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='cd'), '~', 'Shortcut: te lleva instantáneamente a tu carpeta HOME.', 'cd ~'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='cd'), '..', 'Parent: sube un nivel en la jerarquía de carpetas.', 'cd ..'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='cd'), '-', 'Last: regresa a la carpeta anterior donde estabas.', 'cd -');

-- 4. SUDO y Comandos de Sistema
UPDATE learnux.comandos SET descripcion = '<b>sudo (SuperUser DO)</b>: El poder absoluto.<br><br><b>💡 Contexto:</b> Permite ejecutar comandos con privilegios de administrador (root). Es como "Ejecutar como administrador" en Windows, pero más seguro.<br><br><b>⚠️ Peligro:</b> "Un gran poder conlleva una gran responsabilidad". Un <i>sudo rm</i> mal puesto puede borrar tu sistema operativo entero.' WHERE comando_nombre = 'sudo';

INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='sudo'), '-i', 'Interactive: abre una terminal como root (cuidado aquí).', 'sudo -i'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='sudo'), '-u', 'User: ejecuta el comando como otro usuario específico (no solo root).', 'sudo -u dan comando'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='sudo'), '-l', 'List: muestra qué permisos tienes permitidos con sudo.', 'sudo -l');

-- 5. FREE y TOP: Salud del sistema
UPDATE learnux.comandos SET descripcion = '<b>free</b>: El termómetro de la memoria RAM.<br><br><b>📊 Datos:</b> Muestra cuánta RAM tienes total, usada, libre y en caché. También muestra la "Swap" (memoria de intercambio en disco).' WHERE comando_nombre = 'free';

INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='free'), '-h', 'Human-readable: muestra la RAM en GB y MB de forma automática.', 'free -h'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='free'), '-m', 'Megabytes: fuerza a mostrar los datos solo en MB.', 'free -m'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='free'), '-s', 'Seconds: actualiza la información cada N segundos.', 'free -h -s 5');

UPDATE learnux.comandos SET descripcion = '<b>top</b>: El administrador de tareas clásico.<br><br><b>📈 Vivo:</b> Muestra los procesos que más CPU y RAM consumen en tiempo real. Presiona "q" para salir.' WHERE comando_nombre = 'top';

INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='top'), '-d', 'Delay: cambia la velocidad de actualización (por defecto 3s).', 'top -d 1'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='top'), '-p', 'PID: monitorea únicamente procesos específicos por su ID.', 'top -p 1234,5678'),
((SELECT id_comando FROM learnux.comandos WHERE comando_nombre='top'), '-u', 'User: muestra solo los procesos de un usuario.', 'top -u dan');

COMMIT;
SET session_replication_role = 'origin';
