-- =====================================================
-- LAB-04 | Actividades 3, 7 y 11: Parametros de configuracion
-- Estudiante: Zamora Serrano Irvin Donovan
-- Fecha: 2026-11-02
-- Los cambios quedan en postgresql.auto.conf (ALTER SYSTEM).
-- listen_addresses requiere REINICIAR el contenedor: docker restart postgres-lab
-- Reversion de cualquiera: ALTER SYSTEM RESET <parametro>; SELECT pg_reload_conf();
-- =====================================================

\echo '--- ANTES ---'
SELECT name, setting FROM pg_settings
WHERE name IN ('listen_addresses', 'log_connections', 'log_disconnections',
               'statement_timeout', 'idle_in_transaction_session_timeout',
               'password_encryption')
ORDER BY name;

-- Auditoria de conexiones
ALTER SYSTEM SET log_connections = 'on';
ALTER SYSTEM SET log_disconnections = 'on';

-- Disponibilidad: evitar sesiones y sentencias indefinidas
ALTER SYSTEM SET statement_timeout = '5min';
ALTER SYSTEM SET idle_in_transaction_session_timeout = '60s';

-- Autenticacion: almacenar contrasenas nuevas con SCRAM
ALTER SYSTEM SET password_encryption = 'scram-sha-256';

-- Red: escuchar solo en la interfaz local (requiere reinicio)
ALTER SYSTEM SET listen_addresses = 'localhost';

SELECT pg_reload_conf();

\echo '--- DESPUES (listen_addresses queda pendiente de reinicio) ---'
SELECT name, setting, pending_restart FROM pg_settings
WHERE name IN ('listen_addresses', 'log_connections', 'log_disconnections',
               'statement_timeout', 'idle_in_transaction_session_timeout',
               'password_encryption')
ORDER BY name;
