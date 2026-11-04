# Evidencia 10 — Política de retención

**Estudiante:** Zamora Serrano Irvin Donovan | **Fecha:** 2026-10-31

## Objetivo
Analizar la propuesta "conservar todos los datos de clientes indefinidamente porque podrían ser útiles en el futuro".

## Procedimiento
Análisis conceptual según minimización, finalidad y ciclo de vida. Como referencia técnica se reutiliza la consulta de retención del LAB-01 (`fecha_alta < CURRENT_DATE - INTERVAL '5 years'`), sin eliminar información.

## Resultado

**1. ¿Es compatible con la minimización?**
No. La minimización exige conservar solo lo necesario para una finalidad determinada. "Podría servir en el futuro" no es una finalidad concreta.

**2. Riesgos de conservar información innecesaria**
- Mayor impacto en caso de filtración o incidente.
- Más datos que proteger, respaldar y auditar (costo y superficie de ataque).
- Uso posterior para finalidades incompatibles con las informadas.
- Datos desactualizados o inexactos.
- Mayor dificultad para atender solicitudes de acceso, rectificación, cancelación u oposición.
- Posible incumplimiento de obligaciones de privacidad.

**3. ¿Qué debe determinar la organización antes de fijar un periodo?**
- La finalidad de cada dato.
- Las obligaciones legales, fiscales, contractuales y regulatorias aplicables (a confirmar con jurídico y contabilidad).
- Las necesidades operativas y de auditoría.
- El riesgo de conservarlo.
- El responsable que aprueba el periodo y las excepciones.

**4. ¿Qué debería documentarse para justificar el periodo?**
Finalidad, fundamento (obligación legal o necesidad), periodo y su razón, responsable aprobador, qué ocurre al vencer (eliminar o anonimizar), tratamiento de respaldos y copias, excepciones, fecha de revisión y evidencia de aplicación.

**Propuesta de trabajo (a validar por el responsable de datos y jurídico):**

| Dato | Criterio de retención | Acción al vencer |
|---|---|---|
| nombre, correo, teléfono | Durante la relación comercial + plazo definido por jurídico | Eliminar |
| rfc | Plazo fiscal/contable que determine el área responsable | Eliminar |
| edad, ciudad, código postal | Mientras exista la finalidad estadística | Anonimizar o agregar |
| fecha_alta | Igual que el registro | Eliminar con el registro |

## Análisis
La conservación indefinida convierte la base en un pasivo de riesgo. La retención forma parte del ciclo de vida, y el DBA implementa técnicamente el periodo que otras áreas deciden.

## Conclusión
La política debe ser explícita, justificada por finalidad y obligación, y revisable. No se ejecutó ningún `DELETE`.
