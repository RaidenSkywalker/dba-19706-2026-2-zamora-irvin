-- =====================================================
-- LAB-04 | Actividades 1, 2, 3, 4, 7, 8, 10, 11 y 15: Inspeccion (SOLO LECTURA)
-- Estudiante: Zamora Serrano Irvin Donovan
-- Fecha: 2026-11-02
-- Ejecutar ANTES del hardening (estado inicial) y repetir despues (04-verificacion.sql)
--   Get-Content sql/01-inspeccion.sql | docker exec -i postgres-lab psql -U postgres
-- =====================================================

\echo '=== A1. Superficie de ataque ==='
SELECT version();
SHOW port;
SHOW listen_addresses;
SHOW ssl;
SHOW password_encryption;

\echo '--- A1. Conexiones actuales ---'
SELECT pid, usename, datname, client_addr, client_port, application_name
FROM pg_stat_activity
ORDER BY pid;

\echo '=== A2. Archivos de configuracion ==='
SHOW config_file;
SHOW hba_file;
SHOW ident_file;
SHOW data_directory;
SHOW log_directory;
SHOW log_connections;
SHOW log_disconnections;

\echo '=== A3. listen_addresses (origen del valor y si requiere reinicio) ==='
SELECT name, setting, source, pending_restart
FROM pg_settings
WHERE name IN ('listen_addresses', 'port');

\echo '=== A4. Reglas de pg_hba.conf ==='
SELECT line_number, type, database, user_name, address, auth_method, error
FROM pg_hba_file_rules
ORDER BY line_number;

\echo '=== A7. Autenticacion: tipo de hash almacenado por rol (sin mostrar el hash) ==='
SHOW password_encryption;
SELECT rolname,
       CASE WHEN rolpassword IS NULL THEN 'sin contrasena'
            WHEN rolpassword LIKE 'SCRAM-SHA-256$%' THEN 'SCRAM-SHA-256'
            WHEN rolpassword LIKE 'md5%' THEN 'md5 (heredado)'
            ELSE 'otro' END AS mecanismo
FROM pg_authid
WHERE rolcanlogin
ORDER BY rolname;

\echo '=== A8. Roles y privilegios ==='
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin
FROM pg_roles
WHERE rolname !~ '^pg_'
ORDER BY rolname;

\echo '=== A10. Extensiones ==='
SELECT extname, extversion FROM pg_extension ORDER BY extname;

\echo '=== A11. Parametros de conexion ==='
SHOW max_connections;
SHOW superuser_reserved_connections;
SHOW statement_timeout;
SHOW idle_in_transaction_session_timeout;

\echo '=== A15. TLS ==='
SHOW ssl;
SHOW ssl_min_protocol_version;
SELECT a.pid, a.usename, a.client_addr, s.ssl, s.version, s.cipher
FROM pg_stat_ssl s
JOIN pg_stat_activity a USING (pid)
WHERE pid = pg_backend_pid();
