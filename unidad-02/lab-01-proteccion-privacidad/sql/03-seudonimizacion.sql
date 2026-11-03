-- =====================================================
-- LAB-01 | Actividad 3: Seudonimizacion
--          Actividad 4: Separacion de funciones
-- Estudiante: Zamora Serrano Irvin Donovan
-- Fecha: 2026-10-23
-- Requiere: 01-clasificacion.sql ejecutado (public.clientes)
-- =====================================================

-- 0. Reinicio para poder re-ejecutar el script
DROP SCHEMA IF EXISTS analitica CASCADE;
DROP SCHEMA IF EXISTS pii CASCADE;
DROP ROLE IF EXISTS analista;

-- 9.1 Crear los esquemas
CREATE SCHEMA pii;
CREATE SCHEMA analitica;

-- 9.2 Crear la tabla de correspondencia
CREATE TABLE pii.mapa_cliente (
    token UUID PRIMARY KEY,
    cliente_id BIGINT UNIQUE REFERENCES public.clientes(id)
);

-- 9.3 Generar los tokens
CREATE EXTENSION IF NOT EXISTS pgcrypto;

INSERT INTO pii.mapa_cliente (token, cliente_id)
SELECT gen_random_uuid(), id FROM clientes;

-- Verificar
SELECT * FROM pii.mapa_cliente;

-- 10. Conjunto de datos para analitica
CREATE TABLE analitica.clientes AS
SELECT
    m.token AS cliente_token,
    c.edad,
    c.ciudad,
    c.codigo_postal,
    c.fecha_alta
FROM pii.mapa_cliente m
JOIN clientes c ON c.id = m.cliente_id;

-- Verificar
SELECT * FROM analitica.clientes;

-- 11. Rol analista
CREATE ROLE analista NOLOGIN;

GRANT USAGE ON SCHEMA analitica TO analista;
GRANT SELECT ON analitica.clientes TO analista;

-- Sin acceso a pii.mapa_cliente ni a public.clientes (no se otorga nada)

-- 11.1 Verificar los permisos COMO analista
SET ROLE analista;

SELECT * FROM analitica.clientes;   -- permitido
SELECT * FROM pii.mapa_cliente;     -- debe dar permission denied
SELECT * FROM public.clientes;      -- debe dar permission denied

RESET ROLE;