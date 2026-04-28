-- Agregar 2 ejercicios DRAG_DROP a cada nivel de tier 1 y 2 que tiene solo 2 ejercicios.
-- Niveles afectados: 2, 3, 4, 5 (tier 1) y 7, 8, 9, 10, 11 (tier 2).
-- Niveles 6 y 12 (bosses) no se tocan.

-- ── Nivel 2: Navegar con pwd y cd ────────────────────────────────────
INSERT INTO learnux.ejercicios (id_nivel, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden)
VALUES
(2, 'DRAG_DROP',
 '¿Qué comando muestra la ruta absoluta del directorio donde te encuentras actualmente?',
 'pwd',
 '["pwd", "cd", "ls", "echo"]',
 'Print Working Directory: imprime el directorio de trabajo actual.',
 5),

(2, 'DRAG_DROP',
 'Para saltar al directorio en el que estabas ANTES del último cd, ¿qué escribes después de cd?',
 '-',
 '["-", "~", "..", "/"]',
 'Es un guion: cd - te lleva de vuelta al directorio anterior.',
 6);

-- ── Nivel 3: Crear carpetas con mkdir ────────────────────────────────
INSERT INTO learnux.ejercicios (id_nivel, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden)
VALUES
(3, 'DRAG_DROP',
 '¿Qué flag de mkdir crea automáticamente los directorios padre que falten en la ruta?',
 '-p',
 '["-p", "-v", "-r", "-m"]',
 'p de "parents": mkdir -p a/b/c crea a, luego a/b, luego a/b/c.',
 6),

(3, 'DRAG_DROP',
 'Elige el comando correcto para crear tres directorios (config, logs, tmp) en una sola línea.',
 'mkdir config logs tmp',
 '["mkdir config logs tmp", "mkdir -a config logs tmp", "touch config logs tmp", "mkdir config; mkdir logs"]',
 'mkdir acepta múltiples nombres separados por espacios en un solo comando.',
 7);

-- ── Nivel 4: Copiar y mover con cp y mv ──────────────────────────────
INSERT INTO learnux.ejercicios (id_nivel, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden)
VALUES
(4, 'DRAG_DROP',
 '¿Qué comando se usa para RENOMBRAR un archivo en Linux (sin moverlo de directorio)?',
 'mv',
 '["mv", "cp", "rename", "rn"]',
 'mv origen destino: si el destino está en el mismo directorio, el resultado es un renombrado.',
 6),

(4, 'DRAG_DROP',
 '¿Qué flag de cp hace que la copia sea recursiva para poder copiar directorios completos?',
 '-r',
 '["-r", "-p", "-v", "-f"]',
 'r de "recursive": recorre todos los archivos y subdirectorios dentro del directorio.',
 7);

-- ── Nivel 5: Leer y borrar con cat y rm ──────────────────────────────
INSERT INTO learnux.ejercicios (id_nivel, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden)
VALUES
(5, 'DRAG_DROP',
 '¿Qué flag de rm pide confirmación antes de borrar cada archivo?',
 '-i',
 '["-i", "-f", "-v", "-r"]',
 'i de "interactive": te pregunta "¿seguro?" antes de cada borrado.',
 6),

(5, 'DRAG_DROP',
 '¿Qué combinación de flags borra un directorio con todo su contenido sin pedir confirmación?',
 '-rf',
 '["-rf", "-ri", "-if", "-rv"]',
 'r de recursive + f de force. ¡Úsalo con cuidado, no hay papelera!',
 7);

-- ── Nivel 7: Flags de ls en detalle ──────────────────────────────────
INSERT INTO learnux.ejercicios (id_nivel, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden)
VALUES
(7, 'DRAG_DROP',
 '¿Qué flag de ls muestra TODOS los archivos, incluidos los ocultos (los que empiezan con .)?',
 '-a',
 '["-a", "-l", "-h", "-r"]',
 'a de "all": sin este flag, ls oculta los archivos cuyo nombre empieza con punto.',
 6),

(7, 'DRAG_DROP',
 '¿Qué flag de ls ordena los resultados por fecha de modificación, del más reciente al más antiguo?',
 '-t',
 '["-t", "-s", "-u", "-c"]',
 't de "time": muy útil para ver rápidamente qué archivos cambiaron últimamente.',
 7);

-- ── Nivel 8: cp y mv con flags ────────────────────────────────────────
INSERT INTO learnux.ejercicios (id_nivel, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden)
VALUES
(8, 'DRAG_DROP',
 '¿Qué flag de cp preserva los permisos, dueño y timestamps del archivo original?',
 '-p',
 '["-p", "-r", "-v", "-u"]',
 'p de "preserve": mantiene los metadatos intactos, útil en backups.',
 6),

(8, 'DRAG_DROP',
 'Arrastra el flag de mv que muestra en pantalla cada archivo que se está moviendo.',
 '-v',
 '["-v", "-f", "-n", "-b"]',
 'v de "verbose": te confirma visualmente qué operaciones se realizaron.',
 7);

-- ── Nivel 9: rm y sus peligros ────────────────────────────────────────
INSERT INTO learnux.ejercicios (id_nivel, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden)
VALUES
(9, 'DRAG_DROP',
 '¿Qué flag de rm borra forzosamente sin mostrar errores ni pedir confirmación?',
 '-f',
 '["-f", "-i", "-v", "-r"]',
 'f de "force": ignora archivos inexistentes y nunca pregunta. Peligroso sin -r.',
 6),

(9, 'DRAG_DROP',
 '¿Qué comando (diferente a rm) se usa para borrar un directorio vacío de forma segura?',
 'rmdir',
 '["rmdir", "rd", "del", "rm -d"]',
 'rmdir solo funciona si el directorio está completamente vacío, lo cual lo hace seguro.',
 7);

-- ── Nivel 10: touch y cat en profundidad ──────────────────────────────
INSERT INTO learnux.ejercicios (id_nivel, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden)
VALUES
(10, 'DRAG_DROP',
 '¿Qué flag de cat numera TODAS las líneas del archivo, incluidas las líneas vacías?',
 '-n',
 '["-n", "-b", "-v", "-A"]',
 'n de "number": -b también numera líneas pero salta las vacías.',
 6),

(10, 'DRAG_DROP',
 '¿Qué flag de touch actualiza SOLO la fecha de modificación sin tocar la fecha de acceso?',
 '-m',
 '["-m", "-a", "-t", "-c"]',
 'm de "modification": su opuesto es -a que actualiza solo la fecha de acceso.',
 7);

-- ── Nivel 11: Introducción a grep ─────────────────────────────────────
INSERT INTO learnux.ejercicios (id_nivel, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden)
VALUES
(11, 'DRAG_DROP',
 '¿Qué flag de grep hace que la búsqueda ignore mayúsculas y minúsculas?',
 '-i',
 '["-i", "-v", "-n", "-c"]',
 'i de "ignore-case": con este flag "Error", "error" y "ERROR" son lo mismo.',
 6),

(11, 'DRAG_DROP',
 '¿Qué flag de grep muestra el número de línea donde aparece cada coincidencia?',
 '-n',
 '["-n", "-c", "-l", "-i"]',
 'n de "line number": te dice exactamente en qué línea está cada resultado.',
 7);
