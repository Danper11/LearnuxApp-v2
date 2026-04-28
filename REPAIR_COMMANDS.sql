-- ============================================================
-- REPAIR_COMMANDS.sql
-- Restaura descripciones detalladas de los comandos.
-- ============================================================

UPDATE learnux.comandos SET 
    descripcion = 'Lista el contenido de un directorio. Sin opciones muestra solo nombres; con -l muestra permisos, propietario, tamaño y fecha. Con -a incluye archivos ocultos. Fundamental para orientarse en el sistema.'
WHERE comando_nombre = 'ls';

UPDATE learnux.comandos SET 
    descripcion = 'Cambia el directorio de trabajo actual. Usa cd .. para subir un nivel, cd ~ para ir al home, cd - para volver al directorio anterior. El comando más usado en la terminal.'
WHERE comando_nombre = 'cd';

UPDATE learnux.comandos SET 
    descripcion = 'Copia archivos o directorios de ORIGEN a DESTINO. Si DESTINO es un directorio existente, copia dentro. Con -r copia directorios completos. No elimina el original.'
WHERE comando_nombre = 'cp';

UPDATE learnux.comandos SET 
    descripcion = 'Mueve archivos/directorios a otra ubicación o los renombra. Si DESTINO existe como directorio, mueve dentro. Sirve para mover Y para renombrar en un solo comando.'
WHERE comando_nombre = 'mv';

UPDATE learnux.comandos SET 
    descripcion = 'Crea uno o más directorios nuevos. Con -p crea toda la cadena de directorios padres si no existen, sin generar error si ya existen. Ideal para scripts de configuración.'
WHERE comando_nombre = 'mkdir';

UPDATE learnux.comandos SET 
    descripcion = 'Elimina archivos o directorios de forma permanente (no hay papelera). Con -r elimina directorios recursivamente; con -f fuerza sin pedir confirmación. Usar con cuidado.'
WHERE comando_nombre = 'rm';

UPDATE learnux.comandos SET 
    descripcion = 'Muestra la ruta absoluta del directorio de trabajo actual. Útil para saber exactamente dónde estás en el sistema de archivos, especialmente dentro de scripts.'
WHERE comando_nombre = 'pwd';

UPDATE learnux.comandos SET 
    descripcion = 'Busca texto dentro de archivos usando patrones. Muy potente con banderas como -i (ignorar mayúsculas), -r (recursivo) y -v (invertir búsqueda).'
WHERE comando_nombre = 'grep';

UPDATE learnux.comandos SET 
    descripcion = 'Busca archivos y directorios en el sistema basándose en criterios como nombre, tamaño, fecha de modificación o permisos.'
WHERE comando_nombre = 'find';

UPDATE learnux.comandos SET 
    descripcion = 'Cambia los permisos de acceso de archivos y directorios. Usa notación numérica (755) o simbólica (u+x) para controlar quién puede leer, escribir o ejecutar.'
WHERE comando_nombre = 'chmod';
