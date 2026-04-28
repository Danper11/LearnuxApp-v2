--
-- PostgreSQL database dump
--

\restrict pp4VznQ9KJ8bdu4rYEd3kSY6ziHeK8cHPfakMkQEbpP1OhdWSALU7tJkl4bYL1k

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

--
-- Name: learnux; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA learnux;


ALTER SCHEMA learnux OWNER TO postgres;

--
-- Name: dificultad_tipo; Type: DOMAIN; Schema: learnux; Owner: postgres
--

CREATE DOMAIN learnux.dificultad_tipo AS text
	CONSTRAINT dificultad_tipo_check CHECK ((VALUE = ANY (ARRAY['principiante'::text, 'intermedio'::text, 'avanzado'::text, 'maestro'::text])));


ALTER DOMAIN learnux.dificultad_tipo OWNER TO postgres;

--
-- Name: ejercicio_tipo; Type: DOMAIN; Schema: learnux; Owner: postgres
--

CREATE DOMAIN learnux.ejercicio_tipo AS text
	CONSTRAINT ejercicio_tipo_check CHECK ((VALUE = ANY (ARRAY['DRAG_DROP'::text, 'MULTIPLE_CHOICE'::text, 'FILL_BLANK'::text, 'TYPE_COMMAND'::text, 'TERMINAL_SIM'::text])));


ALTER DOMAIN learnux.ejercicio_tipo OWNER TO postgres;

--
-- Name: f_buscar_comando(text); Type: FUNCTION; Schema: learnux; Owner: postgres
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


ALTER FUNCTION learnux.f_buscar_comando(p_nombre text) OWNER TO postgres;

--
-- Name: f_buscar_usuario(text); Type: FUNCTION; Schema: learnux; Owner: postgres
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


ALTER FUNCTION learnux.f_buscar_usuario(p_nombre text) OWNER TO postgres;

--
-- Name: f_get_comandos_de_nivel(integer); Type: FUNCTION; Schema: learnux; Owner: postgres
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


ALTER FUNCTION learnux.f_get_comandos_de_nivel(p_id_nivel integer) OWNER TO postgres;

--
-- Name: f_get_ejercicios_nivel(integer); Type: FUNCTION; Schema: learnux; Owner: postgres
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


ALTER FUNCTION learnux.f_get_ejercicios_nivel(p_id_nivel integer) OWNER TO postgres;

--
-- Name: f_get_niveles_con_progreso(integer); Type: FUNCTION; Schema: learnux; Owner: postgres
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


ALTER FUNCTION learnux.f_get_niveles_con_progreso(p_id_usuario integer) OWNER TO postgres;

--
-- Name: f_get_opciones_comando(integer); Type: FUNCTION; Schema: learnux; Owner: postgres
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


ALTER FUNCTION learnux.f_get_opciones_comando(p_id_comando integer) OWNER TO postgres;

--
-- Name: f_get_todas_categorias(); Type: FUNCTION; Schema: learnux; Owner: postgres
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


ALTER FUNCTION learnux.f_get_todas_categorias() OWNER TO postgres;

--
-- Name: f_ls_comandos_categoria(integer); Type: FUNCTION; Schema: learnux; Owner: postgres
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


ALTER FUNCTION learnux.f_ls_comandos_categoria(p_id_categoria integer) OWNER TO postgres;

--
-- Name: f_porcentaje_nivel(integer, integer); Type: FUNCTION; Schema: learnux; Owner: postgres
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


ALTER FUNCTION learnux.f_porcentaje_nivel(p_id_usuario integer, p_id_nivel integer) OWNER TO postgres;

--
-- Name: f_resumen_progreso(integer); Type: FUNCTION; Schema: learnux; Owner: postgres
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


ALTER FUNCTION learnux.f_resumen_progreso(p_id_usuario integer) OWNER TO postgres;

--
-- Name: f_siguiente_nivel(integer); Type: FUNCTION; Schema: learnux; Owner: postgres
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


ALTER FUNCTION learnux.f_siguiente_nivel(p_id_usuario integer) OWNER TO postgres;

--
-- Name: fn_audit_comandos(); Type: FUNCTION; Schema: learnux; Owner: postgres
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


ALTER FUNCTION learnux.fn_audit_comandos() OWNER TO postgres;

--
-- Name: fn_avanzar_nivel_usuario(); Type: FUNCTION; Schema: learnux; Owner: postgres
--

CREATE FUNCTION learnux.fn_avanzar_nivel_usuario() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_siguiente INTEGER;
BEGIN
    -- Solo actúa cuando se marca como completado
    IF NEW.completado = TRUE AND (OLD.completado IS DISTINCT FROM TRUE) THEN
        SELECT n.numero + 1
        INTO v_siguiente
        FROM learnux.niveles n
        WHERE n.id_nivel = NEW.id_nivel;

        IF v_siguiente IS NOT NULL AND v_siguiente <= 20 THEN
            UPDATE learnux.usuarios
            SET nivel_actual    = GREATEST(nivel_actual, v_siguiente),
                puntos_totales  = puntos_totales + (
                    SELECT puntos_recompensa FROM learnux.niveles WHERE id_nivel = NEW.id_nivel
                )
            WHERE id_usuario = NEW.id_usuario;
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION learnux.fn_avanzar_nivel_usuario() OWNER TO postgres;

--
-- Name: fn_log_sesion(); Type: FUNCTION; Schema: learnux; Owner: postgres
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


ALTER FUNCTION learnux.fn_log_sesion() OWNER TO postgres;

--
-- Name: fn_normalizar_comando(); Type: FUNCTION; Schema: learnux; Owner: postgres
--

CREATE FUNCTION learnux.fn_normalizar_comando() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.comando_nombre := LOWER(TRIM(NEW.comando_nombre));
    RETURN NEW;
END;
$$;


ALTER FUNCTION learnux.fn_normalizar_comando() OWNER TO postgres;

--
-- Name: fn_proteger_progreso(); Type: FUNCTION; Schema: learnux; Owner: postgres
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


ALTER FUNCTION learnux.fn_proteger_progreso() OWNER TO postgres;

--
-- Name: sp_actualizar_progreso(integer, integer, boolean); Type: PROCEDURE; Schema: learnux; Owner: postgres
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


ALTER PROCEDURE learnux.sp_actualizar_progreso(IN p_id_usuario integer, IN p_id_comando integer, IN p_dominado boolean) OWNER TO postgres;

--
-- Name: sp_agregar_comando(integer, text, text, text, learnux.dificultad_tipo); Type: PROCEDURE; Schema: learnux; Owner: postgres
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


ALTER PROCEDURE learnux.sp_agregar_comando(IN p_id_categoria integer, IN p_nombre text, IN p_descripcion text, IN p_sintaxis text, IN p_dificultad learnux.dificultad_tipo) OWNER TO postgres;

--
-- Name: sp_registrar_intento(integer, integer, text, integer); Type: PROCEDURE; Schema: learnux; Owner: postgres
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


ALTER PROCEDURE learnux.sp_registrar_intento(IN p_id_usuario integer, IN p_id_ejercicio integer, IN p_respuesta text, IN p_tiempo_seg integer) OWNER TO postgres;

--
-- Name: sp_registrar_usuario(text, text); Type: PROCEDURE; Schema: learnux; Owner: postgres
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


ALTER PROCEDURE learnux.sp_registrar_usuario(IN p_nombre text, IN p_email text) OWNER TO postgres;

