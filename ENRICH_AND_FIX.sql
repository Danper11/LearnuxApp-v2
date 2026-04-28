-- ============================================================
-- ENRICH_AND_FIX.sql
-- Repara el error de caracteres en Nivel 1 y enriquece descripciones.
-- ============================================================

SET session_replication_role = 'replica';

BEGIN;

-- 1. CORRECCIÓN DE EJERCICIOS NIVEL 1
-- Reparamos el ejercicio de la flag -t (ordenar por tiempo) con guiones correctos y más contexto
UPDATE learnux.ejercicios SET 
    pregunta = 'El comando ls muestra archivos por orden alfabético, pero a veces necesitas ver qué has modificado recientemente. ¿Qué bandera (flag) añade el orden por fecha de modificación?',
    respuesta_correcta = '-t',
    opciones_json = '["-t", "-r", "-S", "-a"]'::jsonb,
    pista = 'Viene de "time". Nota: Las mayúsculas importan en Linux.'
WHERE id_ejercicio = 200;

-- Añadimos un ejercicio extra de emparejamiento para dar contexto a las flags básicas (ls -l, -a, -h)
-- Borramos el anterior si existía con ID 2 para evitar conflictos
DELETE FROM learnux.ejercicios WHERE id_ejercicio = 2;
INSERT INTO learnux.ejercicios (id_ejercicio, id_nivel, id_comando, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden) VALUES
(2, 1, 1, 'DRAG_DROP', 
 'Las "flags" o banderas modifican el comportamiento del comando ls. Empareja cada una con su superpoder:',
 '{"-l":"Muestra detalles (permisos, tamaño, fecha)","-a":"Muestra TODO (incluye archivos ocultos . )","-h":"Hace los tamaños legibles (KB, MB, GB)"}',
 '["-l", "-a", "-h", "-R"]'::jsonb,
 'Usa -l para "long format" y -a para "all".', 2);

-- 2. ENRIQUECIMIENTO DE DESCRIPCIONES DE COMANDOS
UPDATE learnux.comandos SET descripcion = 
    '<b>ls (List)</b>: Tu brújula en la terminal.<br><br>' ||
    'Lista el contenido del directorio actual. Por defecto es minimalista, pero con flags se vuelve poderoso.<br><br>' ||
    '<b>💡 Uso Pro:</b> Usa <b>ls -lah</b> para ver absolutamente todo con detalles y en tamaños fáciles de leer.<br>' ||
    '<b>⚠️ Nota:</b> Los archivos que empiezan con punto (como <i>.bashrc</i>) son ocultos y solo se ven con <b>-a</b>.'
WHERE comando_nombre = 'ls';

UPDATE learnux.comandos SET descripcion = 
    '<b>cd (Change Directory)</b>: Tu vehículo para moverte.<br><br>' ||
    'Permite saltar entre carpetas. Es la base de la navegación en Linux.<br><br>' ||
    '<b>📂 Atajos rápidos:</b><br>' ||
    '· <b>cd ..</b> : Sube un nivel (al padre).<br>' ||
    '· <b>cd ~</b> : Vuelve a tu hogar (HOME) instantáneamente.<br>' ||
    '· <b>cd -</b> : Regresa a la carpeta donde estabas justo antes.'
WHERE comando_nombre = 'cd';

UPDATE learnux.comandos SET descripcion = 
    '<b>mkdir (Make Directory)</b>: Crea nuevos contenedores.<br><br>' ||
    'Sirve para organizar tus proyectos creando carpetas nuevas.<br><br>' ||
    '<b>🚀 Truco Maestro:</b> Usa <b>mkdir -p ruta/a/mi/carpeta</b> para crear toda una cadena de subcarpetas de una sola vez, aunque los padres no existan.'
WHERE comando_nombre = 'mkdir';

UPDATE learnux.comandos SET descripcion = 
    '<b>rm (Remove)</b>: El comando sin retorno.<br><br>' ||
    'Borra archivos o directorios de forma permanente. <b>En Linux no hay papelera de reciclaje</b>.<br><br>' ||
    '<b>🛑 Regla de Oro:</b> Siempre que uses <b>rm -rf</b>, detente un segundo y lee la ruta dos veces.<br>' ||
    '<b>🛡️ Seguridad:</b> Usa <b>rm -i</b> para que la terminal te pregunte antes de borrar cada archivo.'
WHERE comando_nombre = 'rm';

UPDATE learnux.comandos SET descripcion = 
    '<b>grep (Global Regular Expression Print)</b>: Tu buscador láser.<br><br>' ||
    'Busca texto dentro de los archivos. Es increíblemente rápido para encontrar errores en logs gigantes.<br><br>' ||
    '<b>🔍 Combinación ganadora:</b> <b>grep -rin "error" /var/log/</b> busca la palabra "error" de forma recursiva, ignorando mayúsculas y mostrando el número de línea.'
WHERE comando_nombre = 'grep';

COMMIT;
SET session_replication_role = 'origin';
