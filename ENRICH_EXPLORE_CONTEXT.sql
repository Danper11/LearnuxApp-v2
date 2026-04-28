-- ============================================================
-- ENRICH_EXPLORE_CONTEXT.sql
-- Inyección de contexto profundo para el almanaque (Explorar).
-- ============================================================

SET session_replication_role = 'replica';

BEGIN;

-- ln: El comando de los enlaces
UPDATE learnux.comandos SET descripcion = '<b>ln (Link)</b>: Crea puentes entre archivos.<br><br><b>💡 Contexto:</b> En Linux, puedes hacer que un archivo aparezca en dos lugares a la vez sin duplicar su espacio en disco. Existen dos tipos:<br>' ||
    '· <b>Soft Links (-s):</b> Como los "Accesos directos" de Windows. Si borras el original, el link se rompe.<br>' ||
    '· <b>Hard Links:</b> Son clones reales. Si borras uno, el otro sigue vivo con el contenido intacto.<br><br>' ||
    '<b>🚀 Uso común:</b> Instalar programas manualmente creando un link en <i>/usr/local/bin</i>.'
WHERE comando_nombre = 'ln';

-- ps: La foto de los procesos
UPDATE learnux.comandos SET descripcion = '<b>ps (Process Status)</b>: Una "foto" instantánea de lo que corre en tu PC.<br><br><b>💡 Contexto:</b> A diferencia de <i>top</i> (que es un video en vivo), <b>ps</b> captura un momento exacto. Es fundamental para scripts o para encontrar el ID de un programa que se ha quedado colgado.<br><br>' ||
    '<b>🔍 Pro Tip:</b> Casi siempre lo usarás como <b>ps aux</b>. La "a" es para todos los usuarios, la "u" para ver el dueño y la "x" para incluir procesos sin terminal.'
WHERE comando_nombre = 'ps';

-- awk: El cirujano de columnas
UPDATE learnux.comandos SET descripcion = '<b>awk</b>: El procesador de datos por columnas.<br><br><b>💡 Contexto:</b> Es casi un lenguaje de programación por sí mismo. Su especialidad es leer archivos que parecen tablas (como listas de usuarios o logs) y extraer solo la columna que te interesa.<br><br>' ||
    '<b>📂 Ejemplo:</b> Si tienes una lista de nombres y edades, <b>awk</b> puede sumarlas todas o imprimir solo los nombres en segundos.'
WHERE comando_nombre = 'awk';

-- sed: El editor invisible
UPDATE learnux.comandos SET descripcion = '<b>sed (Stream Editor)</b>: Busca y reemplaza sin abrir el archivo.<br><br><b>💡 Contexto:</b> Es un editor de texto "en flujo". No necesitas abrir un archivo con <i>nano</i> o <i>vim</i> para cambiar una palabra. <b>sed</b> lo hace desde fuera, ideal para configurar servidores automáticamente.<br><br>' ||
    '<b>🚀 Comando estrella:</b> <i>sed "s/viejo/nuevo/g" archivo</i> reemplaza todas las apariciones de "viejo" por "nuevo".'
WHERE comando_nombre = 'sed';

-- df: El radar de espacio
UPDATE learnux.comandos SET descripcion = '<b>df (Disk Free)</b>: ¿Cuánto espacio me queda?.<br><br><b>💡 Contexto:</b> En un servidor, quedarse sin espacio es sinónimo de desastre (las bases de datos se corrompen). <b>df</b> te dice rápidamente qué disco o partición está a punto de llenarse.<br><br>' ||
    '<b>📦 Tip:</b> Siempre úsalo con <b>-h</b> para no tener que calcular bytes de cabeza.'
WHERE comando_nombre = 'df';

-- chmod: El portero de la discoteca
UPDATE learnux.comandos SET descripcion = '<b>chmod (Change Mode)</b>: Control de acceso total.<br><br><b>💡 Contexto:</b> Linux es multiusuario por naturaleza. <b>chmod</b> decide quién puede Leer (r), Escribir (w) o Ejecutar (x).<br><br>' ||
    '<b>🔢 El truco de los números:</b><br>' ||
    '· 7 (rwx) - Todo permitido.<br>' ||
    '· 5 (r-x) - Leer y correr programa.<br>' ||
    '· 4 (r--) - Solo lectura.<br>' ||
    'Ejemplo: <b>755</b> significa Yo (Todo), Grupo (Lectura/Ejecución), Otros (Lectura/Ejecución).'
WHERE comando_nombre = 'chmod';

-- mkdir: Mejorando el contexto
UPDATE learnux.comandos SET descripcion = '<b>mkdir (Make Directory)</b>: Crea tu propio orden.<br><br><b>💡 Contexto:</b> Organizar archivos es la base de un buen administrador. Con <b>mkdir</b> empiezas a construir la estructura de tus proyectos.<br><br>' ||
    '<b>🚀 Tip:</b> No crees carpetas una a una. Usa <b>mkdir -p</b> para crear una ruta completa como <i>fotos/2024/vacaciones</i> de un solo golpe.'
WHERE comando_nombre = 'mkdir';

-- cd: El vehículo
UPDATE learnux.comandos SET descripcion = '<b>cd (Change Directory)</b>: Viaja por el sistema de archivos.<br><br><b>💡 Contexto:</b> Es tu forma de moverte. Sin <b>cd</b>, estarías atrapado en una sola carpeta. Es el comando que más usarás junto a <i>ls</i>.<br><br>' ||
    '<b>📂 Atajos:</b><br>' ||
    '· <b>cd ..</b> : Retrocede (vuelve a la carpeta padre).<br>' ||
    '· <b>cd -</b> : Como el botón "Atrás" del mando de la tele (vuelve a donde estabas antes).'
WHERE comando_nombre = 'cd';

COMMIT;
SET session_replication_role = 'origin';
