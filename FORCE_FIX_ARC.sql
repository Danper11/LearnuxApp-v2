-- Forzar tipos correctos para los primeros 12 niveles (Etapa 1 y 2)
-- Evitar cualquier mención a TYPE_COMMAND o TERMINAL_SIM antes del nivel 13

-- 1. Actualizar la tabla de niveles
UPDATE learnux.niveles 
SET tipo_ejercicio = 'DRAG_DROP' 
WHERE numero BETWEEN 1 AND 5;

UPDATE learnux.niveles 
SET tipo_ejercicio = 'MULTIPLE_CHOICE' 
WHERE numero BETWEEN 7 AND 11;

-- 2. Asegurar que los ejercicios individuales tengan el tipo correcto
-- Si un ejercicio era TYPE_COMMAND en niveles bajos, lo pasamos a MULTIPLE_CHOICE
UPDATE learnux.ejercicios
SET tipo = 'MULTIPLE_CHOICE'
WHERE id_nivel IN (SELECT id_nivel FROM learnux.niveles WHERE numero <= 12)
  AND tipo IN ('TYPE_COMMAND', 'TERMINAL_SIM');

-- 3. Caso específico Nivel 2: Navegar pwd y cd
UPDATE learnux.niveles SET tipo_ejercicio = 'DRAG_DROP' WHERE numero = 2;
UPDATE learnux.ejercicios SET tipo = 'DRAG_DROP' WHERE id_nivel = (SELECT id_nivel FROM learnux.niveles WHERE numero = 2);
