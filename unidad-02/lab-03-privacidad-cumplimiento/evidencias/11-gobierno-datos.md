# Evidencia 11 — Matriz de gobierno de datos

**Estudiante:** Zamora Serrano Irvin Donovan | **Fecha:** 2026-10-31

## Objetivo
Relacionar cada dato con su finalidad, responsable, usuarios autorizados, protección, retención y acción final, demostrando que el acceso responde a una necesidad funcional.

## Procedimiento
Construcción de la matriz a partir del inventario (evidencia 01) y de los controles implementados en LAB-01 a LAB-03 (vistas, roles, esquemas separados y cifrado).

## Resultado

| Dato | Finalidad | Responsable | Usuarios autorizados | Protección | Retención | Acción al finalizar |
|---|---|---|---|---|---|---|
| nombre | Identificar al cliente | Atención al cliente / Facturación | Atención al cliente, Facturación | Acceso por rol y vista; TLS en tránsito | Relación comercial + plazo definido por jurídico | Eliminar |
| correo | Contacto y atención | Atención al cliente | Atención al cliente | Enmascaramiento en vista para soporte; TLS | Relación comercial | Eliminar |
| telefono | Contacto en atención | Atención al cliente | Atención al cliente | Enmascaramiento en vista; TLS | Relación comercial | Eliminar |
| rfc | Facturación | Facturación / Contabilidad | Facturación | Cifrado de columna (pgcrypto), acceso restringido | Plazo fiscal (a confirmar) | Eliminar |
| edad | Estadística | Analítica | Analítica (solo en rangos) | Generalización por rangos; vista sin identificadores | Mientras exista la finalidad | Anonimizar / agregar |
| ciudad | Estadística regional | Analítica | Analítica (agregada), Dirección | Agregación; vista sin identificadores | Mientras exista la finalidad | Anonimizar / agregar |
| codigo_postal | Estadística por región | Analítica | Analítica (región), Facturación si aplica | Generalización a prefijo de región | Mientras exista la finalidad | Anonimizar / agregar |

**Reparto de responsabilidades**

| Rol | Responsabilidad |
|---|---|
| Propietario de los datos (área funcional) | Decide la finalidad, quién accede y el periodo de retención |
| DBA (custodio) | Implementa y mantiene los controles técnicos; identifica implicaciones técnicas |
| Responsable de privacidad | Define criterios de privacidad y atiende solicitudes de titulares |
| Área jurídica | Determina obligaciones legales y base jurídica |
| Dirección | Aprueba políticas y asigna recursos |

## Análisis
Cada dato tiene un responsable funcional y solo lo ven los roles que lo necesitan. El DBA custodia pero no decide la finalidad. No todos los roles aparecen en todos los datos.

## Conclusión
El gobierno de datos vincula dato, finalidad, responsable y control técnico, y evita que el acceso dependa de la comodidad en lugar de la necesidad.
