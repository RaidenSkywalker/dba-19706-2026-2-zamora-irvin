# Evidencia 12 — Privacidad por diseño

**Estudiante:** Zamora Serrano Irvin Donovan | **Fecha:** 2026-10-31

## Objetivo
Evaluar un diseño de tabla propuesto por un desarrollador ("guardar todos los datos por si luego se necesitan") y proponer una alternativa con privacidad por diseño y por defecto.

## Procedimiento
Análisis conceptual de la tabla `clientes` propuesta (con dirección, fecha de nacimiento, ocupación, salario, estado civil, etc.). No se ejecutan comandos.

## Resultado

**1. Problemas identificados**
- Se recopilan datos sin finalidad definida (`direccion`, `ocupacion`, `salario`, `estado_civil`).
- Algunos datos son especialmente delicados (situación económica, estado civil) y elevan el impacto de una filtración.
- Redundancia: `edad` y `fecha_nacimiento` expresan lo mismo.
- Todos los campos son `TEXT`, sin límites ni validación, y `id BIGSERIAL` sin restricción de llave primaria declarada.
- No hay retención, clasificación ni responsable.
- La justificación "por si acaso" no es válida.

**2. Principio ignorado:** minimización (junto con necesidad, proporcionalidad y limitación de finalidad).

**3. Preguntas antes de aprobar el diseño**
- ¿Para qué proceso se usa cada dato y qué decisión depende de él?
- ¿Se puede cumplir la finalidad con menos datos o con datos generalizados?
- ¿Cuál es la base jurídica y qué se informará al titular?
- ¿Quién accederá y por cuánto tiempo se conservará?
- ¿Qué pasa si el dato se filtra?

**4. Datos que eliminaría:** `salario`, `ocupacion`, `estado_civil`, y una de las dos columnas `edad`/`fecha_nacimiento`.

**5. Datos que requerirían justificación adicional:** `rfc`, `telefono`, `direccion` y `fecha_nacimiento` (solo si una finalidad concreta, como facturación o envío, lo exige).

**6. Cómo aplicar privacidad por defecto**
- Crear tablas separadas por finalidad (clientes operativos, facturación, analítica).
- Columnas opcionales con valor `NULL` y sin recolección por defecto.
- Sin permisos por defecto: `REVOKE ALL` y otorgar solo lo necesario por rol.
- Preferencias de contacto como "no" hasta que el titular acepte.
- Retención definida desde el diseño y vistas para exponer solo lo necesario.

Propuesta conceptual mínima (no ejecutada):
```sql
CREATE TABLE clientes (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    correo VARCHAR(150) NOT NULL,
    telefono VARCHAR(20),            -- opcional
    fecha_alta DATE DEFAULT CURRENT_DATE
);
CREATE TABLE clientes_facturacion (   -- solo si hay finalidad fiscal
    cliente_id BIGINT PRIMARY KEY REFERENCES clientes(id),
    rfc VARCHAR(13) NOT NULL
);
```

## Análisis
Recolectar más datos de los necesarios no aporta valor demostrable y sí aumenta el riesgo. El diseño es el momento más barato para aplicar privacidad.

## Conclusión
La tabla debe diseñarse a partir de las finalidades, no de lo que "podría servir": privacidad por diseño significa decidir qué no se recolecta.
