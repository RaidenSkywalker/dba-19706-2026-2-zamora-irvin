-- =====================================================
-- LAB-03 | Actividad 4: Control de acceso relacionado con la finalidad
-- Estudiante: Zamora Serrano Irvin Donovan
-- Fecha: 2026-10-31
-- Requiere: public.clientes (LAB-01)
-- NOTA: el rol analista ya pudo crearse en el LAB-01; por eso se crea
--       solo si no existe (el script se puede ejecutar en cualquier caso).
-- =====================================================

-- Rol (se reutiliza si ya existe del LAB-01)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'analista') THEN
        CREATE ROLE analista NOLOGIN;
    END IF;
END
$$;

-- Vista con la informacion preparada para analitica (sin identificadores directos)
DROP VIEW IF EXISTS v_analitica_clientes;
CREATE VIEW v_analitica_clientes AS
SELECT ciudad,
       CASE
           WHEN edad < 18 THEN 'Menor de 18'
           WHEN edad BETWEEN 18 AND 29 THEN '18-29'
           WHEN edad BETWEEN 30 AND 44 THEN '30-44'
           WHEN edad BETWEEN 45 AND 59 THEN '45-59'
           ELSE '60 o mas'
       END AS rango_edad
FROM clientes;

-- Permisos: solo la vista, nunca la tabla original
GRANT USAGE ON SCHEMA public TO analista;
GRANT SELECT ON v_analitica_clientes TO analista;
REVOKE ALL ON clientes FROM analista;

\echo '--- Privilegios del rol analista ---'
SELECT grantee, table_schema, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE grantee = 'analista'
ORDER BY table_schema, table_name;

-- Verificacion COMO analista
SET ROLE analista;

\echo '--- PERMITIDO: consulta a la vista ---'
SELECT * FROM v_analitica_clientes;

\echo '--- DENEGADO: consulta directa a clientes ---'
SELECT * FROM clientes;

\echo '--- DENEGADO: intento de obtener nombre, correo y rfc ---'
SELECT nombre, correo, rfc FROM clientes;

\echo '--- La vista no contiene la columna nombre ---'
SELECT nombre FROM v_analitica_clientes;

RESET ROLE;
