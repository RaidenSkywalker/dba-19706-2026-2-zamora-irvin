-- =====================================================
-- LAB-02 | Actividad 2: Cifrado de informacion sensible (RFC)
-- Estudiante: Zamora Serrano Irvin Donovan
-- Fecha: 2026-10-27
-- Requiere: extension pgcrypto (se crea en 01-credenciales.sql)
-- NOTA: la clave 'CLAVE-DE-PRUEBA' es ficticia, solo de laboratorio.
-- =====================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 8.1 Tabla de demostracion
DROP TABLE IF EXISTS clientes_protegidos;
CREATE TABLE clientes_protegidos (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    rfc_cifrado BYTEA NOT NULL
);

INSERT INTO clientes_protegidos (nombre, rfc_cifrado)
VALUES ('Ana Lopez', pgp_sym_encrypt('LOPA900101ABC', 'CLAVE-DE-PRUEBA'));

\echo '--- 8.1 El RFC ya no aparece directamente (bytea cifrado) ---'
SELECT * FROM clientes_protegidos;

-- 8.2 Recuperar el dato con la clave correcta
\echo '--- 8.2 Recuperacion con la clave correcta ---'
SELECT id, nombre, pgp_sym_decrypt(rfc_cifrado, 'CLAVE-DE-PRUEBA') AS rfc
FROM clientes_protegidos;

-- Pregunta: que ocurre con una clave incorrecta (se espera un ERROR)
\echo '--- Clave INCORRECTA (error esperado) ---'
SELECT id, nombre, pgp_sym_decrypt(rfc_cifrado, 'CLAVE-INCORRECTA') AS rfc
FROM clientes_protegidos;