--
-- Name: actualizar_progreso(integer, integer, boolean); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.actualizar_progreso(IN p_id_usuario integer, IN p_id_comando integer, IN p_marcar_dominado boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Attempt to insert a new record for the first time the user practices this command
    INSERT INTO progreso_usuarios (id_usuario, id_comando, dominado, veces_practicado, ultima_practica)
    VALUES (p_id_usuario, p_id_comando, p_marcar_dominado, 1, CURRENT_TIMESTAMP)
    
    -- If the record already exists, update their existing progress instead
    ON CONFLICT (id_usuario, id_comando) 
    DO UPDATE SET 
        dominado = EXCLUDED.dominado,
        veces_practicado = progreso_usuarios.veces_practicado + 1,
        ultima_practica = CURRENT_TIMESTAMP;
END;
$$;


ALTER PROCEDURE public.actualizar_progreso(IN p_id_usuario integer, IN p_id_comando integer, IN p_marcar_dominado boolean) OWNER TO postgres;

--
-- Name: agg_comando(integer, text, text, text, text); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.agg_comando(IN p_id_categoria integer, IN p_nombre_comando text, IN p_descripcion text, IN p_sintaxis text, IN p_dificultad text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Validation: Ensure command is lowercase
    IF p_nombre_comando != LOWER(p_nombre_comando) THEN
        RAISE EXCEPTION 'LOS COMANDOS DEBEN SER ESTRICTAMENTE ESCRITOS EN MINUSCULAS';
    END IF ;

    -- The corrected Insert statement
    INSERT INTO comandos (id_categoria, comando_nombre, descripcion, sintaxis, dificultad_nivel) 
    VALUES (p_id_categoria, p_nombre_comando, p_descripcion, p_sintaxis, p_dificultad);
END;
$$;


ALTER PROCEDURE public.agg_comando(IN p_id_categoria integer, IN p_nombre_comando text, IN p_descripcion text, IN p_sintaxis text, IN p_dificultad text) OWNER TO postgres;

--
-- Name: f_log_comandos(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.f_log_comandos() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO comandos_audit_log (tipo_accion, nombre_comando)
        VALUES ('INSERT', NEW.comando_nombre);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO comandos_audit_log (tipo_accion, nombre_comando)
        VALUES ('DELETE', OLD.comando_nombre);
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.f_log_comandos() OWNER TO postgres;

--
-- Name: f_ls_comandos_categoria(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.f_ls_comandos_categoria(p_id_categoria integer) RETURNS TABLE(ret_id_comando integer, ret_id_categoria integer, ret_comando_nombre text, ret_descripcion text, ret_sintaxis text, ret_dificultad text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        id_comando,
        id_categoria,
        comando_nombre,
        descripcion,
        sintaxis,
        dificultad_nivel
    FROM comandos
    WHERE id_categoria = p_id_categoria;
END;
$$;


ALTER FUNCTION public.f_ls_comandos_categoria(p_id_categoria integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: categorias; Type: TABLE; Schema: learnux; Owner: postgres
--

CREATE TABLE learnux.categorias (
    id_categoria integer NOT NULL,
    nombre text NOT NULL,
    descripcion text
);


ALTER TABLE learnux.categorias OWNER TO postgres;

--
-- Name: categorias_id_categoria_seq; Type: SEQUENCE; Schema: learnux; Owner: postgres
--

CREATE SEQUENCE learnux.categorias_id_categoria_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE learnux.categorias_id_categoria_seq OWNER TO postgres;

--
-- Name: categorias_id_categoria_seq; Type: SEQUENCE OWNED BY; Schema: learnux; Owner: postgres
--

ALTER SEQUENCE learnux.categorias_id_categoria_seq OWNED BY learnux.categorias.id_categoria;


--
-- Name: comandos; Type: TABLE; Schema: learnux; Owner: postgres
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


ALTER TABLE learnux.comandos OWNER TO postgres;

--
-- Name: comandos_audit_log; Type: TABLE; Schema: learnux; Owner: postgres
--

CREATE TABLE learnux.comandos_audit_log (
    id_audit integer NOT NULL,
    tipo_accion text NOT NULL,
    nombre_comando text NOT NULL,
    usuario_db text DEFAULT CURRENT_USER,
    fecha_evento timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_tipo_accion CHECK ((tipo_accion = ANY (ARRAY['INSERT'::text, 'UPDATE'::text, 'DELETE'::text])))
);


ALTER TABLE learnux.comandos_audit_log OWNER TO postgres;

--
-- Name: comandos_audit_log_id_audit_seq; Type: SEQUENCE; Schema: learnux; Owner: postgres
--

CREATE SEQUENCE learnux.comandos_audit_log_id_audit_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE learnux.comandos_audit_log_id_audit_seq OWNER TO postgres;

--
-- Name: comandos_audit_log_id_audit_seq; Type: SEQUENCE OWNED BY; Schema: learnux; Owner: postgres
--

ALTER SEQUENCE learnux.comandos_audit_log_id_audit_seq OWNED BY learnux.comandos_audit_log.id_audit;


--
-- Name: comandos_id_comando_seq; Type: SEQUENCE; Schema: learnux; Owner: postgres
--

CREATE SEQUENCE learnux.comandos_id_comando_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE learnux.comandos_id_comando_seq OWNER TO postgres;

--
-- Name: comandos_id_comando_seq; Type: SEQUENCE OWNED BY; Schema: learnux; Owner: postgres
--

ALTER SEQUENCE learnux.comandos_id_comando_seq OWNED BY learnux.comandos.id_comando;


--
-- Name: ejercicios; Type: TABLE; Schema: learnux; Owner: postgres
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


ALTER TABLE learnux.ejercicios OWNER TO postgres;

--
-- Name: ejercicios_id_ejercicio_seq; Type: SEQUENCE; Schema: learnux; Owner: postgres
--

CREATE SEQUENCE learnux.ejercicios_id_ejercicio_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE learnux.ejercicios_id_ejercicio_seq OWNER TO postgres;

--
-- Name: ejercicios_id_ejercicio_seq; Type: SEQUENCE OWNED BY; Schema: learnux; Owner: postgres
--

ALTER SEQUENCE learnux.ejercicios_id_ejercicio_seq OWNED BY learnux.ejercicios.id_ejercicio;


--
-- Name: intentos_ejercicio; Type: TABLE; Schema: learnux; Owner: postgres
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


ALTER TABLE learnux.intentos_ejercicio OWNER TO postgres;

--
-- Name: intentos_ejercicio_id_intento_seq; Type: SEQUENCE; Schema: learnux; Owner: postgres
--

CREATE SEQUENCE learnux.intentos_ejercicio_id_intento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE learnux.intentos_ejercicio_id_intento_seq OWNER TO postgres;

--
-- Name: intentos_ejercicio_id_intento_seq; Type: SEQUENCE OWNED BY; Schema: learnux; Owner: postgres
--

ALTER SEQUENCE learnux.intentos_ejercicio_id_intento_seq OWNED BY learnux.intentos_ejercicio.id_intento;


--
-- Name: niveles; Type: TABLE; Schema: learnux; Owner: postgres
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


ALTER TABLE learnux.niveles OWNER TO postgres;

--
-- Name: niveles_id_nivel_seq; Type: SEQUENCE; Schema: learnux; Owner: postgres
--

CREATE SEQUENCE learnux.niveles_id_nivel_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE learnux.niveles_id_nivel_seq OWNER TO postgres;

--
-- Name: niveles_id_nivel_seq; Type: SEQUENCE OWNED BY; Schema: learnux; Owner: postgres
--

ALTER SEQUENCE learnux.niveles_id_nivel_seq OWNED BY learnux.niveles.id_nivel;


--
-- Name: opciones_comando; Type: TABLE; Schema: learnux; Owner: postgres
--

CREATE TABLE learnux.opciones_comando (
    id_opcion integer NOT NULL,
    id_comando integer NOT NULL,
    bandera text NOT NULL,
    descripcion text NOT NULL,
    ejemplo_uso text
);


ALTER TABLE learnux.opciones_comando OWNER TO postgres;

--
-- Name: opciones_comando_id_opcion_seq; Type: SEQUENCE; Schema: learnux; Owner: postgres
--

CREATE SEQUENCE learnux.opciones_comando_id_opcion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE learnux.opciones_comando_id_opcion_seq OWNER TO postgres;

--
-- Name: opciones_comando_id_opcion_seq; Type: SEQUENCE OWNED BY; Schema: learnux; Owner: postgres
--

ALTER SEQUENCE learnux.opciones_comando_id_opcion_seq OWNED BY learnux.opciones_comando.id_opcion;


--
-- Name: progreso_nivel; Type: TABLE; Schema: learnux; Owner: postgres
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


ALTER TABLE learnux.progreso_nivel OWNER TO postgres;

--
-- Name: progreso_usuarios; Type: TABLE; Schema: learnux; Owner: postgres
--

CREATE TABLE learnux.progreso_usuarios (
    id_usuario integer NOT NULL,
    id_comando integer NOT NULL,
    dominado boolean DEFAULT false,
    veces_practicado integer DEFAULT 0,
    ultima_practica timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_veces_practicado CHECK ((veces_practicado >= 0))
);


ALTER TABLE learnux.progreso_usuarios OWNER TO postgres;

--
-- Name: sesiones_log; Type: TABLE; Schema: learnux; Owner: postgres
--

CREATE TABLE learnux.sesiones_log (
    id_sesion integer NOT NULL,
    id_usuario integer,
    ip_cliente text,
    fecha_login timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    fecha_logout timestamp without time zone
);


ALTER TABLE learnux.sesiones_log OWNER TO postgres;

--
-- Name: sesiones_log_id_sesion_seq; Type: SEQUENCE; Schema: learnux; Owner: postgres
--

CREATE SEQUENCE learnux.sesiones_log_id_sesion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE learnux.sesiones_log_id_sesion_seq OWNER TO postgres;

--
-- Name: sesiones_log_id_sesion_seq; Type: SEQUENCE OWNED BY; Schema: learnux; Owner: postgres
--

ALTER SEQUENCE learnux.sesiones_log_id_sesion_seq OWNED BY learnux.sesiones_log.id_sesion;


--
-- Name: usuarios; Type: TABLE; Schema: learnux; Owner: postgres
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
    CONSTRAINT chk_nivel_rango CHECK (((nivel_actual >= 1) AND (nivel_actual <= 20))),
    CONSTRAINT chk_puntos_positivos CHECK ((puntos_totales >= 0))
);


ALTER TABLE learnux.usuarios OWNER TO postgres;

--
-- Name: usuarios_id_usuario_seq; Type: SEQUENCE; Schema: learnux; Owner: postgres
--

CREATE SEQUENCE learnux.usuarios_id_usuario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE learnux.usuarios_id_usuario_seq OWNER TO postgres;

--
-- Name: usuarios_id_usuario_seq; Type: SEQUENCE OWNED BY; Schema: learnux; Owner: postgres
--

ALTER SEQUENCE learnux.usuarios_id_usuario_seq OWNED BY learnux.usuarios.id_usuario;


--
-- Name: vista_comandos_completos; Type: VIEW; Schema: learnux; Owner: postgres
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


ALTER VIEW learnux.vista_comandos_completos OWNER TO postgres;

--
-- Name: vista_ejercicios_nivel; Type: VIEW; Schema: learnux; Owner: postgres
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


ALTER VIEW learnux.vista_ejercicios_nivel OWNER TO postgres;

--
-- Name: vista_progreso_usuario; Type: VIEW; Schema: learnux; Owner: postgres
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


ALTER VIEW learnux.vista_progreso_usuario OWNER TO postgres;

--
-- Name: vista_ranking; Type: VIEW; Schema: learnux; Owner: postgres
--

CREATE VIEW learnux.vista_ranking AS
 SELECT row_number() OVER (ORDER BY puntos_totales DESC, nivel_actual DESC) AS posicion,
    nombre_usuario,
    puntos_totales,
    nivel_actual
   FROM learnux.usuarios
  WHERE (activo = true)
  ORDER BY puntos_totales DESC;


ALTER VIEW learnux.vista_ranking OWNER TO postgres;

--
-- Name: vista_resumen_progreso; Type: VIEW; Schema: learnux; Owner: postgres
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


ALTER VIEW learnux.vista_resumen_progreso OWNER TO postgres;

--
-- Name: categorias; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categorias (
    id_categoria integer NOT NULL,
    nombre text NOT NULL,
    descripcion text
);


ALTER TABLE public.categorias OWNER TO postgres;

--
-- Name: categorias_id_categoria_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categorias_id_categoria_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categorias_id_categoria_seq OWNER TO postgres;

--
-- Name: categorias_id_categoria_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categorias_id_categoria_seq OWNED BY public.categorias.id_categoria;


--
-- Name: comandos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comandos (
    id_comando integer NOT NULL,
    id_categoria integer NOT NULL,
    comando_nombre text NOT NULL,
    descripcion text NOT NULL,
    sintaxis text NOT NULL,
    dificultad_nivel text DEFAULT 'principiante'::text
);


ALTER TABLE public.comandos OWNER TO postgres;

--
-- Name: comandos_audit_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comandos_audit_log (
    id_audit integer NOT NULL,
    tipo_accion text NOT NULL,
    nombre_comando text NOT NULL,
    fecha_evento timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.comandos_audit_log OWNER TO postgres;

--
-- Name: comandos_audit_log_id_audit_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.comandos_audit_log_id_audit_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.comandos_audit_log_id_audit_seq OWNER TO postgres;

--
-- Name: comandos_audit_log_id_audit_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.comandos_audit_log_id_audit_seq OWNED BY public.comandos_audit_log.id_audit;


--
-- Name: comandos_id_comando_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.comandos_id_comando_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.comandos_id_comando_seq OWNER TO postgres;

--
-- Name: comandos_id_comando_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.comandos_id_comando_seq OWNED BY public.comandos.id_comando;


--
-- Name: opciones_comando; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.opciones_comando (
    id_opcion integer NOT NULL,
    id_comando integer NOT NULL,
    bandera text NOT NULL,
    descripcion text NOT NULL,
    ejemplo_uso text
);


ALTER TABLE public.opciones_comando OWNER TO postgres;

--
-- Name: opciones_comando_id_opcion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.opciones_comando_id_opcion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.opciones_comando_id_opcion_seq OWNER TO postgres;

--
-- Name: opciones_comando_id_opcion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.opciones_comando_id_opcion_seq OWNED BY public.opciones_comando.id_opcion;


--
-- Name: progreso_usuarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.progreso_usuarios (
    id_usuario integer NOT NULL,
    id_comando integer NOT NULL,
    dominado boolean DEFAULT false,
    veces_practicado integer DEFAULT 0,
    ultima_practica timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.progreso_usuarios OWNER TO postgres;

--
-- Name: usuarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuarios (
    id_usuario integer NOT NULL,
    nombre_usuario text NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.usuarios OWNER TO postgres;

--
-- Name: usuarios_id_usuario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usuarios_id_usuario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuarios_id_usuario_seq OWNER TO postgres;

--
-- Name: usuarios_id_usuario_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usuarios_id_usuario_seq OWNED BY public.usuarios.id_usuario;


--
-- Name: categorias id_categoria; Type: DEFAULT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.categorias ALTER COLUMN id_categoria SET DEFAULT nextval('learnux.categorias_id_categoria_seq'::regclass);


--
-- Name: comandos id_comando; Type: DEFAULT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.comandos ALTER COLUMN id_comando SET DEFAULT nextval('learnux.comandos_id_comando_seq'::regclass);


--
-- Name: comandos_audit_log id_audit; Type: DEFAULT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.comandos_audit_log ALTER COLUMN id_audit SET DEFAULT nextval('learnux.comandos_audit_log_id_audit_seq'::regclass);


--
-- Name: ejercicios id_ejercicio; Type: DEFAULT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.ejercicios ALTER COLUMN id_ejercicio SET DEFAULT nextval('learnux.ejercicios_id_ejercicio_seq'::regclass);


--
-- Name: intentos_ejercicio id_intento; Type: DEFAULT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.intentos_ejercicio ALTER COLUMN id_intento SET DEFAULT nextval('learnux.intentos_ejercicio_id_intento_seq'::regclass);


--
-- Name: niveles id_nivel; Type: DEFAULT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.niveles ALTER COLUMN id_nivel SET DEFAULT nextval('learnux.niveles_id_nivel_seq'::regclass);


--
-- Name: opciones_comando id_opcion; Type: DEFAULT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.opciones_comando ALTER COLUMN id_opcion SET DEFAULT nextval('learnux.opciones_comando_id_opcion_seq'::regclass);


--
-- Name: sesiones_log id_sesion; Type: DEFAULT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.sesiones_log ALTER COLUMN id_sesion SET DEFAULT nextval('learnux.sesiones_log_id_sesion_seq'::regclass);


--
-- Name: usuarios id_usuario; Type: DEFAULT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.usuarios ALTER COLUMN id_usuario SET DEFAULT nextval('learnux.usuarios_id_usuario_seq'::regclass);


--
-- Name: categorias id_categoria; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categorias ALTER COLUMN id_categoria SET DEFAULT nextval('public.categorias_id_categoria_seq'::regclass);


--
-- Name: comandos id_comando; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comandos ALTER COLUMN id_comando SET DEFAULT nextval('public.comandos_id_comando_seq'::regclass);


--
-- Name: comandos_audit_log id_audit; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comandos_audit_log ALTER COLUMN id_audit SET DEFAULT nextval('public.comandos_audit_log_id_audit_seq'::regclass);


--
-- Name: opciones_comando id_opcion; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opciones_comando ALTER COLUMN id_opcion SET DEFAULT nextval('public.opciones_comando_id_opcion_seq'::regclass);


--
-- Name: usuarios id_usuario; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios ALTER COLUMN id_usuario SET DEFAULT nextval('public.usuarios_id_usuario_seq'::regclass);


--
-- Data for Name: categorias; Type: TABLE DATA; Schema: learnux; Owner: postgres
--

COPY learnux.categorias (id_categoria, nombre, descripcion) FROM stdin;
1	manejo de archivos	Comandos para manipular y eliminar archivos
2	informacion de sistema	Comandos para ver rendimiento del sistema y hardware
3	permisos y seguridad	Comandos para gestionar usuarios, grupos y permisos
4	busqueda y filtrado	Comandos avanzados para buscar archivos y manipular texto
5	compresion y empaquetado	Herramientas para comprimir archivos y crear respaldos
\.


--
-- Data for Name: comandos; Type: TABLE DATA; Schema: learnux; Owner: postgres
--

COPY learnux.comandos (id_comando, id_categoria, comando_nombre, descripcion, sintaxis, dificultad_nivel, salida_simulada) FROM stdin;
21	1	cd	Cambia el directorio de trabajo actual. Usa cd .. para subir un nivel, cd ~ para ir al home, cd - para volver al directorio anterior. El comando más usado en la terminal.	cd [DIRECTORIO]	principiante	\N
1	1	ls	Lista el contenido de un directorio. Sin opciones muestra solo nombres; con -l muestra permisos, propietario, tamaño y fecha. Con -a incluye archivos ocultos. Fundamental para orientarse en el sistema.	ls [OPCION]... [ARCHIVO]	principiante	archivo1.txt  carpeta/  script.sh
2	1	cp	Copia archivos o directorios de ORIGEN a DESTINO. Si DESTINO es un directorio existente, copia dentro. Con -r copia directorios completos. No elimina el original.	cp [OPCION]... ORIGEN DESTINO	principiante	\N
3	1	mkdir	Crea uno o más directorios nuevos. Con -p crea toda la cadena de directorios padres si no existen, sin generar error si ya existen. Ideal para scripts de configuración.	mkdir [OPCION]... DIRECTORIO	principiante	\N
4	1	rm	Elimina archivos o directorios de forma permanente (no hay papelera). Con -r elimina directorios recursivamente; con -f fuerza sin pedir confirmación. Usar con cuidado: no se puede deshacer.	rm [OPCION]... ARCHIVO	intermedio	\N
5	1	mv	Mueve archivos/directorios a otra ubicación o los renombra. Si DESTINO existe como directorio, mueve dentro. Sirve para mover Y para renombrar en un solo comando.	mv [OPCION]... ORIGEN DESTINO	principiante	\N
6	1	cat	Concatena y muestra el contenido de archivos en la salida estándar. Útil para leer archivos cortos, combinar varios archivos o redirigir contenido con >>. Para archivos largos prefiere less.	cat [OPCION]... ARCHIVO	principiante	Hola Mundo\\nLinea dos\\nLinea tres
7	1	touch	Crea un archivo vacío si no existe, o actualiza su marca de tiempo si ya existe. Muy usado en scripts para garantizar que un archivo exista antes de escribir en él.	touch [OPCION]... ARCHIVO	principiante	\N
8	1	pwd	Muestra la ruta absoluta del directorio de trabajo actual. Útil para saber exactamente dónde estás en el sistema de archivos, especialmente dentro de scripts.	pwd	principiante	/home/usuario/proyectos
9	2	top	Muestra los procesos activos en tiempo real con su uso de CPU y RAM. Presiona q para salir, k para matar un proceso por PID. Imprescindible para diagnosticar sobrecarga del sistema.	top	intermedio	\N
10	2	df	Reporta el espacio total, usado y disponible en cada sistema de archivos montado. Con -h muestra en KB/MB/GB legibles. Esencial para detectar discos llenos antes de que fallen servicios.	df [OPCION]... [ARCHIVO]	principiante	Filesystem  1K-blocks  Used  Avail Use% Mounted on\\n/dev/sda1  50G  20G  28G  42%  /
11	2	free	Muestra la memoria RAM total, usada, libre y la swap. Con -h los valores son legibles. Clave para detectar si el sistema se está quedando sin memoria antes de que los procesos fallen.	free [OPCION]	principiante	              total  used  free\\nMem:          8000   3200  4800
12	3	chmod	Cambia los permisos de archivos usando notación octal (755) o simbólica (u+x). Los permisos controlan quién puede leer (r), escribir (w) o ejecutar (x) el archivo. Con -R aplica de forma recursiva.	chmod [OPCION]... MODO ARCHIVO	intermedio	\N
13	3	sudo	Ejecuta un comando con privilegios de superusuario (root). Requiere que tu usuario esté en el grupo sudoers. Usado para instalar paquetes, editar archivos del sistema o gestionar servicios.	sudo [OPCION]... COMANDO	principiante	\N
14	4	grep	Busca líneas que coincidan con un patrón de texto en archivos o en la entrada estándar. Soporta expresiones regulares. Con -i ignora mayúsculas; con -r busca en subdirectorios. Muy potente combinado con pipes.	grep [OPCION]... PATRON [ARCHIVO]	intermedio	\N
15	4	find	Busca archivos y directorios en una jerarquía según nombre, tipo, tamaño, fecha o permisos. Puede ejecutar acciones sobre los resultados con -exec. Mucho más potente que buscar en el explorador gráfico.	find [RUTA]... [EXPRESION]	avanzado	\N
16	5	tar	Empaqueta múltiples archivos en un solo .tar y opcionalmente los comprime (gzip, bzip2, xz). Base de los respaldos en Linux. Con -c crea, -x extrae, -v muestra progreso, -f especifica el nombre del archivo.	tar [OPCION]... [DESTINO] [ORIGEN]	avanzado	\N
17	4	awk	Procesador de texto estructurado por columnas. Lee archivo línea a línea aplicando un programa. Ideal para extraer columnas, calcular sumas o transformar datos tabulares. Lenguaje propio muy conciso.	awk 'PROGRAMA' [ARCHIVO]	avanzado	\N
18	4	sed	Editor de flujo no interactivo: transforma texto línea a línea con sustituciones, eliminaciones e inserciones. El uso más común es s/viejo/nuevo/g para reemplazar texto en archivos o en pipes.	sed [OPCION]... SCRIPT [ARCHIVO]	avanzado	\N
19	1	ln	Crea enlaces entre archivos. Un enlace duro (sin -s) apunta al mismo inodo; un enlace simbólico (-s) es un puntero a la ruta. Los simbólicos son los más comunes, como accesos directos en Linux.	ln [OPCION]... DESTINO NOMBRE	intermedio	\N
20	2	ps	Muestra una instantánea de los procesos en ejecución. Con aux muestra todos los procesos del sistema con usuario, CPU y RAM. Combínalo con grep para buscar un proceso específico: ps aux | grep nginx.	ps [OPCION]	intermedio	PID TTY  TIME CMD\\n1234 pts/0  00:00:01 bash
\.


--
-- Data for Name: comandos_audit_log; Type: TABLE DATA; Schema: learnux; Owner: postgres
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
\.


--
-- Data for Name: ejercicios; Type: TABLE DATA; Schema: learnux; Owner: postgres
--

COPY learnux.ejercicios (id_ejercicio, id_nivel, id_comando, tipo, pregunta, respuesta_correcta, opciones_json, pista, orden, activo, salida_simulada) FROM stdin;
69	1	1	DRAG_DROP	¿Qué comando usas para ver los archivos de la carpeta actual?	ls	["ls", "cd", "pwd", "cat"]	Son dos letras. Viene de "list".	1	t	\N
70	1	1	DRAG_DROP	Empareja cada bandera de ls con lo que hace:	{"-l":"Muestra detalles (permisos, tamaño, fecha)","-a":"Incluye archivos ocultos","-h":"Tamaños en KB/MB legibles"}	["-l", "-a", "-h"]	Los archivos ocultos en Linux empiezan con punto ( . )	2	t	\N
71	1	1	DRAG_DROP	Ordena el comando para listar TODO con detalles en /home:	ls -la /home	["ls", "-la", "/home", "-r"]	Primero el comando, luego las banderas, al final la ruta.	3	t	\N
72	2	8	DRAG_DROP	¿Qué comando imprime la ruta del directorio donde estás ahora mismo?	pwd	["pwd", "ls", "cd", "whoami"]	Viene de "Print Working Directory".	1	t	\N
73	2	\N	DRAG_DROP	Empareja cada forma de usar cd con su efecto:	{"cd /etc":"Entra a la carpeta /etc","cd ..":"Sube un nivel (directorio padre)","cd ~":"Va a tu carpeta personal HOME"}	["cd /etc", "cd ..", "cd ~"]	Los dos puntos ( .. ) siempre significan el directorio padre.	2	t	\N
74	3	3	DRAG_DROP	¿Qué comando crea una carpeta nueva?	mkdir	["mkdir", "touch", "ls", "rm"]	Viene de "make directory".	1	t	\N
75	3	3	DRAG_DROP	¿Qué bandera de mkdir crea automáticamente todas las carpetas padres necesarias?	-p	["-p", "-r", "-v", "-f"]	Se usa cuando quieres crear una ruta completa como a/b/c de un solo comando.	2	t	\N
76	3	3	DRAG_DROP	Ordena el comando para crear las carpetas proyectos/web de un solo golpe:	mkdir -p proyectos/web	["mkdir", "-p", "proyectos/web", "-r"]	Necesitas la bandera que crea los directorios padre automáticamente.	3	t	\N
77	4	2	DRAG_DROP	Empareja cada comando con su acción:	{"cp":"Copia archivos (el original se conserva)","mv":"Mueve o renombra (el original desaparece)"}	["cp", "mv"]	Solo uno de los dos deja el original intacto en su lugar.	1	t	\N
78	4	2	DRAG_DROP	Ordena el comando para COPIAR notas.txt como backup.txt:	cp notas.txt backup.txt	["cp", "notas.txt", "backup.txt", "mv"]	Formato: comando → origen → destino.	2	t	\N
79	4	5	DRAG_DROP	Ordena el comando para RENOMBRAR notas.txt a diario.txt:	mv notas.txt diario.txt	["mv", "notas.txt", "diario.txt", "cp"]	En Linux, renombrar = mover al mismo directorio con otro nombre.	3	t	\N
80	5	6	DRAG_DROP	¿Qué comando muestra el contenido de un archivo de texto?	cat	["cat", "ls", "rm", "pwd"]	Viene de "concatenate". Son solo 3 letras.	1	t	\N
81	5	4	DRAG_DROP	Ordena el comando para borrar el archivo viejo.txt:	rm viejo.txt	["rm", "viejo.txt", "cat"]	Recuerda: rm borra de forma permanente. Primero el comando, luego el archivo.	2	t	\N
82	5	4	DRAG_DROP	Empareja cada variante de rm con su efecto:	{"rm archivo.txt":"Borra un archivo","rm -r carpeta/":"Borra carpeta y su contenido","rm -i archivo.txt":"Pide confirmación antes de borrar"}	["rm archivo.txt", "rm -r carpeta/", "rm -i archivo.txt"]	La -r es recursivo (baja por subcarpetas) y la -i es interactivo (pregunta antes).	3	t	\N
83	6	1	MULTIPLE_CHOICE	Quieres ver los archivos de /var/log con detalles y que los tamaños aparezcan como 2.4K o 1.1M en lugar de números enormes. ¿Qué comando usas?	ls -lh /var/log	["ls -lh /var/log", "ls -la /var/log", "ls -R /var/log", "ls -lS /var/log"]	Necesitas detalles (-l) y tamaños legibles (-h).	1	t	\N
84	6	1	MULTIPLE_CHOICE	Acabas de descargar varios archivos y quieres ver cuál es el más reciente. ¿Qué comando usas?	ls -lt	["ls -lt", "ls -lS", "ls -lh", "ls -R"]	t de "time": ordena por tiempo de modificación.	2	t	\N
85	6	1	MULTIPLE_CHOICE	Quieres explorar toda la estructura de /home/dan/proyectos incluyendo cada subdirectorio. ¿Qué flag usas?	ls -R /home/dan/proyectos	["ls -R /home/dan/proyectos", "ls -l /home/dan/proyectos", "ls -a /home/dan/proyectos", "ls -lt /home/dan/proyectos"]	R de "Recursivo": entra en cada subdirectorio.	3	t	\N
86	7	2	MULTIPLE_CHOICE	Quieres copiar el directorio /home/dan/fotos completo (con todo su contenido) a /backup. ¿Qué comando usas?	cp -r /home/dan/fotos /backup	["cp -r /home/dan/fotos /backup", "cp /home/dan/fotos /backup", "cp -i /home/dan/fotos /backup", "mv -r /home/dan/fotos /backup"]	Para directorios necesitas el flag -r (recursivo).	1	t	\N
87	7	2	MULTIPLE_CHOICE	Vas a mover un archivo importante y NO quieres sobreescribir nada sin darte cuenta. ¿Qué comando es más seguro?	mv -i informe.txt /tmp/	["mv -i informe.txt /tmp/", "mv -n informe.txt /tmp/", "mv informe.txt /tmp/", "cp -i informe.txt /tmp/"]	-i = interactivo, te pide confirmación antes de sobreescribir.	2	t	\N
88	7	2	MULTIPLE_CHOICE	Estás copiando cientos de archivos y quieres ver en pantalla cada archivo mientras se copia. ¿Qué flag usas?	cp -v	["cp -v", "cp -i", "cp -r", "cp -n"]	v de "verbose": muestra lo que está haciendo.	3	t	\N
89	8	4	MULTIPLE_CHOICE	Quieres borrar varios archivos pero que el sistema te pregunte uno por uno antes de borrarlos. ¿Cuál es la forma MÁS SEGURA?	rm -i *.tmp	["rm -i *.tmp", "rm -rf *.tmp", "rm -f *.tmp", "rm *.tmp"]	-i = interactivo, te pide confirmación por cada archivo.	1	t	\N
90	8	4	MULTIPLE_CHOICE	Quieres eliminar el directorio /tmp/basura y todo su contenido (archivos y subdirectorios). ¿Qué comando usas?	rm -r /tmp/basura	["rm -r /tmp/basura", "rm /tmp/basura", "rm -i /tmp/basura", "rm -v /tmp/basura"]	Para directorios necesitas -r (recursivo).	2	t	\N
91	8	4	MULTIPLE_CHOICE	¿Cuál de estos comandos es el MÁS PELIGROSO y debes evitar usar por accidente?	rm -rf /	["rm -rf /", "rm -i /tmp/basura.txt", "rm -v archivo.log", "rm -r ~/documentos_viejos"]	La combinación -rf aplicada a / borra TODO el sistema.	3	t	\N
92	9	7	MULTIPLE_CHOICE	Quieres crear tres archivos vacíos: readme.md, todo.txt y log.txt con un solo comando. ¿Cuál usas?	touch readme.md todo.txt log.txt	["touch readme.md todo.txt log.txt", "cat readme.md todo.txt log.txt", "mkdir readme.md todo.txt log.txt", "cp readme.md todo.txt log.txt"]	touch acepta varios archivos como argumentos.	1	t	\N
93	9	6	MULTIPLE_CHOICE	Quieres ver el contenido de script.sh mostrando el número de cada línea (para localizar errores). ¿Qué comando usas?	cat -n script.sh	["cat -n script.sh", "cat script.sh", "ls -n script.sh", "cat -l script.sh"]	-n = numerar líneas.	2	t	\N
94	9	6	MULTIPLE_CHOICE	Tienes parte1.txt y parte2.txt y quieres verlos uno detrás del otro en pantalla, como si fueran un solo archivo. ¿Qué comando usas?	cat parte1.txt parte2.txt	["cat parte1.txt parte2.txt", "cat -n parte1.txt parte2.txt", "cp parte1.txt parte2.txt", "ls parte1.txt parte2.txt"]	cat acepta varios archivos y los concatena.	3	t	\N
95	10	14	MULTIPLE_CHOICE	Quieres buscar la palabra "error" en /var/log/syslog pero sin importar si está en mayúsculas o minúsculas. ¿Qué comando usas?	grep -i "error" /var/log/syslog	["grep -i \\"error\\" /var/log/syslog", "grep \\"error\\" /var/log/syslog", "grep -n \\"error\\" /var/log/syslog", "grep -c \\"error\\" /var/log/syslog"]	-i = ignore case (ignorar mayúsculas).	1	t	\N
96	10	14	MULTIPLE_CHOICE	Quieres buscar "TODO" en TODOS los archivos del directorio /home/dan/proyecto y sus subdirectorios. ¿Qué comando usas?	grep -r "TODO" /home/dan/proyecto	["grep -r \\"TODO\\" /home/dan/proyecto", "grep \\"TODO\\" /home/dan/proyecto", "grep -i \\"TODO\\" /home/dan/proyecto", "grep -c \\"TODO\\" /home/dan/proyecto"]	-r = recursivo, entra en subdirectorios.	2	t	\N
97	10	14	MULTIPLE_CHOICE	Solo quieres saber CUÁNTAS veces aparece "warning" en app.log, no ver las líneas. ¿Qué comando usas?	grep -c "warning" app.log	["grep -c \\"warning\\" app.log", "grep -n \\"warning\\" app.log", "grep -i \\"warning\\" app.log", "grep -r \\"warning\\" app.log"]	-c = count (contar coincidencias).	3	t	\N
98	11	1	FILL_BLANK	Completa: ls ___ /var/log (con detalles y tamaños legibles como 2.4K, 1.1M)	-lh	["-lh", "-la", "-R", "-lS"]	-l = detalles, -h = human readable (tamaños legibles).	1	t	\N
99	11	3	FILL_BLANK	Completa: mkdir ___ /home/dan/proyecto/src/utils (crea todos los directorios padres que no existan)	-p	["-p", "-r", "-v", "-i"]	-p = crear los "parents" (padres) automáticamente.	2	t	\N
100	11	2	FILL_BLANK	Completa: cp ___ /home/dan/fotos /backup (copiar un directorio completo con todo su contenido)	-r	["-r", "-i", "-v", "-n"]	Para copiar directorios necesitas el flag recursivo.	3	t	\N
101	12	4	FILL_BLANK	Completa: rm ___ /tmp/basura (borra el directorio y todo su contenido de forma segura, preguntando por cada archivo)	-ri	["-ri", "-rf", "-f", "-v"]	Necesitas recursivo (-r) e interactivo (-i) para mayor seguridad.	1	t	\N
102	12	14	FILL_BLANK	Completa: grep ___ "error" /var/log/syslog (ignorar mayúsculas Y mostrar el número de línea)	-in	["-in", "-i", "-n", "-c"]	Combina -i (ignore case) con -n (number of line).	2	t	\N
103	12	6	FILL_BLANK	Completa: cat ___ script.sh (ver el contenido mostrando el número de cada línea)	-n	["-n", "-i", "-r", "-l"]	-n = numerar líneas del archivo.	3	t	\N
104	13	1	TYPE_COMMAND	Escribe el comando para listar el contenido de /var/log mostrando detalles (permisos, dueño, fecha) y tamaños en formato legible (K, M, G).	ls -lh /var/log	\N	ls + combina -l y -h en -lh + ruta /var/log.	1	t	\N
105	13	3	TYPE_COMMAND	Escribe el comando para crear el directorio /home/dan/proyecto/src/utils incluyendo todos los directorios padres que no existan.	mkdir -p /home/dan/proyecto/src/utils	\N	mkdir -p crea padres automáticamente. Pon la ruta completa.	2	t	\N
106	13	2	TYPE_COMMAND	Escribe el comando para copiar el directorio completo /home/dan/fotos al directorio /backup (incluyendo todo su contenido).	cp -r /home/dan/fotos /backup	\N	cp -r para directorios. Origen primero, destino después.	3	t	\N
107	14	15	TYPE_COMMAND	Escribe el comando para buscar todos los archivos que terminen en .txt dentro de /home y sus subdirectorios.	find /home -name "*.txt"	\N	find RUTA -name "PATRON". Usa comillas dobles y el comodín *.	1	t	\N
108	14	15	TYPE_COMMAND	Escribe el comando para listar solo los directorios (no archivos) dentro de /var.	find /var -type d	\N	-type d significa directorio. No necesitas -name aquí.	2	t	\N
109	14	15	TYPE_COMMAND	Escribe el comando para encontrar solo los archivos (no directorios) que terminen en .log dentro de /var/log.	find /var/log -type f -name "*.log"	\N	Combina -type f (solo archivos) con -name "*.log".	3	t	\N
110	15	14	TYPE_COMMAND	Escribe el comando para buscar la palabra "error" (sin importar mayúsculas) en /var/log/syslog mostrando el número de línea de cada coincidencia.	grep -in "error" /var/log/syslog	\N	Combina -i (ignore case) y -n (number). Entrecomilla "error".	1	t	\N
111	15	14	TYPE_COMMAND	Escribe el comando para buscar la palabra "TODO" de forma recursiva en todos los archivos del directorio /home/dan/proyecto.	grep -r "TODO" /home/dan/proyecto	\N	-r = recursivo. El patrón "TODO" entre comillas.	2	t	\N
112	15	14	TYPE_COMMAND	Escribe el comando para CONTAR cuántas líneas contienen la palabra "warning" en el archivo app.log.	grep -c "warning" app.log	\N	-c = count. Solo devuelve el número de líneas coincidentes.	3	t	\N
113	16	8	TERMINAL_SIM	Estás en tu home y quieres confirmar la ruta exacta donde te encuentras. ¿Qué comando escribes?	pwd	\N	Es el comando del nivel 2 que "imprime el directorio actual".	1	t	dan@learnux:~$ 
114	16	1	TERMINAL_SIM	Acabas de ejecutar un comando y viste esta salida en pantalla. ¿Qué comando ejecutaste?	ls -lh	\N	Los tamaños están como 4.0K y 1.2K (legibles = -h), y hay detalles (permisos, dueño = -l).	2	t	total 32K\ndrwxr-xr-x 2 dan dan 4.0K ene 15 10:28 documentos\ndrwxr-xr-x 3 dan dan 4.0K ene 15 10:30 proyectos\n-rw-r--r-- 1 dan dan 1.2K ene 15 10:30 notas.txt\n-rw-r--r-- 1 dan dan  15K ene 15 10:25 reporte.pdf
115	16	1	TERMINAL_SIM	Quieres ver TODOS los archivos de tu home, incluidos los ocultos (los que empiezan con punto), con detalles completos. ¿Qué comando escribes?	ls -la	\N	Combina -l (detalles) con -a (all, incluye ocultos).	3	t	dan@learnux:~$ 
116	17	3	TERMINAL_SIM	Empiezas un nuevo proyecto. Necesitas crear la ruta completa /home/dan/proyecto/src/utils de una sola vez (ninguno de esos directorios existe todavía).	mkdir -p /home/dan/proyecto/src/utils	\N	mkdir con -p crea padres e hijos en una sola llamada.	1	t	dan@learnux:~$ ls proyecto\nls: no se puede acceder a 'proyecto': No existe el archivo o directorio\ndan@learnux:~$ 
117	17	2	TERMINAL_SIM	Quieres copiar el directorio completo /home/dan/fotos al directorio /backup.	cp -r /home/dan/fotos /backup	\N	cp -r origen destino. Para directorios siempre -r.	2	t	dan@learnux:~$ 
118	17	5	TERMINAL_SIM	Quieres renombrar el archivo borrador.txt a informe_final.txt, pero de forma segura (si ya existe informe_final.txt que te pida confirmación).	mv -i borrador.txt informe_final.txt	\N	-i = interactivo, pregunta antes de sobreescribir.	3	t	dan@learnux:~/documentos$ ls\nborrador.txt  informe_final.txt\ndan@learnux:~/documentos$ 
119	18	14	TERMINAL_SIM	Necesitas ver todas las líneas que contienen "error" en /var/log/syslog, sin importar mayúsculas, mostrando el número de línea de cada una.	grep -in "error" /var/log/syslog	\N	Combina -i (ignore case) y -n (número de línea). Entrecomilla "error".	1	t	dan@learnux:~$ 
120	18	14	TERMINAL_SIM	Viste esta salida en tu terminal. Estabas buscando "TODO" en todo tu directorio de proyecto. ¿Qué comando ejecutaste?	grep -r "TODO" /home/dan/proyecto	\N	La salida muestra "ruta/archivo:contenido", formato típico de grep -r (recursivo).	2	t	/home/dan/proyecto/src/main.c:// TODO: refactor this function\n/home/dan/proyecto/src/utils.c:// TODO: add error handling\n/home/dan/proyecto/README.md:TODO: document the API
121	18	14	TERMINAL_SIM	Solo quieres saber CUÁNTAS líneas contienen "warning" en app.log. No te interesan las líneas, solo el número.	grep -c "warning" app.log	\N	-c = count, solo devuelve el número de líneas que coinciden.	3	t	dan@learnux:~$ 
122	19	12	TERMINAL_SIM	Acabas de crear deploy.sh. Necesitas hacerlo ejecutable para todos (dueño, grupo y otros) manteniendo lectura. Usa notación numérica 755.	chmod 755 deploy.sh	\N	755 = rwx (7) para dueño, r-x (5) para grupo y otros.	1	t	dan@learnux:~$ ls -l deploy.sh\n-rw-r--r-- 1 dan dan 512 ene 15 11:00 deploy.sh\ndan@learnux:~$ 
123	19	12	TERMINAL_SIM	Tienes un archivo de clave privada id_rsa. SOLO tú debes poder leer y escribir, nadie más tiene ningún permiso. Usa notación numérica.	chmod 600 id_rsa	\N	Dueño: rw = 6. Grupo y otros: ningún permiso = 0. Resultado: 600.	2	t	dan@learnux:~/.ssh$ ls -l id_rsa\n-rw-r--r-- 1 dan dan 2048 ene 15 11:05 id_rsa\ndan@learnux:~/.ssh$ 
124	19	12	TERMINAL_SIM	Tienes script.sh y solo quieres AÑADIR el permiso de ejecución al dueño, sin tocar los demás permisos. Usa notación simbólica.	chmod u+x script.sh	\N	u = user (dueño), + = añadir, x = execute.	3	t	dan@learnux:~$ ls -l script.sh\n-rw-r--r-- 1 dan dan 256 ene 15 11:10 script.sh\ndan@learnux:~$ 
125	20	15	TERMINAL_SIM	El servidor se está llenando. Encuentra TODOS los archivos .log dentro de /var/log (solo archivos, no directorios).	find /var/log -type f -name "*.log"	\N	find + ruta + tipo archivo (-type f) + patrón de nombre (-name).	1	t	root@learnux:~# df -h /var/log\nSist. de ficheros  Tamaño Usados  Disp Uso% Montado en\n/dev/sda1            50G    47G   3.0G  94% /var\nroot@learnux:~# 
126	20	14	TERMINAL_SIM	Sospechas fallos de autenticación. Busca recursivamente "authentication failure" en /var/log, ignorando mayúsculas y mostrando el número de línea.	grep -rin "authentication failure" /var/log	\N	grep con tres flags: -r (recursivo), -i (ignore case), -n (número línea).	2	t	root@learnux:~# 
127	20	12	TERMINAL_SIM	SSH rechaza tu clave privada porque los permisos son demasiado abiertos. Dale los permisos correctos a /home/dan/.ssh/id_rsa con notación numérica.	chmod 600 /home/dan/.ssh/id_rsa	\N	Claves privadas SSH necesitan permisos 600 (solo el dueño lee y escribe).	3	t	dan@learnux:~$ ssh servidor\nPermissions 0644 for '/home/dan/.ssh/id_rsa' are too open.\nIt is required that your private key files are NOT accessible by others.\ndan@learnux:~$ 
\.


--
-- Data for Name: intentos_ejercicio; Type: TABLE DATA; Schema: learnux; Owner: postgres
--

COPY learnux.intentos_ejercicio (id_intento, id_usuario, id_ejercicio, id_nivel, respuesta_dada, correcta, puntos_ganados, tiempo_segundos, fecha_intento) FROM stdin;
85	1	69	1	ls	t	10	\N	2026-04-18 22:42:12.750177
86	1	70	1	{"-l":"Muestra detalles (permisos, tamaño, fecha)","-a":"Incluye archivos ocultos","-h":"Tamaños en KB/MB legibles"}	t	10	\N	2026-04-18 22:42:31.979268
87	1	71	1	ls -la /home	t	10	\N	2026-04-18 22:42:38.855165
88	1	69	1	ls	t	10	\N	2026-04-19 00:04:08.118644
89	1	70	1	{"-l":"Muestra detalles (permisos, tamaño, fecha)","-a":"Incluye archivos ocultos","-h":"Tamaños en KB/MB legibles"}	t	10	\N	2026-04-19 00:04:19.081545
90	1	71	1	ls -la /home	t	10	\N	2026-04-19 00:04:29.298138
91	1	89	8	rm -i *.tmp	t	10	\N	2026-04-19 00:07:10.820578
92	1	90	8	rm -r /tmp/basura	t	10	\N	2026-04-19 00:07:20.2956
93	1	91	8	rm -rf /	t	10	\N	2026-04-19 00:07:24.990457
94	1	92	9	touch readme.md todo.txt log.txt	t	10	\N	2026-04-19 00:08:08.093069
95	1	93	9	cat -n script.sh	t	10	\N	2026-04-19 00:08:18.632266
96	1	94	9	cat -n parte1.txt parte2.txt	f	0	\N	2026-04-19 00:08:37.658727
97	1	95	10	grep -i "error" /var/log/syslog	t	10	\N	2026-04-19 00:09:25.06377
98	1	96	10	grep -i "TODO" /home/dan/proyecto	f	0	\N	2026-04-19 00:09:32.898196
99	1	97	10	grep -c "warning" app.log	t	10	\N	2026-04-19 00:09:42.340213
100	1	69	1	ls	t	10	\N	2026-04-19 00:45:09.93407
101	1	113	16	pwd	t	10	\N	2026-04-19 01:03:04.125056
102	1	114	16	ls -l	f	0	\N	2026-04-19 01:03:25.31597
103	1	115	16	ls -a	f	0	\N	2026-04-19 01:03:45.878376
104	1	116	17	mv -p /home/dan/proyecto/src/utils	f	0	\N	2026-04-19 01:04:49.093601
105	1	117	17	cp -r /home/dan/fotos /backup	t	10	\N	2026-04-19 01:05:21.642914
106	1	118	17	mv borrador.txt informe_final.txt	f	0	\N	2026-04-19 01:05:53.481727
107	1	74	3	mkdir	t	10	\N	2026-04-19 11:37:55.861526
108	1	69	1	ls	t	10	\N	2026-04-19 15:49:21.622226
109	1	70	1	{"-l":"Muestra detalles (permisos, tamaño, fecha)","-a":"Incluye archivos ocultos","-h":"Tamaños en KB/MB legibles"}	t	10	\N	2026-04-19 15:49:39.368889
110	1	71	1	ls -la /home	t	10	\N	2026-04-19 15:49:50.680348
111	1	69	1	ls	t	10	\N	2026-04-19 16:02:26.680278
112	1	70	1	{"-l":"Muestra detalles (permisos, tamaño, fecha)","-a":"Incluye archivos ocultos","-h":"Tamaños en KB/MB legibles"}	t	10	\N	2026-04-19 16:02:31.840918
113	1	71	1	ls -la /home	t	10	\N	2026-04-19 16:02:41.370626
114	1	69	1	ls	t	10	\N	2026-04-19 16:21:39.093763
115	1	70	1	__INCORRECTO__	f	0	\N	2026-04-19 16:21:55.75421
116	1	71	1	ls /home -la	f	0	\N	2026-04-19 16:22:20.661018
117	1	69	1	pwd	f	0	\N	2026-04-19 16:29:50.269065
118	1	69	1	pwd	f	0	\N	2026-04-19 16:29:51.754533
119	1	69	1	pwd	f	0	\N	2026-04-19 16:29:52.950772
120	1	69	1	ls	t	10	\N	2026-04-19 16:29:59.263934
121	1	70	1	__INCORRECTO__	f	0	\N	2026-04-19 16:30:13.15203
122	1	70	1	{"-l":"Muestra detalles (permisos, tamaño, fecha)","-a":"Incluye archivos ocultos","-h":"Tamaños en KB/MB legibles"}	t	10	\N	2026-04-19 16:30:20.835303
123	1	71	1	ls -la /home	t	10	\N	2026-04-19 16:30:45.805511
124	1	69	1	ls	t	10	\N	2026-04-19 17:28:12.674763
125	1	70	1	__INCORRECTO__	f	0	\N	2026-04-19 17:28:18.308298
126	1	70	1	__INCORRECTO__	f	0	\N	2026-04-19 17:28:24.554247
127	1	70	1	{"-l":"Muestra detalles (permisos, tamaño, fecha)","-a":"Incluye archivos ocultos","-h":"Tamaños en KB/MB legibles"}	t	10	\N	2026-04-19 17:28:29.137705
128	1	71	1	/home -r -la	f	0	\N	2026-04-19 17:28:34.094262
45	1	69	1	ls	t	10	\N	2026-04-18 19:43:30.52366
46	1	70	1	{"-l":"Muestra detalles (permisos, tamaño, fecha)","-a":"Incluye archivos ocultos","-h":"Tamaños en KB/MB legibles"}	t	10	\N	2026-04-18 19:43:45.612141
47	1	71	1	ls -r /home	f	0	\N	2026-04-18 19:44:05.862424
48	1	72	2	pwd	t	10	\N	2026-04-18 19:44:54.193229
49	1	73	2	{"cd /etc":"Entra a la carpeta /etc","cd ..":"Sube un nivel (directorio padre)","cd ~":"Va a tu carpeta personal HOME"}	t	10	\N	2026-04-18 19:45:05.026353
50	1	74	3	mkdir	t	10	\N	2026-04-18 19:45:39.189893
51	1	75	3	-p	t	10	\N	2026-04-18 19:45:44.481413
52	1	76	3	mkdir -p proyectos/web	t	10	\N	2026-04-18 19:45:57.009843
53	1	69	1	ls	t	10	\N	2026-04-18 19:47:35.173966
54	1	70	1	__INCORRECTO__	f	0	\N	2026-04-18 19:48:00.955688
55	1	71	1	ls -la /home	t	10	\N	2026-04-18 19:49:01.950423
56	1	72	2	pwd	t	10	\N	2026-04-18 19:50:29.118963
57	1	73	2	__INCORRECTO__	f	0	\N	2026-04-18 19:50:42.717941
58	1	74	3	mkdir	t	10	\N	2026-04-18 19:51:29.157621
59	1	75	3	-p	t	10	\N	2026-04-18 19:51:39.047575
60	1	76	3	mkdir -p proyectos/web	t	10	\N	2026-04-18 19:51:52.257819
61	1	77	4	__INCORRECTO__	f	0	\N	2026-04-18 19:53:18.246842
62	1	78	4	notas.txt cp backup.txt	f	0	\N	2026-04-18 19:53:37.090182
63	1	79	4	mv notas.txt diario.txt	t	10	\N	2026-04-18 19:54:13.398339
64	1	80	5	cat	t	10	\N	2026-04-18 19:55:29.15655
65	1	81	5	rm viejo.txt	t	10	\N	2026-04-18 19:55:37.933776
66	1	82	5	{"rm archivo.txt":"Borra un archivo","rm -r carpeta/":"Borra carpeta y su contenido","rm -i archivo.txt":"Pide confirmación antes de borrar"}	t	10	\N	2026-04-18 19:55:57.123223
129	1	69	1	ls	t	10	\N	2026-04-19 17:40:47.679195
130	1	70	1	__INCORRECTO__	f	0	\N	2026-04-19 17:40:56.932683
131	1	70	1	{"-l":"Muestra detalles (permisos, tamaño, fecha)","-a":"Incluye archivos ocultos","-h":"Tamaños en KB/MB legibles"}	t	10	\N	2026-04-19 17:41:13.503177
132	1	71	1	ls /home -r	f	0	\N	2026-04-19 17:41:18.002578
133	1	71	1	ls /home -r	f	0	\N	2026-04-19 17:41:18.549195
134	1	69	1	ls	t	10	\N	2026-04-19 17:41:26.223318
135	2	69	1	ls	t	10	\N	2026-04-21 07:59:52.346899
136	2	70	1	__INCORRECTO__	f	0	\N	2026-04-21 08:00:09.976997
137	2	70	1	__INCORRECTO__	f	0	\N	2026-04-21 08:00:11.37276
138	2	70	1	__INCORRECTO__	f	0	\N	2026-04-21 08:00:12.957546
\.


--
-- Data for Name: niveles; Type: TABLE DATA; Schema: learnux; Owner: postgres
--

COPY learnux.niveles (id_nivel, numero, nombre, descripcion, tipo_ejercicio, dificultad, puntos_para_pasar, puntos_recompensa, desbloqueado_por) FROM stdin;
9	9	touch y cat en profundidad	<b>touch: crear y actualizar</b><br><b>touch archivo.txt</b>: si el archivo no existe, lo crea vacío. Si existe, actualiza su timestamp (fecha de modificación) a ahora.<br>Ejemplo: <i>touch notas.md</i> crea un archivo vacío listo para editar.<br>Ejemplo: <i>touch a.txt b.txt c.txt</i> crea varios archivos a la vez.<br><br><b>cat en profundidad</b><br><b>cat archivo</b>: muestra contenido.<br><b>cat -n archivo</b>: muestra el contenido con <b>números de línea</b>. Útil para código o logs.<br><b>cat archivo1 archivo2</b>: concatena (une) varios archivos y los muestra juntos.<br>Ejemplo: <i>cat parte1.txt parte2.txt</i>.<br><br>Truco: <i>cat archivo1 archivo2 > unido.txt</i> guarda el resultado en un archivo nuevo.	MULTIPLE_CHOICE	intermedio	60	15	8
1	1	Tu primer comando: ls	<b>ls</b> lista los archivos y carpetas del directorio actual. Es el comando más usado en Linux.<br><br><b>Uso:</b> ls [opciones] [ruta]<br><b>Ejemplo:</b> <b>ls /home</b> muestra los archivos de /home<br><br>Banderas útiles: <b>-l</b> (detalles), <b>-a</b> (incluye ocultos), <b>-h</b> (tamaños legibles)	DRAG_DROP	principiante	50	15	\N
2	2	Navegar: pwd y cd	<b>pwd</b> imprime la ruta completa del directorio donde estás.<br><b>cd</b> cambia de directorio (te mueves por las carpetas).<br><br><b>Ejemplos:</b><br>· <b>pwd</b> → imprime /home/dan<br>· <b>cd /etc</b> → entra a la carpeta /etc<br>· <b>cd ..</b> → sube un nivel (va al directorio padre)<br>· <b>cd ~</b> → vuelve directo a tu carpeta personal (HOME)	DRAG_DROP	principiante	50	15	1
3	3	Crear carpetas: mkdir	<b>mkdir</b> crea un directorio (carpeta) nuevo.<br><br><b>Uso:</b> mkdir [opciones] nombre_carpeta<br><b>Ejemplo:</b> <b>mkdir proyectos</b> crea la carpeta "proyectos" donde estás<br><br>Con la bandera <b>-p</b> puedes crear carpetas anidadas de golpe:<br><b>mkdir -p proyectos/web/css</b> crea los tres niveles aunque no existan	DRAG_DROP	principiante	50	15	2
4	4	Copiar y mover: cp y mv	<b>cp</b> copia un archivo — el original se queda intacto.<br><b>mv</b> mueve o renombra — el original desaparece del lugar original.<br><br><b>Sintaxis:</b> cp/mv ORIGEN DESTINO<br><b>Ejemplos:</b><br>· <b>cp notas.txt copia.txt</b> → crea una copia llamada copia.txt<br>· <b>mv notas.txt diario.txt</b> → renombra el archivo a diario.txt<br>· <b>cp -r fotos/ backup/</b> → copia una carpeta completa (necesita -r)	DRAG_DROP	principiante	60	15	3
5	5	Leer y borrar: cat y rm	<b>cat</b> muestra el contenido completo de un archivo de texto en la terminal.<br><b>rm</b> elimina archivos — CUIDADO: no hay papelera, es permanente.<br><br><b>Ejemplos:</b><br>· <b>cat notas.txt</b> → imprime todo el contenido de notas.txt<br>· <b>rm viejo.txt</b> → borra viejo.txt para siempre<br>· <b>rm -r carpeta/</b> → borra una carpeta y todo su contenido<br>· <b>rm -i archivo</b> → pide confirmación antes de borrar (más seguro)	DRAG_DROP	principiante	60	15	4
6	6	Flags de ls en detalle	<b>Más allá de ls -l y ls -a</b><br>El comando <b>ls</b> tiene flags muy útiles para trabajar con muchos archivos.<br><br><b>ls -lh</b>: combina detalles (-l) con tamaños legibles (-h). Ejemplo: <i>ls -lh /var/log</i> muestra <i>2.4K, 1.1M, 3.5G</i>.<br><b>ls -lt</b>: ordena por fecha de modificación, los más recientes primero. Ideal para ver "qué cambió hace poco".<br><b>ls -lS</b>: ordena por tamaño, los más grandes primero. Útil para encontrar archivos pesados.<br><b>ls -R</b>: recursivo, muestra el contenido de todos los subdirectorios. Ejemplo: <i>ls -R /home/dan/proyectos</i>.<br><br>Las flags se pueden combinar: <i>ls -lhR /etc</i> = detalles + legible + recursivo.	MULTIPLE_CHOICE	principiante	60	15	5
7	7	cp y mv con flags	<b>Flags importantes de cp y mv</b><br><br><b>cp -r origen destino</b>: copia directorios completos (recursivo). Sin -r, cp falla con directorios. Ejemplo: <i>cp -r /home/dan/fotos /backup</i>.<br><b>cp -v</b>: verbose, muestra cada archivo mientras se copia. Útil para copias largas.<br><b>cp -i</b>: interactivo, pregunta antes de sobreescribir archivos existentes.<br><br><b>mv -i origen destino</b>: pide confirmación antes de sobreescribir. Ejemplo: <i>mv -i informe.txt /tmp/</i>.<br><b>mv -n</b>: no sobreescribe nunca, si el destino existe, no hace nada.<br><br>Consejo: usar -i siempre que copies o muevas archivos importantes evita pérdidas accidentales.	MULTIPLE_CHOICE	principiante	60	15	6
8	8	rm y sus peligros	<b>rm: el comando más peligroso de Linux</b><br>En Linux <b>NO hay papelera</b>. Lo que borras con rm se va para siempre.<br><br><b>rm archivo</b>: borra un archivo normal.<br><b>rm -r directorio</b>: borra un directorio y todo su contenido (recursivo).<br><b>rm -f</b>: fuerza el borrado, sin preguntar, sin errores si el archivo no existe.<br><b>rm -rf</b>: el más peligroso. Borra todo sin preguntar. Nunca uses <i>rm -rf /</i> o <i>rm -rf *</i> sin pensarlo dos veces.<br><b>rm -i</b>: interactivo, pregunta antes de borrar cada archivo. La forma MÁS SEGURA.<br><b>rm -v</b>: verbose, muestra cada archivo que borra.<br><br>Regla de oro: ante la duda, usa <i>rm -i</i>.	MULTIPLE_CHOICE	principiante	60	15	7
11	11	Completa: ls, mkdir, cp, mv	<b>Hora de completar comandos</b><br>Verás comandos con un espacio en blanco. Debes elegir del desplegable la opción que completa correctamente el comando.<br><br>Los comandos cubiertos son los que ya aprendiste: <b>ls</b>, <b>mkdir</b>, <b>cp</b> y <b>mv</b>, con sus flags (<i>-l, -a, -h, -lh, -lt, -R, -r, -i, -v, -p</i>).<br><br>El texto entre paréntesis te dice QUÉ debe hacer el comando. Tu tarea es elegir el flag o argumento que lo logra.<br><br>Ejemplo: <i>ls ___ /home</i> (con detalles y tamaños legibles) → la respuesta correcta es <b>-lh</b>.	FILL_BLANK	intermedio	65	20	10
13	13	Escribe: ls, mkdir, cp, mv	<b>Ahora escribes el comando completo</b><br>No hay dropdown. Debes escribir el comando exacto, con sus flags y argumentos.<br><br>Reglas importantes:<br>- Las mayúsculas/minúsculas importan.<br>- Los espacios importan.<br>- Si la pregunta da rutas concretas (<i>/home/dan/fotos</i>), úsalas EXACTAS.<br>- Los flags van antes de las rutas.<br><br>Ejemplo: si te piden "listar /etc con detalles y tamaños legibles", escribes exactamente: <b>ls -lh /etc</b>.<br><br>Lee con cuidado la pista si te quedas atascado.	TYPE_COMMAND	intermedio	65	20	12
17	17	Terminal II: crear y copiar	<b>Construye estructuras de directorios</b><br>En este nivel simularás tareas reales: crear estructuras anidadas, copiar y mover archivos.<br><br>Comandos disponibles: <b>mkdir -p</b>, <b>cp -r</b>, <b>cp -v</b>, <b>mv -i</b>, <b>touch</b>.<br><br>Lee el contexto de cada ejercicio para deducir qué comando ejecutar a continuación.	TERMINAL_SIM	avanzado	70	25	16
20	20	Desafío final	<b>El examen del sysadmin</b><br>Este es tu desafío final. Combinarás todo lo aprendido:<br><br>- Navegar y listar: <b>ls</b>, <b>pwd</b>, <b>cd</b><br>- Crear y organizar: <b>mkdir -p</b>, <b>touch</b><br>- Mover, copiar y borrar: <b>cp -r</b>, <b>mv -i</b>, <b>rm -rf</b><br>- Buscar: <b>find</b>, <b>grep -rin</b><br>- Permisos: <b>chmod</b><br><br>Las pistas son mínimas. Confía en lo que aprendiste. ¡Buena suerte!	TERMINAL_SIM	avanzado	70	25	19
21	21	Jefe Final: Fundamentos	<b>Tu primer desafío real</b><br>Después de aprender los conceptos básicos, es hora de ponerlos a prueba.<br><br>Deberás crear una estructura de directorios para un proyecto real, mover archivos de configuración, y limpiar archivos temporales.<br><br>Usa todo lo que aprendiste en niveles 1-5. No hay pistas esta vez.	TERMINAL_SIM	principiante	70	30	20
22	22	Jefe Final: Intermedio	<b>El servidor de archivos</b><br>Un servidor de archivos necesita mantenimiento. Tienes que organizar backups, buscar en logs, y configurar permisos.<br><br>Comandos necesarios: <b>ls</b>, <b>cd</b>, <b>mkdir</b>, <b>touch</b>, <b>cp</b>, <b>mv</b>, <b>rm</b>, <b>grep</b>, <b>chmod</b>.<br><br>Nivel 7-12. Piensa como un sysadmin real.	TERMINAL_SIM	intermedio	70	35	21
23	23	Jefe Final: Avanzado	<b>El desastre avertedido</b><br>El servidor tiene problemas. Tienes que diagnosticar qué está mal buscando en logs, mover archivos críticos, y configurar permisos de emergencia.<br><br>Usa: <b>find</b>, <b>grep</b>, <b>chmod</b>, <b>chown</b>, <b>ls</b>, <b>cp</b>, <b>mv</b>.<br><br>Estás en modo crisis. Niveles 11-15.	TERMINAL_SIM	avanzado	75	40	22
24	24	Jefe Final: Maestro	<b>Elsysadmin master</b><br>Este es el desafio final. Un servidor completo necesita tu ayuda.<br><br>Deberás:<br>- Buscar y reemplazar texto en múltiples archivos<br>- Crear scripts de backup<br>- Gestionar permisos complejos<br>- Limpiar y organizar estructuras grandes<br><br>Todos los comandos de LearnUX. Confía en tu preparación.	TERMINAL_SIM	maestro	80	50	23
10	10	Introducción a grep	<b>grep: buscar texto dentro de archivos</b><br>grep es uno de los comandos más potentes de Linux. Sirve para encontrar líneas que contienen un patrón.<br><br><b>grep "patron" archivo</b>: busca el patrón en el archivo y muestra las líneas que lo contienen.<br>Ejemplo: <i>grep "error" /var/log/syslog</i>.<br><br><b>grep -i</b>: ignora mayúsculas/minúsculas. <i>grep -i "error"</i> encuentra "Error", "ERROR" y "error".<br><b>grep -r "patron" directorio</b>: busca recursivamente en todos los archivos. Ejemplo: <i>grep -r "TODO" /home/dan/proyecto</i>.<br><b>grep -n</b>: muestra el número de línea donde aparece la coincidencia.<br><b>grep -c</b>: cuenta cuántas líneas coinciden (solo muestra el número).<br><br>Se pueden combinar: <i>grep -in "warning" app.log</i>.	MULTIPLE_CHOICE	intermedio	60	15	9
12	12	Completa: cat, rm, touch, grep	<b>Completa comandos de cat, rm, touch y grep</b><br>Mismo formato que el nivel anterior: elige del desplegable el flag o argumento correcto.<br><br>Repaso de flags disponibles:<br><b>cat</b>: <i>-n</i> (numerar líneas).<br><b>rm</b>: <i>-r</i> (recursivo), <i>-f</i> (forzar), <i>-i</i> (interactivo), <i>-rf</i> (recursivo + forzado).<br><b>touch</b>: sin flags especiales, solo el nombre del archivo.<br><b>grep</b>: <i>-i</i> (ignorar mayúsculas), <i>-r</i> (recursivo), <i>-n</i> (número de línea), <i>-c</i> (contar), <i>-in</i> (combinar i y n).<br><br>Lee con calma el texto entre paréntesis.	FILL_BLANK	intermedio	65	20	11
14	14	Escribe: find básico	<b>find: buscar archivos por nombre o tipo</b><br>El comando <b>find</b> recorre directorios buscando archivos que cumplan criterios.<br><br><b>Sintaxis</b>: <i>find RUTA CRITERIO</i><br><br><b>find RUTA -name "patron"</b>: busca por nombre. El patrón puede tener comodines.<br>Ejemplo: <i>find /home -name "*.txt"</i> encuentra todos los .txt bajo /home.<br><br><b>find RUTA -type f</b>: solo archivos normales (f = file).<br><b>find RUTA -type d</b>: solo directorios (d = directory).<br><br>Se pueden combinar criterios:<br><i>find /home -type f -name "*.log"</i> busca solo archivos que terminen en .log.<br><br>IMPORTANTE: Siempre entrecomilla el patrón cuando tiene comodines: <i>"*.txt"</i>.	TYPE_COMMAND	intermedio	65	20	13
15	15	Escribe: grep	<b>Consolidar grep escribiendo</b><br>Repaso de todas las flags de grep:<br><b>-i</b>: ignorar mayúsculas/minúsculas.<br><b>-r</b>: recursivo (buscar en subdirectorios).<br><b>-n</b>: mostrar número de línea.<br><b>-c</b>: contar coincidencias (solo muestra el número).<br><br>Se pueden combinar: <i>grep -in "warning" app.log</i> o <i>grep -rn "TODO" /proyecto</i>.<br><br>El patrón va entre comillas dobles, sobre todo si tiene espacios.<br>Ejemplo: <i>grep "connection refused" app.log</i><br><br>Formato general: <i>grep [FLAGS] "PATRON" RUTA</i>	TYPE_COMMAND	intermedio	65	20	14
16	16	Terminal I: navegar y listar	<b>Bienvenido al modo terminal</b><br>A partir de aquí simulas una terminal real. Verás el <b>prompt</b> y contexto, y debes escribir el comando correcto.<br><br>Todos los comandos de este nivel los aprendiste en niveles 1-6: <b>ls</b> con sus flags, <b>cd</b>, <b>pwd</b>.<br><br>Presta atención al contexto: si ves tamaños como 4.0K o 1.2M, se usó <i>-h</i>. Si ves permisos (drwxr-xr-x), se usó <i>-l</i>. Si hay archivos ocultos (empiezan con punto), se usó <i>-a</i>.<br><br>Contexto: estás en <i>/home/dan</i>.	TERMINAL_SIM	avanzado	70	25	15
18	18	Terminal III: buscar con grep	<b>Buscar en logs y código</b><br>Simulas ser un sysadmin revisando logs o un desarrollador buscando en código. Usarás grep con distintos flags.<br><br>Recuerda: <b>-i</b> (ignore case), <b>-n</b> (line number), <b>-r</b> (recursivo), <b>-c</b> (contar).<br><br>Mira con atención la salida que te muestran: el formato <i>archivo:lineaNum:contenido</i> aparece cuando se usa <i>-n</i>. El formato <i>ruta/archivo:contenido</i> aparece con <i>-r</i>.	TERMINAL_SIM	avanzado	70	25	17
19	19	Terminal IV: permisos con chmod	<b>chmod: cambiar permisos</b><br>Cada archivo tiene tres grupos: <b>u</b> (dueño), <b>g</b> (grupo), <b>o</b> (otros). Cada grupo tiene: <b>r</b>=leer, <b>w</b>=escribir, <b>x</b>=ejecutar.<br><br><b>Notación numérica</b>: r=4, w=2, x=1. Se suman:<br>7 = rwx &nbsp;|&nbsp; 6 = rw- &nbsp;|&nbsp; 5 = r-x &nbsp;|&nbsp; 4 = r-- &nbsp;|&nbsp; 0 = ---<br><br>Se ponen tres dígitos: dueño, grupo, otros.<br><b>755</b>: dueño rwx, grupo+otros r-x (típico de scripts).<br><b>644</b>: dueño rw-, grupo+otros r-- (archivos de configuración).<br><b>700</b>: solo el dueño puede todo.<br><b>600</b>: solo el dueño lee y escribe (claves SSH).<br><br><b>Notación simbólica</b>:<br><i>chmod u+x archivo</i>: añade ejecución al dueño.<br><i>chmod a-w archivo</i>: quita escritura a todos.<br><i>chmod g+r archivo</i>: añade lectura al grupo.	TERMINAL_SIM	avanzado	70	25	18
\.


--
-- Data for Name: opciones_comando; Type: TABLE DATA; Schema: learnux; Owner: postgres
--

COPY learnux.opciones_comando (id_opcion, id_comando, bandera, descripcion, ejemplo_uso) FROM stdin;
1	1	-h	Tamaños en formato legible (KB, MB, GB)	ls -lh
2	1	-a	Muestra archivos ocultos (que empiezan con .)	ls -a
3	1	-l	Muestra formato largo con permisos, dueño, tamaño y fecha	ls -l
4	3	-p	Crea directorios padre si no existen	mkdir -p /ruta/larga/nueva
5	4	-f	Fuerza la eliminación sin pedir confirmación	rm -rf /carpeta_rebelde
6	4	-r	Elimina directorios y sus contenidos recursivamente	rm -r /carpeta_vieja
7	6	-n	Numera todas las líneas de salida	cat -n archivo.txt
8	10	-h	Muestra tamaños legibles para humanos	df -h
9	11	-h	Muestra memoria en formato legible	free -h
10	12	-R	Aplica permisos recursivamente en directorios	chmod -R 755 /mi_proyecto
11	13	-u	Ejecuta el comando como usuario específico	sudo -u postgres psql
12	14	-r	Busca recursivamente en todos los archivos de un directorio	grep -r "main()" /src
13	14	-i	Ignora distinción entre mayúsculas y minúsculas	grep -i "error" server.log
14	15	-type	Filtra por tipo: f=archivo, d=directorio	find . -type d
15	15	-name	Busca archivos que coincidan con el patrón	find / -name "*.java"
16	16	-xvf	Extrae un archivo tar mostrando el progreso	tar -xvf respaldo.tar
17	16	-cvf	Crea un archivo (c), modo verbose (v), especifica nombre (f)	tar -cvf respaldo.tar /docs
18	20	-aux	Muestra todos los procesos del sistema con detalle	ps aux
19	21	-	Vuelve al directorio en el que estabas antes	cd -
20	21	~	Va directamente al directorio home del usuario	cd ~
21	21	..	Sube al directorio padre (nivel superior)	cd ..
22	2	-r	Copia directorios completos de forma recursiva	cp -r proyectos/ backup/
23	2	-i	Pide confirmación si el archivo destino ya existe	cp -i notas.txt /home/dan/
24	2	-v	Muestra en pantalla cada archivo que se está copiando	cp -v *.txt /backup/
25	2	-p	Preserva permisos, fechas y propietario del original	cp -p config.conf config.conf.bak
26	5	-i	Pide confirmación antes de sobrescribir un archivo	mv -i viejo.txt nuevo.txt
27	5	-v	Muestra cada archivo que se mueve o renombra	mv -v *.log /var/log/old/
28	5	-n	No sobrescribe archivos si el destino ya existe	mv -n foto.jpg /fotos/
29	7	-t	Establece una fecha y hora específica (en vez de ahora)	touch -t 202501011200 archivo.txt
30	7	-a	Solo actualiza la fecha de último acceso del archivo	touch -a log.txt
31	7	-m	Solo actualiza la fecha de última modificación	touch -m log.txt
32	8	-L	Muestra la ruta lógica (respeta los enlaces simbólicos)	pwd -L
33	8	-P	Muestra la ruta física real (resuelve los symlinks)	pwd -P
34	9	-n	Ejecuta top durante N ciclos y luego sale automáticamente	top -n 5
35	9	-u	Muestra solo los procesos de un usuario concreto	top -u dan
36	9	-d	Intervalo de refresco en segundos (por defecto 3s)	top -d 1
37	6	-b	Numera solo las líneas no vacías	cat -b script.sh
38	6	-A	Muestra caracteres especiales: tabs (^I) y fin de línea	cat -A config.ini
39	6	-s	Comprime múltiples líneas en blanco consecutivas en una	cat -s texto_largo.txt
40	4	-i	Pregunta confirmación antes de borrar cada archivo	rm -i *.bak
41	4	-v	Muestra el nombre de cada archivo eliminado	rm -v /tmp/*.log
42	3	-v	Muestra un mensaje por cada directorio creado	mkdir -v nueva_carpeta
43	3	-m	Establece los permisos del directorio al crearlo	mkdir -m 755 publica
44	14	-n	Muestra el número de línea de cada coincidencia encontrada	grep -n "ERROR" app.log
45	14	-v	Invierte la búsqueda: muestra líneas que NO coinciden	grep -v "DEBUG" app.log
46	14	-c	Cuenta cuántas líneas contienen la coincidencia	grep -c "warning" syslog
47	14	-l	Muestra solo los nombres de archivos con coincidencias	grep -l "TODO" src/*.java
48	14	-E	Activa expresiones regulares extendidas (regex)	grep -E "error|warn" log.txt
49	15	-size	Filtra por tamaño: +Nc mayor, -Nc menor (k=KB, M=MB)	find /var -size +10M
50	15	-mtime	Archivos modificados hace N días (-7 = últimos 7 días)	find . -mtime -7
51	15	-exec	Ejecuta un comando sobre cada resultado encontrado	find . -name "*.log" -exec rm {} \\\\;
52	15	-maxdepth	Limita la profundidad máxima de búsqueda en directorios	find . -maxdepth 2 -name "*.conf"
53	12	-v	Muestra cada archivo cuyos permisos se han cambiado	chmod -v 644 *.txt
54	12	+x	Añade permiso de ejecución (sin cambiar el resto)	chmod +x script.sh
55	12	u+w	Da permiso de escritura solo al propietario (user)	chmod u+w informe.txt
56	12	o-r	Quita permiso de lectura a otros (others)	chmod o-r privado.conf
57	10	-T	Muestra el tipo de sistema de archivos (ext4, tmpfs…)	df -T
58	10	-i	Muestra uso de inodos en lugar de espacio en bloques	df -i /home
59	11	-s	Refresca la pantalla cada N segundos de forma continua	free -h -s 2
60	11	-t	Añade una fila con el total de RAM + swap combinados	free -t -h
61	16	-z	Comprime o descomprime usando gzip (.tar.gz)	tar -czvf backup.tar.gz /docs
62	16	-j	Comprime o descomprime usando bzip2 (.tar.bz2)	tar -cjvf backup.tar.bz2 /docs
63	16	-t	Lista el contenido del archivo tar sin extraer nada	tar -tvf backup.tar
64	16	-C	Extrae los archivos en el directorio indicado	tar -xvf backup.tar -C /destino/
65	20	-e	Muestra todos los procesos en ejecución del sistema	ps -e
66	20	--forest	Muestra procesos en árbol mostrando la jerarquía padre-hijo	ps aux --forest
67	20	-p	Muestra información solo del PID indicado	ps -p 1234
68	13	-l	Lista los comandos que tienes permiso de ejecutar con sudo	sudo -l
69	13	-s	Abre una shell como superusuario en el directorio actual	sudo -s
70	13	-i	Inicia sesión interactiva completa como root (con su entorno)	sudo -i
71	17	-F	Define el separador de campo al procesar líneas	awk -F: '{print $1}' /etc/passwd
72	17	-v	Asigna un valor a una variable antes de ejecutar el script	awk -v n=5 'NR<=n{print}' datos.txt
73	17	-f	Lee el programa awk desde un archivo externo en vez de inline	awk -f analisis.awk datos.txt
74	18	-i	Modifica el archivo original directamente (in-place)	sed -i 's/http/https/g' config.txt
75	18	-n	Suprime la salida; solo imprime lo que /p indique	sed -n '5,10p' archivo.txt
76	18	-e	Permite encadenar múltiples expresiones en un solo comando	sed -e 's/foo/bar/g' -e 's/baz/qux/g' f.txt
77	18	-E	Activa expresiones regulares extendidas (ERE)	sed -E 's/(error|warn)/[!]/gi' log.txt
78	19	-s	Crea un enlace simbólico (acceso directo al archivo original)	ln -s /etc/nginx/sites-available/app /etc/nginx/sites-enabled/app
79	19	-f	Sobreescribe el enlace destino si ya existe	ln -sf /nueva/ruta/bin /usr/local/bin/app
80	19	-v	Muestra en pantalla el nombre de cada enlace creado	ln -sv origen destino
\.


--
-- Data for Name: progreso_nivel; Type: TABLE DATA; Schema: learnux; Owner: postgres
--

COPY learnux.progreso_nivel (id_usuario, id_nivel, completado, puntos_acumulados, intentos_totales, fecha_inicio, fecha_completado) FROM stdin;
1	16	t	80	8	2026-04-19 01:00:57.796814	2026-04-15 01:00:57.796814
1	17	t	80	8	2026-04-19 01:00:57.796814	2026-04-16 01:00:57.796814
1	3	t	60	6	2026-04-18 14:13:13.019892	2026-04-02 01:00:57.796814
1	1	t	200	32	2026-04-17 21:30:29.44003	2026-03-31 01:00:57.796814
2	1	f	10	4	2026-04-21 07:59:22.669982	\N
1	9	t	60	5	2026-04-19 00:08:08.093069	2026-04-08 01:00:57.796814
1	2	t	50	5	2026-04-18 13:58:31.889691	2026-04-01 01:00:57.796814
1	4	t	60	5	2026-04-18 14:43:34.75097	2026-04-03 01:00:57.796814
1	5	t	60	5	2026-04-18 19:35:17.230267	2026-04-04 01:00:57.796814
1	6	t	60	5	2026-04-18 19:56:23.257588	2026-04-05 01:00:57.796814
1	7	t	60	5	2026-04-18 19:59:04.88987	2026-04-06 01:00:57.796814
1	8	t	60	5	2026-04-18 20:00:22.907169	2026-04-07 01:00:57.796814
1	11	t	65	5	2026-04-19 01:00:57.796814	2026-04-10 01:00:57.796814
1	13	t	65	5	2026-04-19 01:00:57.796814	2026-04-12 01:00:57.796814
1	20	f	28	2	2026-04-19 01:00:57.796814	\N
1	10	t	60	5	2026-04-19 00:09:25.06377	2026-04-09 01:00:57.796814
1	12	t	65	5	2026-04-19 01:00:57.796814	2026-04-11 01:00:57.796814
1	14	t	65	5	2026-04-19 01:00:57.796814	2026-04-13 01:00:57.796814
1	15	t	65	5	2026-04-19 01:00:57.796814	2026-04-14 01:00:57.796814
1	18	f	28	2	2026-04-19 01:00:57.796814	\N
1	19	f	28	2	2026-04-19 01:00:57.796814	\N
\.


--
-- Data for Name: progreso_usuarios; Type: TABLE DATA; Schema: learnux; Owner: postgres
--

COPY learnux.progreso_usuarios (id_usuario, id_comando, dominado, veces_practicado, ultima_practica) FROM stdin;
1	2	f	3	2026-04-19 01:05:21.656616
1	3	f	11	2026-04-19 11:37:55.900662
1	1	f	35	2026-04-19 17:41:26.260686
2	1	f	1	2026-04-21 07:59:52.386602
1	5	f	3	2026-04-18 19:57:58.824795
1	13	f	2	2026-04-18 19:59:52.00464
1	12	f	1	2026-04-18 19:59:55.017705
1	20	f	1	2026-04-18 20:00:55.578979
1	4	f	9	2026-04-19 00:07:25.008215
1	7	f	1	2026-04-19 00:08:08.110979
1	6	f	2	2026-04-19 00:08:18.646196
1	14	f	3	2026-04-19 00:09:42.356677
1	21	f	1	2026-04-19 00:10:26.849985
1	8	f	3	2026-04-19 01:03:04.138174
\.


--
-- Data for Name: sesiones_log; Type: TABLE DATA; Schema: learnux; Owner: postgres
--

COPY learnux.sesiones_log (id_sesion, id_usuario, ip_cliente, fecha_login, fecha_logout) FROM stdin;
1	1	\N	2026-04-19 00:10:26.849985	\N
2	2	\N	2026-04-21 07:59:52.386602	\N
\.


--
-- Data for Name: usuarios; Type: TABLE DATA; Schema: learnux; Owner: postgres
--

COPY learnux.usuarios (id_usuario, nombre_usuario, email, password_hash, puntos_totales, nivel_actual, fecha_creacion, activo) FROM stdin;
1	dan	\N	\N	300	18	2026-04-17 21:30:29.44003	t
2	Ale	\N	\N	0	1	2026-04-21 07:59:22.669982	t
\.


--
-- Data for Name: categorias; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categorias (id_categoria, nombre, descripcion) FROM stdin;
1	manejo de archivos	comandos usados para la manipulacion y eliminacion de archivos
2	informacion de sistema	comandos usados para ver el rendimiento del sistema y el hardware
3	permisos y seguridad	Comandos para gestionar usuarios, grupos y permisos de lectura/escritura.
4	busqueda y filtrado	Comandos avanzados para buscar archivos y manipular texto dentro de ellos.
5	compresion y empaquetado	Herramientas para comprimir archivos y crear respaldos (backups).
\.


--
-- Data for Name: comandos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.comandos (id_comando, id_categoria, comando_nombre, descripcion, sintaxis, dificultad_nivel) FROM stdin;
1	1	ls	enlista los contenidos de un directorio	ls [OPCION]... [ARCHIVO]	principiante
2	1	cp	copia archivos y directorios	cp [OPCION]... [DIRECCION_DE_DESTINO]	principiante
3	2	top	muestra los procesos de linux	top	Intermedio
4	1	mkdir	Crea uno o varios directorios nuevos.	mkdir [OPCION]... DIRECTORIO...	principiante
5	1	rm	Elimina archivos o directorios permanentemente.	rm [OPCION]... ARCHIVO...	intermedio
6	1	mv	Mueve o renombra archivos y directorios.	mv [OPCION]... ORIGEN DESTINO	principiante
7	2	df	Muestra el espacio disponible en los sistemas de archivos montados.	df [OPCION]... [ARCHIVO]...	principiante
8	2	free	Muestra la cantidad de memoria RAM libre y usada en el sistema.	free [OPCION]	principiante
9	3	chmod	Cambia los permisos de acceso (lectura, escritura, ejecucion) de un archivo.	chmod [OPCION]... MODO ARCHIVO...	intermedio
10	3	sudo	Ejecuta un comando con privilegios de superusuario (root).	sudo [OPCION]... COMANDO	principiante
11	4	grep	Busca patrones de texto especificos dentro de archivos o salidas de comandos.	grep [OPCION]... PATRON [ARCHIVO]...	intermedio
12	4	find	Busca archivos en una jerarquia de directorios basandose en diversos criterios.	find [RUTA]... [EXPRESION]	avanzado
13	5	tar	Empaqueta multiples archivos en un solo archivo (archive) y puede comprimirlos.	tar [OPCION]... [ARCHIVO_DESTINO] [ARCHIVOS_ORIGEN]	avanzado
\.


--
-- Data for Name: comandos_audit_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.comandos_audit_log (id_audit, tipo_accion, nombre_comando, fecha_evento) FROM stdin;
1	INSERT	mkdir	2026-03-30 15:23:27.116805
2	INSERT	rm	2026-03-30 15:23:27.116805
3	INSERT	mv	2026-03-30 15:23:27.116805
4	INSERT	df	2026-03-30 15:23:27.121666
5	INSERT	free	2026-03-30 15:23:27.121666
6	INSERT	chmod	2026-03-30 15:23:27.123011
7	INSERT	sudo	2026-03-30 15:23:27.123011
8	INSERT	grep	2026-03-30 15:23:27.12447
9	INSERT	find	2026-03-30 15:23:27.12447
10	INSERT	tar	2026-03-30 15:23:27.126008
\.


--
-- Data for Name: opciones_comando; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.opciones_comando (id_opcion, id_comando, bandera, descripcion, ejemplo_uso) FROM stdin;
1	4	-p	Crea directorios padre si no existen, evitando errores.	mkdir -p /ruta/larga/nueva
2	5	-r	Elimina directorios y sus contenidos de forma recursiva.	rm -r /carpeta_vieja
3	5	-f	Fuerza la eliminacion sin pedir confirmacion (peligroso).	rm -rf /carpeta_rebelde
4	7	-h	Muestra los tamaños en formato legible para humanos (MB, GB).	df -h
5	8	-h	Muestra la memoria RAM en formato legible para humanos.	free -h
6	9	-R	Aplica los cambios de permisos a todos los archivos dentro de un directorio de forma recursiva.	chmod -R 755 /mi_proyecto
7	10	-u	Ejecuta el comando como un usuario especifico en lugar de root.	sudo -u postgres psql
8	11	-i	Ignora la distincion entre mayusculas y minusculas al buscar.	grep -i "error" server.log
9	11	-r	Busca recursivamente dentro de todos los archivos de un directorio.	grep -r "main()" /src
10	12	-name	Busca archivos que coincidan exactamente con el nombre o patron proporcionado.	find / -name "*.java"
11	12	-type	Filtra la busqueda por tipo: "f" para archivos, "d" para directorios.	find . -type d
12	13	-cvf	Crea un archivo nuevo (c), muestra el progreso (v), y especifica el nombre del archivo (f).	tar -cvf respaldo.tar /documentos
13	13	-xvf	Extrae los contenidos (x) de un archivo tar, mostrando el progreso (v).	tar -xvf respaldo.tar
\.


--
-- Data for Name: progreso_usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.progreso_usuarios (id_usuario, id_comando, dominado, veces_practicado, ultima_practica) FROM stdin;
\.


--
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuarios (id_usuario, nombre_usuario, fecha_creacion) FROM stdin;
\.


--
-- Name: categorias_id_categoria_seq; Type: SEQUENCE SET; Schema: learnux; Owner: postgres
--

SELECT pg_catalog.setval('learnux.categorias_id_categoria_seq', 5, true);


--
-- Name: comandos_audit_log_id_audit_seq; Type: SEQUENCE SET; Schema: learnux; Owner: postgres
--

SELECT pg_catalog.setval('learnux.comandos_audit_log_id_audit_seq', 41, true);


--
-- Name: comandos_id_comando_seq; Type: SEQUENCE SET; Schema: learnux; Owner: postgres
--

SELECT pg_catalog.setval('learnux.comandos_id_comando_seq', 21, true);


--
-- Name: ejercicios_id_ejercicio_seq; Type: SEQUENCE SET; Schema: learnux; Owner: postgres
--

SELECT pg_catalog.setval('learnux.ejercicios_id_ejercicio_seq', 127, true);


--
-- Name: intentos_ejercicio_id_intento_seq; Type: SEQUENCE SET; Schema: learnux; Owner: postgres
--

SELECT pg_catalog.setval('learnux.intentos_ejercicio_id_intento_seq', 138, true);


--
-- Name: niveles_id_nivel_seq; Type: SEQUENCE SET; Schema: learnux; Owner: postgres
--

SELECT pg_catalog.setval('learnux.niveles_id_nivel_seq', 20, true);


--
-- Name: opciones_comando_id_opcion_seq; Type: SEQUENCE SET; Schema: learnux; Owner: postgres
--

SELECT pg_catalog.setval('learnux.opciones_comando_id_opcion_seq', 80, true);


--
-- Name: sesiones_log_id_sesion_seq; Type: SEQUENCE SET; Schema: learnux; Owner: postgres
--

SELECT pg_catalog.setval('learnux.sesiones_log_id_sesion_seq', 2, true);


--
-- Name: usuarios_id_usuario_seq; Type: SEQUENCE SET; Schema: learnux; Owner: postgres
--

SELECT pg_catalog.setval('learnux.usuarios_id_usuario_seq', 2, true);


--
-- Name: categorias_id_categoria_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categorias_id_categoria_seq', 5, true);


--
-- Name: comandos_audit_log_id_audit_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.comandos_audit_log_id_audit_seq', 10, true);


--
-- Name: comandos_id_comando_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.comandos_id_comando_seq', 13, true);


--
-- Name: opciones_comando_id_opcion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.opciones_comando_id_opcion_seq', 13, true);


--
-- Name: usuarios_id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuarios_id_usuario_seq', 1, false);


--
-- Name: categorias categorias_pkey; Type: CONSTRAINT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.categorias
    ADD CONSTRAINT categorias_pkey PRIMARY KEY (id_categoria);


--
-- Name: comandos_audit_log comandos_audit_log_pkey; Type: CONSTRAINT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.comandos_audit_log
    ADD CONSTRAINT comandos_audit_log_pkey PRIMARY KEY (id_audit);


--
-- Name: comandos comandos_pkey; Type: CONSTRAINT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.comandos
    ADD CONSTRAINT comandos_pkey PRIMARY KEY (id_comando);


--
-- Name: ejercicios ejercicios_pkey; Type: CONSTRAINT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.ejercicios
    ADD CONSTRAINT ejercicios_pkey PRIMARY KEY (id_ejercicio);


--
-- Name: intentos_ejercicio intentos_ejercicio_pkey; Type: CONSTRAINT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.intentos_ejercicio
    ADD CONSTRAINT intentos_ejercicio_pkey PRIMARY KEY (id_intento);


--
-- Name: niveles niveles_pkey; Type: CONSTRAINT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.niveles
    ADD CONSTRAINT niveles_pkey PRIMARY KEY (id_nivel);


--
-- Name: opciones_comando opciones_comando_pkey; Type: CONSTRAINT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.opciones_comando
    ADD CONSTRAINT opciones_comando_pkey PRIMARY KEY (id_opcion);


--
-- Name: progreso_nivel progreso_nivel_pkey; Type: CONSTRAINT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.progreso_nivel
    ADD CONSTRAINT progreso_nivel_pkey PRIMARY KEY (id_usuario, id_nivel);


--
-- Name: progreso_usuarios progreso_usuarios_pkey; Type: CONSTRAINT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.progreso_usuarios
    ADD CONSTRAINT progreso_usuarios_pkey PRIMARY KEY (id_usuario, id_comando);


--
-- Name: sesiones_log sesiones_log_pkey; Type: CONSTRAINT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.sesiones_log
    ADD CONSTRAINT sesiones_log_pkey PRIMARY KEY (id_sesion);


--
-- Name: categorias uq_categoria_nombre; Type: CONSTRAINT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.categorias
    ADD CONSTRAINT uq_categoria_nombre UNIQUE (nombre);


--
-- Name: comandos uq_comando_nombre; Type: CONSTRAINT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.comandos
    ADD CONSTRAINT uq_comando_nombre UNIQUE (comando_nombre);


--
-- Name: usuarios uq_email; Type: CONSTRAINT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.usuarios
    ADD CONSTRAINT uq_email UNIQUE (email);


--
-- Name: niveles uq_nivel_numero; Type: CONSTRAINT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.niveles
    ADD CONSTRAINT uq_nivel_numero UNIQUE (numero);


--
-- Name: usuarios uq_nombre_usuario; Type: CONSTRAINT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.usuarios
    ADD CONSTRAINT uq_nombre_usuario UNIQUE (nombre_usuario);


--
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id_usuario);


--
-- Name: categorias categorias_nombre_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categorias
    ADD CONSTRAINT categorias_nombre_key UNIQUE (nombre);


--
-- Name: categorias categorias_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categorias
    ADD CONSTRAINT categorias_pkey PRIMARY KEY (id_categoria);


--
-- Name: comandos_audit_log comandos_audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comandos_audit_log
    ADD CONSTRAINT comandos_audit_log_pkey PRIMARY KEY (id_audit);


--
-- Name: comandos comandos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comandos
    ADD CONSTRAINT comandos_pkey PRIMARY KEY (id_comando);


--
-- Name: opciones_comando opciones_comando_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opciones_comando
    ADD CONSTRAINT opciones_comando_pkey PRIMARY KEY (id_opcion);


--
-- Name: progreso_usuarios progreso_usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.progreso_usuarios
    ADD CONSTRAINT progreso_usuarios_pkey PRIMARY KEY (id_usuario, id_comando);


--
-- Name: usuarios usuarios_nombre_usuario_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_nombre_usuario_key UNIQUE (nombre_usuario);


--
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id_usuario);


--
-- Name: comandos_audit_log rule_audit_inmutable; Type: RULE; Schema: learnux; Owner: postgres
--

CREATE RULE rule_audit_inmutable AS
    ON DELETE TO learnux.comandos_audit_log DO INSTEAD NOTHING;


--
-- Name: sesiones_log rule_sesion_unica; Type: RULE; Schema: learnux; Owner: postgres
--

CREATE RULE rule_sesion_unica AS
    ON INSERT TO learnux.sesiones_log
   WHERE (EXISTS ( SELECT 1
           FROM learnux.sesiones_log sesiones_log_1
          WHERE ((sesiones_log_1.id_usuario = new.id_usuario) AND (sesiones_log_1.fecha_logout IS NULL)))) DO INSTEAD  UPDATE learnux.sesiones_log SET fecha_login = CURRENT_TIMESTAMP
  WHERE ((sesiones_log.id_usuario = new.id_usuario) AND (sesiones_log.fecha_logout IS NULL));


--
-- Name: usuarios rule_soft_delete_usuarios; Type: RULE; Schema: learnux; Owner: postgres
--

CREATE RULE rule_soft_delete_usuarios AS
    ON DELETE TO learnux.usuarios DO INSTEAD  UPDATE learnux.usuarios SET activo = false
  WHERE (usuarios.id_usuario = old.id_usuario);


--
-- Name: vista_comandos_completos rule_update_vista_comandos; Type: RULE; Schema: learnux; Owner: postgres
--

CREATE RULE rule_update_vista_comandos AS
    ON UPDATE TO learnux.vista_comandos_completos DO INSTEAD  UPDATE learnux.comandos SET descripcion = new.descripcion, sintaxis = new.sintaxis, dificultad_nivel = new.dificultad_nivel
  WHERE (comandos.id_comando = new.id_comando);


--
-- Name: comandos tr_audit_comandos; Type: TRIGGER; Schema: learnux; Owner: postgres
--

CREATE TRIGGER tr_audit_comandos AFTER INSERT OR DELETE OR UPDATE ON learnux.comandos FOR EACH ROW EXECUTE FUNCTION learnux.fn_audit_comandos();


--
-- Name: progreso_nivel tr_avanzar_nivel; Type: TRIGGER; Schema: learnux; Owner: postgres
--

CREATE TRIGGER tr_avanzar_nivel AFTER UPDATE OF completado ON learnux.progreso_nivel FOR EACH ROW EXECUTE FUNCTION learnux.fn_avanzar_nivel_usuario();


--
-- Name: progreso_usuarios tr_log_sesion_practica; Type: TRIGGER; Schema: learnux; Owner: postgres
--

CREATE TRIGGER tr_log_sesion_practica AFTER INSERT ON learnux.progreso_usuarios FOR EACH ROW EXECUTE FUNCTION learnux.fn_log_sesion();


--
-- Name: comandos tr_normalizar_comando; Type: TRIGGER; Schema: learnux; Owner: postgres
--

CREATE TRIGGER tr_normalizar_comando BEFORE INSERT OR UPDATE OF comando_nombre ON learnux.comandos FOR EACH ROW EXECUTE FUNCTION learnux.fn_normalizar_comando();


--
-- Name: progreso_usuarios tr_proteger_progreso; Type: TRIGGER; Schema: learnux; Owner: postgres
--

CREATE TRIGGER tr_proteger_progreso BEFORE UPDATE ON learnux.progreso_usuarios FOR EACH ROW EXECUTE FUNCTION learnux.fn_proteger_progreso();


--
-- Name: comandos tr_comandos_log; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_comandos_log AFTER INSERT OR DELETE ON public.comandos FOR EACH ROW EXECUTE FUNCTION public.f_log_comandos();


--
-- Name: comandos fk_cmd_categoria; Type: FK CONSTRAINT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.comandos
    ADD CONSTRAINT fk_cmd_categoria FOREIGN KEY (id_categoria) REFERENCES learnux.categorias(id_categoria) ON DELETE CASCADE;


--
-- Name: ejercicios fk_ej_comando; Type: FK CONSTRAINT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.ejercicios
    ADD CONSTRAINT fk_ej_comando FOREIGN KEY (id_comando) REFERENCES learnux.comandos(id_comando) ON DELETE SET NULL;


--
-- Name: ejercicios fk_ej_nivel; Type: FK CONSTRAINT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.ejercicios
    ADD CONSTRAINT fk_ej_nivel FOREIGN KEY (id_nivel) REFERENCES learnux.niveles(id_nivel) ON DELETE CASCADE;


--
-- Name: intentos_ejercicio fk_it_ejercicio; Type: FK CONSTRAINT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.intentos_ejercicio
    ADD CONSTRAINT fk_it_ejercicio FOREIGN KEY (id_ejercicio) REFERENCES learnux.ejercicios(id_ejercicio) ON DELETE CASCADE;


--
-- Name: intentos_ejercicio fk_it_nivel; Type: FK CONSTRAINT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.intentos_ejercicio
    ADD CONSTRAINT fk_it_nivel FOREIGN KEY (id_nivel) REFERENCES learnux.niveles(id_nivel) ON DELETE CASCADE;


--
-- Name: intentos_ejercicio fk_it_usuario; Type: FK CONSTRAINT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.intentos_ejercicio
    ADD CONSTRAINT fk_it_usuario FOREIGN KEY (id_usuario) REFERENCES learnux.usuarios(id_usuario) ON DELETE CASCADE;


--
-- Name: opciones_comando fk_opcion_comando; Type: FK CONSTRAINT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.opciones_comando
    ADD CONSTRAINT fk_opcion_comando FOREIGN KEY (id_comando) REFERENCES learnux.comandos(id_comando) ON DELETE CASCADE;


--
-- Name: progreso_nivel fk_pn_nivel; Type: FK CONSTRAINT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.progreso_nivel
    ADD CONSTRAINT fk_pn_nivel FOREIGN KEY (id_nivel) REFERENCES learnux.niveles(id_nivel) ON DELETE CASCADE;


--
-- Name: progreso_nivel fk_pn_usuario; Type: FK CONSTRAINT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.progreso_nivel
    ADD CONSTRAINT fk_pn_usuario FOREIGN KEY (id_usuario) REFERENCES learnux.usuarios(id_usuario) ON DELETE CASCADE;


--
-- Name: progreso_usuarios fk_pu_comando; Type: FK CONSTRAINT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.progreso_usuarios
    ADD CONSTRAINT fk_pu_comando FOREIGN KEY (id_comando) REFERENCES learnux.comandos(id_comando) ON DELETE CASCADE;


--
-- Name: progreso_usuarios fk_pu_usuario; Type: FK CONSTRAINT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.progreso_usuarios
    ADD CONSTRAINT fk_pu_usuario FOREIGN KEY (id_usuario) REFERENCES learnux.usuarios(id_usuario) ON DELETE CASCADE;


--
-- Name: sesiones_log fk_sesion_usuario; Type: FK CONSTRAINT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.sesiones_log
    ADD CONSTRAINT fk_sesion_usuario FOREIGN KEY (id_usuario) REFERENCES learnux.usuarios(id_usuario) ON DELETE CASCADE;


--
-- Name: niveles niveles_desbloqueado_por_fkey; Type: FK CONSTRAINT; Schema: learnux; Owner: postgres
--

ALTER TABLE ONLY learnux.niveles
    ADD CONSTRAINT niveles_desbloqueado_por_fkey FOREIGN KEY (desbloqueado_por) REFERENCES learnux.niveles(id_nivel);


--
-- Name: comandos fk_categoria; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comandos
    ADD CONSTRAINT fk_categoria FOREIGN KEY (id_categoria) REFERENCES public.categorias(id_categoria) ON DELETE CASCADE;


--
-- Name: opciones_comando fk_comando_opcion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opciones_comando
    ADD CONSTRAINT fk_comando_opcion FOREIGN KEY (id_comando) REFERENCES public.comandos(id_comando) ON DELETE CASCADE;


--
-- Name: progreso_usuarios fk_progreso_comando; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.progreso_usuarios
    ADD CONSTRAINT fk_progreso_comando FOREIGN KEY (id_comando) REFERENCES public.comandos(id_comando) ON DELETE CASCADE;


--
-- Name: progreso_usuarios fk_usuario; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.progreso_usuarios
    ADD CONSTRAINT fk_usuario FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id_usuario) ON DELETE CASCADE;


--
-- Name: SCHEMA learnux; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA learnux TO learnux_admin;
GRANT USAGE ON SCHEMA learnux TO learnux_estudiante;
GRANT USAGE ON SCHEMA learnux TO learnux_publico;


--
-- Name: FUNCTION f_buscar_comando(p_nombre text); Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON FUNCTION learnux.f_buscar_comando(p_nombre text) TO learnux_admin;
GRANT ALL ON FUNCTION learnux.f_buscar_comando(p_nombre text) TO learnux_estudiante;
GRANT ALL ON FUNCTION learnux.f_buscar_comando(p_nombre text) TO learnux_publico;


--
-- Name: FUNCTION f_buscar_usuario(p_nombre text); Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON FUNCTION learnux.f_buscar_usuario(p_nombre text) TO learnux_estudiante;
GRANT ALL ON FUNCTION learnux.f_buscar_usuario(p_nombre text) TO learnux_admin;


--
-- Name: FUNCTION f_get_comandos_de_nivel(p_id_nivel integer); Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON FUNCTION learnux.f_get_comandos_de_nivel(p_id_nivel integer) TO learnux_estudiante;
GRANT ALL ON FUNCTION learnux.f_get_comandos_de_nivel(p_id_nivel integer) TO learnux_publico;
GRANT ALL ON FUNCTION learnux.f_get_comandos_de_nivel(p_id_nivel integer) TO learnux_admin;


--
-- Name: FUNCTION f_get_ejercicios_nivel(p_id_nivel integer); Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON FUNCTION learnux.f_get_ejercicios_nivel(p_id_nivel integer) TO learnux_estudiante;
GRANT ALL ON FUNCTION learnux.f_get_ejercicios_nivel(p_id_nivel integer) TO learnux_admin;


--
-- Name: FUNCTION f_get_niveles_con_progreso(p_id_usuario integer); Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON FUNCTION learnux.f_get_niveles_con_progreso(p_id_usuario integer) TO learnux_estudiante;
GRANT ALL ON FUNCTION learnux.f_get_niveles_con_progreso(p_id_usuario integer) TO learnux_admin;
GRANT ALL ON FUNCTION learnux.f_get_niveles_con_progreso(p_id_usuario integer) TO learnux_publico;


--
-- Name: FUNCTION f_get_opciones_comando(p_id_comando integer); Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON FUNCTION learnux.f_get_opciones_comando(p_id_comando integer) TO learnux_estudiante;
GRANT ALL ON FUNCTION learnux.f_get_opciones_comando(p_id_comando integer) TO learnux_publico;
GRANT ALL ON FUNCTION learnux.f_get_opciones_comando(p_id_comando integer) TO learnux_admin;


--
-- Name: FUNCTION f_get_todas_categorias(); Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON FUNCTION learnux.f_get_todas_categorias() TO learnux_estudiante;
GRANT ALL ON FUNCTION learnux.f_get_todas_categorias() TO learnux_publico;
GRANT ALL ON FUNCTION learnux.f_get_todas_categorias() TO learnux_admin;


--
-- Name: FUNCTION f_ls_comandos_categoria(p_id_categoria integer); Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON FUNCTION learnux.f_ls_comandos_categoria(p_id_categoria integer) TO learnux_admin;
GRANT ALL ON FUNCTION learnux.f_ls_comandos_categoria(p_id_categoria integer) TO learnux_estudiante;
GRANT ALL ON FUNCTION learnux.f_ls_comandos_categoria(p_id_categoria integer) TO learnux_publico;


--
-- Name: FUNCTION f_porcentaje_nivel(p_id_usuario integer, p_id_nivel integer); Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON FUNCTION learnux.f_porcentaje_nivel(p_id_usuario integer, p_id_nivel integer) TO learnux_admin;
GRANT ALL ON FUNCTION learnux.f_porcentaje_nivel(p_id_usuario integer, p_id_nivel integer) TO learnux_estudiante;


--
-- Name: FUNCTION f_resumen_progreso(p_id_usuario integer); Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON FUNCTION learnux.f_resumen_progreso(p_id_usuario integer) TO learnux_admin;
GRANT ALL ON FUNCTION learnux.f_resumen_progreso(p_id_usuario integer) TO learnux_estudiante;


--
-- Name: FUNCTION f_siguiente_nivel(p_id_usuario integer); Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON FUNCTION learnux.f_siguiente_nivel(p_id_usuario integer) TO learnux_admin;
GRANT ALL ON FUNCTION learnux.f_siguiente_nivel(p_id_usuario integer) TO learnux_estudiante;


--
-- Name: FUNCTION fn_audit_comandos(); Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON FUNCTION learnux.fn_audit_comandos() TO learnux_admin;
GRANT ALL ON FUNCTION learnux.fn_audit_comandos() TO learnux_estudiante;


--
-- Name: FUNCTION fn_avanzar_nivel_usuario(); Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON FUNCTION learnux.fn_avanzar_nivel_usuario() TO learnux_admin;
GRANT ALL ON FUNCTION learnux.fn_avanzar_nivel_usuario() TO learnux_estudiante;


--
-- Name: FUNCTION fn_log_sesion(); Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON FUNCTION learnux.fn_log_sesion() TO learnux_admin;
GRANT ALL ON FUNCTION learnux.fn_log_sesion() TO learnux_estudiante;


--
-- Name: FUNCTION fn_normalizar_comando(); Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON FUNCTION learnux.fn_normalizar_comando() TO learnux_admin;
GRANT ALL ON FUNCTION learnux.fn_normalizar_comando() TO learnux_estudiante;


--
-- Name: FUNCTION fn_proteger_progreso(); Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON FUNCTION learnux.fn_proteger_progreso() TO learnux_admin;
GRANT ALL ON FUNCTION learnux.fn_proteger_progreso() TO learnux_estudiante;


--
-- Name: PROCEDURE sp_actualizar_progreso(IN p_id_usuario integer, IN p_id_comando integer, IN p_dominado boolean); Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON PROCEDURE learnux.sp_actualizar_progreso(IN p_id_usuario integer, IN p_id_comando integer, IN p_dominado boolean) TO learnux_admin;
GRANT ALL ON PROCEDURE learnux.sp_actualizar_progreso(IN p_id_usuario integer, IN p_id_comando integer, IN p_dominado boolean) TO learnux_estudiante;


--
-- Name: PROCEDURE sp_agregar_comando(IN p_id_categoria integer, IN p_nombre text, IN p_descripcion text, IN p_sintaxis text, IN p_dificultad learnux.dificultad_tipo); Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON PROCEDURE learnux.sp_agregar_comando(IN p_id_categoria integer, IN p_nombre text, IN p_descripcion text, IN p_sintaxis text, IN p_dificultad learnux.dificultad_tipo) TO learnux_admin;
GRANT ALL ON PROCEDURE learnux.sp_agregar_comando(IN p_id_categoria integer, IN p_nombre text, IN p_descripcion text, IN p_sintaxis text, IN p_dificultad learnux.dificultad_tipo) TO learnux_estudiante;


--
-- Name: PROCEDURE sp_registrar_intento(IN p_id_usuario integer, IN p_id_ejercicio integer, IN p_respuesta text, IN p_tiempo_seg integer); Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON PROCEDURE learnux.sp_registrar_intento(IN p_id_usuario integer, IN p_id_ejercicio integer, IN p_respuesta text, IN p_tiempo_seg integer) TO learnux_admin;
GRANT ALL ON PROCEDURE learnux.sp_registrar_intento(IN p_id_usuario integer, IN p_id_ejercicio integer, IN p_respuesta text, IN p_tiempo_seg integer) TO learnux_estudiante;


--
-- Name: PROCEDURE sp_registrar_usuario(IN p_nombre text, IN p_email text); Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON PROCEDURE learnux.sp_registrar_usuario(IN p_nombre text, IN p_email text) TO learnux_admin;
GRANT ALL ON PROCEDURE learnux.sp_registrar_usuario(IN p_nombre text, IN p_email text) TO learnux_estudiante;


--
-- Name: TABLE categorias; Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON TABLE learnux.categorias TO learnux_admin;
GRANT SELECT ON TABLE learnux.categorias TO learnux_estudiante;
GRANT SELECT ON TABLE learnux.categorias TO learnux_publico;


--
-- Name: SEQUENCE categorias_id_categoria_seq; Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON SEQUENCE learnux.categorias_id_categoria_seq TO learnux_admin;


--
-- Name: TABLE comandos; Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON TABLE learnux.comandos TO learnux_admin;
GRANT SELECT ON TABLE learnux.comandos TO learnux_estudiante;
GRANT SELECT ON TABLE learnux.comandos TO learnux_publico;


--
-- Name: TABLE comandos_audit_log; Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON TABLE learnux.comandos_audit_log TO learnux_admin;
GRANT SELECT ON TABLE learnux.comandos_audit_log TO learnux_estudiante;


--
-- Name: SEQUENCE comandos_audit_log_id_audit_seq; Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON SEQUENCE learnux.comandos_audit_log_id_audit_seq TO learnux_admin;


--
-- Name: SEQUENCE comandos_id_comando_seq; Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON SEQUENCE learnux.comandos_id_comando_seq TO learnux_admin;


--
-- Name: TABLE ejercicios; Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON TABLE learnux.ejercicios TO learnux_admin;
GRANT SELECT ON TABLE learnux.ejercicios TO learnux_estudiante;


--
-- Name: SEQUENCE ejercicios_id_ejercicio_seq; Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON SEQUENCE learnux.ejercicios_id_ejercicio_seq TO learnux_admin;


--
-- Name: TABLE intentos_ejercicio; Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON TABLE learnux.intentos_ejercicio TO learnux_admin;
GRANT SELECT,INSERT ON TABLE learnux.intentos_ejercicio TO learnux_estudiante;


--
-- Name: SEQUENCE intentos_ejercicio_id_intento_seq; Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON SEQUENCE learnux.intentos_ejercicio_id_intento_seq TO learnux_admin;
GRANT USAGE ON SEQUENCE learnux.intentos_ejercicio_id_intento_seq TO learnux_estudiante;


--
-- Name: TABLE niveles; Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON TABLE learnux.niveles TO learnux_admin;
GRANT SELECT ON TABLE learnux.niveles TO learnux_estudiante;
GRANT SELECT ON TABLE learnux.niveles TO learnux_publico;


--
-- Name: SEQUENCE niveles_id_nivel_seq; Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON SEQUENCE learnux.niveles_id_nivel_seq TO learnux_admin;


--
-- Name: TABLE opciones_comando; Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON TABLE learnux.opciones_comando TO learnux_admin;
GRANT SELECT ON TABLE learnux.opciones_comando TO learnux_estudiante;
GRANT SELECT ON TABLE learnux.opciones_comando TO learnux_publico;


--
-- Name: SEQUENCE opciones_comando_id_opcion_seq; Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON SEQUENCE learnux.opciones_comando_id_opcion_seq TO learnux_admin;


--
-- Name: TABLE progreso_nivel; Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON TABLE learnux.progreso_nivel TO learnux_admin;
GRANT SELECT,INSERT,UPDATE ON TABLE learnux.progreso_nivel TO learnux_estudiante;


--
-- Name: TABLE progreso_usuarios; Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON TABLE learnux.progreso_usuarios TO learnux_admin;
GRANT SELECT,INSERT,UPDATE ON TABLE learnux.progreso_usuarios TO learnux_estudiante;


--
-- Name: TABLE sesiones_log; Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON TABLE learnux.sesiones_log TO learnux_admin;
GRANT SELECT,INSERT ON TABLE learnux.sesiones_log TO learnux_estudiante;


--
-- Name: SEQUENCE sesiones_log_id_sesion_seq; Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON SEQUENCE learnux.sesiones_log_id_sesion_seq TO learnux_admin;
GRANT USAGE ON SEQUENCE learnux.sesiones_log_id_sesion_seq TO learnux_estudiante;


--
-- Name: TABLE usuarios; Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON TABLE learnux.usuarios TO learnux_admin;
GRANT SELECT,INSERT ON TABLE learnux.usuarios TO learnux_estudiante;


--
-- Name: SEQUENCE usuarios_id_usuario_seq; Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON SEQUENCE learnux.usuarios_id_usuario_seq TO learnux_admin;
GRANT USAGE ON SEQUENCE learnux.usuarios_id_usuario_seq TO learnux_estudiante;


--
-- Name: TABLE vista_comandos_completos; Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON TABLE learnux.vista_comandos_completos TO learnux_admin;
GRANT SELECT ON TABLE learnux.vista_comandos_completos TO learnux_estudiante;
GRANT SELECT ON TABLE learnux.vista_comandos_completos TO learnux_publico;


--
-- Name: TABLE vista_ejercicios_nivel; Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON TABLE learnux.vista_ejercicios_nivel TO learnux_admin;
GRANT SELECT ON TABLE learnux.vista_ejercicios_nivel TO learnux_estudiante;


--
-- Name: TABLE vista_progreso_usuario; Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON TABLE learnux.vista_progreso_usuario TO learnux_admin;
GRANT SELECT ON TABLE learnux.vista_progreso_usuario TO learnux_estudiante;


--
-- Name: TABLE vista_ranking; Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON TABLE learnux.vista_ranking TO learnux_admin;
GRANT SELECT ON TABLE learnux.vista_ranking TO learnux_estudiante;
GRANT SELECT ON TABLE learnux.vista_ranking TO learnux_publico;


--
-- Name: TABLE vista_resumen_progreso; Type: ACL; Schema: learnux; Owner: postgres
--

GRANT ALL ON TABLE learnux.vista_resumen_progreso TO learnux_admin;
GRANT SELECT ON TABLE learnux.vista_resumen_progreso TO learnux_estudiante;


--
-- PostgreSQL database dump complete
--

\unrestrict pp4VznQ9KJ8bdu4rYEd3kSY6ziHeK8cHPfakMkQEbpP1OhdWSALU7tJkl4bYL1k

