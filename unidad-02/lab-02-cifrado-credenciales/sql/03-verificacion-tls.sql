-- =====================================================
-- LAB-02 | Actividades 4, 5 y 6: Verificacion de TLS
-- Estudiante: Zamora Serrano Irvin Donovan
-- Fecha: 2026-10-27
-- Ejecutar por TCP (no por socket Unix), por ejemplo:
--   Get-Content sql/03-verificacion-tls.sql | docker exec -i postgres-lab psql "host=localhost port=5432 dbname=postgres user=postgres sslmode=require"
-- =====================================================

\echo '--- 11. Estado de TLS en el servidor ---'
SHOW ssl;
SHOW ssl_min_protocol_version;
SHOW port;
SHOW listen_addresses;

\echo '--- 11.1 Datos de la conexion actual ---'
SELECT inet_client_addr(), inet_client_port();

\echo '--- 11.1 La sesion actual usa TLS? ---'
SELECT ssl, version, cipher
FROM pg_stat_ssl
WHERE pid = pg_backend_pid();

SELECT ssl, version,cipher FROM pg_stat_ssl WHERE pid = pg_backend_pid();
