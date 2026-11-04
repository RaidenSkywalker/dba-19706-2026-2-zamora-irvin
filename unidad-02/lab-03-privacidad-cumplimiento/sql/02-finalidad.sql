-- =====================================================
-- LAB-03 | Actividades 3, 6, 7 y 8: Finalidad, ARCO y ciclo de vida
-- Estudiante: Zamora Serrano Irvin Donovan
-- Fecha: 2026-10-31
-- Requiere: public.clientes (LAB-01), clientes_soporte (01-minimizacion.sql)
--           y, para algunas consultas, pii.mapa_cliente y analitica.clientes (LAB-01)
-- NOTA: no se ejecuta ningun DELETE. El UPDATE de la Actividad 7 se
--       revierte con ROLLBACK para no alterar los datos del LAB-01.
-- =====================================================

-- ---------- Actividad 3: informacion agregada para analitica ----------
\echo '--- 3.1 Clientes por ciudad ---'
SELECT ciudad, COUNT(*) AS cantidad_clientes
FROM clientes
GROUP BY ciudad
ORDER BY cantidad_clientes DESC;

\echo '--- 3.2 Rangos de edad ---'
SELECT CASE
           WHEN edad < 18 THEN 'Menor de 18'
           WHEN edad BETWEEN 18 AND 29 THEN '18-29'
           WHEN edad BETWEEN 30 AND 44 THEN '30-44'
           WHEN edad BETWEEN 45 AND 59 THEN '45-59'
           ELSE '60 o mas'
       END AS rango_edad,
       COUNT(*) AS cantidad
FROM clientes
GROUP BY 1
ORDER BY 1;

\echo '--- 3.3 Region del codigo postal ---'
SELECT LEFT(codigo_postal, 2) AS region, COUNT(*) AS cantidad
FROM clientes
GROUP BY 1
ORDER BY 1;

\echo '--- 3.4 Combinacion ciudad + rango de edad + region (riesgo de grupos pequenos) ---'
SELECT ciudad,
       CASE
           WHEN edad < 18 THEN 'Menor de 18'
           WHEN edad BETWEEN 18 AND 29 THEN '18-29'
           WHEN edad BETWEEN 30 AND 44 THEN '30-44'
           WHEN edad BETWEEN 45 AND 59 THEN '45-59'
           ELSE '60 o mas'
       END AS rango_edad,
       LEFT(codigo_postal, 2) AS region,
       COUNT(*) AS cantidad
FROM clientes
GROUP BY 1, 2, 3
ORDER BY cantidad DESC, 1;

-- ---------- Actividad 6: derecho de acceso ----------
\echo '--- 6.1 Datos del titular en la tabla principal ---'
SELECT id, nombre, correo, telefono, rfc, edad, ciudad, codigo_postal, fecha_alta
FROM clientes
WHERE correo = 'ana.lopez@example.test';

\echo '--- 6.1 Copias derivadas del mismo titular: clientes_soporte ---'
SELECT id, nombre, correo, telefono
FROM clientes_soporte
WHERE correo = 'ana.lopez@example.test';

\echo '--- 6.1 Copias derivadas del mismo titular: analitica (via token) ---'
SELECT m.token, a.edad, a.ciudad, a.codigo_postal, a.fecha_alta
FROM clientes c
JOIN pii.mapa_cliente m ON m.cliente_id = c.id
JOIN analitica.clientes a ON a.cliente_token = m.token
WHERE c.correo = 'ana.lopez@example.test';

-- ---------- Actividad 7: derecho de rectificacion (con ROLLBACK) ----------
BEGIN;
UPDATE clientes SET correo = 'nuevo-correo@example.test' WHERE id = 1;

\echo '--- 7. Tabla principal despues del UPDATE ---'
SELECT id, nombre, correo FROM clientes WHERE id = 1;

\echo '--- 7. La copia clientes_soporte conserva el correo ANTERIOR (desincronizada) ---'
SELECT id, nombre, correo FROM clientes_soporte WHERE id = 1;
ROLLBACK;

\echo '--- 7. Despues del ROLLBACK el dato original queda restaurado ---'
SELECT id, nombre, correo FROM clientes WHERE id = 1;

-- ---------- Actividad 8: ciclo de vida (solo lectura, SIN DELETE) ----------
\echo '--- 8. Llaves foraneas que dependen de clientes ---'
SELECT conrelid::regclass AS tabla_dependiente,
       conname AS restriccion,
       pg_get_constraintdef(oid) AS definicion
FROM pg_constraint
WHERE confrelid = 'public.clientes'::regclass;

\echo '--- 8. Vistas que dependen de clientes ---'
SELECT DISTINCT v.oid::regclass AS vista
FROM pg_depend d
JOIN pg_rewrite r ON r.oid = d.objid
JOIN pg_class v ON v.oid = r.ev_class
WHERE d.refobjid = 'public.clientes'::regclass
  AND v.relkind = 'v';

\echo '--- 8. Tablas y vistas con columnas de datos personales (posibles copias) ---'
SELECT table_schema, table_name, column_name
FROM information_schema.columns
WHERE column_name IN ('cliente_id', 'nombre', 'correo', 'telefono', 'rfc')
  AND table_schema NOT IN ('pg_catalog', 'information_schema')
ORDER BY 1, 2, 3;
