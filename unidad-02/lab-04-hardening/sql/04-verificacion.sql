-- =====================================================
-- LAB-04 | Actividad 16 y verificacion final
-- Estudiante: Zamora Serrano Irvin Donovan
-- Fecha: 2026-11-02
-- Ejecutar DESPUES del hardening y del reinicio del contenedor:
--   Get-Content sql/04-verificacion.sql | docker exec -i postgres-lab psql -U postgres
-- =====================================================

\echo '=== V1. Parametros despues del hardening ==='
SELECT name, setting, pending_restart FROM pg_settings
WHERE name IN ('listen_addresses', 'port', 'ssl', 'password_encryption',
               'log_connections', 'log_disconnections',
               'statement_timeout', 'idle_in_transaction_session_timeout')
ORDER BY name;

\echo '=== V2. Reglas de pg_hba.conf (la columna error debe estar vacia) ==='
SELECT line_number, type, database, user_name, address, auth_method, error
FROM pg_hba_file_rules
ORDER BY line_number;

\echo '=== V3. Roles y privilegios ==='
SELECT rolname, rolcanlogin AS login, rolsuper AS superuser,
       rolcreaterole AS createrole, rolcreatedb AS createdb, rolconnlimit AS limite
FROM pg_roles
WHERE rolname !~ '^pg_'
ORDER BY rolname;

\echo '=== V4. Pruebas de privilegios (cada prueba negativa va en su transaccion) ==='
\echo '--- app_user: PERMITIDO leer clientes_soporte ---'
SET ROLE app_user;
SELECT id, nombre FROM clientes_soporte ORDER BY id LIMIT 2;
RESET ROLE;

\echo '--- app_user: DENEGADO DELETE sobre clientes_soporte ---'
BEGIN;
SET LOCAL ROLE app_user;
DELETE FROM clientes_soporte WHERE id = 1;
ROLLBACK;

\echo '--- app_user: DENEGADO leer la tabla clientes ---'
BEGIN;
SET LOCAL ROLE app_user;
SELECT * FROM clientes;
ROLLBACK;

\echo '--- app_user: DENEGADO crear objetos (DDL) ---'
BEGIN;
SET LOCAL ROLE app_user;
CREATE TABLE prueba_ddl (id INT);
ROLLBACK;

\echo '--- consulta_user: PERMITIDO leer la vista ---'
SET ROLE consulta_user;
SELECT * FROM v_analitica_clientes LIMIT 2;
RESET ROLE;

\echo '--- consulta_user: DENEGADO escribir en clientes_soporte ---'
BEGIN;
SET LOCAL ROLE consulta_user;
UPDATE clientes_soporte SET telefono = telefono WHERE id = 1;
ROLLBACK;

\echo '=== V5. Extensiones ==='
SELECT extname, extversion FROM pg_extension ORDER BY extname;

\echo '=== V6. TLS de la sesion actual (socket Unix: ssl = f; las pruebas TCP estan en la guia) ==='
SHOW ssl;
SELECT a.pid, a.usename, a.client_addr, s.ssl, s.version, s.cipher
FROM pg_stat_ssl s
JOIN pg_stat_activity a USING (pid)
WHERE pid = pg_backend_pid();
