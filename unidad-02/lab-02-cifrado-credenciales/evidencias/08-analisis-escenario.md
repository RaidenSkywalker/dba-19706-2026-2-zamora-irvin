# Evidencia 08 — Análisis de un escenario de seguridad

**Estudiante:** Zamora Serrano Irvin Donovan | **Fecha:** 2026-10-27

## Objetivo
Analizar riesgos y mecanismos de una organización con roles correctos pero con otras debilidades.

## Resultado obtenido (respuestas)

**Pregunta 1 — Principales riesgos**
- Contraseñas en texto claro: una filtración o lectura de la tabla expone credenciales utilizables de inmediato.
- RFC en texto claro: exposición de datos personales/fiscales ante lectura directa, volcados o respaldos.
- Conexiones sin validación del servidor: posible suplantación o interceptación (ataque de intermediario).
- Claves criptográficas en archivos SQL: quien acceda al repositorio o a los scripts puede descifrar los datos; permanecen en el historial.
- Respaldos sin protección: una copia completa puede extraerse sin pasar por los roles ni permisos de la base.

**Pregunta 2 — Mecanismo para cada elemento**

| Elemento | Mecanismo |
|---|---|
| Nombre, correo | Control de acceso; enmascaramiento o seudonimización según el uso; TLS en tránsito |
| Contraseña | Hash con sal (Argon2id/bcrypt/scrypt) |
| RFC | Cifrado de columna (p. ej. `pgp_sym_encrypt`) con claves gestionadas aparte |
| Información financiera | Cifrado, mínimo privilegio y auditoría de accesos |
| Claves criptográficas | Gestor de secretos / KMS, fuera del código, con rotación |
| Conexiones | TLS con `sslmode=verify-full` |
| Respaldos | Cifrado del respaldo y control de acceso al archivo |

**Pregunta 3 — Problema más crítico**
Las claves criptográficas en archivos SQL. Anulan el valor de todo el cifrado (actual y de respaldos), se propagan por el historial de Git y copias, y su contención exige rotar claves y recifrar datos. Las contraseñas en texto claro también son muy graves, pero su impacto se limita a credenciales; una clave expuesta compromete todos los datos que protege.

**Pregunta 4 — ¿Los usuarios y permisos correctos eliminan estos riesgos?**
No. Los permisos controlan quién puede consultar mediante la base, pero no protegen contra el acceso al disco o a los respaldos, el tráfico de red sin TLS, la exposición de claves ni los datos guardados en claro cuando alguien logra acceso. Se requiere defensa en profundidad.

## Análisis
Cada debilidad pertenece a una capa distinta (credenciales, datos almacenados, comunicaciones, claves, respaldos); corregir una no corrige las demás.

## Conclusión
La seguridad de una base de datos es integral: control de acceso + cifrado + TLS + gestión de claves + protección de respaldos.
