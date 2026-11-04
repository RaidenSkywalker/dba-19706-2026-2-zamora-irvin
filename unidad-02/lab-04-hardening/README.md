# LAB-04 — Hardening y configuración segura de PostgreSQL

**Estudiante:** Zamora Serrano Irvin Donovan <br>
**Grupo:** 4-3 <br>
**Materia:** Gestión de Seguridad y Desempeño de Bases de Datos — Unidad II, tema 2.6<br>
**Fecha:** 2026-11-02

## Objetivo
Aplicar un proceso básico de hardening a PostgreSQL 16: identificar la superficie de ataque, reducir la exposición de red y de autenticación, separar cuentas con mínimo privilegio, revisar permisos del sistema operativo y TLS, y documentar el estado antes y después con una línea base y una checklist.

## Entorno
- PostgreSQL 16 en un contenedor Docker académico y aislado: `postgres-lab`.
- Cliente: `psql` mediante `docker exec`, desde PowerShell en VS Code.
- Base de las prácticas: `postgres`, con los objetos de los LAB-01 a LAB-03.
- No se modificó ningún servidor institucional ni firewall. El firewall se diseña de forma conceptual.

| Ruta | Contenido |
|---|---|
| `sql/01-inspeccion.sql` | Inspección de solo lectura (superficie, archivos, `pg_hba`, roles, extensiones, conexiones, TLS) |
| `sql/02-roles.sql` | Cuentas `app_user` y `consulta_user` con privilegios mínimos |
| `sql/03-configuracion.sql` | Parámetros: registro de conexiones, tiempos máximos, SCRAM, `listen_addresses` |
| `sql/04-verificacion.sql` | Verificación del estado posterior y pruebas de privilegios |
| `configuracion/baseline.md` | Línea base de seguridad de PostgreSQL 16 |
| `configuracion/cambios.md` | Comparación antes/después, registro de cambios y análisis |
| `configuracion/pg_hba.hardened.conf` | Reglas de acceso endurecidas |
| `configuracion/guia-ejecucion.md` | Pasos reproducibles, en orden |
| `evidencias/` | Capturas 01 a 06 |
| `informe.md` | Respuestas, caso integral y reflexión |

## Superficie de ataque inicial
Salida de `sql/01-inspeccion.sql` ejecutada antes de aplicar cambios (PostgreSQL 16.15 en Debian, contenedor `postgres-lab`).

| Elemento | Estado actual | ¿Es necesario? | Riesgo |
|---|---|---|---|
| Puerto PostgreSQL | `5432` (origen `default`) | Sí, para el servicio | Punto de entrada conocido |
| Interfaces de escucha | `listen_addresses = '*'` (origen `configuration file`) | Solo la local | Expone el servicio en todas las interfaces |
| Conexiones remotas | `pg_stat_activity`: 6 procesos; la única sesión de cliente es `psql` como `postgres`, sin `client_addr` (socket local) | No hay aplicaciones remotas en el laboratorio | Superficie innecesaria |
| Usuarios administrativos | `postgres` (`rolsuper = t`), único rol con `LOGIN`; `analista` y `soporte` son `NOLOGIN` sin privilegios administrativos | Solo para administración | Una cuenta con control total y sin cuentas por función |
| SSL/TLS | `ssl = off`; `ssl_min_protocol_version = TLSv1.2` | Sí | Sin TLS, credenciales y datos viajan sin protección |
| Métodos de autenticación | `trust` en `local`, `127.0.0.1`, `::1` y `replication`; `scram-sha-256` solo en `host all all all` | `scram-sha-256` | `trust` permite entrar sin contraseña |

## Hallazgos

