-- =====================================================
-- LAB-04 | Actividades 8 y 9: Separacion de cuentas (DBA / APP / CONSULTA)
-- Estudiante: Zamora Serrano Irvin Donovan
-- Fecha: 2026-11-02
-- Requiere: tablas/vistas del LAB-03 (clientes_soporte y v_analitica_clientes)
-- NOTA: NO se escriben contrasenas en este script. Se asignan despues,
--       de forma interactiva, con \password (ver configuracion/guia-ejecucion.md).
-- =====================================================

-- Cuentas con LOGIN (se crean solo si no existen)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_user') THEN
        CREATE ROLE app_user LOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'consulta_user') THEN
        CREATE ROLE consulta_user LOGIN;
    END IF;
END
$$;

-- Atributos minimos (sin privilegios administrativos) y limite de conexiones
ALTER ROLE app_user      NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS CONNECTION LIMIT 10;
ALTER ROLE consulta_user NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS CONNECTION LIMIT 5;

-- Limite de duracion de sentencias por rol
ALTER ROLE app_user      SET statement_timeout = '30s';
ALTER ROLE consulta_user SET statement_timeout = '30s';

-- Conexion a la base: solo las cuentas autorizadas
SELECT current_database() AS db \gset
REVOKE CONNECT ON DATABASE :"db" FROM PUBLIC;
GRANT  CONNECT ON DATABASE :"db" TO app_user, consulta_user;
-- Reversion (si hiciera falta): GRANT CONNECT ON DATABASE :"db" TO PUBLIC;

-- Privilegios minimos por funcion
GRANT USAGE ON SCHEMA public TO app_user, consulta_user;
GRANT SELECT, INSERT, UPDATE ON clientes_soporte TO app_user;     -- sin DELETE ni DDL
GRANT SELECT ON v_analitica_clientes TO consulta_user;            -- solo lectura de la vista

\echo '--- Roles resultantes ---'
SELECT rolname, rolcanlogin AS login, rolsuper AS superuser,
       rolcreaterole AS createrole, rolcreatedb AS createdb, rolconnlimit AS limite_conexiones
FROM pg_roles
WHERE rolname IN ('postgres', 'app_user', 'consulta_user')
ORDER BY rolname;
