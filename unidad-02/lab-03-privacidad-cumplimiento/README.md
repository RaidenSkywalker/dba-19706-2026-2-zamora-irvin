# LAB-03 — Privacidad, cumplimiento y gobierno de los datos

**Estudiante:** Zamora Serrano Irvin Donovan
**Materia:** Gestión de Seguridad y Desempeño de Bases de Datos — Unidad II, tema 2.5
**Motor:** PostgreSQL 16 en Docker (contenedor `postgres-lab`)
**Fecha:** 2026-10-31

## Contenido

| Ruta | Descripción |
|---|---|
| `sql/01-minimizacion.sql` | Actividad 2: tabla `clientes_soporte` con datos mínimos |
| `sql/02-finalidad.sql` | Actividades 3, 6, 7 y 8: agregación, ARCO y ciclo de vida |
| `sql/03-control-acceso.sql` | Actividad 4: rol `analista` y vista `v_analitica_clientes` |
| `evidencias/` | 01 inventario, 05 finalidad secundaria, 08 ciclo de vida, 10 retención, 11 gobierno, 12 privacidad por diseño, 14 evaluación integral, 15 arquitectura |

## Cómo ejecutar
Requiere la base del LAB-01 (`clientes`, `pii.mapa_cliente`, `analitica.clientes`). Desde esta carpeta:
```powershell
Get-Content sql/01-minimizacion.sql | docker exec -i postgres-lab psql -U postgres
Get-Content sql/02-finalidad.sql | docker exec -i postgres-lab psql -U postgres
Get-Content sql/03-control-acceso.sql | docker exec -i postgres-lab psql -U postgres
```
El `UPDATE` de la Actividad 7 se ejecuta dentro de una transacción y se revierte con `ROLLBACK`; no se ejecuta ningún `DELETE`.

## 1. Introducción
Una base de datos puede estar bien configurada y aun así incumplir principios de privacidad: recolectar datos innecesarios, usarlos para otra finalidad, conservarlos sin límite o dar acceso a quien no lo necesita. Este laboratorio traduce esos principios a decisiones concretas en PostgreSQL para Comercializadora Norte.

## 2. Inventario de datos
Todos los campos de `clientes` son datos personales, directos (nombre, correo, teléfono, RFC) o indirectos y cuasi-identificadores (id, edad, ciudad, código postal, fecha de alta). La matriz completa con justificación está en `evidencias/01-inventario-datos.md`.

## 3. Finalidades
- **Atención al cliente:** nombre, correo, teléfono.
- **Facturación:** nombre, RFC y los datos fiscales necesarios.
- **Analítica:** ciudad, rango de edad y región del código postal, sin identificar individuos.
- **DBA:** administración técnica, sin que ello autorice usar los datos para cualquier finalidad.

**¿Por qué la información agregada es más apropiada para analítica que la tabla completa?** Porque entrega lo necesario para estadísticas sin exponer identificadores directos y reduce el riesgo de uso indebido y de reidentificación.

## 4. Minimización
Soporte pidió una tabla con todos los campos. Análisis:
- No todos son necesarios: soporte necesita identificar y contactar al cliente (id, nombre, correo, teléfono).
- El RFC es un dato fiscal para facturación, no para soporte.
- La edad y el código postal no sirven para atender solicitudes.
- Principio aplicado: **minimización** (junto con necesidad y limitación de finalidad).

Se creó `clientes_soporte` solo con `id`, `nombre`, `correo` y `telefono` (`sql/01-minimizacion.sql`). Se eliminaron del alcance de soporte: `rfc`, `edad`, `ciudad`, `codigo_postal` y `fecha_alta`.

## 5. Control de acceso
Se creó la vista `v_analitica_clientes` (solo `ciudad` y `rango_edad`) y se otorgó al rol `analista` únicamente `SELECT` sobre ella, sin acceso a `clientes` (`sql/03-control-acceso.sql`).

