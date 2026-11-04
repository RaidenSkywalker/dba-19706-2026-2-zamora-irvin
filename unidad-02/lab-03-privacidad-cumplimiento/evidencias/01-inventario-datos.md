# Evidencia 01 — Inventario y finalidad de los datos

**Estudiante:** Zamora Serrano Irvin Donovan | **Fecha:** 2026-10-31

## Objetivo
Identificar qué datos de la tabla `clientes` son personales, para qué finalidad se usan, si son necesarios, quién debe acceder a ellos y cuánto tiempo deben conservarse.

## Procedimiento
1. Revisar la estructura de la tabla (origen: LAB-01):
```powershell
docker exec postgres-lab psql -U postgres -c "\d clientes"
```
2. Contrastar cada campo con los procesos del escenario (atención al cliente, facturación, analítica y DBA) y decidir finalidad, necesidad, acceso y retención.

## Resultado

**Estructura de la tabla:**
![Ejecucion del script](img/01-minimizacion/01.png)

**Matriz de inventario:**

| Campo | ¿Es dato personal? | Finalidad | ¿Es necesario? | Nivel de acceso | Retención | Justificación |
|---|---|---|---|---|---|---|
| id | Sí, indirecto (identificador interno ligado a una persona) | Enlazar registros entre procesos | Sí | Atención, Facturación, DBA (técnico) | Mientras exista el registro del cliente | Por sí solo no identifica, pero permite llegar a la persona y vincula copias derivadas |
| nombre | Sí, directo | Identificar al cliente en atención y facturación | Sí | Atención al cliente, Facturación | Durante la relación comercial + plazo que fije el área jurídica | Identifica directamente a la persona |
| correo | Sí, directo | Contacto y atención al cliente | Sí (para soporte) | Atención al cliente; no analítica | Durante la relación comercial | Permite contactar e identificar; es el campo usado para campañas, que sería una finalidad distinta |
| telefono | Sí, directo | Contacto en atención al cliente | Sí/condicionado: útil, pero puede ser opcional | Atención al cliente | Durante la relación comercial | Identifica y permite contacto; si hay otro canal, podría no recolectarse |
| rfc | Sí, directo; dato fiscal | Facturación | Solo para Facturación | Facturación (no soporte, no analítica) | Plazo fiscal/contable (a confirmar con jurídico/contabilidad) | Es un identificador fiscal único; su acceso debe limitarse a quien factura |
| edad | Sí, indirecto (cuasi-identificador) | Estadística (analítica) | Solo como rango, no como valor exacto | Analítica (generalizada); no soporte | Mientras exista la finalidad estadística | Combinada con ciudad y código postal reduce el anonimato |
| ciudad | Sí, indirecto (cuasi-identificador) | Estadística regional | Sí, para analítica | Analítica (agregada); DBA | Mientras exista la finalidad estadística | Por sí sola es poco identificable, pero suma al riesgo en combinación |
| codigo_postal | Sí, indirecto (cuasi-identificador) | Estadística por región | Solo el prefijo (región) para analítica; completo solo si Facturación lo requiere | Analítica (región); Facturación si aplica | Mientras exista la finalidad | Más preciso que la ciudad; el código completo aumenta la posibilidad de reidentificación |
| fecha_alta | Sí, indirecto (dato de la relación con una persona identificable) | Control del ciclo de vida y cálculo de retención | Sí | DBA y responsable de datos | Igual que el registro | Permite aplicar la política de retención; no es necesaria para soporte ni analítica |

## Análisis
- **Datos que no deberían llegar a todos los procesos:** RFC solo a Facturación; nombre, correo y teléfono solo a quien atiende o factura; analítica solo necesita datos generalizados.
- **Acceso administrativo ≠ derecho de uso:** que el DBA pueda leer todo técnicamente no lo autoriza a usar los datos para cualquier finalidad.
- Los plazos de retención dependen de obligaciones legales y de la finalidad; el DBA propone y documenta, y la decisión final corresponde al responsable del dato y a las áreas jurídica y de privacidad.

## Conclusión
No todos los campos son necesarios para todos los procesos. Definir finalidad y necesidad **antes** de dar acceso permite aplicar minimización y mínimo privilegio con criterio.
