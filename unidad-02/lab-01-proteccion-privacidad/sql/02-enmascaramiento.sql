-- ==========================================
-- ACTIVIDAD 2: ENMASCARAMIENTO (MASKING)
-- Estudiante: Zamora Serrano Irvin Donovan
-- Fecha: 2026-10-23
-- Requiere: 01-clasificacion.sql ejecutado (public.clientes)
-- ==========================================

-- 1. Crear el rol de soporte sin inicio de sesión
CREATE ROLE soporte NOLOGIN;

-- 2. Crear la vista de acceso restringido con datos enmascarados
CREATE VIEW v_clientes_soporte AS 
SELECT 
    id, 
    nombre, 
    CONCAT(LEFT(correo, 2), '*****', SUBSTRING(correo FROM POSITION('@' IN correo))) AS correo, 
    CONCAT('******', RIGHT(telefono, 4)) AS telefono, 
    CONCAT('*********', RIGHT(rfc, 4)) AS rfc 
FROM clientes;

-- 3. Otorgar permisos sobre la vista al rol soporte
GRANT USAGE ON SCHEMA public TO soporte;
GRANT SELECT ON v_clientes_soporte TO soporte;

-- 4. Revocar el acceso directo a la tabla original clientes
REVOKE ALL ON clientes FROM soporte;

-- 5. Consulta para verificar el resultado enmascarado
SELECT * FROM v_clientes_soporte;