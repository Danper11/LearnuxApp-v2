-- ============================================================
-- MASTER_REPAIR.sql (v5 - Direct Execution)
-- ============================================================

-- Forzamos limpieza total (sin transacciones para evitar abortos en cadena)
TRUNCATE learnux.opciones_comando RESTART IDENTITY CASCADE;
TRUNCATE learnux.ejercicios RESTART IDENTITY CASCADE;
TRUNCATE learnux.comandos RESTART IDENTITY CASCADE;
TRUNCATE learnux.niveles RESTART IDENTITY CASCADE;
TRUNCATE learnux.categorias RESTART IDENTITY CASCADE;
TRUNCATE learnux.progreso_nivel RESTART IDENTITY CASCADE;
TRUNCATE learnux.intentos_ejercicio RESTART IDENTITY CASCADE;
TRUNCATE learnux.progreso_usuarios RESTART IDENTITY CASCADE;

-- 1. Categorías
INSERT INTO learnux.categorias (id_categoria, nombre, descripcion) VALUES
(1, 'fundamentos', 'Navegación básica'),
(2, 'gestion de sistema', 'Procesos y recursos'),
(3, 'permisos y seguridad', 'Gestión de acceso'),
(4, 'busqueda y filtrado', 'Grep y find'),
(5, 'compresion y empaquetado', 'Tar y otros');

-- 2. Comandos
INSERT INTO learnux.comandos (id_comando, id_categoria, comando_nombre, descripcion, sintaxis, dificultad_nivel) VALUES
(1, 1, 'ls', 'Lista archivos', 'ls [OPCION]', 'principiante'),
(2, 1, 'cp', 'Copia archivos', 'cp ORIGEN DESTINO', 'principiante'),
(3, 1, 'mkdir', 'Crea carpetas', 'mkdir DIR', 'principiante'),
(4, 1, 'rm', 'Borra archivos', 'rm ARCHIVO', 'intermedio'),
(5, 1, 'mv', 'Mueve archivos', 'mv ORIGEN DESTINO', 'principiante'),
(6, 1, 'cat', 'Muestra texto', 'cat ARCHIVO', 'principiante'),
(7, 1, 'touch', 'Crea archivos', 'touch ARCHIVO', 'principiante'),
(8, 1, 'pwd', 'Ruta actual', 'pwd', 'principiante'),
(9, 2, 'top', 'Procesos', 'top', 'intermedio'),
(10, 2, 'df', 'Disco', 'df', 'intermedio'),
(11, 2, 'free', 'RAM', 'free', 'intermedio'),
(12, 3, 'chmod', 'Permisos', 'chmod MODO', 'intermedio'),
(13, 3, 'sudo', 'Superusuario', 'sudo CMD', 'intermedio'),
(14, 4, 'grep', 'Busca texto', 'grep PATRON', 'intermedio'),
(15, 4, 'find', 'Busca archivos', 'find RUTA', 'intermedio'),
(16, 5, 'tar', 'Empaqueta', 'tar CMD', 'intermedio'),
(17, 4, 'awk', 'Procesa columnas', 'awk PROG', 'avanzado'),
(18, 4, 'sed', 'Edita flujo', 'sed SCRIPT', 'avanzado'),
(19, 1, 'ln', 'Enlaces', 'ln ORIGEN DEST', 'intermedio'),
(20, 2, 'ps', 'Procesos snap', 'ps', 'intermedio'),
(21, 1, 'cd', 'Cambia dir', 'cd DIR', 'principiante');

