# Evidencia 14 — Evaluación integral

**Estudiante:** Zamora Serrano Irvin Donovan | **Fecha:** 2026-10-31

## Objetivo
Identificar al menos 10 problemas de privacidad y gobierno en un escenario de 50,000 clientes, con su principio afectado, riesgo y control propuesto.

## Procedimiento
Análisis del escenario: analítica consulta directamente `clientes`, la tabla contiene nombre, correo, teléfono, RFC, edad, ciudad y CP, los datos se conservan hace 12 años sin política de retención, los desarrolladores reciben copias reales, marketing usa los correos para campañas y no existe documentación de finalidades.

## Resultado

| # | Problema | Principio afectado | Riesgo | Control propuesto |
|---|---|---|---|---|
| 1 | Todos en analítica consultan directamente `clientes` | Mínimo privilegio | Acceso a datos personales que no necesitan | Vista agregada y rol de analítica sin acceso a la tabla |
| 2 | Analítica ve nombre, correo, teléfono y RFC aunque solo hace estadísticas | Minimización | Exposición innecesaria de identificadores | Entregar solo rangos de edad, ciudad y región |
| 3 | Datos conservados desde hace 12 años | Limitación de conservación | Mayor impacto de una filtración y datos obsoletos | Política de retención y eliminación/anonimización al vencer |
| 4 | No existe política de retención documentada | Gobierno / responsabilidad | Conservación sin justificación | Documentar periodos por dato con aprobación del responsable |
| 5 | Desarrolladores reciben copias completas de la base | Mínimo privilegio y confidencialidad | Fuga de datos reales fuera de producción | Entregar datos enmascarados o sintéticos |
| 6 | Copias de desarrollo con información real | Seguridad y ciclo de vida | Ambientes con menos controles que producción | Enmascaramiento estático y borrado de copias |
| 7 | Marketing usa los correos para campañas | Limitación de finalidad | Uso incompatible, falta de base jurídica u oposición | Validar base jurídica, vista y rol para marketing, lista de oposición |
| 8 | No hay documentación de finalidad por dato | Transparencia / responsabilidad | No se puede justificar el tratamiento | Inventario y catálogo de datos con finalidad |
| 9 | No hay propietarios de datos definidos | Gobierno de datos | Nadie decide ni responde por el uso | Asignar propietarios y custodio (matriz de gobierno) |
| 10 | RFC accesible a quienes no facturan | Minimización / confidencialidad | Exposición de un dato fiscal | Restringir RFC a Facturación y cifrarlo |
| 11 | Difícil atender derechos ARCO (no se sabe dónde están los datos ni sus copias) | Derechos del titular | Respuesta incompleta o tardía | Mapa del ciclo de vida y procedimiento ARCO |
| 12 | Mezcla de uso operativo y analítico en la misma tabla | Separación por finalidad | Cualquier uso accede a todo | Separar por finalidad: operación, analítica y auditoría |
| 13 | No se menciona trazabilidad de consultas y cambios | Rendición de cuentas | No se detectan accesos indebidos | Registro de auditoría (tema de la Unidad III) |

## Análisis
Los problemas se agrupan en acceso excesivo (1, 2, 5, 6, 10), conservación (3, 4), uso por finalidad (7, 8, 12) y gobierno (4, 8, 9, 11, 13). Corregir solo uno no basta: se necesitan controles técnicos y administrativos combinados.

## Conclusión
Una base de datos con permisos y cifrado puede seguir incumpliendo principios de privacidad si no hay finalidad, retención, responsables y controles sobre las copias.