- **¿Qué puede consultar el rol?** Ciudad y rango de edad de la vista (y lo que ya tenía del LAB-01 en `analitica.clientes`).
- **¿Puede consultar `clientes`?** No: `permission denied`.
- **¿Puede obtener nombre, correo o RFC?** No: no existen en la vista ni tiene acceso a la tabla.
- **Principio de privacidad:** minimización y limitación de finalidad.
- **Principio de seguridad:** mínimo privilegio.
- **Riesgo residual:** la vista entrega un renglón por cliente; con pocos registros, algunos grupos pueden ser únicos (ver LAB-01, anonimización).

**Evidencia (capturas)**

![Rol analista](evidencias/img/03-control-acceso/rol-analista.png)
![Privilegios concedidos](evidencias/img/03-control-acceso/permisos.png)
![Consulta permitida a la vista v_analitica_clientes](evidencias/img/03-control-acceso/v_analitica.png)
![Consulta denegada a clientes: permission denied](evidencias/img/03-control-acceso/permiso-denegado-analista.png)
![Verificacion de permisos](evidencias/img/03-control-acceso/verificar-permisos.png)

**Controles técnicos y administrativos (Actividad 13)**

| Medida | Técnico | Administrativo | Justificación |
|---|---|---|---|
| Crear roles de PostgreSQL | ✔ | | Se implementa en la base; decidir quién necesita un rol es administrativo |
| Política de retención | | ✔ | Es una regla organizacional; su ejecución puede automatizarse técnicamente |
| Cifrado de datos | ✔ | | Control técnico; la gestión de claves requiere procedimientos administrativos |
| Procedimiento para solicitudes ARCO | | ✔ | Define responsables y pasos; la búsqueda y modificación son técnicas |
| Vista con información limitada | ✔ | | Limita lo que se muestra; qué mostrar lo decide el propietario de datos |
| Clasificación de información | | ✔ | Es una decisión organizacional; puede reflejarse técnicamente (por ejemplo `COMMENT ON`) |
| Registro de auditoría | ✔ | | Se configura técnicamente; su revisión periódica es administrativa |
| Política de control de acceso | | ✔ | Documento que se aterriza con roles y `GRANT` |

## 6. Derechos ARCO
**Acceso (Actividad 6).** Se localiza al titular con una consulta sobre `clientes` y se buscan sus datos también en las copias derivadas (`clientes_soporte`, `analitica.clientes` mediante el token). Además del resultado, la organización debería informar finalidades, origen, a quién se comparten, plazos de conservación y cómo ejercer derechos. Técnicamente hay que verificar la identidad del solicitante, registrar la solicitud y entregar los datos en formato legible.

**Rectificación (Actividad 7).** Se actualizó el correo con `UPDATE` dentro de una transacción y se revirtió con `ROLLBACK`. Implicaciones:
- Comprobar que el cambio fue autorizado: solicitud documentada, identidad verificada y aprobación del responsable.
- Debe registrarse quién, cuándo y qué valor anterior/nuevo (trazabilidad, que se retoma en la Unidad III).
- La rectificación debe **propagarse a las copias**: `clientes_soporte` quedó desincronizada con el correo anterior.

**Cancelación (Actividad 8).** Ver `evidencias/08-ciclo-vida.md`: antes de borrar hay que revisar dependencias, copias, respaldos, réplicas, auditoría, exportaciones y sistemas externos. No se ejecutó ningún `DELETE`.

**Oposición (Actividad 9).** No es necesario eliminar inmediatamente todos los datos:
- **Se mantiene** lo necesario para la finalidad principal u obligaciones legales (relación comercial, facturación).
- **Deja de usarse** para la finalidad secundaria a la que el titular se opuso.
- **Mecanismos técnicos:** columna o tabla de preferencias (`acepta_promociones` con fecha), vistas y roles separados por finalidad, exclusión en campañas y en exportaciones a terceros.
- **La decisión final no corresponde solo al DBA:** requiere al responsable de privacidad y al área jurídica para determinar si procede, y al propietario del dato para aplicarlo.

## 7. Retención
El periodo debe determinarse a partir de la finalidad, las obligaciones legales, fiscales y contractuales, las necesidades operativas y el riesgo de conservar, con aprobación del responsable y documentación. Conservar indefinidamente contradice la minimización. Detalle en `evidencias/10-retencion.md`.