-- 3. Niveles (1 al 24) - Usamos 'avanzado' para el 24 para evitar el error 'maestro' por si acaso
INSERT INTO learnux.niveles (id_nivel, numero, nombre, tipo_ejercicio, dificultad, puntos_para_pasar, puntos_recompensa, desbloqueado_por) VALUES
(1, 1, 'Tu primer comando: ls', 'DRAG_DROP', 'principiante', 50, 15, NULL),
(2, 2, 'Navegar: pwd y cd', 'DRAG_DROP', 'principiante', 50, 15, 1),
(3, 3, 'Crear carpetas: mkdir', 'DRAG_DROP', 'principiante', 50, 15, 2),
(4, 4, 'Copiar y mover: cp y mv', 'DRAG_DROP', 'principiante', 60, 15, 3),
(5, 5, 'Leer y borrar: cat y rm', 'DRAG_DROP', 'principiante', 60, 15, 4),
(6, 6, 'Jefe Final: Fundamentos', 'TERMINAL_SIM', 'principiante', 70, 30, 5),
(7, 7, 'Flags de ls en detalle', 'MULTIPLE_CHOICE', 'principiante', 60, 15, 6),
(8, 8, 'cp y mv con flags', 'MULTIPLE_CHOICE', 'principiante', 60, 15, 7),
(9, 9, 'rm y sus peligros', 'MULTIPLE_CHOICE', 'principiante', 60, 15, 8),
(10, 10, 'touch y cat profundo', 'MULTIPLE_CHOICE', 'intermedio', 60, 15, 9),
(11, 11, 'Introducción a grep', 'MULTIPLE_CHOICE', 'intermedio', 60, 15, 10),
(12, 12, 'Jefe Final: Intermedio', 'TERMINAL_SIM', 'intermedio', 70, 35, 11),
(13, 13, 'Completa: Básicos', 'FILL_BLANK', 'intermedio', 65, 20, 12),
(14, 14, 'Completa: Avanzados', 'FILL_BLANK', 'intermedio', 65, 20, 13),
(15, 15, 'Escribe: find y grep', 'TYPE_COMMAND', 'intermedio', 65, 20, 14),
(16, 16, 'Permisos con chmod', 'TYPE_COMMAND', 'intermedio', 65, 20, 15),
(17, 17, 'Terminal: Gestión', 'TERMINAL_SIM', 'avanzado', 70, 25, 16),
(18, 18, 'Jefe Final: Avanzado', 'TERMINAL_SIM', 'avanzado', 75, 40, 17),
(19, 19, 'Terminal: Red y Discos', 'TERMINAL_SIM', 'avanzado', 70, 25, 18),
(20, 20, 'Terminal: Búsqueda Pro', 'TERMINAL_SIM', 'avanzado', 70, 25, 19),
(21, 21, 'Compresión con tar', 'TYPE_COMMAND', 'intermedio', 65, 20, 20),
(22, 22, 'Procesos con ps y top', 'TERMINAL_SIM', 'intermedio', 70, 25, 21),
(23, 23, 'Filtros AWK y SED', 'TYPE_COMMAND', 'avanzado', 75, 30, 22),
(24, 24, 'Jefe Final: Maestro', 'TERMINAL_SIM', 'avanzado', 80, 50, 23);

-- 4. Opciones de Comando (Muestra)
INSERT INTO learnux.opciones_comando (id_comando, bandera, descripcion, ejemplo_uso) VALUES
(1, '-l', 'Formato largo', 'ls -l'),
(14, '-i', 'Ignora mayúsculas', 'grep -i "error" log.txt');

-- 5. Ejercicios Base
INSERT INTO learnux.ejercicios (id_ejercicio, id_nivel, id_comando, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden, activo) VALUES
(1, 1, 1, 'DRAG_DROP', '¿Comando para listar?', 'ls', '["ls", "cd"]'::jsonb, 'ls', 1, true);

-- 6. Resetear secuencias
SELECT setval('learnux.categorias_id_categoria_seq', COALESCE((SELECT MAX(id_categoria) FROM learnux.categorias), 1));
SELECT setval('learnux.comandos_id_comando_seq', COALESCE((SELECT MAX(id_comando) FROM learnux.comandos), 1));
SELECT setval('learnux.niveles_id_nivel_seq', COALESCE((SELECT MAX(id_nivel) FROM learnux.niveles), 1));
SELECT setval('learnux.ejercicios_id_ejercicio_seq', COALESCE((SELECT MAX(id_ejercicio) FROM learnux.ejercicios), 1));
