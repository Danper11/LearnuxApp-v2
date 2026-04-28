-- ============================================================
-- REPAIR_DESCRIPTIONS.sql
-- Restaura descripciones detalladas de todos los niveles.
-- ============================================================

UPDATE learnux.niveles SET 
    nombre = 'Tu primer comando: ls',
    descripcion = '<b>ls</b> lista los archivos y carpetas del directorio actual. Es el comando más usado en Linux.<br><br><b>Uso:</b> ls [opciones] [ruta]<br><b>Ejemplo:</b> <b>ls /home</b> muestra los archivos de /home<br><br>Banderas útiles: <b>-l</b> (detalles), <b>-a</b> (incluye ocultos), <b>-h</b> (tamaños legibles)'
WHERE numero = 1;

UPDATE learnux.niveles SET 
    nombre = 'Navegar: pwd y cd',
    descripcion = '<b>pwd</b> imprime la ruta completa del directorio donde estás.<br><b>cd</b> cambia de directorio (te mueves por las carpetas).<br><br><b>Ejemplos:</b><br>· <b>pwd</b> → imprime /home/dan<br>· <b>cd /etc</b> → entra a la carpeta /etc<br>· <b>cd ..</b> → sube un nivel (va al directorio padre)<br>· <b>cd ~</b> → vuelve directo a tu carpeta personal (HOME)'
WHERE numero = 2;

UPDATE learnux.niveles SET 
    nombre = 'Crear carpetas: mkdir',
    descripcion = '<b>mkdir</b> crea un directorio (carpeta) nuevo.<br><br><b>Uso:</b> mkdir [opciones] nombre_carpeta<br><b>Ejemplo:</b> <b>mkdir proyectos</b> crea la carpeta "proyectos" donde estás<br><br>Con la bandera <b>-p</b> puedes crear carpetas anidadas de golpe:<br><b>mkdir -p proyectos/web/css</b> crea los tres niveles aunque no existan'
WHERE numero = 3;

UPDATE learnux.niveles SET 
    nombre = 'Copiar y mover: cp y mv',
    descripcion = '<b>cp</b> copia un archivo — el original se queda intacto.<br><b>mv</b> mueve o renombra — el original desaparece del lugar original.<br><br><b>Sintaxis:</b> cp/mv ORIGEN DESTINO<br><b>Ejemplos:</b><br>· <b>cp notas.txt copia.txt</b> → crea una copia llamada copia.txt<br>· <b>mv notas.txt diario.txt</b> → renombra el archivo a diario.txt<br>· <b>cp -r fotos/ backup/</b> → copia una carpeta completa (necesita -r)'
WHERE numero = 4;

UPDATE learnux.niveles SET 
    nombre = 'Leer y borrar: cat y rm',
    descripcion = '<b>cat</b> muestra el contenido completo de un archivo de texto en la terminal.<br><b>rm</b> elimina archivos — CUIDADO: no hay papelera, es permanente.<br><br><b>Ejemplos:</b><br>· <b>cat notas.txt</b> → imprime todo el contenido de notas.txt<br>· <b>rm viejo.txt</b> → borra viejo.txt para siempre<br>· <b>rm -r carpeta/</b> → borra una carpeta y todo su contenido<br>· <b>rm -i archivo</b> → pide confirmación antes de borrar (más seguro)'
WHERE numero = 5;

UPDATE learnux.niveles SET 
    nombre = 'Jefe Final: Fundamentos',
    descripcion = '<b>Tu primer desafío real</b><br>Después de aprender los conceptos básicos, es hora de ponerlos a prueba.<br><br>Deberás crear una estructura de directorios para un proyecto real, mover archivos de configuración, y limpiar archivos temporales.<br><br>Usa todo lo que aprendiste en niveles 1-5. No hay pistas esta vez.'
WHERE numero = 6;

UPDATE learnux.niveles SET 
    nombre = 'Flags de ls en detalle',
    descripcion = '<b>Más allá de ls -l y ls -a</b><br>El comando <b>ls</b> tiene flags muy útiles para trabajar con muchos archivos.<br><br><b>ls -lh</b>: combina detalles (-l) con tamaños legibles (-h).<br><b>ls -lt</b>: ordena por fecha de modificación.<br><b>ls -lS</b>: ordena por tamaño.<br><b>ls -R</b>: recursivo, muestra subdirectorios.'
WHERE numero = 7;

UPDATE learnux.niveles SET 
    nombre = 'touch y cat en profundidad',
    descripcion = '<b>touch: crear y actualizar</b><br><b>touch archivo.txt</b>: si el archivo no existe, lo crea vacío.<br><br><b>cat en profundidad</b><br><b>cat -n archivo</b>: muestra el contenido con <b>números de línea</b>.<br><b>cat archivo1 archivo2</b>: concatena varios archivos.'
WHERE numero = 10;

UPDATE learnux.niveles SET 
    nombre = 'Introducción a grep',
    descripcion = '<b>grep: buscar texto dentro de archivos</b><br>grep es uno de los comandos más potentes de Linux.<br><br><b>grep -i</b>: ignora mayúsculas/minúsculas.<br><b>grep -r</b>: busca recursivamente en directorios.<br><b>grep -n</b>: muestra el número de línea.<br><b>grep -c</b>: cuenta cuántas líneas coinciden.'
WHERE numero = 11;

UPDATE learnux.niveles SET 
    nombre = 'Terminal IV: permisos con chmod',
    descripcion = '<b>chmod: cambiar permisos</b><br>Cada archivo tiene tres grupos: <b>u</b> (dueño), <b>g</b> (grupo), <b>o</b> (otros).<br><br><b>Notación numérica</b>: r=4, w=2, x=1.<br><b>755</b>: dueño rwx, grupo+otros r-x.<br><b>600</b>: solo el dueño lee y escribe.'
WHERE numero = 16;

UPDATE learnux.niveles SET 
    nombre = 'Jefe Final: Maestro',
    descripcion = '<b>El sysadmin master</b><br>Este es el desafío final. Un servidor completo necesita tu ayuda.<br><br>Deberás:<br>- Buscar y reemplazar texto<br>- Crear scripts de backup<br>- Gestionar permisos complejos<br>- Limpiar y organizar estructuras'
WHERE numero = 24;
