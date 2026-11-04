# Evidencia 15 — Arquitectura de datos protegidos

**Estudiante:** Zamora Serrano Irvin Donovan | **Fecha:** 2026-10-31

## Objetivo
Proponer una arquitectura conceptual que separe los datos según su finalidad y traduzca principios de privacidad a decisiones técnicas.

## Procedimiento
Diseño conceptual apoyado en lo implementado en LAB-01 (vistas, roles, esquema `pii`/`analitica`), LAB-02 (cifrado y TLS) y LAB-03 (minimización por finalidad). No se implementa físicamente toda la arquitectura.

## Resultado

```
                    BASE DE DATOS
                          │
      ┌───────────────────┼───────────────────┐
      ▼                   ▼                   ▼
  OPERACIÓN           ANALÍTICA           AUDITORÍA
      │                   │                   │
 Datos necesarios    Datos agregados /   Registro de accesos
 para operación      seudonimizados      y cambios
 (clientes,          (vistas, rangos,    (quién, qué, cuándo)
  facturación)        sin identificadores)
      │
 pii (mapa de tokens, acceso restringido)
```

| Control | Decisión técnica |
|---|---|
| Acceso | Roles por función (soporte, facturación, analista, DBA); `GRANT` solo sobre vistas; `REVOKE ALL` sobre tablas base |
| Minimización | Tablas y vistas por finalidad (por ejemplo `clientes_soporte` solo con id, nombre, correo y teléfono) |
| Protección de información sensible | Cifrado de columna para RFC (pgcrypto), tokens en lugar de identificadores, TLS en tránsito, claves fuera de la base |
| Retención | Periodos por dato; consulta periódica de registros vencidos; eliminación o anonimización con aprobación y respaldo |
| Trazabilidad | Registro de auditoría de consultas y cambios sobre datos personales (se profundiza en la Unidad III) |
| Eliminación | Procedimiento que cubre tablas derivadas, copias, respaldos, exportaciones y sistemas externos, con evidencia |
| Atención de solicitudes | Procedimiento ARCO: verificar identidad, localizar datos en todas las copias, ejecutar, propagar y registrar |

## Análisis
Separar por finalidad evita que un único acceso exponga todo. Operación conserva lo necesario, analítica trabaja con datos generalizados o seudonimizados y auditoría permite demostrar qué ocurrió.

## Conclusión
La arquitectura convierte principios (finalidad, minimización, retención, rendición de cuentas) en decisiones concretas: esquemas, roles, vistas, cifrado, auditoría y procedimientos.
