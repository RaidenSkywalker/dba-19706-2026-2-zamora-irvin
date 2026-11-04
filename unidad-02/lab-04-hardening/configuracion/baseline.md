# Línea base de seguridad — PostgreSQL 16 (LAB-04)

**Estudiante:** Zamora Serrano Irvin Donovan | **Entorno:** contenedor académico `postgres-lab` | **Fecha:** 2026-11-01

Esta línea base define el estado esperado de una instancia PostgreSQL 16 y sirve para comparar y verificar. Los valores concretos de este laboratorio van entre paréntesis.

## Red
| Control | Requisito | Valor en el laboratorio |
|---|---|---|
| Interfaces autorizadas | Solo las necesarias, nunca `'*'` sin justificación | `listen_addresses = 'localhost'` |
| Puerto | Documentado; no sustituye otros controles | 5432 (cambiarlo no es hardening) |
| Firewall | Política de denegar por defecto y permitir solo la red de administración | Diseño conceptual en `cambios.md` (no se modificó ningún firewall) |
| Redes permitidas | Lista explícita (allowlist) | Solo `127.0.0.1/32` y `::1/128` |

## Autenticación
| Control | Requisito | Valor en el laboratorio |
|---|---|---|
| Método | `scram-sha-256`; evitar `md5` y `trust` en TCP | `scram-sha-256` en todas las reglas TCP |
| Contraseñas | Fuertes, únicas, no almacenadas en scripts ni repositorio | Asignadas con `\password`; no versionadas |
| Cuentas administrativas | Pocas, identificadas y no usadas por aplicaciones | `postgres` (solo administración) |
| Excepciones | Documentar y justificar | `local ... postgres trust` para administrar vía `docker exec` en un contenedor aislado |

## Autorización
| Control | Requisito | Valor en el laboratorio |
|---|---|---|
| Roles | Una cuenta por función | DBA (`postgres`), `app_user`, `consulta_user` |
| Privilegios | Mínimos, sin `SUPERUSER`/`CREATEROLE`/`CREATEDB` para aplicaciones | `app_user`: SELECT/INSERT/UPDATE en `clientes_soporte`; `consulta_user`: SELECT en `v_analitica_clientes` |
| Conexión a la base | Solo cuentas autorizadas | `REVOKE CONNECT ... FROM PUBLIC` y `GRANT CONNECT` explícito |
| Límite de conexiones | Por rol | 10 (`app_user`) y 5 (`consulta_user`) |

## Configuración
| Control | Requisito | Valor en el laboratorio |
|---|---|---|
| `password_encryption` | `scram-sha-256` | `scram-sha-256` |
| `log_connections` / `log_disconnections` | Activados para trazabilidad | `on` / `on` |
| `statement_timeout` | Definido | 5 min global; 30 s por rol de aplicación/consulta |
| `idle_in_transaction_session_timeout` | Definido | 60 s |
| Extensiones | Solo las necesarias | Revisadas (ver `cambios.md`) |

## Sistema operativo
| Control | Requisito | Valor en el laboratorio |
|---|---|---|
| Propietario | Cuenta de servicio `postgres` | `postgres:postgres` |
| Directorio de datos | Sin acceso a otros usuarios | `drwx------` (700) |
| Archivos de configuración | Lectura/escritura solo del propietario | `pg_hba.conf` y `postgresql.conf` con `-rw-------` (600) |

## Cifrado
| Control | Requisito | Valor en el laboratorio |
|---|---|---|
| TLS | Activado y exigido para conexiones TCP | Objetivo: `ssl = on` y reglas `hostssl`. Estado verificado en el LAB-04: `ssl = off` (pendiente de activar) |
| Versión mínima | TLS 1.2 o superior | `ssl_min_protocol_version = TLSv1.2` |
| Credenciales | Almacenadas como hash SCRAM, no en texto claro | Verificado en `pg_authid` (sin mostrar el hash) |
| Información sensible | Cifrado de columna cuando aplique | RFC con pgcrypto (LAB-02) |

## Mantenimiento
- **Actualizaciones:** aplicar versiones menores de PostgreSQL 16 y actualizar la imagen del contenedor con una ventana de mantenimiento, probando antes en un entorno no productivo.
- **Revisión periódica:** `pg_hba.conf`, roles y privilegios, extensiones, parámetros de conexión, certificados y permisos del sistema operativo (por ejemplo, trimestral).
- **Documentación:** cada cambio se registra en `cambios.md` con comando, motivo, verificación y reversión.
