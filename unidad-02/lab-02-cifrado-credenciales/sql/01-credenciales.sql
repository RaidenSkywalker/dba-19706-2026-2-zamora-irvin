-- =====================================================
-- LAB-02 | Actividad 1: Proteccion de credenciales
-- Estudiante: Zamora Serrano Irvin Donovan
-- Fecha: 2026-10-27
-- Requiere: PostgreSQL 16 (contenedor postgres-lab)
-- NOTA: todos los valores son ficticios (solo laboratorio).
-- '\echo' se utiliza para imprimir mensajes de texto directamente en la terminal durante la 
--    ejecución de las consultas.
-- =====================================================

-- 6. Preparacion: extension pgcrypto
CREATE EXTENSION IF NOT EXISTS pgcrypto;
\echo '--- pgcrypto disponible ---'
SELECT extname FROM pg_extension WHERE extname = 'pgcrypto';

-- 7.1 MALA PRACTICA: contrasena en texto claro
DROP TABLE IF EXISTS usuarios_insegura;
CREATE TABLE usuarios_insegura (
    id BIGSERIAL PRIMARY KEY,
    usuario VARCHAR(50) NOT NULL,
    password VARCHAR(100) NOT NULL
);
INSERT INTO usuarios_insegura (usuario, password) VALUES ('juan', 'Password123');
\echo '--- 7.1 Tabla insegura: la contrasena se ve directamente ---'
SELECT * FROM usuarios_insegura;

-- 7.3 Generar una representacion no reversible (dos ejecuciones)
\echo '--- 7.3 Primer hash de la misma contrasena ---'
SELECT crypt('Password123', gen_salt('bf')) AS hash_1;
\echo '--- 7.3 Segundo hash de la misma contrasena (debe ser distinto) ---'
SELECT crypt('Password123', gen_salt('bf')) AS hash_2;

-- 7.4 Tabla para credenciales protegidas
DROP TABLE IF EXISTS usuarios_segura;
CREATE TABLE usuarios_segura (
    id BIGSERIAL PRIMARY KEY,
    usuario VARCHAR(50) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL
);
INSERT INTO usuarios_segura (usuario, password_hash)
VALUES ('juan', crypt('Password123', gen_salt('bf')));
\echo '--- 7.4 Tabla segura: ya no aparece la contrasena original ---'
SELECT * FROM usuarios_segura;

-- 7.5 Verificar una contrasena
\echo '--- 7.5 Contrasena CORRECTA ---'
SELECT usuario, password_hash = crypt('Password123', password_hash) AS contrasena_correcta
FROM usuarios_segura WHERE usuario = 'juan';
\echo '--- 7.5 Contrasena INCORRECTA ---'
SELECT usuario, password_hash = crypt('OtraPassword', password_hash) AS contrasena_correcta
FROM usuarios_segura WHERE usuario = 'juan';