| # | Hallazgo | Riesgo | Evidencia |
|---|---|---|---|
| 1 | `listen_addresses = '*'` | Servicio en interfaces innecesarias | `evidencias/01-inspeccion/02-listen-addresses.png` |
| 2 | `pg_hba.conf` con `host all all all scram-sha-256` (cualquier base, usuario y origen) y `trust` en local, loopback y replicación | Cualquier origen puede intentar autenticarse; acceso sin contraseña en local | `evidencias/01-inspeccion/03-pg-hba.png` |
| 3 | Solo `postgres` (superusuario) puede iniciar sesión; no hay cuentas por función | Una cuenta de aplicación tendría control total | `evidencias/01-inspeccion/04-roles.png` |
| 4 | `log_connections` y `log_disconnections` en `off`; `idle_in_transaction_session_timeout = 0` (sin límite) | Sin trazabilidad de conexiones; sesiones indefinidas | `evidencias/01-inspeccion/01-superficie-ataque3.png`, `evidencias/01-inspeccion/05-tls.png` |
| 5 | `ssl = off` | Tráfico sin cifrar | `evidencias/01-inspeccion/05-tls.png` |
| 6 | Permisos de archivos del sistema operativo: no se capturó `ls -l` | Posible lectura de archivos sensibles (sin evidencia aún) | Pendiente (guía, Paso 5) |

## Cambios realizados
Detalle, comandos y reversión en `configuracion/cambios.md`.

**Aplicados y verificados** (`04-verificacion.sql`):
1. Cuentas `app_user` (límite 10 conexiones) y `consulta_user` (límite 5), sin `SUPERUSER`, `CREATEROLE` ni `CREATEDB`, con privilegios mínimos.
2. `log_connections = on` y `log_disconnections = on`.
3. `statement_timeout = 5 min` e `idle_in_transaction_session_timeout = 60 s`; `password_encryption = scram-sha-256`.

**Preparados pero pendientes de aplicar** (la verificación posterior todavía muestra el estado original):
4. `pg_hba.conf` con reglas específicas (`configuracion/pg_hba.hardened.conf`): en V2 siguen las 7 reglas originales.
5. `listen_addresses = 'localhost'`: ya se ejecutó `ALTER SYSTEM`, pero V1 muestra `*` con `pending_restart = t`; falta `docker restart postgres-lab`.
6. Permisos `600` y propietario `postgres` en `pg_hba.conf`: sin evidencia.
7. TLS: `ssl = off`; las reglas `hostssl` solo funcionan con TLS activo (si sigue apagado, usar `host` y documentarlo, como indica la guía).

## Justificación de los cambios
- **Exposición de red:** si PostgreSQL no escucha fuera del equipo local, la mayoría de las rutas de ataque remotas desaparecen.
- **`pg_hba.conf` específico:** limita quién puede autenticarse, en qué base, desde dónde y con qué método.
- **Cuentas por función:** una cuenta comprometida solo puede hacer lo que su función requiere. Verificado: `app_user` no puede hacer `DELETE`, leer `clientes` ni crear objetos, y `consulta_user` no puede escribir.
- **Tiempos y registros:** protegen la disponibilidad y permiten detectar abusos.
- **TLS y SCRAM:** protegen credenciales y datos en tránsito y el almacenamiento de contraseñas.
- **No se cambió el puerto:** hacerlo no es hardening suficiente.

## Verificación
Resultados de `sql/04-verificacion.sql` (capturas en `evidencias/04-verificacion/`, archivos `Get-Content1.png` a `Get-Content5.png`).

| Prueba | Resultado esperado | Resultado obtenido | Evidencia |
|---|---|---|---|
| `SHOW listen_addresses` | `localhost` | `*` con `pending_restart = t`: falta reiniciar el contenedor | `Get-Content1.png` |
| `pg_hba_file_rules` sin errores | columna `error` vacía | Sin errores, pero son las 7 reglas originales: el archivo endurecido aún no se aplicó | `Get-Content1.png` |
| Parámetros de conexión | registro activo y tiempos definidos | `log_connections = on`, `log_disconnections = on`, `statement_timeout = 300000`, `idle_in_transaction_session_timeout = 60000`, `password_encryption = scram-sha-256` | `Get-Content1.png` |
| Roles y privilegios | sin superusuarios de aplicación | `app_user` (límite 10) y `consulta_user` (límite 5) con `superuser = f`; solo `postgres` es superusuario | `Get-Content2.png` |
| `app_user` hace `DELETE` | `permission denied` | `permission denied for table clientes_soporte` | `Get-Content3.png` |
| `app_user` lee `clientes` | `permission denied` | `permission denied for table clientes` | `Get-Content3.png` |
| `app_user` crea una tabla | `permission denied` | `permission denied for schema public` | `Get-Content3.png` |
| `consulta_user` escribe | `permission denied` | `permission denied for table clientes_soporte` | `Get-Content4.png` |
| `consulta_user` lee la vista | permitido | Devuelve filas de `v_analitica_clientes` | `Get-Content4.png` |
| Extensiones | solo las necesarias | `pgcrypto 1.3` y `plpgsql 1.0` | `Get-Content5.png` |
| Conexión con TLS | `ssl = t`, versión y cipher | `ssl = off`: sin TLS; la consulta de `pg_stat_ssl` falló por `usename` (corregida en el script) | `Get-Content5.png` |
| Conexión sin contraseña, usuario no autorizado y sin TLS por TCP | rechazadas | No ejecutadas todavía (Paso 5 de la guía) | Pendiente |

