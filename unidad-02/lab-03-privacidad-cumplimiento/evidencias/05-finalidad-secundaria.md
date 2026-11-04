# Evidencia 05 — Análisis de una finalidad secundaria

**Estudiante:** Zamora Serrano Irvin Donovan | **Fecha:** 2026-10-31

## Objetivo
Analizar la propuesta de usar los datos de clientes para "enviar promociones personalizadas basadas en la edad, ciudad y comportamiento de compra".

## Procedimiento
Análisis conceptual del escenario aplicando limitación de finalidad, minimización, necesidad y control de acceso. No requiere ejecutar comandos.

## Resultado

**1. ¿Tener los datos significa poder usarlos para cualquier finalidad?**
No. Los datos se recopilaron para finalidades determinadas (atención, facturación). Un uso nuevo debe ser compatible con esas finalidades o contar con una base jurídica (por ejemplo, información en el aviso de privacidad y, cuando corresponda, consentimiento). Esa determinación la hacen las áreas jurídica y de privacidad, no el DBA.

**2. Preguntas que debería hacer la organización antes de implementarlo**
- ¿La finalidad promocional está informada en el aviso de privacidad?
- ¿Es compatible con la finalidad original o requiere consentimiento?
- ¿Existe un mecanismo para que el titular se oponga (dejar de recibir promociones)?
- ¿Qué datos exactos hacen falta y por cuánto tiempo?
- ¿Quién es el responsable del tratamiento y quién autoriza el uso?
- ¿Se compartirán datos con terceros (proveedor de correo, publicidad)?
- ¿Cómo se registrará y auditará el uso?

**3. Datos realmente necesarios**
- Necesarios: un canal de contacto (correo o teléfono, según el medio), rango de edad, ciudad y el dato de comportamiento de compra (que hoy no está en `clientes` y requeriría su propia justificación).
- No necesarios: RFC, código postal completo, fecha de alta exacta y, en general, edad exacta.

**4. ¿Marketing necesita acceso directo a `clientes`?**
No. Debería recibir solo una vista o tabla preparada con las columnas indispensables y únicamente de clientes que no se hayan opuesto.

**5. Controles técnicos para limitar la información entregada**
- Vista específica para marketing con columnas mínimas y rango de edad en lugar de edad exacta.
- Rol `marketing` con `SELECT` solo sobre esa vista y sin permisos sobre `clientes`.
- Marca de preferencias (por ejemplo, `acepta_promociones` con fecha) para excluir a quienes se opongan.
- Registro de auditoría de consultas y de exportaciones; entrega controlada a proveedores externos.

Propuesta conceptual (no ejecutada, porque la tabla de preferencias no existe en el laboratorio):
```sql
CREATE VIEW v_marketing_clientes AS
SELECT c.id, c.nombre, c.correo, c.ciudad,
       CASE WHEN c.edad BETWEEN 18 AND 29 THEN '18-29'
            WHEN c.edad BETWEEN 30 AND 44 THEN '30-44'
            ELSE '45+' END AS rango_edad
FROM clientes c
JOIN preferencias_cliente p ON p.cliente_id = c.id
WHERE p.acepta_promociones = TRUE;
```

## Análisis
La disponibilidad técnica de un dato no equivale a autorización para usarlo. Una nueva finalidad exige justificar el tratamiento, limitar los datos a los necesarios y permitir la oposición del titular.

## Conclusión
La propuesta puede evaluarse, pero solo después de aclarar la base jurídica y bajo controles técnicos (vista mínima, rol separado, exclusión de opositores y auditoría).
