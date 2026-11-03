-- =====================================================
-- LAB-01 | Actividad 7: Retencion de datos
-- Estudiante: Zamora Serrano Irvin Donovan
-- Fecha: 2026-10-23
-- Requiere: 01-clasificacion.sql ejecutado (public.clientes)
-- NOTA: este script NO elimina informacion (no hay DELETE).
-- =====================================================

-- Registros que superan el periodo de retencion (5 anos)
SELECT * FROM clientes
WHERE fecha_alta < CURRENT_DATE - INTERVAL '5 years';

-- Resumen: cuantos registros exceden el periodo y cuantos hay en total
SELECT COUNT(*) FILTER (WHERE fecha_alta < CURRENT_DATE - INTERVAL '5 years') AS fuera_de_retencion,
       COUNT(*) AS total
FROM clientes;

-- Simulacion didactica: si el periodo fuera de 0 dias, ¿que registros se afectarian?
-- (solo para demostrar que la consulta identifica registros; no modifica datos)
SELECT id, nombre, fecha_alta
FROM clientes
WHERE fecha_alta <= CURRENT_DATE - INTERVAL '0 days';