## Checklist de hardening
☑ = verificado con evidencia; ☐ = pendiente.

| # | Control | Verificado | Evidencia |
|---|---|---|---|
| 1 | Puerto documentado | ☑ | `evidencias/01-inspeccion/01-superficie-ataque.png` |
| 2 | Interfaces de escucha justificadas | ☐ | `evidencias/01-inspeccion/02-listen-addresses.png` (identificada `*`; falta aplicar `localhost` y reiniciar) |
| 3 | `pg_hba.conf` revisado | ☑ | `evidencias/01-inspeccion/03-pg-hba.png` |
| 4 | Redes autorizadas restringidas | ☐ | Falta aplicar `pg_hba.hardened.conf` |
| 5 | Autenticación segura (SCRAM) | ☐ | `password_encryption` y `postgres` en SCRAM ☑, pero sigue `trust` en `pg_hba.conf` |
| 6 | Superusuarios identificados | ☑ | `evidencias/01-inspeccion/04-roles.png` |
| 7 | Cuentas de aplicación separadas | ☑ | `evidencias/04-verificacion/Get-Content2.png` |
| 8 | Privilegios mínimos | ☑ | `evidencias/04-verificacion/Get-Content3.png`, `evidencias/04-verificacion/Get-Content4.png` |
| 9 | Extensiones revisadas | ☑ | `evidencias/04-verificacion/Get-Content5.png` |
| 10 | TLS verificado | ☐ | `evidencias/01-inspeccion/05-tls.png` muestra `ssl = off` |
| 11 | Configuración protegida (permisos de archivos) | ☐ | Sin captura de `ls -l` |
| 12 | Directorio de datos protegido | ☐ | Sin captura de `ls -l` |
| 13 | Firewall documentado | ☑ | `cambios.md` §8 (diseño conceptual) |
| 14 | Actualizaciones documentadas | ☑ | `baseline.md` (versión 16.15 y política de parches) |
| 15 | Configuración registrada | ☑ | `cambios.md` |
| 16 | Registro de conexiones activado | ☑ | `evidencias/04-verificacion/Get-Content1.png` |
| 17 | Límites de conexión y tiempos definidos | ☑ | `evidencias/04-verificacion/Get-Content1.png`, `evidencias/04-verificacion/Get-Content2.png` |
| 18 | Contraseñas fuera de scripts y repositorio | ☑ | `02-roles.sql` no contiene contraseñas; respaldos en `.gitignore` |

## Conclusiones
El hardening reduce la superficie de ataque: elimina o restringe lo innecesario y controla lo que debe permanecer. En este laboratorio la inspección mostró tres exposiciones principales: `listen_addresses = '*'`, reglas de `pg_hba.conf` amplias con `trust`, y una sola cuenta administrativa sin TLS. Los cambios verificados hasta ahora son de **autorización y trazabilidad**: cuentas `app_user` y `consulta_user` con privilegios mínimos (las pruebas negativas devolvieron `permission denied`), registro de conexiones y tiempos máximos. Los cambios de **red y autenticación** (`pg_hba.conf` endurecido, `listen_addresses = 'localhost'`, TLS y permisos del sistema operativo) están preparados, pero la verificación posterior aún muestra el estado original, por lo que quedan pendientes. Ningún control sustituye a los demás: red, autenticación, autorización, sistema operativo, TLS y monitoreo trabajan en capas. Un hardening solo es útil si está documentado, es reproducible y se verifica.