## 8. Gobierno de datos
Cada dato tiene finalidad, responsable funcional, usuarios autorizados, protección, retención y acción final. El DBA actúa como custodio técnico. Matriz completa en `evidencias/11-gobierno-datos.md`.

## 9. Evaluación integral
Se identificaron 13 riesgos en el escenario de 50,000 clientes. Los más importantes: acceso directo de analítica a `clientes`, exposición de nombre, correo, teléfono y RFC sin necesidad, conservación de 12 años sin política, copias de desarrollo con datos reales y uso de correos para campañas sin finalidad documentada. Matriz en `evidencias/14-evaluacion-integral.md`; propuesta de arquitectura en `evidencias/15-arquitectura.md`.

## 10. Conclusiones
La privacidad responde a por qué se tiene un dato, quién lo usa, para qué y por cuánto tiempo; la seguridad protege el dato técnicamente. Un DBA debe traducir los principios de privacidad en controles (vistas, roles, esquemas separados, retención, trazabilidad) y escalar las decisiones jurídicas y de finalidad a quien corresponde.

### Verificación final

- **Seguridad vs privacidad:** la seguridad protege la confidencialidad, integridad y disponibilidad; la privacidad define si se debe recolectar y usar el dato y para qué.
- **Finalidad:** el uso debe ser compatible con lo informado; tener el dato no autoriza cualquier uso.
- **Minimización:** más datos significan más riesgo, costo y obligaciones sin beneficio demostrable.
- **ARCO:** exigen localizar datos en todas las copias, corregirlos y propagarlos, eliminarlos u excluirlos de usos y dejar evidencia.
- **Retención:** conservar sin límite aumenta el impacto de un incidente y contradice la minimización.
- **Gobierno:** decide el propietario del dato, con apoyo de privacidad y jurídico; el DBA implementa.
- **DBA:** implementa y mantiene controles técnicos e identifica implicaciones; las decisiones jurídicas y de finalidad se escalan.

## Preguntas de reflexión

1. **¿Una base técnicamente segura cumple siempre con privacidad?** No. Puede tener buenos controles técnicos y aun así recolectar de más, usar datos para otra finalidad o conservarlos sin justificación.
2. **¿Por qué el mínimo privilegio contribuye a la privacidad?** Porque limita quién accede a datos personales a quien los necesita para su función.
3. **¿Por qué el DBA no decide solo la finalidad?** La finalidad es una decisión del negocio y del marco jurídico; el DBA administra técnicamente pero no es el propietario del dato ni el responsable legal.
4. **¿Por qué los desarrolladores no deben recibir copias completas?** Porque no necesitan datos reales y se amplía innecesariamente el acceso a información personal.
5. **¿Por qué una copia de desarrollo también es un riesgo?** Suele tener menos controles que producción y es una vía de fuga; además, es otro lugar donde existen datos del titular.
6. **¿Por qué la retención forma parte del ciclo de vida?** Porque define cuándo un dato deja de ser necesario y debe eliminarse o anonimizarse.
7. **¿Relación entre privacidad por diseño y diseño de bases de datos?** El diseño decide qué columnas existen, quién las ve y cuánto duran; aplicar privacidad desde ahí es más barato y eficaz que corregir después.
8. **¿Qué controles técnicos reduciría el riesgo de exposición?** Roles de mínimo privilegio, vistas con datos limitados, enmascaramiento, seudonimización, cifrado, TLS, separación por finalidad, auditoría y datos no reales en desarrollo.
9. **¿Qué debe conocer un DBA para atender una solicitud ARCO?** Dónde residen los datos del titular (tablas, copias, respaldos, exportaciones, sistemas externos), cómo identificarlo, qué dependencias existen y cómo registrar la acción.
10. **¿Responsabilidades?** DBA: controles técnicos y localización de datos. Responsable de privacidad: criterios y atención a titulares. Área jurídica: base jurídica y obligaciones. Propietario de datos: finalidad, accesos y retención.
