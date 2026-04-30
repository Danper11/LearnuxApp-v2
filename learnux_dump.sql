--
-- PostgreSQL database dump
--

\restrict k6A8fn9ZxT4kIgG6EgahaGd5eTdB9scC3Hu3cNKVj3pGYd5znUzLUP8VL313b3M

-- Dumped from database version 17.9 (Ubuntu 17.9-1.pgdg24.04+1)
-- Dumped by pg_dump version 17.9 (Ubuntu 17.9-1.pgdg24.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY learnux.niveles DROP CONSTRAINT IF EXISTS niveles_desbloqueado_por_fkey;
ALTER TABLE IF EXISTS ONLY learnux.sesiones_log DROP CONSTRAINT IF EXISTS fk_sesion_usuario;
ALTER TABLE IF EXISTS ONLY learnux.progreso_usuarios DROP CONSTRAINT IF EXISTS fk_pu_usuario;
ALTER TABLE IF EXISTS ONLY learnux.progreso_usuarios DROP CONSTRAINT IF EXISTS fk_pu_comando;
ALTER TABLE IF EXISTS ONLY learnux.progreso_nivel DROP CONSTRAINT IF EXISTS fk_pn_usuario;
ALTER TABLE IF EXISTS ONLY learnux.progreso_nivel DROP CONSTRAINT IF EXISTS fk_pn_nivel;
ALTER TABLE IF EXISTS ONLY learnux.opciones_comando DROP CONSTRAINT IF EXISTS fk_opcion_comando;
ALTER TABLE IF EXISTS ONLY learnux.intentos_ejercicio DROP CONSTRAINT IF EXISTS fk_it_usuario;
ALTER TABLE IF EXISTS ONLY learnux.intentos_ejercicio DROP CONSTRAINT IF EXISTS fk_it_nivel;
ALTER TABLE IF EXISTS ONLY learnux.intentos_ejercicio DROP CONSTRAINT IF EXISTS fk_it_ejercicio;
ALTER TABLE IF EXISTS ONLY learnux.ejercicios DROP CONSTRAINT IF EXISTS fk_ej_nivel;
ALTER TABLE IF EXISTS ONLY learnux.ejercicios DROP CONSTRAINT IF EXISTS fk_ej_comando;
ALTER TABLE IF EXISTS ONLY learnux.comandos DROP CONSTRAINT IF EXISTS fk_cmd_categoria;
DROP TRIGGER IF EXISTS tr_proteger_progreso ON learnux.progreso_usuarios;
DROP TRIGGER IF EXISTS tr_normalizar_comando ON learnux.comandos;
DROP TRIGGER IF EXISTS tr_log_sesion_practica ON learnux.progreso_usuarios;
DROP TRIGGER IF EXISTS tr_avanzar_nivel ON learnux.progreso_nivel;
DROP TRIGGER IF EXISTS tr_audit_comandos ON learnux.comandos;
DROP RULE IF EXISTS rule_update_vista_comandos ON learnux.vista_comandos_completos;
DROP RULE IF EXISTS rule_soft_delete_usuarios ON learnux.usuarios;
DROP RULE IF EXISTS rule_sesion_unica ON learnux.sesiones_log;
DROP RULE IF EXISTS rule_audit_inmutable ON learnux.comandos_audit_log;
ALTER TABLE IF EXISTS ONLY learnux.usuarios DROP CONSTRAINT IF EXISTS usuarios_pkey;
ALTER TABLE IF EXISTS ONLY learnux.usuarios DROP CONSTRAINT IF EXISTS uq_nombre_usuario;
ALTER TABLE IF EXISTS ONLY learnux.niveles DROP CONSTRAINT IF EXISTS uq_nivel_numero;
ALTER TABLE IF EXISTS ONLY learnux.usuarios DROP CONSTRAINT IF EXISTS uq_email;
ALTER TABLE IF EXISTS ONLY learnux.comandos DROP CONSTRAINT IF EXISTS uq_comando_nombre;
ALTER TABLE IF EXISTS ONLY learnux.categorias DROP CONSTRAINT IF EXISTS uq_categoria_nombre;
ALTER TABLE IF EXISTS ONLY learnux.sesiones_log DROP CONSTRAINT IF EXISTS sesiones_log_pkey;
ALTER TABLE IF EXISTS ONLY learnux.progreso_usuarios DROP CONSTRAINT IF EXISTS progreso_usuarios_pkey;
ALTER TABLE IF EXISTS ONLY learnux.progreso_nivel DROP CONSTRAINT IF EXISTS progreso_nivel_pkey;
ALTER TABLE IF EXISTS ONLY learnux.opciones_comando DROP CONSTRAINT IF EXISTS opciones_comando_pkey;
ALTER TABLE IF EXISTS ONLY learnux.niveles DROP CONSTRAINT IF EXISTS niveles_pkey;
ALTER TABLE IF EXISTS ONLY learnux.intentos_ejercicio DROP CONSTRAINT IF EXISTS intentos_ejercicio_pkey;
ALTER TABLE IF EXISTS ONLY learnux.ejercicios DROP CONSTRAINT IF EXISTS ejercicios_pkey;
ALTER TABLE IF EXISTS ONLY learnux.comandos DROP CONSTRAINT IF EXISTS comandos_pkey;
ALTER TABLE IF EXISTS ONLY learnux.comandos_audit_log DROP CONSTRAINT IF EXISTS comandos_audit_log_pkey;
ALTER TABLE IF EXISTS ONLY learnux.categorias DROP CONSTRAINT IF EXISTS categorias_pkey;
ALTER TABLE IF EXISTS learnux.usuarios ALTER COLUMN id_usuario DROP DEFAULT;
ALTER TABLE IF EXISTS learnux.sesiones_log ALTER COLUMN id_sesion DROP DEFAULT;
ALTER TABLE IF EXISTS learnux.opciones_comando ALTER COLUMN id_opcion DROP DEFAULT;
ALTER TABLE IF EXISTS learnux.niveles ALTER COLUMN id_nivel DROP DEFAULT;
ALTER TABLE IF EXISTS learnux.intentos_ejercicio ALTER COLUMN id_intento DROP DEFAULT;
ALTER TABLE IF EXISTS learnux.ejercicios ALTER COLUMN id_ejercicio DROP DEFAULT;
ALTER TABLE IF EXISTS learnux.comandos_audit_log ALTER COLUMN id_audit DROP DEFAULT;
ALTER TABLE IF EXISTS learnux.comandos ALTER COLUMN id_comando DROP DEFAULT;
ALTER TABLE IF EXISTS learnux.categorias ALTER COLUMN id_categoria DROP DEFAULT;
DROP VIEW IF EXISTS learnux.vista_resumen_progreso;
DROP VIEW IF EXISTS learnux.vista_ranking;
DROP VIEW IF EXISTS learnux.vista_progreso_usuario;
DROP VIEW IF EXISTS learnux.vista_ejercicios_nivel;
DROP VIEW IF EXISTS learnux.vista_comandos_completos;
DROP SEQUENCE IF EXISTS learnux.usuarios_id_usuario_seq;
DROP TABLE IF EXISTS learnux.usuarios;
DROP SEQUENCE IF EXISTS learnux.sesiones_log_id_sesion_seq;
DROP TABLE IF EXISTS learnux.sesiones_log;
DROP TABLE IF EXISTS learnux.progreso_usuarios;
DROP TABLE IF EXISTS learnux.progreso_nivel;
DROP SEQUENCE IF EXISTS learnux.opciones_comando_id_opcion_seq;
DROP TABLE IF EXISTS learnux.opciones_comando;
DROP SEQUENCE IF EXISTS learnux.niveles_id_nivel_seq;
DROP TABLE IF EXISTS learnux.niveles;
DROP SEQUENCE IF EXISTS learnux.intentos_ejercicio_id_intento_seq;
DROP TABLE IF EXISTS learnux.intentos_ejercicio;
DROP SEQUENCE IF EXISTS learnux.ejercicios_id_ejercicio_seq;
DROP TABLE IF EXISTS learnux.ejercicios;
DROP SEQUENCE IF EXISTS learnux.comandos_id_comando_seq;
DROP SEQUENCE IF EXISTS learnux.comandos_audit_log_id_audit_seq;
DROP TABLE IF EXISTS learnux.comandos_audit_log;
DROP TABLE IF EXISTS learnux.comandos;
DROP SEQUENCE IF EXISTS learnux.categorias_id_categoria_seq;
DROP TABLE IF EXISTS learnux.categorias;
DROP PROCEDURE IF EXISTS learnux.sp_registrar_usuario(IN p_nombre text, IN p_email text);
DROP PROCEDURE IF EXISTS learnux.sp_registrar_intento(IN p_id_usuario integer, IN p_id_ejercicio integer, IN p_respuesta text, IN p_tiempo_seg integer);
DROP PROCEDURE IF EXISTS learnux.sp_agregar_comando(IN p_id_categoria integer, IN p_nombre text, IN p_descripcion text, IN p_sintaxis text, IN p_dificultad learnux.dificultad_tipo);
DROP PROCEDURE IF EXISTS learnux.sp_actualizar_progreso(IN p_id_usuario integer, IN p_id_comando integer, IN p_dominado boolean);
DROP FUNCTION IF EXISTS learnux.fn_proteger_progreso();
DROP FUNCTION IF EXISTS learnux.fn_normalizar_comando();
DROP FUNCTION IF EXISTS learnux.fn_log_sesion();
DROP FUNCTION IF EXISTS learnux.fn_avanzar_nivel_usuario();
DROP FUNCTION IF EXISTS learnux.fn_audit_comandos();
DROP FUNCTION IF EXISTS learnux.f_siguiente_nivel(p_id_usuario integer);
DROP FUNCTION IF EXISTS learnux.f_resumen_progreso(p_id_usuario integer);
DROP FUNCTION IF EXISTS learnux.f_porcentaje_nivel(p_id_usuario integer, p_id_nivel integer);
DROP FUNCTION IF EXISTS learnux.f_ls_comandos_categoria(p_id_categoria integer);
DROP FUNCTION IF EXISTS learnux.f_get_todas_categorias();
DROP FUNCTION IF EXISTS learnux.f_get_opciones_comando(p_id_comando integer);
DROP FUNCTION IF EXISTS learnux.f_get_niveles_con_progreso(p_id_usuario integer);
DROP FUNCTION IF EXISTS learnux.f_get_ejercicios_nivel(p_id_nivel integer);
DROP FUNCTION IF EXISTS learnux.f_get_comandos_de_nivel(p_id_nivel integer);
DROP FUNCTION IF EXISTS learnux.f_buscar_usuario(p_nombre text);
DROP FUNCTION IF EXISTS learnux.f_buscar_comando(p_nombre text);
DROP DOMAIN IF EXISTS learnux.ejercicio_tipo;
DROP DOMAIN IF EXISTS learnux.dificultad_tipo;
DROP SCHEMA IF EXISTS learnux;
--
-- Name: learnux; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA learnux;


--
-- Name: dificultad_tipo; Type: DOMAIN; Schema: learnux; Owner: -
--

CREATE DOMAIN learnux.dificultad_tipo AS text
	CONSTRAINT dificultad_tipo_check CHECK ((VALUE = ANY (ARRAY['principiante'::text, 'intermedio'::text, 'avanzado'::text])));


--
-- Name: ejercicio_tipo; Type: DOMAIN; Schema: learnux; Owner: -
--

CREATE DOMAIN learnux.ejercicio_tipo AS text
	CONSTRAINT ejercicio_tipo_check CHECK ((VALUE = ANY (ARRAY['DRAG_DROP'::text, 'MULTIPLE_CHOICE'::text, 'FILL_BLANK'::text, 'TYPE_COMMAND'::text, 'TERMINAL_SIM'::text])));


--
-- Name: f_buscar_comando(text); Type: FUNCTION; Schema: learnux; Owner: -
--

CREATE FUNCTION learnux.f_buscar_comando(p_nombre text) RETURNS TABLE(ret_id_comando integer, ret_comando_nombre text, ret_descripcion text, ret_sintaxis text, ret_dificultad text, ret_categoria text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
        SELECT c.id_comando,
               c.comando_nombre,
               c.descripcion,
               c.sintaxis,
               c.dificultad_nivel::TEXT,
               cat.nombre
        FROM learnux.comandos c
        JOIN learnux.categorias cat ON c.id_categoria = cat.id_categoria
        WHERE LOWER(c.comando_nombre) LIKE LOWER('%' || p_nombre || '%');
END;
$$;


--
-- Name: f_buscar_usuario(text); Type: FUNCTION; Schema: learnux; Owner: -
--

CREATE FUNCTION learnux.f_buscar_usuario(p_nombre text) RETURNS TABLE(ret_id_usuario integer, ret_nombre_usuario text, ret_fecha_creacion timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
        SELECT id_usuario,
               nombre_usuario,
               fecha_creacion
        FROM learnux.usuarios
        WHERE nombre_usuario = p_nombre
          AND activo = TRUE;
END;
$$;


--
-- Name: f_get_comandos_de_nivel(integer); Type: FUNCTION; Schema: learnux; Owner: -
--

CREATE FUNCTION learnux.f_get_comandos_de_nivel(p_id_nivel integer) RETURNS TABLE(ret_id_comando integer, ret_nombre text, ret_descripcion text, ret_sintaxis text, ret_dificultad text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM (
        SELECT DISTINCT
            c.id_comando,
            c.comando_nombre::TEXT,
            c.descripcion::TEXT,
            c.sintaxis::TEXT,
            c.dificultad_nivel::TEXT
        FROM learnux.ejercicios e
        JOIN learnux.comandos c ON c.id_comando = e.id_comando
        WHERE e.id_nivel   = p_id_nivel
          AND e.id_comando IS NOT NULL
          AND e.activo     = TRUE

        UNION

        SELECT DISTINCT
            c.id_comando,
            c.comando_nombre::TEXT,
            c.descripcion::TEXT,
            c.sintaxis::TEXT,
            c.dificultad_nivel::TEXT
        FROM learnux.ejercicios e
        CROSS JOIN LATERAL jsonb_object_keys(e.opciones_json) AS key
        JOIN learnux.comandos c ON c.comando_nombre = key
        WHERE e.id_nivel                  = p_id_nivel
          AND e.id_comando                IS NULL
          AND e.activo                    = TRUE
          AND jsonb_typeof(e.opciones_json) = 'object'

        UNION

        SELECT DISTINCT
            c.id_comando,
            c.comando_nombre::TEXT,
            c.descripcion::TEXT,
            c.sintaxis::TEXT,
            c.dificultad_nivel::TEXT
        FROM learnux.ejercicios e
        CROSS JOIN LATERAL jsonb_array_elements_text(e.opciones_json) AS elem
        JOIN learnux.comandos c ON c.comando_nombre = elem
        WHERE e.id_nivel                  = p_id_nivel
          AND e.id_comando                IS NULL
          AND e.activo                    = TRUE
          AND jsonb_typeof(e.opciones_json) = 'array'
    ) sub
    ORDER BY sub.comando_nombre;
END;
$$;


--
-- Name: f_get_ejercicios_nivel(integer); Type: FUNCTION; Schema: learnux; Owner: -
--

CREATE FUNCTION learnux.f_get_ejercicios_nivel(p_id_nivel integer) RETURNS TABLE(ret_id_ejercicio integer, ret_id_nivel integer, ret_id_comando integer, ret_tipo text, ret_pregunta text, ret_respuesta_correcta text, ret_opciones_json text, ret_pista text, ret_orden integer, ret_salida_simulada text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
        SELECT  e.id_ejercicio,
                e.id_nivel,
                e.id_comando,
                e.tipo::TEXT,
                e.pregunta,
                e.respuesta_correcta,
                e.opciones_json::TEXT,
                e.pista,
                e.orden,
                COALESCE(e.salida_simulada, c.salida_simulada)
        FROM learnux.ejercicios e
        LEFT JOIN learnux.comandos c ON c.id_comando = e.id_comando
        WHERE e.id_nivel = p_id_nivel AND e.activo = TRUE
        ORDER BY e.orden;
END;
$$;


--
-- Name: f_get_niveles_con_progreso(integer); Type: FUNCTION; Schema: learnux; Owner: -
--

CREATE FUNCTION learnux.f_get_niveles_con_progreso(p_id_usuario integer) RETURNS TABLE(ret_id_nivel integer, ret_numero integer, ret_nombre text, ret_descripcion text, ret_tipo_ejercicio text, ret_dificultad text, ret_puntos_para_pasar integer, ret_puntos_recompensa integer, ret_completado boolean, ret_puntos_acumulados integer, ret_desbloqueado boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        n.id_nivel,
        n.numero,
        n.nombre,
        n.descripcion,
        n.tipo_ejercicio::TEXT,
        n.dificultad::TEXT,
        n.puntos_para_pasar,
        n.puntos_recompensa,
        COALESCE(pn.completado,        FALSE),
        COALESCE(pn.puntos_acumulados, 0),
        CASE
            WHEN n.desbloqueado_por IS NULL THEN TRUE
            WHEN EXISTS (
                SELECT 1
                FROM learnux.progreso_nivel prereq
                WHERE prereq.id_usuario = p_id_usuario
                  AND prereq.id_nivel   = n.desbloqueado_por
                  AND prereq.completado = TRUE
            ) THEN TRUE
            ELSE FALSE
        END
    FROM learnux.niveles n
    LEFT JOIN learnux.progreso_nivel pn
           ON pn.id_nivel   = n.id_nivel
          AND pn.id_usuario = p_id_usuario
    ORDER BY n.numero;
END;
$$;


--
-- Name: f_get_opciones_comando(integer); Type: FUNCTION; Schema: learnux; Owner: -
--

CREATE FUNCTION learnux.f_get_opciones_comando(p_id_comando integer) RETURNS TABLE(ret_id_opcion integer, ret_id_comando integer, ret_bandera text, ret_descripcion text, ret_ejemplo_uso text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
        SELECT id_opcion,
               id_comando,
               bandera,
               descripcion,
               ejemplo_uso
        FROM learnux.opciones_comando
        WHERE id_comando = p_id_comando
        ORDER BY id_opcion;
END;
$$;


--
-- Name: f_get_todas_categorias(); Type: FUNCTION; Schema: learnux; Owner: -
--

CREATE FUNCTION learnux.f_get_todas_categorias() RETURNS TABLE(ret_id_categoria integer, ret_nombre text, ret_descripcion text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
        SELECT id_categoria,
               nombre,
               descripcion
        FROM learnux.categorias
        ORDER BY id_categoria;
END;
$$;


--
-- Name: f_ls_comandos_categoria(integer); Type: FUNCTION; Schema: learnux; Owner: -
--

CREATE FUNCTION learnux.f_ls_comandos_categoria(p_id_categoria integer) RETURNS TABLE(ret_id_comando integer, ret_id_categoria integer, ret_comando_nombre text, ret_descripcion text, ret_sintaxis text, ret_dificultad text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
        SELECT c.id_comando,
               c.id_categoria,
               c.comando_nombre,
               c.descripcion,
               c.sintaxis,
               c.dificultad_nivel::TEXT
        FROM learnux.comandos c
        WHERE c.id_categoria = p_id_categoria;
END;
$$;


--
-- Name: f_porcentaje_nivel(integer, integer); Type: FUNCTION; Schema: learnux; Owner: -
--

CREATE FUNCTION learnux.f_porcentaje_nivel(p_id_usuario integer, p_id_nivel integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_total    INTEGER;
    v_correctos INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_total
    FROM learnux.ejercicios
    WHERE id_nivel = p_id_nivel AND activo = TRUE;

    IF v_total = 0 THEN RETURN 0; END IF;

    SELECT COUNT(DISTINCT ie.id_ejercicio) INTO v_correctos
    FROM learnux.intentos_ejercicio ie
    WHERE ie.id_usuario  = p_id_usuario
      AND ie.id_nivel    = p_id_nivel
      AND ie.correcta    = TRUE;

    RETURN ROUND((v_correctos::NUMERIC / v_total) * 100, 1);
END;
$$;


--
-- Name: f_resumen_progreso(integer); Type: FUNCTION; Schema: learnux; Owner: -
--

CREATE FUNCTION learnux.f_resumen_progreso(p_id_usuario integer) RETURNS TABLE(ret_comando text, ret_dificultad text, ret_dominado boolean, ret_veces integer, ret_ultima timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
        SELECT c.comando_nombre,
               c.dificultad_nivel::TEXT,
               p.dominado,
               p.veces_practicado,
               p.ultima_practica
        FROM learnux.progreso_usuarios p
        JOIN learnux.comandos c ON p.id_comando = c.id_comando
        WHERE p.id_usuario = p_id_usuario
        ORDER BY p.ultima_practica DESC;
END;
$$;


--
-- Name: f_siguiente_nivel(integer); Type: FUNCTION; Schema: learnux; Owner: -
--

CREATE FUNCTION learnux.f_siguiente_nivel(p_id_usuario integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_nivel_actual INTEGER;
BEGIN
    SELECT nivel_actual INTO v_nivel_actual
    FROM learnux.usuarios
    WHERE id_usuario = p_id_usuario;

    RETURN v_nivel_actual;
END;
$$;


--
-- Name: fn_audit_comandos(); Type: FUNCTION; Schema: learnux; Owner: -
--

CREATE FUNCTION learnux.fn_audit_comandos() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO learnux.comandos_audit_log (tipo_accion, nombre_comando)
        VALUES ('INSERT', NEW.comando_nombre);
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO learnux.comandos_audit_log (tipo_accion, nombre_comando)
        VALUES ('DELETE', OLD.comando_nombre);
        RETURN OLD;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO learnux.comandos_audit_log (tipo_accion, nombre_comando)
        VALUES ('UPDATE', NEW.comando_nombre);
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$;


--
-- Name: fn_avanzar_nivel_usuario(); Type: FUNCTION; Schema: learnux; Owner: -
--

CREATE FUNCTION learnux.fn_avanzar_nivel_usuario() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_siguiente INTEGER;
BEGIN
    IF NEW.completado = TRUE AND (OLD.completado IS DISTINCT FROM TRUE) THEN
        SELECT n.numero + 1
        INTO v_siguiente
        FROM learnux.niveles n
        WHERE n.id_nivel = NEW.id_nivel;

        IF v_siguiente IS NOT NULL AND v_siguiente <= 24 THEN
            UPDATE learnux.usuarios
            SET nivel_actual   = GREATEST(nivel_actual, v_siguiente),
                puntos_totales = puntos_totales + (
                    SELECT puntos_recompensa FROM learnux.niveles WHERE id_nivel = NEW.id_nivel
                )
            WHERE id_usuario = NEW.id_usuario;
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: fn_log_sesion(); Type: FUNCTION; Schema: learnux; Owner: -
--

CREATE FUNCTION learnux.fn_log_sesion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO learnux.sesiones_log (id_usuario)
    VALUES (NEW.id_usuario);
    RETURN NEW;
END;
$$;


--
-- Name: fn_normalizar_comando(); Type: FUNCTION; Schema: learnux; Owner: -
--

CREATE FUNCTION learnux.fn_normalizar_comando() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.comando_nombre := LOWER(TRIM(NEW.comando_nombre));
    RETURN NEW;
END;
$$;


--
-- Name: fn_proteger_progreso(); Type: FUNCTION; Schema: learnux; Owner: -
--

CREATE FUNCTION learnux.fn_proteger_progreso() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.veces_practicado < 0 THEN
        NEW.veces_practicado := 0;
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: sp_actualizar_progreso(integer, integer, boolean); Type: PROCEDURE; Schema: learnux; Owner: -
--

CREATE PROCEDURE learnux.sp_actualizar_progreso(IN p_id_usuario integer, IN p_id_comando integer, IN p_dominado boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO learnux.progreso_usuarios
        (id_usuario, id_comando, dominado, veces_practicado, ultima_practica)
    VALUES
        (p_id_usuario, p_id_comando, p_dominado, 1, CURRENT_TIMESTAMP)
    ON CONFLICT (id_usuario, id_comando) DO UPDATE SET
        dominado         = EXCLUDED.dominado,
        veces_practicado = learnux.progreso_usuarios.veces_practicado + 1,
        ultima_practica  = CURRENT_TIMESTAMP;
END;
$$;


--
-- Name: sp_agregar_comando(integer, text, text, text, learnux.dificultad_tipo); Type: PROCEDURE; Schema: learnux; Owner: -
--

CREATE PROCEDURE learnux.sp_agregar_comando(IN p_id_categoria integer, IN p_nombre text, IN p_descripcion text, IN p_sintaxis text, IN p_dificultad learnux.dificultad_tipo)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO learnux.comandos
        (id_categoria, comando_nombre, descripcion, sintaxis, dificultad_nivel)
    VALUES
        (p_id_categoria, p_nombre, p_descripcion, p_sintaxis, p_dificultad);
END;
$$;


--
-- Name: sp_registrar_intento(integer, integer, text, integer); Type: PROCEDURE; Schema: learnux; Owner: -
--

CREATE PROCEDURE learnux.sp_registrar_intento(IN p_id_usuario integer, IN p_id_ejercicio integer, IN p_respuesta text, IN p_tiempo_seg integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_id_nivel          INTEGER;
    v_respuesta_ok      TEXT;
    v_es_correcta       BOOLEAN;
    v_puntos            INTEGER;
    v_porcentaje        NUMERIC;
    v_puntos_para_pasar INTEGER;
BEGIN
    SELECT e.id_nivel, e.respuesta_correcta, n.puntos_para_pasar
    INTO v_id_nivel, v_respuesta_ok, v_puntos_para_pasar
    FROM learnux.ejercicios e
    JOIN learnux.niveles n ON e.id_nivel = n.id_nivel
    WHERE e.id_ejercicio = p_id_ejercicio;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Ejercicio % no encontrado', p_id_ejercicio;
    END IF;

    v_es_correcta := LOWER(TRIM(p_respuesta)) = LOWER(TRIM(v_respuesta_ok));
    v_puntos      := CASE WHEN v_es_correcta THEN 10 ELSE 0 END;

    INSERT INTO learnux.intentos_ejercicio
        (id_usuario, id_ejercicio, id_nivel, respuesta_dada,
         correcta, puntos_ganados, tiempo_segundos)
    VALUES
        (p_id_usuario, p_id_ejercicio, v_id_nivel, p_respuesta,
         v_es_correcta, v_puntos, p_tiempo_seg);

    INSERT INTO learnux.progreso_nivel (id_usuario, id_nivel, intentos_totales)
    VALUES (p_id_usuario, v_id_nivel, 1)
    ON CONFLICT (id_usuario, id_nivel) DO UPDATE SET
        intentos_totales  = learnux.progreso_nivel.intentos_totales + 1,
        puntos_acumulados = learnux.progreso_nivel.puntos_acumulados + v_puntos;

    v_porcentaje := learnux.f_porcentaje_nivel(p_id_usuario, v_id_nivel);

    IF v_porcentaje >= v_puntos_para_pasar THEN
        UPDATE learnux.progreso_nivel
        SET completado       = TRUE,
            fecha_completado = CURRENT_TIMESTAMP
        WHERE id_usuario = p_id_usuario
          AND id_nivel   = v_id_nivel
          AND completado = FALSE;
    END IF;
END;
$$;


--
-- Name: sp_registrar_usuario(text, text); Type: PROCEDURE; Schema: learnux; Owner: -
--

CREATE PROCEDURE learnux.sp_registrar_usuario(IN p_nombre text, IN p_email text DEFAULT NULL::text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF LENGTH(TRIM(p_nombre)) < 3 THEN
        RAISE EXCEPTION 'El nombre debe tener al menos 3 caracteres';
    END IF;

    INSERT INTO learnux.usuarios (nombre_usuario, email)
    VALUES (TRIM(p_nombre), LOWER(TRIM(p_email)));

    INSERT INTO learnux.progreso_nivel (id_usuario, id_nivel)
    SELECT currval('learnux.usuarios_id_usuario_seq'), id_nivel
    FROM learnux.niveles WHERE numero = 1;

EXCEPTION WHEN unique_violation THEN
    RAISE EXCEPTION 'El nombre de usuario "%" ya existe', p_nombre;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: categorias; Type: TABLE; Schema: learnux; Owner: -
--

CREATE TABLE learnux.categorias (
    id_categoria integer NOT NULL,
    nombre text NOT NULL,
    descripcion text
);


--
-- Name: categorias_id_categoria_seq; Type: SEQUENCE; Schema: learnux; Owner: -
--

CREATE SEQUENCE learnux.categorias_id_categoria_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categorias_id_categoria_seq; Type: SEQUENCE OWNED BY; Schema: learnux; Owner: -
--

ALTER SEQUENCE learnux.categorias_id_categoria_seq OWNED BY learnux.categorias.id_categoria;


--
-- Name: comandos; Type: TABLE; Schema: learnux; Owner: -
--

CREATE TABLE learnux.comandos (
    id_comando integer NOT NULL,
    id_categoria integer NOT NULL,
    comando_nombre text NOT NULL,
    descripcion text NOT NULL,
    sintaxis text NOT NULL,
    dificultad_nivel learnux.dificultad_tipo DEFAULT 'principiante'::text,
    salida_simulada text,
    CONSTRAINT chk_cmd_minusculas CHECK ((comando_nombre = lower(comando_nombre)))
);


--
-- Name: comandos_audit_log; Type: TABLE; Schema: learnux; Owner: -
--

CREATE TABLE learnux.comandos_audit_log (
    id_audit integer NOT NULL,
    tipo_accion text NOT NULL,
    nombre_comando text NOT NULL,
    usuario_db text DEFAULT CURRENT_USER,
    fecha_evento timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_tipo_accion CHECK ((tipo_accion = ANY (ARRAY['INSERT'::text, 'UPDATE'::text, 'DELETE'::text])))
);


--
-- Name: comandos_audit_log_id_audit_seq; Type: SEQUENCE; Schema: learnux; Owner: -
--

CREATE SEQUENCE learnux.comandos_audit_log_id_audit_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comandos_audit_log_id_audit_seq; Type: SEQUENCE OWNED BY; Schema: learnux; Owner: -
--

ALTER SEQUENCE learnux.comandos_audit_log_id_audit_seq OWNED BY learnux.comandos_audit_log.id_audit;


--
-- Name: comandos_id_comando_seq; Type: SEQUENCE; Schema: learnux; Owner: -
--

CREATE SEQUENCE learnux.comandos_id_comando_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comandos_id_comando_seq; Type: SEQUENCE OWNED BY; Schema: learnux; Owner: -
--

ALTER SEQUENCE learnux.comandos_id_comando_seq OWNED BY learnux.comandos.id_comando;


--
-- Name: ejercicios; Type: TABLE; Schema: learnux; Owner: -
--

CREATE TABLE learnux.ejercicios (
    id_ejercicio integer NOT NULL,
    id_nivel integer NOT NULL,
    id_comando integer,
    tipo learnux.ejercicio_tipo NOT NULL,
    pregunta text NOT NULL,
    respuesta_correcta text NOT NULL,
    opciones_json jsonb,
    pista text,
    orden integer DEFAULT 1,
    activo boolean DEFAULT true,
    salida_simulada text,
    CONSTRAINT chk_orden_positivo CHECK ((orden > 0))
);


--
-- Name: ejercicios_id_ejercicio_seq; Type: SEQUENCE; Schema: learnux; Owner: -
--

CREATE SEQUENCE learnux.ejercicios_id_ejercicio_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ejercicios_id_ejercicio_seq; Type: SEQUENCE OWNED BY; Schema: learnux; Owner: -
--

ALTER SEQUENCE learnux.ejercicios_id_ejercicio_seq OWNED BY learnux.ejercicios.id_ejercicio;


--
-- Name: intentos_ejercicio; Type: TABLE; Schema: learnux; Owner: -
--

CREATE TABLE learnux.intentos_ejercicio (
    id_intento integer NOT NULL,
    id_usuario integer NOT NULL,
    id_ejercicio integer NOT NULL,
    id_nivel integer NOT NULL,
    respuesta_dada text,
    correcta boolean DEFAULT false NOT NULL,
    puntos_ganados integer DEFAULT 0,
    tiempo_segundos integer,
    fecha_intento timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_puntos_intento CHECK ((puntos_ganados >= 0)),
    CONSTRAINT chk_tiempo_intento CHECK (((tiempo_segundos IS NULL) OR (tiempo_segundos >= 0)))
);


--
-- Name: intentos_ejercicio_id_intento_seq; Type: SEQUENCE; Schema: learnux; Owner: -
--

CREATE SEQUENCE learnux.intentos_ejercicio_id_intento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: intentos_ejercicio_id_intento_seq; Type: SEQUENCE OWNED BY; Schema: learnux; Owner: -
--

ALTER SEQUENCE learnux.intentos_ejercicio_id_intento_seq OWNED BY learnux.intentos_ejercicio.id_intento;


--
-- Name: niveles; Type: TABLE; Schema: learnux; Owner: -
--

CREATE TABLE learnux.niveles (
    id_nivel integer NOT NULL,
    numero integer NOT NULL,
    nombre text NOT NULL,
    descripcion text,
    tipo_ejercicio learnux.ejercicio_tipo NOT NULL,
    dificultad learnux.dificultad_tipo NOT NULL,
    puntos_para_pasar integer DEFAULT 70,
    puntos_recompensa integer DEFAULT 10,
    desbloqueado_por integer,
    CONSTRAINT chk_numero_nivel CHECK (((numero >= 1) AND (numero <= 24))),
    CONSTRAINT chk_puntos_para_pasar CHECK (((puntos_para_pasar >= 1) AND (puntos_para_pasar <= 100))),
    CONSTRAINT chk_recompensa_pos CHECK ((puntos_recompensa > 0))
);


--
-- Name: niveles_id_nivel_seq; Type: SEQUENCE; Schema: learnux; Owner: -
--

CREATE SEQUENCE learnux.niveles_id_nivel_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: niveles_id_nivel_seq; Type: SEQUENCE OWNED BY; Schema: learnux; Owner: -
--

ALTER SEQUENCE learnux.niveles_id_nivel_seq OWNED BY learnux.niveles.id_nivel;


--
-- Name: opciones_comando; Type: TABLE; Schema: learnux; Owner: -
--

CREATE TABLE learnux.opciones_comando (
    id_opcion integer NOT NULL,
    id_comando integer NOT NULL,
    bandera text NOT NULL,
    descripcion text NOT NULL,
    ejemplo_uso text
);


--
-- Name: opciones_comando_id_opcion_seq; Type: SEQUENCE; Schema: learnux; Owner: -
--

CREATE SEQUENCE learnux.opciones_comando_id_opcion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: opciones_comando_id_opcion_seq; Type: SEQUENCE OWNED BY; Schema: learnux; Owner: -
--

ALTER SEQUENCE learnux.opciones_comando_id_opcion_seq OWNED BY learnux.opciones_comando.id_opcion;


--
-- Name: progreso_nivel; Type: TABLE; Schema: learnux; Owner: -
--

CREATE TABLE learnux.progreso_nivel (
    id_usuario integer NOT NULL,
    id_nivel integer NOT NULL,
    completado boolean DEFAULT false,
    puntos_acumulados integer DEFAULT 0,
    intentos_totales integer DEFAULT 0,
    fecha_inicio timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    fecha_completado timestamp without time zone,
    CONSTRAINT chk_pn_intentos CHECK ((intentos_totales >= 0)),
    CONSTRAINT chk_pn_puntos CHECK ((puntos_acumulados >= 0))
);


--
-- Name: progreso_usuarios; Type: TABLE; Schema: learnux; Owner: -
--

CREATE TABLE learnux.progreso_usuarios (
    id_usuario integer NOT NULL,
    id_comando integer NOT NULL,
    dominado boolean DEFAULT false,
    veces_practicado integer DEFAULT 0,
    ultima_practica timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_veces_practicado CHECK ((veces_practicado >= 0))
);


--
-- Name: sesiones_log; Type: TABLE; Schema: learnux; Owner: -
--

CREATE TABLE learnux.sesiones_log (
    id_sesion integer NOT NULL,
    id_usuario integer,
    ip_cliente text,
    fecha_login timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    fecha_logout timestamp without time zone
);


--
-- Name: sesiones_log_id_sesion_seq; Type: SEQUENCE; Schema: learnux; Owner: -
--

CREATE SEQUENCE learnux.sesiones_log_id_sesion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sesiones_log_id_sesion_seq; Type: SEQUENCE OWNED BY; Schema: learnux; Owner: -
--

ALTER SEQUENCE learnux.sesiones_log_id_sesion_seq OWNED BY learnux.sesiones_log.id_sesion;


--
-- Name: usuarios; Type: TABLE; Schema: learnux; Owner: -
--

CREATE TABLE learnux.usuarios (
    id_usuario integer NOT NULL,
    nombre_usuario text NOT NULL,
    email text,
    password_hash text,
    puntos_totales integer DEFAULT 0,
    nivel_actual integer DEFAULT 1,
    fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    activo boolean DEFAULT true,
    CONSTRAINT chk_nivel_rango CHECK (((nivel_actual >= 1) AND (nivel_actual <= 24))),
    CONSTRAINT chk_puntos_positivos CHECK ((puntos_totales >= 0))
);


--
-- Name: usuarios_id_usuario_seq; Type: SEQUENCE; Schema: learnux; Owner: -
--

CREATE SEQUENCE learnux.usuarios_id_usuario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: usuarios_id_usuario_seq; Type: SEQUENCE OWNED BY; Schema: learnux; Owner: -
--

ALTER SEQUENCE learnux.usuarios_id_usuario_seq OWNED BY learnux.usuarios.id_usuario;


--
-- Name: vista_comandos_completos; Type: VIEW; Schema: learnux; Owner: -
--

CREATE VIEW learnux.vista_comandos_completos AS
 SELECT c.id_comando,
    c.comando_nombre,
    c.descripcion,
    c.sintaxis,
    c.dificultad_nivel,
    c.salida_simulada,
    cat.nombre AS categoria,
    cat.descripcion AS descripcion_categoria
   FROM (learnux.comandos c
     JOIN learnux.categorias cat ON ((c.id_categoria = cat.id_categoria)));


--
-- Name: vista_ejercicios_nivel; Type: VIEW; Schema: learnux; Owner: -
--

CREATE VIEW learnux.vista_ejercicios_nivel AS
 SELECT e.id_ejercicio,
    e.id_nivel,
    n.numero AS numero_nivel,
    n.nombre AS nombre_nivel,
    e.tipo,
    e.pregunta,
    e.respuesta_correcta,
    e.opciones_json,
    e.pista,
    e.orden,
    c.comando_nombre
   FROM ((learnux.ejercicios e
     JOIN learnux.niveles n ON ((e.id_nivel = n.id_nivel)))
     LEFT JOIN learnux.comandos c ON ((e.id_comando = c.id_comando)))
  WHERE (e.activo = true)
  ORDER BY e.id_nivel, e.orden;


--
-- Name: vista_progreso_usuario; Type: VIEW; Schema: learnux; Owner: -
--

CREATE VIEW learnux.vista_progreso_usuario AS
 SELECT u.id_usuario,
    u.nombre_usuario,
    u.puntos_totales,
    u.nivel_actual,
    count(p.id_comando) AS total_practicados,
    sum(
        CASE
            WHEN p.dominado THEN 1
            ELSE 0
        END) AS total_dominados,
    max(p.ultima_practica) AS ultima_sesion
   FROM (learnux.usuarios u
     LEFT JOIN learnux.progreso_usuarios p ON ((u.id_usuario = p.id_usuario)))
  GROUP BY u.id_usuario, u.nombre_usuario, u.puntos_totales, u.nivel_actual;


--
-- Name: vista_ranking; Type: VIEW; Schema: learnux; Owner: -
--

CREATE VIEW learnux.vista_ranking AS
 SELECT row_number() OVER (ORDER BY puntos_totales DESC, nivel_actual DESC) AS posicion,
    nombre_usuario,
    puntos_totales,
    nivel_actual
   FROM learnux.usuarios
  WHERE (activo = true)
  ORDER BY puntos_totales DESC;


--
-- Name: vista_resumen_progreso; Type: VIEW; Schema: learnux; Owner: -
--

CREATE VIEW learnux.vista_resumen_progreso AS
 SELECT u.nombre_usuario,
    u.puntos_totales,
    u.nivel_actual,
    count(p.id_comando) AS total_practicados,
    sum(
        CASE
            WHEN p.dominado THEN 1
            ELSE 0
        END) AS total_dominados,
    max(p.ultima_practica) AS ultima_actividad
   FROM (learnux.usuarios u
     LEFT JOIN learnux.progreso_usuarios p ON ((u.id_usuario = p.id_usuario)))
  WHERE (u.activo = true)
  GROUP BY u.id_usuario, u.nombre_usuario, u.puntos_totales, u.nivel_actual;


--
-- Name: categorias id_categoria; Type: DEFAULT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.categorias ALTER COLUMN id_categoria SET DEFAULT nextval('learnux.categorias_id_categoria_seq'::regclass);


--
-- Name: comandos id_comando; Type: DEFAULT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.comandos ALTER COLUMN id_comando SET DEFAULT nextval('learnux.comandos_id_comando_seq'::regclass);


--
-- Name: comandos_audit_log id_audit; Type: DEFAULT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.comandos_audit_log ALTER COLUMN id_audit SET DEFAULT nextval('learnux.comandos_audit_log_id_audit_seq'::regclass);


--
-- Name: ejercicios id_ejercicio; Type: DEFAULT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.ejercicios ALTER COLUMN id_ejercicio SET DEFAULT nextval('learnux.ejercicios_id_ejercicio_seq'::regclass);


--
-- Name: intentos_ejercicio id_intento; Type: DEFAULT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.intentos_ejercicio ALTER COLUMN id_intento SET DEFAULT nextval('learnux.intentos_ejercicio_id_intento_seq'::regclass);


--
-- Name: niveles id_nivel; Type: DEFAULT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.niveles ALTER COLUMN id_nivel SET DEFAULT nextval('learnux.niveles_id_nivel_seq'::regclass);


--
-- Name: opciones_comando id_opcion; Type: DEFAULT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.opciones_comando ALTER COLUMN id_opcion SET DEFAULT nextval('learnux.opciones_comando_id_opcion_seq'::regclass);


--
-- Name: sesiones_log id_sesion; Type: DEFAULT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.sesiones_log ALTER COLUMN id_sesion SET DEFAULT nextval('learnux.sesiones_log_id_sesion_seq'::regclass);


--
-- Name: usuarios id_usuario; Type: DEFAULT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.usuarios ALTER COLUMN id_usuario SET DEFAULT nextval('learnux.usuarios_id_usuario_seq'::regclass);


--
-- Data for Name: categorias; Type: TABLE DATA; Schema: learnux; Owner: -
--

COPY learnux.categorias (id_categoria, nombre, descripcion) FROM stdin;
1	fundamentos	Navegación básica
2	gestion de sistema	Procesos y recursos
3	permisos y seguridad	Gestión de acceso
4	busqueda y filtrado	Grep y find
5	compresion y empaquetado	Tar y otros
\.


--
-- Data for Name: comandos; Type: TABLE DATA; Schema: learnux; Owner: -
--

COPY learnux.comandos (id_comando, id_categoria, comando_nombre, descripcion, sintaxis, dificultad_nivel, salida_simulada) FROM stdin;
4	1	rm	<b>rm (Remove)</b>: El comando sin retorno.<br><br>Borra archivos o directorios de forma permanente. <b>En Linux no hay papelera de reciclaje</b>.<br><br><b>🛑 Regla de Oro:</b> Siempre que uses <b>rm -rf</b>, detente un segundo y lee la ruta dos veces.<br><b>🛡️ Seguridad:</b> Usa <b>rm -i</b> para que la terminal te pregunte antes de borrar cada archivo.	rm ARCHIVO	intermedio	\N
13	3	sudo	<b>sudo (SuperUser DO)</b>: El poder absoluto.<br><br><b>💡 Contexto:</b> Permite ejecutar comandos con privilegios de administrador (root). Es como "Ejecutar como administrador" en Windows, pero más seguro.<br><br><b>⚠️ Peligro:</b> "Un gran poder conlleva una gran responsabilidad". Un <i>sudo rm</i> mal puesto puede borrar tu sistema operativo entero.	sudo CMD	intermedio	\N
1	1	ls	<b>ls (List)</b>: El comando más usado. Permite ver qué hay dentro de una carpeta.<br><br><b>💡 Contexto:</b> En Linux, "todo es un archivo". <b>ls</b> es tu forma de confirmar que lo que hiciste (crear, mover, borrar) realmente sucedió.<br><br><b>⚠️ Nota:</b> Si ves archivos que empiezan con ".", no los borres a menos que sepas qué haces; son configuraciones críticas del sistema.	ls [OPCION]	principiante	\N
2	1	cp	<b>cp (Copy)</b>: Duplica la información.<br><br><b>💡 Contexto:</b> A diferencia de Windows, <b>cp</b> no pregunta nada por defecto. Si el destino ya existe, lo sobrescribirá sin avisar.<br><br><b>🚀 Tip:</b> Siempre usa <b>-i</b> (interactivo) si tienes miedo de perder un archivo importante al copiar.	cp ORIGEN DESTINO	principiante	\N
5	1	mv	<b>mv (Move)</b>: El comando de doble propósito: mover y renombrar.<br><br><b>💡 Contexto:</b> En Linux no existe un comando "rename". Renombrar es simplemente "mover" un archivo a la misma carpeta pero con otro nombre.<br><br><b>📂 Ejemplo:</b> <i>mv viejo.txt nuevo.txt</i>	mv ORIGEN DESTINO	principiante	\N
14	4	grep	<b>grep</b>: El buscador de agujas en pajares.<br><br><b>💡 Contexto:</b> Imagina un log de 1 millón de líneas. <b>grep</b> lo lee en milisegundos para encontrarte ese único error que buscas.<br><br><b>🛡️ Pro:</b> Es el mejor amigo del administrador para auditar accesos sospechosos en el servidor.	grep PATRON	intermedio	\N
15	4	find	<b>find</b>: El explorador incansable.<br><br><b>💡 Contexto:</b> A diferencia de <i>ls</i>, <b>find</b> busca profundamente en todo el árbol de directorios basándose en nombre, tamaño, fecha o dueños.	find RUTA	intermedio	\N
16	5	tar	<b>tar (Tape Archiver)</b>: El empaquetador universal.<br><br><b>💡 Contexto:</b> Se originó para guardar datos en cintas magnéticas, hoy es el estándar para comprimir software (.tar.gz).<br><br><b>📦 Regla mnemotécnica:</b> c=Create (crear), x=eXtract (extraer).	tar CMD	intermedio	\N
6	1	cat	<b>cat (Concatenate)</b>: El gran visor de archivos.<br><br><b>💡 Contexto:</b> Su nombre viene de su capacidad para unir (concatenar) varios archivos en uno solo. Es ideal para leer archivos cortos rápidamente o para volcar contenido de un archivo a otro usando tuberías (pipes).<br><br><b>🚀 Tip:</b> Si quieres leer un archivo MUY largo, usa mejor el comando <i>less</i> para poder navegar con las flechas.	cat ARCHIVO	principiante	\N
7	1	touch	<b>touch</b>: El guardián del tiempo.<br><br><b>💡 Contexto:</b> Aunque el 90% del tiempo lo usamos para crear archivos vacíos, su función técnica es cambiar los "timestamps" (fechas) de los archivos.<br><br><b>⚙️ Utilidad:</b> Es crucial en sistemas de backup y compilación (como <i>make</i>) para engañar al sistema haciéndole creer que un archivo ha sido modificado recientemente.	touch ARCHIVO	principiante	\N
8	1	pwd	<b>pwd (Print Working Directory)</b>: ¿Dónde estoy?.<br><br><b>💡 Contexto:</b> En una interfaz gráfica siempre ves la carpeta, en la terminal es fácil "perderse" tras varios saltos. <b>pwd</b> te da la ruta absoluta completa.	pwd	principiante	\N
11	2	free	<b>free</b>: El termómetro de la memoria RAM.<br><br><b>📊 Datos:</b> Muestra cuánta RAM tienes total, usada, libre y en caché. También muestra la "Swap" (memoria de intercambio en disco).	free	intermedio	\N
9	2	top	<b>top</b>: El administrador de tareas clásico.<br><br><b>📈 Vivo:</b> Muestra los procesos que más CPU y RAM consumen en tiempo real. Presiona "q" para salir.	top	intermedio	\N
19	1	ln	<b>ln (Link)</b>: Crea puentes entre archivos.<br><br><b>💡 Contexto:</b> En Linux, puedes hacer que un archivo aparezca en dos lugares a la vez sin duplicar su espacio en disco. Existen dos tipos:<br>· <b>Soft Links (-s):</b> Como los "Accesos directos" de Windows. Si borras el original, el link se rompe.<br>· <b>Hard Links:</b> Son clones reales. Si borras uno, el otro sigue vivo con el contenido intacto.<br><br><b>🚀 Uso común:</b> Instalar programas manualmente creando un link en <i>/usr/local/bin</i>.	ln ORIGEN DEST	intermedio	\N
20	2	ps	<b>ps (Process Status)</b>: Una "foto" instantánea de lo que corre en tu PC.<br><br><b>💡 Contexto:</b> A diferencia de <i>top</i> (que es un video en vivo), <b>ps</b> captura un momento exacto. Es fundamental para scripts o para encontrar el ID de un programa que se ha quedado colgado.<br><br><b>🔍 Pro Tip:</b> Casi siempre lo usarás como <b>ps aux</b>. La "a" es para todos los usuarios, la "u" para ver el dueño y la "x" para incluir procesos sin terminal.	ps	intermedio	\N
17	4	awk	<b>awk</b>: El procesador de datos por columnas.<br><br><b>💡 Contexto:</b> Es casi un lenguaje de programación por sí mismo. Su especialidad es leer archivos que parecen tablas (como listas de usuarios o logs) y extraer solo la columna que te interesa.<br><br><b>📂 Ejemplo:</b> Si tienes una lista de nombres y edades, <b>awk</b> puede sumarlas todas o imprimir solo los nombres en segundos.	awk PROG	avanzado	\N
18	4	sed	<b>sed (Stream Editor)</b>: Busca y reemplaza sin abrir el archivo.<br><br><b>💡 Contexto:</b> Es un editor de texto "en flujo". No necesitas abrir un archivo con <i>nano</i> o <i>vim</i> para cambiar una palabra. <b>sed</b> lo hace desde fuera, ideal para configurar servidores automáticamente.<br><br><b>🚀 Comando estrella:</b> <i>sed "s/viejo/nuevo/g" archivo</i> reemplaza todas las apariciones de "viejo" por "nuevo".	sed SCRIPT	avanzado	\N
10	2	df	<b>df (Disk Free)</b>: ¿Cuánto espacio me queda?.<br><br><b>💡 Contexto:</b> En un servidor, quedarse sin espacio es sinónimo de desastre (las bases de datos se corrompen). <b>df</b> te dice rápidamente qué disco o partición está a punto de llenarse.<br><br><b>📦 Tip:</b> Siempre úsalo con <b>-h</b> para no tener que calcular bytes de cabeza.	df	intermedio	\N
12	3	chmod	<b>chmod (Change Mode)</b>: Control de acceso total.<br><br><b>💡 Contexto:</b> Linux es multiusuario por naturaleza. <b>chmod</b> decide quién puede Leer (r), Escribir (w) o Ejecutar (x).<br><br><b>🔢 El truco de los números:</b><br>· 7 (rwx) - Todo permitido.<br>· 5 (r-x) - Leer y correr programa.<br>· 4 (r--) - Solo lectura.<br>Ejemplo: <b>755</b> significa Yo (Todo), Grupo (Lectura/Ejecución), Otros (Lectura/Ejecución).	chmod MODO	intermedio	\N
3	1	mkdir	<b>mkdir (Make Directory)</b>: Crea tu propio orden.<br><br><b>💡 Contexto:</b> Organizar archivos es la base de un buen administrador. Con <b>mkdir</b> empiezas a construir la estructura de tus proyectos.<br><br><b>🚀 Tip:</b> No crees carpetas una a una. Usa <b>mkdir -p</b> para crear una ruta completa como <i>fotos/2024/vacaciones</i> de un solo golpe.	mkdir DIR	principiante	\N
21	1	cd	<b>cd (Change Directory)</b>: Viaja por el sistema de archivos.<br><br><b>💡 Contexto:</b> Es tu forma de moverte. Sin <b>cd</b>, estarías atrapado en una sola carpeta. Es el comando que más usarás junto a <i>ls</i>.<br><br><b>📂 Atajos:</b><br>· <b>cd ..</b> : Retrocede (vuelve a la carpeta padre).<br>· <b>cd -</b> : Como el botón "Atrás" del mando de la tele (vuelve a donde estabas antes).	cd DIR	principiante	\N
\.


--
-- Data for Name: comandos_audit_log; Type: TABLE DATA; Schema: learnux; Owner: -
--

COPY learnux.comandos_audit_log (id_audit, tipo_accion, nombre_comando, usuario_db, fecha_evento) FROM stdin;
1	INSERT	ls	postgres	2026-04-17 21:13:45.286849
2	INSERT	cp	postgres	2026-04-17 21:13:45.286849
3	INSERT	mkdir	postgres	2026-04-17 21:13:45.286849
4	INSERT	rm	postgres	2026-04-17 21:13:45.286849
5	INSERT	mv	postgres	2026-04-17 21:13:45.286849
6	INSERT	cat	postgres	2026-04-17 21:13:45.286849
7	INSERT	touch	postgres	2026-04-17 21:13:45.286849
8	INSERT	pwd	postgres	2026-04-17 21:13:45.286849
9	INSERT	top	postgres	2026-04-17 21:13:45.286849
10	INSERT	df	postgres	2026-04-17 21:13:45.286849
11	INSERT	free	postgres	2026-04-17 21:13:45.286849
12	INSERT	chmod	postgres	2026-04-17 21:13:45.286849
13	INSERT	sudo	postgres	2026-04-17 21:13:45.286849
14	INSERT	grep	postgres	2026-04-17 21:13:45.286849
15	INSERT	find	postgres	2026-04-17 21:13:45.286849
16	INSERT	tar	postgres	2026-04-17 21:13:45.286849
17	INSERT	awk	postgres	2026-04-17 21:13:45.286849
18	INSERT	sed	postgres	2026-04-17 21:13:45.286849
19	INSERT	ln	postgres	2026-04-17 21:13:45.286849
20	INSERT	ps	postgres	2026-04-17 21:13:45.286849
21	INSERT	cd	postgres	2026-04-18 13:40:54.174438
22	UPDATE	ls	postgres	2026-04-18 13:40:54.174438
23	UPDATE	cp	postgres	2026-04-18 13:40:54.174438
24	UPDATE	mkdir	postgres	2026-04-18 13:40:54.174438
25	UPDATE	rm	postgres	2026-04-18 13:40:54.174438
26	UPDATE	mv	postgres	2026-04-18 13:40:54.174438
27	UPDATE	cat	postgres	2026-04-18 13:40:54.174438
28	UPDATE	touch	postgres	2026-04-18 13:40:54.174438
29	UPDATE	pwd	postgres	2026-04-18 13:40:54.174438
30	UPDATE	top	postgres	2026-04-18 13:40:54.174438
31	UPDATE	df	postgres	2026-04-18 13:40:54.174438
32	UPDATE	free	postgres	2026-04-18 13:40:54.174438
33	UPDATE	chmod	postgres	2026-04-18 13:40:54.174438
34	UPDATE	sudo	postgres	2026-04-18 13:40:54.174438
35	UPDATE	grep	postgres	2026-04-18 13:40:54.174438
36	UPDATE	find	postgres	2026-04-18 13:40:54.174438
37	UPDATE	tar	postgres	2026-04-18 13:40:54.174438
38	UPDATE	awk	postgres	2026-04-18 13:40:54.174438
39	UPDATE	sed	postgres	2026-04-18 13:40:54.174438
40	UPDATE	ln	postgres	2026-04-18 13:40:54.174438
41	UPDATE	ps	postgres	2026-04-18 13:40:54.174438
42	INSERT	cd	postgres	2026-04-27 21:38:23.961459
43	INSERT	ls	postgres	2026-04-27 21:38:23.961459
44	INSERT	cp	postgres	2026-04-27 21:38:23.961459
45	INSERT	mkdir	postgres	2026-04-27 21:38:23.961459
46	INSERT	rm	postgres	2026-04-27 21:38:23.961459
47	INSERT	mv	postgres	2026-04-27 21:38:23.961459
48	INSERT	cat	postgres	2026-04-27 21:38:23.961459
49	INSERT	touch	postgres	2026-04-27 21:38:23.961459
50	INSERT	pwd	postgres	2026-04-27 21:38:23.961459
51	INSERT	top	postgres	2026-04-27 21:38:23.961459
52	INSERT	df	postgres	2026-04-27 21:38:23.961459
53	INSERT	free	postgres	2026-04-27 21:38:23.961459
54	INSERT	chmod	postgres	2026-04-27 21:38:23.961459
55	INSERT	sudo	postgres	2026-04-27 21:38:23.961459
56	INSERT	grep	postgres	2026-04-27 21:38:23.961459
57	INSERT	find	postgres	2026-04-27 21:38:23.961459
58	INSERT	tar	postgres	2026-04-27 21:38:23.961459
59	INSERT	awk	postgres	2026-04-27 21:38:23.961459
60	INSERT	sed	postgres	2026-04-27 21:38:23.961459
61	INSERT	ln	postgres	2026-04-27 21:38:23.961459
62	INSERT	ps	postgres	2026-04-27 21:38:23.961459
63	UPDATE	ls	postgres	2026-04-27 22:31:58.716504
64	UPDATE	cd	postgres	2026-04-27 22:31:58.720035
65	UPDATE	cp	postgres	2026-04-27 22:31:58.721711
66	UPDATE	mv	postgres	2026-04-27 22:31:58.723312
67	UPDATE	mkdir	postgres	2026-04-27 22:31:58.725205
68	UPDATE	rm	postgres	2026-04-27 22:31:58.726631
69	UPDATE	pwd	postgres	2026-04-27 22:31:58.728081
70	UPDATE	grep	postgres	2026-04-27 22:31:58.729372
71	UPDATE	find	postgres	2026-04-27 22:31:58.730593
72	UPDATE	chmod	postgres	2026-04-27 22:31:58.731871
\.


--
-- Data for Name: ejercicios; Type: TABLE DATA; Schema: learnux; Owner: -
--

COPY learnux.ejercicios (id_ejercicio, id_nivel, id_comando, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden, activo, salida_simulada) FROM stdin;
1	1	1	DRAG_DROP	¿Comando para listar?	ls	["ls", "cd"]	ls	1	t	\N
201	1	1	MULTIPLE_CHOICE	¿Cuál de los siguientes comandos muestra los archivos de /etc ordenados por tamaño (mayor a menor)?	ls -lS /etc	["ls -lS /etc", "ls -lt /etc", "ls -lh /etc", "ls -R /etc"]	S de "Size": ordena por tamaño de archivo.	5	t	\N
202	2	21	DRAG_DROP	¿Qué símbolo representa el directorio HOME del usuario en Linux?	~	["~", "..", "/", "$HOME"]	Es el símbolo tilde, siempre apunta a /home/tuusuario.	3	t	\N
204	3	3	MULTIPLE_CHOICE	¿Qué hace mkdir -v al crear un directorio?	Muestra un mensaje por cada directorio creado	["Muestra un mensaje por cada directorio creado", "Crea los directorios padre automáticamente", "Crea el directorio con permisos especiales", "Crea el directorio en modo silencioso"]	v de verbose: muestra lo que está haciendo.	4	t	\N
208	5	7	DRAG_DROP	¿Qué comando crea un archivo vacío si no existe?	touch	["touch", "cat", "echo", "mkdir"]	touch actualiza timestamps o crea el archivo si no existe.	4	t	\N
210	6	1	MULTIPLE_CHOICE	¿Qué combinación de banderas muestra todos los archivos (incluidos ocultos) ordenados del más nuevo al más antiguo?	ls -alt	["ls -alt", "ls -alS", "ls -alh", "ls -alR"]	-a todos, -l detalles, -t ordenado por tiempo.	4	t	\N
211	6	1	TYPE_COMMAND	Escribe el comando para listar solo los directorios en /var (pista: usa ls con grep).	ls -l /var | grep ^d	\N	Combina ls -l con grep ^d (las líneas de directorio empiezan con d).	5	t	\N
222	12	14	FILL_BLANK	Completa: grep ___ "TODO" /home/dan/proyecto (busca recursivamente y muestra solo los nombres de archivos)	-rl	["-rl", "-rc", "-ri", "-rn"]	Necesitas -r (recursivo) y -l (solo nombres de archivo).	4	t	\N
223	12	12	FILL_BLANK	Completa: chmod ___ deploy.sh (dar permiso de ejecución solo al dueño, sin tocar grupo y otros)	u+x	["u+x", "+x", "755", "o+x"]	u = user (dueño), + = añadir, x = execute.	5	t	\N
224	13	14	TYPE_COMMAND	Escribe el comando para buscar recursivamente la palabra "password" (sin distinguir mayúsculas) en /etc y mostrar solo los nombres de archivos.	grep -ril "password" /etc	\N	Combina -r (recursivo), -i (ignore case) y -l (solo nombres de archivo).	4	t	\N
225	13	12	TYPE_COMMAND	Escribe el comando para quitar el permiso de lectura a otros (o) en el archivo secreto.txt.	chmod o-r secreto.txt	\N	o = others (otros), - = quitar, r = read.	5	t	\N
226	14	15	TYPE_COMMAND	Escribe el comando para encontrar archivos modificados en las últimas 24 horas dentro de /home.	find /home -mtime -1	\N	-mtime -1 significa "modificado hace menos de 1 día (24 horas)".	4	t	\N
227	14	15	TYPE_COMMAND	Escribe el comando para buscar archivos mayores de 100MB en /var.	find /var -size +100M	\N	-size +100M: archivos de más de 100 megabytes.	5	t	\N
203	2	21	DRAG_DROP	Para subir al directorio padre desde donde estás, ¿qué escribes después de cd?	..	["..", "~", "-", "/"]	.. siempre apunta al directorio que contiene al directorio actual.	4	t	\N
205	3	3	DRAG_DROP	¿Qué comando usas para confirmar que un directorio fue creado correctamente?	ls	["ls", "check", "verify", "stat"]	ls lista el contenido del directorio actual, así puedes ver si apareció la carpeta nueva.	5	t	\N
207	4	2	DRAG_DROP	¿Qué flag de cp muestra en pantalla cada archivo que está copiando?	-v	["-v", "-r", "-p", "-f"]	v de "verbose": te confirma visualmente cada operación de copia.	5	t	\N
215	8	5	FILL_BLANK	Completa: cp ___ proyecto/ /backup/ (copiar el directorio completo con todo su contenido)	-r	["-r", "-p", "-u", "-v"]	r de "recursive": sin este flag cp no puede copiar directorios.	5	t	\N
216	9	4	MULTIPLE_CHOICE	¿Cuál de estas afirmaciones sobre rm es correcta?	rm elimina archivos de forma permanente, no existe papelera de reciclaje	["rm elimina archivos de forma permanente, no existe papelera de reciclaje", "rm mueve los archivos a la papelera del sistema", "rm solo borra si el archivo no está abierto por otro proceso", "rm pide confirmación antes de borrar por defecto"]	A diferencia del explorador gráfico, rm no usa papelera — el archivo desaparece para siempre.	4	t	\N
218	10	6	MULTIPLE_CHOICE	¿Qué hace cat -A al mostrar un archivo?	Muestra caracteres especiales: fin de línea como $ y tabulaciones como ^I	["Muestra caracteres especiales: fin de línea como $ y tabulaciones como ^I", "Muestra el archivo en formato hexadecimal", "Muestra solo las primeras 10 líneas del archivo", "Muestra el archivo en orden inverso línea por línea"]	-A de "show-all": útil para detectar caracteres invisibles que causan errores en scripts.	4	t	\N
219	10	6	DRAG_DROP	¿Qué flag de cat numera solo las líneas con contenido, omitiendo las líneas vacías?	-b	["-b", "-n", "-v", "-A"]	b de "number nonblank": a diferencia de -n, no cuenta las líneas vacías.	5	t	\N
220	11	14	FILL_BLANK	Completa: grep ___ "ERROR" /var/log/ (buscar la palabra en todos los archivos del directorio recursivamente)	-r	["-r", "-i", "-n", "-v"]	r de "recursive": sin este flag grep solo busca en un archivo, no en directorios.	4	t	\N
221	11	14	FILL_BLANK	Completa: grep ___ "timeout" server.log (mostrar cuántas líneas contienen la palabra, no las líneas en sí)	-c	["-c", "-n", "-l", "-v"]	c de "count": devuelve solo el número, no el contenido de las líneas.	5	t	\N
206	4	5	MULTIPLE_CHOICE	¿Qué hace la bandera -n en el comando mv?	No sobreescribe el archivo destino si ya existe	["No sobreescribe el archivo destino si ya existe", "Mueve sin confirmación", "Crea el directorio destino si no existe", "Mueve en modo recursivo"]	-n de "no-clobber": protege archivos existentes.	4	t	\N
212	7	1	MULTIPLE_CHOICE	¿Cuál de estos comandos muestra los archivos del directorio /etc ordenados por tamaño, de mayor a menor?	ls -lS /etc	["ls -lS /etc", "ls -lt /etc", "ls -lh /etc", "ls -la /etc"]	S de "Size": ordena por tamaño. Combínalo con -l para ver los detalles.	4	t	\N
228	15	14	TYPE_COMMAND	Escribe el comando para mostrar las 3 líneas de contexto ANTES de cada coincidencia de "FATAL" en app.log.	grep -B 3 "FATAL" app.log	\N	-B N muestra N líneas Antes (Before) de la coincidencia.	4	t	\N
229	15	14	TYPE_COMMAND	Escribe el comando para buscar líneas que empiecen con "ERROR" en syslog.	grep "^ERROR" /var/log/syslog	\N	^ en regex significa "inicio de línea".	5	t	\N
230	16	20	TERMINAL_SIM	Quieres ver todos los procesos del sistema con su usuario, PID, CPU y memoria. ¿Qué comando escribes?	ps aux	\N	ps aux: a=todos los usuarios, u=formato orientado a usuario, x=incluye procesos sin terminal.	4	t	dan@learnux:~$ 
231	16	9	TERMINAL_SIM	Quieres monitorear el proceso con PID 1234 durante 5 iteraciones sin interacción. ¿Qué comando usas?	top -n 5 -p 1234	\N	-n N: número de iteraciones, -p PID: monitorear proceso específico.	5	t	dan@learnux:~$ ps aux | grep 1234\\ndan   1234  0.5  1.2  12345  6789 pts/0  S  10:00  0:00 python app.py\\ndan@learnux:~$ 
232	17	10	TERMINAL_SIM	Quieres ver el espacio disponible en todos los discos en formato legible (GB, MB). ¿Qué comando usas?	df -h	\N	-h de "human-readable": muestra en KB/MB/GB.	4	t	dan@learnux:~$ 
233	17	11	TERMINAL_SIM	Quieres ver el uso de memoria RAM y swap mostrando totales al final. ¿Qué comando escribes?	free -ht	\N	-h legible, -t muestra totales de RAM + swap al final.	5	t	dan@learnux:~$ free -h\\n              total  usada  libre\\nMem:          7.7G   3.2G   4.5G\\nSwap:         2.0G   0.0G   2.0G\\ndan@learnux:~$ 
234	18	14	TERMINAL_SIM	Quieres buscar la palabra "denied" en todos los logs de /var/log, mostrando el archivo y número de línea.	grep -rn "denied" /var/log	\N	-r recursivo, -n muestra número de línea.	4	t	dan@learnux:~$ 
235	18	14	TERMINAL_SIM	La siguiente salida fue producida por un comando grep. ¿Cuántas coincidencias había en total?	grep -c "error" /var/log/syslog	\N	-c cuenta las coincidencias. La salida fue un número, no líneas.	5	t	/var/log/syslog:47\\ndan@learnux:~$ 
236	19	12	TERMINAL_SIM	Quieres hacer que todos los archivos .sh en /home/dan/scripts sean ejecutables para el dueño. ¿Qué comando usas?	chmod u+x /home/dan/scripts/*.sh	\N	u+x añade ejecución al dueño. El comodín *.sh aplica a todos los scripts.	4	t	dan@learnux:~$ ls -l /home/dan/scripts/\\n-rw-r--r-- 1 dan dan 1024 ene 15 backup.sh\\n-rw-r--r-- 1 dan dan  512 ene 15 deploy.sh\\ndan@learnux:~$ 
237	19	12	TERMINAL_SIM	Tienes un directorio compartido /datos. Quieres que el grupo tenga permiso de escritura en él. ¿Qué comando usas?	chmod g+w /datos	\N	g = group (grupo), +w = añadir escritura.	5	t	dan@learnux:~$ ls -ld /datos\\ndrwxr-xr-x 2 dan staff 4096 ene 15 /datos\\ndan@learnux:~$ 
238	20	15	TERMINAL_SIM	Necesitas borrar todos los archivos .tmp dentro de /tmp que tengan más de 7 días. ¿Qué comando usas?	find /tmp -name "*.tmp" -mtime +7 -delete	\N	-mtime +7 = más de 7 días, -delete los elimina directamente.	4	t	root@learnux:~# find /tmp -name "*.tmp" | wc -l\\n23\\nroot@learnux:~# 
239	20	16	TERMINAL_SIM	Quieres crear un respaldo comprimido (gzip) de /etc llamado etc_backup.tar.gz. ¿Qué comando usas?	tar -czf etc_backup.tar.gz /etc	\N	-c crear, -z comprimir con gzip, -f nombre del archivo, luego el origen.	5	t	root@learnux:~# du -sh /etc\\n14M    /etc\\nroot@learnux:~# 
200	1	1	DRAG_DROP	El comando ls muestra archivos por orden alfabético, pero a veces necesitas ver qué has modificado recientemente. ¿Qué bandera (flag) añade el orden por fecha de modificación?	-t	["-t", "-r", "-S", "-a"]	Viene de "time". Nota: Las mayúsculas importan en Linux.	4	t	\N
2	1	1	DRAG_DROP	Las "flags" o banderas modifican el comportamiento del comando ls. Empareja cada una con su superpoder:	{"-l":"Muestra detalles (permisos, tamaño, fecha)","-a":"Muestra TODO (incluye archivos ocultos . )","-h":"Hace los tamaños legibles (KB, MB, GB)"}	["-l", "-a", "-h", "-R"]	Usa -l para "long format" y -a para "all".	2	t	\N
3	3	3	DRAG_DROP	¿Qué flag de mkdir crea automáticamente los directorios padre que falten en la ruta?	-p	["-p", "-v", "-r", "-m"]	p de "parents": mkdir -p a/b/c crea a, luego a/b, luego a/b/c.	6	t	\N
5	4	5	DRAG_DROP	¿Qué comando se usa para RENOMBRAR un archivo en Linux (sin moverlo de directorio)?	mv	["mv", "cp", "rename", "rn"]	mv origen destino: si el destino está en el mismo directorio, el resultado es un renombrado.	6	t	\N
6	4	2	DRAG_DROP	¿Qué flag de cp hace que la copia sea recursiva para poder copiar directorios completos?	-r	["-r", "-p", "-v", "-f"]	r de "recursive": recorre todos los archivos y subdirectorios dentro del directorio.	7	t	\N
7	5	4	DRAG_DROP	¿Qué flag de rm pide confirmación antes de borrar cada archivo?	-i	["-i", "-f", "-v", "-r"]	i de "interactive": te pregunta "¿seguro?" antes de cada borrado.	6	t	\N
8	5	4	DRAG_DROP	¿Qué combinación de flags borra un directorio con todo su contenido sin pedir confirmación?	-rf	["-rf", "-ri", "-if", "-rv"]	r de recursive + f de force. ¡Úsalo con cuidado, no hay papelera!	7	t	\N
9	7	1	DRAG_DROP	¿Qué flag de ls muestra TODOS los archivos, incluidos los ocultos (los que empiezan con .)?	-a	["-a", "-l", "-h", "-r"]	a de "all": sin este flag, ls oculta los archivos cuyo nombre empieza con punto.	6	t	\N
10	7	1	DRAG_DROP	¿Qué flag de ls ordena los resultados por fecha de modificación, del más reciente al más antiguo?	-t	["-t", "-s", "-u", "-c"]	t de "time": muy útil para ver rápidamente qué archivos cambiaron últimamente.	7	t	\N
11	8	2	DRAG_DROP	¿Qué flag de cp preserva los permisos, dueño y timestamps del archivo original?	-p	["-p", "-r", "-v", "-u"]	p de "preserve": mantiene los metadatos intactos, útil en backups.	6	t	\N
12	8	5	DRAG_DROP	Arrastra el flag de mv que muestra en pantalla cada archivo que se está moviendo.	-v	["-v", "-f", "-n", "-b"]	v de "verbose": te confirma visualmente qué operaciones se realizaron.	7	t	\N
13	9	4	DRAG_DROP	¿Qué flag de rm borra forzosamente sin mostrar errores ni pedir confirmación?	-f	["-f", "-i", "-v", "-r"]	f de "force": ignora archivos inexistentes y nunca pregunta. Peligroso sin -r.	6	t	\N
14	9	4	DRAG_DROP	¿Qué comando (diferente a rm) se usa para borrar un directorio vacío de forma segura?	rmdir	["rmdir", "rd", "del", "rm -d"]	rmdir solo funciona si el directorio está completamente vacío, lo cual lo hace seguro.	7	t	\N
209	5	6	DRAG_DROP	¿Qué comando muestra el contenido de un archivo de texto directamente en la terminal?	cat	["cat", "read", "open", "show"]	cat de "concatenate": originalmente une archivos, pero también sirve para leer uno solo.	5	t	\N
213	7	1	DRAG_DROP	¿Qué flag de ls lista el contenido de todos los subdirectorios de forma recursiva?	-R	["-R", "-r", "-l", "-d"]	R mayúscula de "Recursive": desciende a cada subdirectorio y muestra su contenido.	5	t	\N
214	8	2	MULTIPLE_CHOICE	¿Qué hace cp -u al copiar archivos?	Solo copia si el origen es más nuevo que el destino o si el destino no existe	["Solo copia si el origen es más nuevo que el destino o si el destino no existe", "Copia en modo silencioso sin mostrar nada", "Copia preservando todos los metadatos del archivo", "Actualiza siempre el archivo en el destino"]	u de "update": evita sobreescribir archivos que ya están actualizados en el destino.	4	t	\N
217	9	4	DRAG_DROP	Para borrar solo los archivos con extensión .log del directorio actual, ¿qué comodín usas junto a rm?	*.log	["*.log", ".log", "all.log", "??.log"]	* representa cualquier cadena de caracteres: rm *.log borra todos los archivos que terminen en .log.	5	t	\N
20	2	21	DRAG_DROP	Para saltar al directorio en el que estabas ANTES del último cd, ¿qué escribes después de cd?	-	["-", "~", "..", "/"]	Es un guion: cd - te lleva de vuelta al directorio anterior.	6	t	\N
4	3	3	DRAG_DROP	¿Qué flag de mkdir asigna permisos al directorio en el momento de crearlo?	-m	["-m", "-p", "-v", "-r"]	m de "mode": mkdir -m 755 carpeta crea el directorio con esos permisos.	7	t	\N
15	10	6	DRAG_DROP	¿Qué flag de cat numera TODAS las líneas del archivo, incluidas las líneas vacías?	-n	["-n", "-b", "-v", "-A"]	n de "number": -b también numera líneas pero salta las vacías.	6	t	\N
16	10	7	DRAG_DROP	¿Qué flag de touch actualiza SOLO la fecha de modificación sin tocar la fecha de acceso?	-m	["-m", "-a", "-t", "-c"]	m de "modification": su opuesto es -a que actualiza solo la fecha de acceso.	7	t	\N
17	11	14	DRAG_DROP	¿Qué flag de grep hace que la búsqueda ignore mayúsculas y minúsculas?	-i	["-i", "-v", "-n", "-c"]	i de "ignore-case": con este flag "Error", "error" y "ERROR" son lo mismo.	6	t	\N
18	11	14	DRAG_DROP	¿Qué flag de grep muestra el número de línea donde aparece cada coincidencia?	-n	["-n", "-c", "-l", "-i"]	n de "line number": te dice exactamente en qué línea está cada resultado.	7	t	\N
19	2	8	DRAG_DROP	¿Qué comando muestra la ruta absoluta del directorio donde te encuentras actualmente?	pwd	["pwd", "cd", "ls", "echo"]	Print Working Directory: imprime el directorio de trabajo actual.	5	t	\N
\.


--
-- Data for Name: intentos_ejercicio; Type: TABLE DATA; Schema: learnux; Owner: -
--

COPY learnux.intentos_ejercicio (id_intento, id_usuario, id_ejercicio, id_nivel, respuesta_dada, correcta, puntos_ganados, tiempo_segundos, fecha_intento) FROM stdin;
1	1	201	1	ls -lS /etc	t	10	\N	2026-04-29 12:19:16.752091
2	1	2	1	{"-l":"Muestra detalles (permisos, tamaño, fecha)","-a":"Muestra TODO (incluye archivos ocultos . )","-h":"Hace los tamaños legibles (KB, MB, GB)"}	t	10	\N	2026-04-29 12:19:25.055118
3	1	1	1	ls	t	10	\N	2026-04-29 12:19:32.005315
4	1	200	1	-t	t	10	\N	2026-04-29 12:19:40.193466
5	1	19	2	pwd	t	10	\N	2026-04-29 12:20:00.301987
6	1	203	2	..	t	10	\N	2026-04-29 12:20:05.071781
7	1	202	2	~	t	10	\N	2026-04-29 12:20:09.847357
8	1	20	2	..	f	0	\N	2026-04-29 12:20:16.552591
9	1	3	3	-p	t	10	\N	2026-04-29 12:23:48.04165
10	1	205	3	ls	t	10	\N	2026-04-29 12:23:54.000645
11	1	204	3	Muestra un mensaje por cada directorio creado	t	10	\N	2026-04-29 12:23:59.566682
12	1	4	3	-r	f	0	\N	2026-04-29 12:24:05.474468
13	1	4	3	-m	t	10	\N	2026-04-29 12:24:08.606825
14	1	6	4	-r	t	10	\N	2026-04-29 12:24:23.424793
15	1	5	4	mv	t	10	\N	2026-04-29 12:24:27.674138
16	1	207	4	-v	t	10	\N	2026-04-29 12:24:32.240989
17	1	206	4	No sobreescribe el archivo destino si ya existe	t	10	\N	2026-04-29 12:24:35.432187
18	1	208	5	touch	t	10	\N	2026-04-29 12:25:33.845747
19	1	209	5	cat	t	10	\N	2026-04-29 12:25:37.768683
20	1	8	5	-rf	t	10	\N	2026-04-29 12:25:41.69707
21	1	7	5	-v	f	0	\N	2026-04-29 12:25:46.621897
22	1	7	5	-i	t	10	\N	2026-04-29 12:25:50.122258
23	1	10	7	-t	t	10	\N	2026-04-29 12:26:49.916463
24	1	9	7	-a	t	10	\N	2026-04-29 12:26:54.603736
25	1	213	7	-R	t	10	\N	2026-04-29 12:26:59.384572
26	1	212	7	ls -lS /etc	t	10	\N	2026-04-29 12:27:09.636708
27	1	214	8	Solo copia si el origen es más nuevo que el destino o si el destino no existe	t	10	\N	2026-04-29 12:27:19.302304
28	1	215	8	-r	t	10	\N	2026-04-29 12:27:31.088783
29	1	12	8	-v	t	10	\N	2026-04-29 12:27:36.45254
30	1	11	8	-p	t	10	\N	2026-04-29 12:27:43.89718
31	1	216	9	rm elimina archivos de forma permanente, no existe papelera de reciclaje	t	10	\N	2026-04-29 12:27:53.160272
32	1	13	9	-f	t	10	\N	2026-04-29 12:27:58.721698
33	1	14	9	rm -d	f	0	\N	2026-04-29 12:28:04.714343
34	1	14	9	rmdir	t	10	\N	2026-04-29 12:28:08.600883
35	1	217	9	*.log	t	10	\N	2026-04-29 12:28:13.249444
36	1	16	10	-m	t	10	\N	2026-04-29 12:28:24.634453
37	1	15	10	-n	t	10	\N	2026-04-29 12:28:27.978701
38	1	218	10	Muestra caracteres especiales: fin de línea como $ y tabulaciones como ^I	t	10	\N	2026-04-29 12:28:34.188157
39	1	219	10	-b	t	10	\N	2026-04-29 12:28:38.544198
40	1	17	11	-i	t	10	\N	2026-04-29 12:29:30.594553
41	1	18	11	-n	t	10	\N	2026-04-29 12:29:34.036282
42	1	220	11	-r	t	10	\N	2026-04-29 12:29:37.852464
43	1	221	11	-c	t	10	\N	2026-04-29 12:29:40.760202
44	1	224	13	grep -ri /etc	f	0	\N	2026-04-29 12:32:28.037876
45	1	224	13	grep -r -i -l /etc	f	0	\N	2026-04-29 12:32:47.67442
46	1	224	13	grep -ril /etc	f	0	\N	2026-04-29 12:32:54.004739
47	2	2	1	{"-l":"Muestra detalles (permisos, tamaño, fecha)","-a":"Muestra TODO (incluye archivos ocultos . )","-h":"Hace los tamaños legibles (KB, MB, GB)"}	t	10	\N	2026-04-29 12:43:30.044696
48	2	1	1	ls	t	10	\N	2026-04-29 12:43:33.694586
49	2	200	1	-t	t	10	\N	2026-04-29 12:43:37.234313
50	2	201	1	ls -R /etc	f	0	\N	2026-04-29 12:43:42.281262
51	2	201	1	ls -R /etc	f	0	\N	2026-04-29 12:43:42.608934
52	2	201	1	ls -lS /etc	t	10	\N	2026-04-29 12:43:49.239141
53	6	2	1	{"-l":"Muestra detalles (permisos, tamaño, fecha)","-a":"Muestra TODO (incluye archivos ocultos . )","-h":"Hace los tamaños legibles (KB, MB, GB)"}	t	10	\N	2026-04-29 21:51:11.296866
54	6	201	1	ls -lt /etc	f	0	\N	2026-04-29 21:51:13.619453
55	6	201	1	ls -lh /etc	f	0	\N	2026-04-29 21:51:21.771475
56	6	201	1	ls -lS /etc	t	10	\N	2026-04-29 21:51:24.459664
\.


--
-- Data for Name: niveles; Type: TABLE DATA; Schema: learnux; Owner: -
--

COPY learnux.niveles (id_nivel, numero, nombre, descripcion, tipo_ejercicio, dificultad, puntos_para_pasar, puntos_recompensa, desbloqueado_por) FROM stdin;
1	1	Tu primer comando: ls	<b>ls</b> lista los archivos y carpetas del directorio actual. Es el comando más usado en Linux.<br><br><b>Uso:</b> ls [opciones] [ruta]<br><b>Ejemplo:</b> <b>ls /home</b> muestra los archivos de /home<br><br>Banderas útiles: <b>-l</b> (detalles), <b>-a</b> (incluye ocultos), <b>-h</b> (tamaños legibles)	DRAG_DROP	principiante	50	15	\N
2	2	Navegar: pwd y cd	<b>pwd</b> imprime la ruta completa del directorio donde estás.<br><b>cd</b> cambia de directorio (te mueves por las carpetas).<br><br><b>Ejemplos:</b><br>· <b>pwd</b> → imprime /home/dan<br>· <b>cd /etc</b> → entra a la carpeta /etc<br>· <b>cd ..</b> → sube un nivel (va al directorio padre)<br>· <b>cd ~</b> → vuelve directo a tu carpeta personal (HOME)	DRAG_DROP	principiante	50	15	1
3	3	Crear carpetas: mkdir	<b>mkdir</b> crea un directorio (carpeta) nuevo.<br><br><b>Uso:</b> mkdir [opciones] nombre_carpeta<br><b>Ejemplo:</b> <b>mkdir proyectos</b> crea la carpeta "proyectos" donde estás<br><br>Con la bandera <b>-p</b> puedes crear carpetas anidadas de golpe:<br><b>mkdir -p proyectos/web/css</b> crea los tres niveles aunque no existan	DRAG_DROP	principiante	50	15	2
4	4	Copiar y mover: cp y mv	<b>cp</b> copia un archivo — el original se queda intacto.<br><b>mv</b> mueve o renombra — el original desaparece del lugar original.<br><br><b>Sintaxis:</b> cp/mv ORIGEN DESTINO<br><b>Ejemplos:</b><br>· <b>cp notas.txt copia.txt</b> → crea una copia llamada copia.txt<br>· <b>mv notas.txt diario.txt</b> → renombra el archivo a diario.txt<br>· <b>cp -r fotos/ backup/</b> → copia una carpeta completa (necesita -r)	DRAG_DROP	principiante	60	15	3
5	5	Leer y borrar: cat y rm	<b>cat</b> muestra el contenido completo de un archivo de texto en la terminal.<br><b>rm</b> elimina archivos — CUIDADO: no hay papelera, es permanente.<br><br><b>Ejemplos:</b><br>· <b>cat notas.txt</b> → imprime todo el contenido de notas.txt<br>· <b>rm viejo.txt</b> → borra viejo.txt para siempre<br>· <b>rm -r carpeta/</b> → borra una carpeta y todo su contenido<br>· <b>rm -i archivo</b> → pide confirmación antes de borrar (más seguro)	DRAG_DROP	principiante	60	15	4
6	6	Jefe Final: Fundamentos	<b>Tu primer desafío real</b><br>Después de aprender los conceptos básicos, es hora de ponerlos a prueba.<br><br>Deberás crear una estructura de directorios para un proyecto real, mover archivos de configuración, y limpiar archivos temporales.<br><br>Usa todo lo que aprendiste en niveles 1-5. No hay pistas esta vez.	TERMINAL_SIM	principiante	70	30	5
7	7	Flags de ls en detalle	<b>Más allá de ls -l y ls -a</b><br>El comando <b>ls</b> tiene flags muy útiles para trabajar con muchos archivos.<br><br><b>ls -lh</b>: combina detalles (-l) con tamaños legibles (-h).<br><b>ls -lt</b>: ordena por fecha de modificación.<br><b>ls -lS</b>: ordena por tamaño.<br><b>ls -R</b>: recursivo, muestra subdirectorios.	MULTIPLE_CHOICE	principiante	60	15	6
10	10	touch y cat en profundidad	<b>touch: crear y actualizar</b><br><b>touch archivo.txt</b>: si el archivo no existe, lo crea vacío.<br><br><b>cat en profundidad</b><br><b>cat -n archivo</b>: muestra el contenido con <b>números de línea</b>.<br><b>cat archivo1 archivo2</b>: concatena varios archivos.	MULTIPLE_CHOICE	intermedio	60	15	9
11	11	Introducción a grep	<b>grep: buscar texto dentro de archivos</b><br>grep es uno de los comandos más potentes de Linux.<br><br><b>grep -i</b>: ignora mayúsculas/minúsculas.<br><b>grep -r</b>: busca recursivamente en directorios.<br><b>grep -n</b>: muestra el número de línea.<br><b>grep -c</b>: cuenta cuántas líneas coinciden.	MULTIPLE_CHOICE	intermedio	60	15	10
16	16	Terminal IV: permisos con chmod	<b>chmod: cambiar permisos</b><br>Cada archivo tiene tres grupos: <b>u</b> (dueño), <b>g</b> (grupo), <b>o</b> (otros).<br><br><b>Notación numérica</b>: r=4, w=2, x=1.<br><b>755</b>: dueño rwx, grupo+otros r-x.<br><b>600</b>: solo el dueño lee y escribe.	TYPE_COMMAND	intermedio	65	20	15
24	24	Jefe Final: Maestro	<b>El sysadmin master</b><br>Este es el desafío final. Un servidor completo necesita tu ayuda.<br><br>Deberás:<br>- Buscar y reemplazar texto<br>- Crear scripts de backup<br>- Gestionar permisos complejos<br>- Limpiar y organizar estructuras	TERMINAL_SIM	avanzado	80	50	23
8	8	cp y mv con flags	<b>cp y mv con banderas avanzadas</b><br>Ambos comandos tienen flags que cambian su comportamiento.<br><br><b>cp -u</b>: solo copia si el origen es más nuevo que el destino (útil para sincronizar).<br><b>cp -r</b>: copia un directorio completo de forma recursiva.<br><b>cp -p</b>: preserva permisos, dueño y fechas del archivo original.<br><b>mv -v</b>: muestra cada archivo que se está moviendo.<br><b>mv -n</b>: no sobreescribe el destino si ya existe.	MULTIPLE_CHOICE	principiante	60	15	7
9	9	rm y sus peligros	<b>rm: el comando más peligroso de Linux</b><br>En Linux <b>NO hay papelera</b>. Lo que borras con rm desaparece para siempre.<br><br><b>rm archivo</b>: borra un archivo.<br><b>rm -r directorio</b>: borra un directorio y todo su contenido (recursivo).<br><b>rm -f</b>: fuerza el borrado sin preguntar ni mostrar errores.<br><b>rm -rf</b>: combinación más peligrosa — borra todo sin confirmación.<br><b>rm -i</b>: modo interactivo, pide confirmación antes de cada borrado.<br><b>rmdir</b>: elimina un directorio vacío de forma segura.	MULTIPLE_CHOICE	principiante	60	15	8
12	12	Jefe Final: Intermedio	<b>Jefe Final: Tier 2 — Intermedio</b><br>Has dominado la navegación, la gestión de archivos y la búsqueda de texto.<br><br>Este jefe pone a prueba tu manejo de <b>grep</b> y <b>chmod</b> en situaciones reales de administración de sistemas. Sin pistas. Confía en lo que aprendiste.	TERMINAL_SIM	intermedio	70	35	11
13	13	Completa: Básicos	<b>Repaso: comandos del Tier 1 y 2</b><br>Consolida lo aprendido usando <b>grep</b> y <b>chmod</b> juntos.<br><br><b>grep -r</b>: busca texto recursivamente en directorios.<br><b>grep -i</b>: ignora mayúsculas/minúsculas.<br><b>chmod +x</b>: agrega permiso de ejecución.<br><b>chmod 644</b>: permisos típicos para archivos de configuración.	FILL_BLANK	intermedio	65	20	12
17	17	Terminal: Gestión	<b>df y free: monitorear recursos del sistema</b><br>Dos comandos esenciales para cualquier administrador de sistemas.<br><br><b>df -h</b>: muestra el espacio en disco de todos los sistemas de archivos en formato legible (KB, MB, GB).<br><b>df -T</b>: también muestra el tipo de sistema de archivos.<br><b>free -h</b>: muestra el uso de RAM y swap en formato legible.<br><b>free -s 2</b>: actualiza el reporte cada 2 segundos.	TERMINAL_SIM	avanzado	70	25	16
14	14	Completa: Avanzados	<b>find: buscar archivos en el sistema</b><br><b>find</b> es el comando más potente para localizar archivos por nombre, fecha, tamaño o permisos.<br><br><b>find / -name archivo</b>: busca por nombre en todo el sistema.<br><b>find . -mtime -1</b>: archivos modificados en las últimas 24h.<br><b>find . -size +100M</b>: archivos mayores de 100 MB.<br><b>find . -type d</b>: solo directorios.	FILL_BLANK	intermedio	65	20	13
15	15	Escribe: find y grep	<b>grep avanzado: patrones y contexto</b><br>grep no solo busca palabras — puede buscar patrones complejos y mostrar contexto.<br><br><b>grep -A 3</b>: muestra 3 líneas después de cada coincidencia.<br><b>grep -B 3</b>: muestra 3 líneas antes.<br><b>grep -C 3</b>: muestra 3 líneas antes y después.<br><b>grep ^texto</b>: líneas que empiezan con "texto".<br><b>grep texto$</b>: líneas que terminan con "texto".	TYPE_COMMAND	intermedio	65	20	14
18	18	Jefe Final: Avanzado	<b>Jefe Final: Tier 3 — Avanzado</b><br>Has dominado la búsqueda avanzada, el análisis de logs y la gestión de procesos y discos.<br><br>Este jefe te enfrenta a escenarios reales de producción donde necesitas aplicar <b>grep</b>, tuberías y análisis de texto bajo presión. Sin pistas. El servidor depende de ti.	TERMINAL_SIM	avanzado	75	40	17
19	19	Terminal: Red y Discos	<b>chmod: control de permisos en profundidad</b><br>Los permisos en Linux definen quién puede leer, escribir o ejecutar cada archivo.<br><br><b>chmod 755</b>: rwxr-xr-x (propietario todo, grupo y otros solo lectura/ejecución).<br><b>chmod 644</b>: rw-r--r-- (propietario lectura/escritura, resto solo lectura).<br><b>chmod 700</b>: rwx------ (solo el propietario tiene acceso total).<br><b>chmod -R</b>: aplica permisos recursivamente a un directorio completo.	TERMINAL_SIM	avanzado	70	25	18
20	20	Terminal: Búsqueda Pro	<b>find y tar: buscar y comprimir</b><br>La combinación perfecta para backups y limpieza del sistema.<br><br><b>find . -name "*.tmp" -delete</b>: encuentra y borra archivos .tmp en un solo comando.<br><b>tar -czf backup.tar.gz directorio/</b>: crea un archivo comprimido con gzip.<br><b>tar -xzf backup.tar.gz</b>: extrae un archivo .tar.gz.<br><b>tar -tf archivo.tar.gz</b>: lista el contenido sin extraer.	TERMINAL_SIM	avanzado	70	25	19
21	21	Compresión con tar	<b>tar: comprimir y archivar</b><br>tar agrupa múltiples archivos en uno solo y opcionalmente los comprime.<br><br><b>tar -czf archivo.tar.gz carpeta/</b>: crear comprimido con gzip.<br><b>tar -cjf archivo.tar.bz2 carpeta/</b>: crear comprimido con bzip2 (más compresión, más lento).<br><b>tar -xzf archivo.tar.gz</b>: extraer.<br><b>tar -tzf archivo.tar.gz</b>: listar contenido sin extraer.<br><b>tar -xzf archivo.tar.gz -C /destino/</b>: extraer en un directorio específico.	TYPE_COMMAND	intermedio	65	20	20
22	22	Procesos con ps y top	<b>ps y top: gestión de procesos</b><br>En Linux cada programa en ejecución es un proceso con su propio PID.<br><br><b>ps aux</b>: muestra todos los procesos del sistema con usuario, PID, CPU y memoria.<br><b>top</b>: monitor interactivo en tiempo real (q para salir).<br><b>kill PID</b>: envía señal de terminación a un proceso.<br><b>kill -9 PID</b>: fuerza la terminación inmediata (SIGKILL).<br><b>ps aux | grep nombre</b>: buscar un proceso por nombre.	TERMINAL_SIM	intermedio	70	25	21
23	23	Filtros AWK y SED	<b>awk y sed: procesar texto como un profesional</b><br>Dos herramientas de Unix para transformar y filtrar texto línea por línea.<br><br><b>awk</b>: procesa archivos columna por columna. awk '{print $1}' imprime la primera columna de cada línea.<br><b>awk -F:</b>: permite definir un separador de campo distinto al espacio.<br><b>sed s/viejo/nuevo/g</b>: reemplaza todas las ocurrencias de un patrón.<br><b>sed -n 5,10p</b>: muestra solo las líneas 5 a 10.<br><b>sed /patron/d</b>: elimina líneas que contienen el patrón.	TYPE_COMMAND	avanzado	75	30	22
\.


--
-- Data for Name: opciones_comando; Type: TABLE DATA; Schema: learnux; Owner: -
--

COPY learnux.opciones_comando (id_opcion, id_comando, bandera, descripcion, ejemplo_uso) FROM stdin;
1	1	-l	Formato largo: muestra permisos, dueño, tamaño y fecha.	ls -l
2	1	-a	All: muestra archivos ocultos (los que empiezan con punto).	ls -a
3	1	-h	Human-readable: muestra tamaños en KB, MB, GB en lugar de bytes.	ls -lh
4	1	-t	Time: ordena por fecha de modificación (más nuevos arriba).	ls -lt
5	1	-S	Size: ordena por tamaño de archivo (más pesados arriba).	ls -lS
6	1	-r	Reverse: invierte el orden de la lista.	ls -ltr
7	1	-R	Recursive: muestra también el contenido de todas las subcarpetas.	ls -R
8	1	-1	Single column: muestra un archivo por línea (ideal para scripts).	ls -1
9	2	-r	Recursive: necesario para copiar carpetas completas.	cp -r carpeta/ destino/
10	2	-i	Interactive: pregunta antes de sobrescribir archivos.	cp -i nota.txt backup/
11	2	-v	Verbose: explica qué está haciendo en cada momento.	cp -rv fotos/ usb/
12	2	-p	Preserve: mantiene los permisos y fechas originales del archivo.	cp -p script.sh /tmp/
13	2	-u	Update: solo copia si el origen es más nuevo que el destino.	cp -u config.conf /backup/
14	5	-i	Interactive: pregunta antes de sobrescribir.	mv -i dato.txt destino/
15	5	-n	No-clobber: no sobrescribe nunca un archivo existente.	mv -n archivo.txt backup/
16	5	-v	Verbose: muestra el nombre del archivo mientras se mueve.	mv -v old.txt new.txt
17	4	-r	Recursive: borra carpetas y todo su contenido.	rm -r carpeta_vieja/
18	4	-f	Force: borra sin preguntar y no da error si el archivo no existe.	rm -f archivo_fantasma
19	4	-i	Interactive: pide confirmación antes de cada borrado.	rm -i *.jpg
20	4	-v	Verbose: confirma qué archivos han sido eliminados.	rm -rv /tmp/cache/*
21	14	-i	Ignore-case: busca sin importar mayúsculas o minúsculas.	grep -i "error" log.txt
22	14	-v	Invert-match: muestra las líneas que NO contienen el patrón.	grep -v "INFO" app.log
23	14	-r	Recursive: busca dentro de todos los archivos de una carpeta.	grep -r "TODO" ./src
24	14	-n	Line-number: muestra el número de línea de cada coincidencia.	grep -n "main" programa.c
25	14	-c	Count: solo dice cuántas veces aparece la palabra.	grep -c "warning" sys.log
26	14	-l	Files-with-matches: solo muestra los nombres de los archivos que contienen el texto.	grep -l "password" /etc/*
27	16	-c	Create: crea un nuevo archivo de archivo (empaquetar).	tar -cvf backup.tar docs/
28	16	-x	eXtract: extrae el contenido de un archivo .tar.	tar -xvf backup.tar
29	16	-z	gzip: comprime el archivo usando el algoritmo gzip (.tar.gz).	tar -czvf web.tar.gz /var/www
30	16	-j	bzip2: compresión más lenta pero más eficiente (.tar.bz2).	tar -cjvf data.tar.bz2 /data
31	16	-f	File: indica el nombre del archivo a manejar (siempre al final de las flags).	tar -f mi_archivo.tar
32	16	-t	List: lista el contenido del archivo sin extraerlo.	tar -tf pack.tar
33	12	-R	Recursive: cambia permisos a carpetas y subcarpetas.	chmod -R 755 /var/www
34	12	+x	Añade permiso de ejecución.	chmod +x script.sh
35	12	u+s	SetUID: permite ejecutar con privilegios del dueño.	chmod u+s binario
36	10	-h	Human-readable: muestra el espacio en GB y MB.	df -h
37	10	-T	Type: muestra el tipo de sistema de archivos (ext4, vfat, etc).	df -T
38	10	-i	Inodes: muestra el uso de inodos (útil si hay espacio pero no puedes crear archivos).	df -i
39	20	aux	Muestra todos los procesos de todos los usuarios con detalle.	ps aux
40	20	-ef	Formato estándar de sistema para ver todos los procesos.	ps -ef
41	20	--forest	Muestra procesos en estructura de árbol (quién creó a quién).	ps aux --forest
42	15	-name	Busca por nombre exacto.	find . -name "*.log"
43	15	-type	Busca por tipo (f=archivo, d=directorio).	find /var -type d
44	15	-size	Busca por tamaño (+100M = más de 100MB).	find / -size +1G
45	15	-mtime	Busca por días desde la última modificación.	find . -mtime -7
46	15	-exec	Ejecuta un comando sobre cada resultado encontrado.	find . -name "*.tmp" -exec rm {} \\;
47	3	-p	Parents: crea directorios padres si no existen sin dar error.	mkdir -p a/b/c
48	3	-v	Verbose: imprime un mensaje por cada directorio creado.	mkdir -v nueva_carpeta
49	6	-n	Number: numera todas las líneas de salida (útil para código).	cat -n script.sh
50	6	-b	Number-nonblank: numera solo las líneas que no están vacías.	cat -b notas.txt
51	6	-s	Squeeze-blank: comprime múltiples líneas vacías en una sola.	cat -s archivo.txt
52	6	-e	Show-ends: muestra un símbolo $ al final de cada línea (detecta espacios ocultos).	cat -e config.conf
53	7	-a	Access-time: cambia solo la hora en que el archivo fue leído por última vez.	touch -a archivo.txt
54	7	-m	Modification-time: cambia solo la hora en que el archivo fue escrito.	touch -m reporte.pdf
55	7	-c	No-create: actualiza la fecha pero NO crea el archivo si no existe.	touch -c manual.txt
56	7	-t	Timestamp: permite poner una fecha y hora exacta (formato [[CC]YY]MMDDhhmm).	touch -t 202401011200 old.txt
57	7	-r	Reference: copia la fecha y hora de OTRO archivo.	touch -r original.jpg copia.jpg
58	8	-P	Physical: muestra la ruta real, evitando enlaces simbólicos.	pwd -P
59	8	-L	Logical: muestra la ruta incluyendo los enlaces (comportamiento por defecto).	pwd -L
60	21	~	Shortcut: te lleva instantáneamente a tu carpeta HOME.	cd ~
61	21	..	Parent: sube un nivel en la jerarquía de carpetas.	cd ..
62	21	-	Last: regresa a la carpeta anterior donde estabas.	cd -
63	13	-i	Interactive: abre una terminal como root (cuidado aquí).	sudo -i
64	13	-u	User: ejecuta el comando como otro usuario específico (no solo root).	sudo -u dan comando
65	13	-l	List: muestra qué permisos tienes permitidos con sudo.	sudo -l
66	11	-h	Human-readable: muestra la RAM en GB y MB de forma automática.	free -h
67	11	-m	Megabytes: fuerza a mostrar los datos solo en MB.	free -m
68	11	-s	Seconds: actualiza la información cada N segundos.	free -h -s 5
69	9	-d	Delay: cambia la velocidad de actualización (por defecto 3s).	top -d 1
70	9	-p	PID: monitorea únicamente procesos específicos por su ID.	top -p 1234,5678
71	9	-u	User: muestra solo los procesos de un usuario.	top -u dan
\.


--
-- Data for Name: progreso_nivel; Type: TABLE DATA; Schema: learnux; Owner: -
--

COPY learnux.progreso_nivel (id_usuario, id_nivel, completado, puntos_acumulados, intentos_totales, fecha_inicio, fecha_completado) FROM stdin;
3	1	f	0	0	2026-04-29 12:55:11.306632	\N
4	1	f	0	0	2026-04-29 12:59:02.626832	\N
5	1	f	0	0	2026-04-29 13:03:40.46161	\N
1	1	t	40	4	2026-04-29 12:15:44.958179	2026-04-29 12:19:25.055118
1	2	t	20	4	2026-04-29 12:20:00.301987	2026-04-29 12:20:05.071781
6	1	t	20	4	2026-04-29 21:35:25.195822	2026-04-29 21:51:24.459664
7	1	f	0	0	2026-04-29 21:52:07.436399	\N
1	3	t	30	5	2026-04-29 12:23:48.04165	2026-04-29 12:23:54.000645
1	4	t	30	4	2026-04-29 12:24:23.424793	2026-04-29 12:24:32.240989
1	5	t	30	5	2026-04-29 12:25:33.845747	2026-04-29 12:25:41.69707
1	6	t	100	4	2026-04-29 12:26:26.590662	2026-04-29 12:26:26.590662
1	7	t	30	4	2026-04-29 12:26:49.916463	2026-04-29 12:26:59.384572
1	8	t	30	4	2026-04-29 12:27:19.302304	2026-04-29 12:27:36.45254
1	9	t	30	5	2026-04-29 12:27:53.160272	2026-04-29 12:28:08.600883
1	10	t	30	4	2026-04-29 12:28:24.634453	2026-04-29 12:28:34.188157
1	11	t	30	4	2026-04-29 12:29:30.594553	2026-04-29 12:29:37.852464
1	12	t	100	4	2026-04-29 12:31:36.032993	2026-04-29 12:31:36.032993
1	13	f	0	3	2026-04-29 12:32:28.037876	\N
2	1	t	40	6	2026-04-29 12:42:37.74061	2026-04-29 12:43:33.694586
\.


--
-- Data for Name: progreso_usuarios; Type: TABLE DATA; Schema: learnux; Owner: -
--

COPY learnux.progreso_usuarios (id_usuario, id_comando, dominado, veces_practicado, ultima_practica) FROM stdin;
1	8	f	1	2026-04-29 12:20:00.318678
1	21	f	2	2026-04-29 12:20:09.869322
1	3	f	4	2026-04-29 12:24:08.621885
1	1	f	8	2026-04-29 12:27:09.65996
1	5	f	4	2026-04-29 12:27:36.468978
1	2	f	4	2026-04-29 12:27:43.919555
1	4	f	6	2026-04-29 12:28:13.267321
1	7	f	2	2026-04-29 12:28:24.65248
1	6	f	4	2026-04-29 12:28:38.565918
1	14	f	4	2026-04-29 12:29:40.773426
2	1	f	4	2026-04-29 12:43:49.253483
6	1	f	2	2026-04-29 21:51:24.495529
\.


--
-- Data for Name: sesiones_log; Type: TABLE DATA; Schema: learnux; Owner: -
--

COPY learnux.sesiones_log (id_sesion, id_usuario, ip_cliente, fecha_login, fecha_logout) FROM stdin;
1	1	\N	2026-04-29 12:29:30.612821	\N
2	2	\N	2026-04-29 12:43:30.065677	\N
3	6	\N	2026-04-29 21:51:11.331475	\N
\.


--
-- Data for Name: usuarios; Type: TABLE DATA; Schema: learnux; Owner: -
--

COPY learnux.usuarios (id_usuario, nombre_usuario, email, password_hash, puntos_totales, nivel_actual, fecha_creacion, activo) FROM stdin;
1	dan	\N	120000:cvMXCxBjqnkFQ7H/CeKt2w==:dXmQq2/YLNbRi/9EII8N8U+hQsJXLLgoXx9ufo4Vcok=	150	12	2026-04-29 12:15:44.958179	t
2	dante	\N	120000:F2lmOduxsKYEDOLK6EKg2w==:gVxO2SREtQxPHyfmx8a4xBE7Hg9gcuOxv3GLgc9KllY=	15	2	2026-04-29 12:42:37.74061	t
3	dandan	\N	120000:rEuq2Le/yZS6LxxG/5wuRA==:s7B19mQEi2884SxTEfoxTR62AUCeLsFC62qbAHQ3+so=	0	1	2026-04-29 12:55:11.306632	t
4	dancito	\N	120000:2HJHqRf1CFFLof0+2AqC4g==:Tk0ukEQXmkoXROzM7f+30lQS1Hjbr9qE7ZMdkn4JEmc=	0	1	2026-04-29 12:59:02.626832	t
5	danter	\N	120000:h6Ak6culAttwkyETHFBrIQ==:uj5/jySVKAQNZwNXa3xyJFDBeOqa0U7miCnb/IUrFpY=	0	1	2026-04-29 13:03:40.46161	t
6	danper	\N	120000:B2ly4olRv2ev4SStst61VQ==:Qjez7Kiz/KoU/XhHDnj3iu4y9T1uroRKxuyvll1aWg4=	15	2	2026-04-29 21:35:25.195822	t
7	dani	\N	120000:lz+jyzXtOc9F+XU4Rg/F+Q==:zS9fg9J2UNpetIq3O6j0E1fM3lcmtUks3s+4/8u2CPE=	0	1	2026-04-29 21:52:07.436399	t
\.


--
-- Name: categorias_id_categoria_seq; Type: SEQUENCE SET; Schema: learnux; Owner: -
--

SELECT pg_catalog.setval('learnux.categorias_id_categoria_seq', 5, true);


--
-- Name: comandos_audit_log_id_audit_seq; Type: SEQUENCE SET; Schema: learnux; Owner: -
--

SELECT pg_catalog.setval('learnux.comandos_audit_log_id_audit_seq', 72, true);


--
-- Name: comandos_id_comando_seq; Type: SEQUENCE SET; Schema: learnux; Owner: -
--

SELECT pg_catalog.setval('learnux.comandos_id_comando_seq', 21, true);


--
-- Name: ejercicios_id_ejercicio_seq; Type: SEQUENCE SET; Schema: learnux; Owner: -
--

SELECT pg_catalog.setval('learnux.ejercicios_id_ejercicio_seq', 20, true);


--
-- Name: intentos_ejercicio_id_intento_seq; Type: SEQUENCE SET; Schema: learnux; Owner: -
--

SELECT pg_catalog.setval('learnux.intentos_ejercicio_id_intento_seq', 56, true);


--
-- Name: niveles_id_nivel_seq; Type: SEQUENCE SET; Schema: learnux; Owner: -
--

SELECT pg_catalog.setval('learnux.niveles_id_nivel_seq', 24, true);


--
-- Name: opciones_comando_id_opcion_seq; Type: SEQUENCE SET; Schema: learnux; Owner: -
--

SELECT pg_catalog.setval('learnux.opciones_comando_id_opcion_seq', 71, true);


--
-- Name: sesiones_log_id_sesion_seq; Type: SEQUENCE SET; Schema: learnux; Owner: -
--

SELECT pg_catalog.setval('learnux.sesiones_log_id_sesion_seq', 3, true);


--
-- Name: usuarios_id_usuario_seq; Type: SEQUENCE SET; Schema: learnux; Owner: -
--

SELECT pg_catalog.setval('learnux.usuarios_id_usuario_seq', 7, true);


--
-- Name: categorias categorias_pkey; Type: CONSTRAINT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.categorias
    ADD CONSTRAINT categorias_pkey PRIMARY KEY (id_categoria);


--
-- Name: comandos_audit_log comandos_audit_log_pkey; Type: CONSTRAINT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.comandos_audit_log
    ADD CONSTRAINT comandos_audit_log_pkey PRIMARY KEY (id_audit);


--
-- Name: comandos comandos_pkey; Type: CONSTRAINT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.comandos
    ADD CONSTRAINT comandos_pkey PRIMARY KEY (id_comando);


--
-- Name: ejercicios ejercicios_pkey; Type: CONSTRAINT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.ejercicios
    ADD CONSTRAINT ejercicios_pkey PRIMARY KEY (id_ejercicio);


--
-- Name: intentos_ejercicio intentos_ejercicio_pkey; Type: CONSTRAINT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.intentos_ejercicio
    ADD CONSTRAINT intentos_ejercicio_pkey PRIMARY KEY (id_intento);


--
-- Name: niveles niveles_pkey; Type: CONSTRAINT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.niveles
    ADD CONSTRAINT niveles_pkey PRIMARY KEY (id_nivel);


--
-- Name: opciones_comando opciones_comando_pkey; Type: CONSTRAINT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.opciones_comando
    ADD CONSTRAINT opciones_comando_pkey PRIMARY KEY (id_opcion);


--
-- Name: progreso_nivel progreso_nivel_pkey; Type: CONSTRAINT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.progreso_nivel
    ADD CONSTRAINT progreso_nivel_pkey PRIMARY KEY (id_usuario, id_nivel);


--
-- Name: progreso_usuarios progreso_usuarios_pkey; Type: CONSTRAINT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.progreso_usuarios
    ADD CONSTRAINT progreso_usuarios_pkey PRIMARY KEY (id_usuario, id_comando);


--
-- Name: sesiones_log sesiones_log_pkey; Type: CONSTRAINT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.sesiones_log
    ADD CONSTRAINT sesiones_log_pkey PRIMARY KEY (id_sesion);


--
-- Name: categorias uq_categoria_nombre; Type: CONSTRAINT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.categorias
    ADD CONSTRAINT uq_categoria_nombre UNIQUE (nombre);


--
-- Name: comandos uq_comando_nombre; Type: CONSTRAINT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.comandos
    ADD CONSTRAINT uq_comando_nombre UNIQUE (comando_nombre);


--
-- Name: usuarios uq_email; Type: CONSTRAINT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.usuarios
    ADD CONSTRAINT uq_email UNIQUE (email);


--
-- Name: niveles uq_nivel_numero; Type: CONSTRAINT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.niveles
    ADD CONSTRAINT uq_nivel_numero UNIQUE (numero);


--
-- Name: usuarios uq_nombre_usuario; Type: CONSTRAINT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.usuarios
    ADD CONSTRAINT uq_nombre_usuario UNIQUE (nombre_usuario);


--
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id_usuario);


--
-- Name: comandos_audit_log rule_audit_inmutable; Type: RULE; Schema: learnux; Owner: -
--

CREATE RULE rule_audit_inmutable AS
    ON DELETE TO learnux.comandos_audit_log DO INSTEAD NOTHING;


--
-- Name: sesiones_log rule_sesion_unica; Type: RULE; Schema: learnux; Owner: -
--

CREATE RULE rule_sesion_unica AS
    ON INSERT TO learnux.sesiones_log
   WHERE (EXISTS ( SELECT 1
           FROM learnux.sesiones_log sesiones_log_1
          WHERE ((sesiones_log_1.id_usuario = new.id_usuario) AND (sesiones_log_1.fecha_logout IS NULL)))) DO INSTEAD  UPDATE learnux.sesiones_log SET fecha_login = CURRENT_TIMESTAMP
  WHERE ((sesiones_log.id_usuario = new.id_usuario) AND (sesiones_log.fecha_logout IS NULL));


--
-- Name: usuarios rule_soft_delete_usuarios; Type: RULE; Schema: learnux; Owner: -
--

CREATE RULE rule_soft_delete_usuarios AS
    ON DELETE TO learnux.usuarios DO INSTEAD  UPDATE learnux.usuarios SET activo = false
  WHERE (usuarios.id_usuario = old.id_usuario);


--
-- Name: vista_comandos_completos rule_update_vista_comandos; Type: RULE; Schema: learnux; Owner: -
--

CREATE RULE rule_update_vista_comandos AS
    ON UPDATE TO learnux.vista_comandos_completos DO INSTEAD  UPDATE learnux.comandos SET descripcion = new.descripcion, sintaxis = new.sintaxis, dificultad_nivel = new.dificultad_nivel
  WHERE (comandos.id_comando = new.id_comando);


--
-- Name: comandos tr_audit_comandos; Type: TRIGGER; Schema: learnux; Owner: -
--

CREATE TRIGGER tr_audit_comandos AFTER INSERT OR DELETE OR UPDATE ON learnux.comandos FOR EACH ROW EXECUTE FUNCTION learnux.fn_audit_comandos();


--
-- Name: progreso_nivel tr_avanzar_nivel; Type: TRIGGER; Schema: learnux; Owner: -
--

CREATE TRIGGER tr_avanzar_nivel AFTER UPDATE OF completado ON learnux.progreso_nivel FOR EACH ROW EXECUTE FUNCTION learnux.fn_avanzar_nivel_usuario();


--
-- Name: progreso_usuarios tr_log_sesion_practica; Type: TRIGGER; Schema: learnux; Owner: -
--

CREATE TRIGGER tr_log_sesion_practica AFTER INSERT ON learnux.progreso_usuarios FOR EACH ROW EXECUTE FUNCTION learnux.fn_log_sesion();


--
-- Name: comandos tr_normalizar_comando; Type: TRIGGER; Schema: learnux; Owner: -
--

CREATE TRIGGER tr_normalizar_comando BEFORE INSERT OR UPDATE OF comando_nombre ON learnux.comandos FOR EACH ROW EXECUTE FUNCTION learnux.fn_normalizar_comando();


--
-- Name: progreso_usuarios tr_proteger_progreso; Type: TRIGGER; Schema: learnux; Owner: -
--

CREATE TRIGGER tr_proteger_progreso BEFORE UPDATE ON learnux.progreso_usuarios FOR EACH ROW EXECUTE FUNCTION learnux.fn_proteger_progreso();


--
-- Name: comandos fk_cmd_categoria; Type: FK CONSTRAINT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.comandos
    ADD CONSTRAINT fk_cmd_categoria FOREIGN KEY (id_categoria) REFERENCES learnux.categorias(id_categoria) ON DELETE CASCADE;


--
-- Name: ejercicios fk_ej_comando; Type: FK CONSTRAINT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.ejercicios
    ADD CONSTRAINT fk_ej_comando FOREIGN KEY (id_comando) REFERENCES learnux.comandos(id_comando) ON DELETE SET NULL;


--
-- Name: ejercicios fk_ej_nivel; Type: FK CONSTRAINT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.ejercicios
    ADD CONSTRAINT fk_ej_nivel FOREIGN KEY (id_nivel) REFERENCES learnux.niveles(id_nivel) ON DELETE CASCADE;


--
-- Name: intentos_ejercicio fk_it_ejercicio; Type: FK CONSTRAINT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.intentos_ejercicio
    ADD CONSTRAINT fk_it_ejercicio FOREIGN KEY (id_ejercicio) REFERENCES learnux.ejercicios(id_ejercicio) ON DELETE CASCADE;


--
-- Name: intentos_ejercicio fk_it_nivel; Type: FK CONSTRAINT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.intentos_ejercicio
    ADD CONSTRAINT fk_it_nivel FOREIGN KEY (id_nivel) REFERENCES learnux.niveles(id_nivel) ON DELETE CASCADE;


--
-- Name: intentos_ejercicio fk_it_usuario; Type: FK CONSTRAINT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.intentos_ejercicio
    ADD CONSTRAINT fk_it_usuario FOREIGN KEY (id_usuario) REFERENCES learnux.usuarios(id_usuario) ON DELETE CASCADE;


--
-- Name: opciones_comando fk_opcion_comando; Type: FK CONSTRAINT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.opciones_comando
    ADD CONSTRAINT fk_opcion_comando FOREIGN KEY (id_comando) REFERENCES learnux.comandos(id_comando) ON DELETE CASCADE;


--
-- Name: progreso_nivel fk_pn_nivel; Type: FK CONSTRAINT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.progreso_nivel
    ADD CONSTRAINT fk_pn_nivel FOREIGN KEY (id_nivel) REFERENCES learnux.niveles(id_nivel) ON DELETE CASCADE;


--
-- Name: progreso_nivel fk_pn_usuario; Type: FK CONSTRAINT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.progreso_nivel
    ADD CONSTRAINT fk_pn_usuario FOREIGN KEY (id_usuario) REFERENCES learnux.usuarios(id_usuario) ON DELETE CASCADE;


--
-- Name: progreso_usuarios fk_pu_comando; Type: FK CONSTRAINT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.progreso_usuarios
    ADD CONSTRAINT fk_pu_comando FOREIGN KEY (id_comando) REFERENCES learnux.comandos(id_comando) ON DELETE CASCADE;


--
-- Name: progreso_usuarios fk_pu_usuario; Type: FK CONSTRAINT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.progreso_usuarios
    ADD CONSTRAINT fk_pu_usuario FOREIGN KEY (id_usuario) REFERENCES learnux.usuarios(id_usuario) ON DELETE CASCADE;


--
-- Name: sesiones_log fk_sesion_usuario; Type: FK CONSTRAINT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.sesiones_log
    ADD CONSTRAINT fk_sesion_usuario FOREIGN KEY (id_usuario) REFERENCES learnux.usuarios(id_usuario) ON DELETE CASCADE;


--
-- Name: niveles niveles_desbloqueado_por_fkey; Type: FK CONSTRAINT; Schema: learnux; Owner: -
--

ALTER TABLE ONLY learnux.niveles
    ADD CONSTRAINT niveles_desbloqueado_por_fkey FOREIGN KEY (desbloqueado_por) REFERENCES learnux.niveles(id_nivel);


--
-- PostgreSQL database dump complete
--

\unrestrict k6A8fn9ZxT4kIgG6EgahaGd5eTdB9scC3Hu3cNKVj3pGYd5znUzLUP8VL313b3M

