-- =====================================================
-- LAB-01 | Actividad 5: Anonimizacion
--          Actividad 6: Analisis del riesgo de reidentificacion
-- Estudiante: Zamora Serrano Irvin Donovan
-- Fecha: 2026-10-23
-- Requiere: 01-clasificacion.sql ejecutado (public.clientes)
-- =====================================================

-- 12.1 Generalizar la edad
SELECT CASE WHEN edad BETWEEN 18 AND 30 THEN '18-30'
            WHEN edad BETWEEN 31 AND 45 THEN '31-45'
            ELSE '46+' END AS rango_edad,
       COUNT(*) AS total
FROM clientes
GROUP BY 1
ORDER BY 1;

-- 12.2 Generalizar la region (primeros 2 digitos del codigo postal)
SELECT LEFT(codigo_postal, 2) AS region,
       COUNT(*) AS total
FROM clientes
GROUP BY 1
ORDER BY 1;

-- 12.3 Combinar atributos
SELECT CASE WHEN edad BETWEEN 18 AND 30 THEN '18-30'
            WHEN edad BETWEEN 31 AND 45 THEN '31-45'
            ELSE '46+' END AS rango_edad,
       LEFT(codigo_postal, 2) AS region,
       COUNT(*) AS total
FROM clientes
GROUP BY 1, 2
ORDER BY 1, 2;

-- 12.4 Suprimir grupos pequenos (umbral didactico k = 5)
SELECT CASE WHEN edad BETWEEN 18 AND 30 THEN '18-30'
            WHEN edad BETWEEN 31 AND 45 THEN '31-45'
            ELSE '46+' END AS rango_edad,
       LEFT(codigo_postal, 2) AS region,
       COUNT(*) AS total
FROM clientes
GROUP BY 1, 2
HAVING COUNT(*) >= 5;

-- =====================================================
-- Actividad 6 (Reto): reducir aun mas el riesgo de reidentificacion
-- Cambios: se elimina la region (cuasi-identificador), se amplian los
-- rangos de edad y los grupos menores a 5 no muestran su conteo exacto.
-- =====================================================
SELECT rango_edad,
       CASE WHEN COUNT(*) >= 5 THEN COUNT(*)::text ELSE '<5' END AS total
FROM (
    SELECT CASE WHEN edad BETWEEN 18 AND 40 THEN '18-40' ELSE '41+' END AS rango_edad
    FROM clientes
) t
GROUP BY rango_edad
ORDER BY rango_edad;