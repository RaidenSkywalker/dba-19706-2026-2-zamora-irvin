# LAB-02 — Cifrado, credenciales y comunicaciones seguras

**Estudiante:** Zamora Serrano Irvin Donovan | **Grupo:** 4-3
**Materia:** Gestión de Seguridad y Desempeño de Bases de Datos — Unidad II, tema 2.4
**Motor:** PostgreSQL 16 en Docker (contenedor `postgres-lab`)
**Fecha:** 2026-10-27

## Contenido

| Ruta | Descripción |
|---|---|
| `sql/01-credenciales.sql` | Actividad 1: contraseña en texto claro vs. hash con `crypt()` y `gen_salt('bf')` |
| `sql/02-cifrado-datos.sql` | Actividad 2: cifrado simétrico del RFC con `pgp_sym_encrypt` / `pgp_sym_decrypt` |
| `sql/03-verificacion-tls.sql` | Actividades 4, 5 y 6: estado de TLS y de la sesión (`pg_stat_ssl`) |
| `evidencias/01-credenciales.md` | Resultados y análisis de la Actividad 1 |
| `evidencias/02-cifrado-datos.md` | Resultados y análisis de la Actividad 2 |
| `evidencias/03-gestion-claves.md` | Mala práctica de claves en scripts y búsqueda de secretos (Actividades 3 y 9) |
| `evidencias/04-tls.md` | Verificación y activación de TLS (Actividades 4 a 6) |
| `evidencias/07-comparacion.md` | Protección en reposo vs. en tránsito |
| `evidencias/08-analisis-escenario.md` | Análisis de un escenario de seguridad |
| `evidencias/10-politica-claves.md` | Política mínima de gestión de claves |

## Cómo ejecutar

Requiere el contenedor `postgres-lab` en ejecución. Desde la carpeta del laboratorio:

```powershell
Get-Content sql/01-credenciales.sql | docker exec -i postgres-lab psql -U postgres
Get-Content sql/02-cifrado-datos.sql | docker exec -i postgres-lab psql -U postgres
Get-Content sql/03-verificacion-tls.sql | docker exec -i postgres-lab psql "host=localhost port=5432 dbname=postgres user=postgres sslmode=require"
```

Todos los valores (usuario `juan`, `Password123`, `CLAVE-DE-PRUEBA`) son ficticios y exclusivos del laboratorio. Los scripts se pueden ejecutar varias veces: reinician sus tablas con `DROP TABLE IF EXISTS`. En `02-cifrado-datos.sql` el error de la última consulta (clave incorrecta) es esperado.

## 1. Introducción

Una base de datos puede tener roles y permisos correctos y aun así exponer información si las contraseñas están en texto claro, los datos sensibles no están cifrados, las conexiones viajan sin protección o las claves quedan escritas en scripts. Este laboratorio aborda tres necesidades de Comercializadora Norte: proteger credenciales, proteger información sensible almacenada y proteger las comunicaciones, además de administrar las claves que sostienen todo lo anterior.

## 2. Protección de credenciales

| Forma | Cómo se guarda | ¿Se puede recuperar la contraseña? | Evaluación |
|---|---|---|---|
| Texto claro | `password = 'Password123'` | Sí, directamente | Incorrecta: una lectura de la tabla entrega la credencial |
| Hash con sal | `crypt('Password123', gen_salt('bf'))` (bcrypt) | No | Correcta: solo permite verificar |
| Cifrado reversible | `pgp_sym_encrypt(...)` | Sí, con la clave | No apropiada para contraseñas: la clave expuesta revela todas |

Con `crypt()` y `gen_salt('bf')` los dos hashes de la misma contraseña salieron distintos porque la sal es aleatoria. Para verificar se recalcula `crypt(intento, hash_guardado)` y se compara: con la contraseña correcta devolvió `t` y con la incorrecta `f`. Detalle en `evidencias/01-credenciales.md`.

## 3. Protección de datos sensibles

Se protegió el **RFC** (dato fiscal identificado en el LAB-01) en la tabla `clientes_protegidos` con cifrado simétrico: `pgp_sym_encrypt` lo almacena como `bytea` y `pgp_sym_decrypt` lo recupera solo con la clave correcta. Con una clave incorrecta PostgreSQL devuelve un error y no entrega el dato. A diferencia de la contraseña, el RFC sí debe poder recuperarse (por ejemplo, para facturar), por eso corresponde cifrado y no hash. Detalle en `evidencias/02-cifrado-datos.md`.

## 4. TLS

**Qué problema resuelve:** protege los datos mientras viajan entre el cliente y PostgreSQL: confidencialidad (nadie interpreta el tráfico), integridad (se detecta la modificación) y autenticación del servidor cuando el cliente valida el certificado.

**Qué se verificó en PostgreSQL** (`sql/03-verificacion-tls.sql`):
- `SHOW ssl;` devuelve `off`: la imagen oficial `postgres:16` trae TLS apagado.
- `ssl_min_protocol_version = TLSv1.2`, `port = 5432` y `listen_addresses = *`.
- `pg_stat_ssl` muestra `ssl = f` en las sesiones por socket Unix (sin TLS; `version` y `cipher` vacíos).

`evidencias/04-tls.md` documenta el procedimiento para activar TLS con un certificado autofirmado de laboratorio (la llave privada se genera dentro del contenedor y no se guarda en el repositorio) y la comparación entre `disable`, `require` y `verify-full`: `require` cifra pero no verifica la identidad del servidor; `verify-full` además valida la CA y el nombre.

> **Pendiente:** completar la evidencia con la conexión TCP en `sslmode=require` y `verify-full` mostrando `ssl = t`, versión y cipher (ver `evidencias/04-tls.md`).

## 5. Gestión de claves

Las claves no deben almacenarse junto con los scripts porque un repositorio conserva el historial: aunque se borre una clave de un archivo, sigue en los commits anteriores, en clones y en copias, y quien tenga el repositorio y una copia de los datos puede descifrarlos. Por eso en el laboratorio solo se usaron claves ficticias, el archivo de mala práctica (`ejemplo-mala-practica.sql`) se creó solo como demostración y se eliminó, y antes del commit se buscaron secretos con `Select-String`/`grep`. En un entorno real las claves viven en un gestor de secretos o KMS, separadas de datos y código, con rotación, acceso restringido y respaldo (ver `evidencias/10-politica-claves.md`).

## 6. Resultados

| Actividad | Resultado | Evidencia |
|---|---|---|
| 1. Credenciales | Hash bcrypt con sal distinta en cada ejecución; verificación `t`/`f` | `01-credenciales.md` |
| 2. Cifrado | RFC almacenado como `bytea`; recuperado solo con la clave correcta; error con clave incorrecta | `02-cifrado-datos.md` |
| 3 y 9. Claves y secretos | Mala práctica analizada, archivo eliminado y búsqueda de secretos sin hallazgos reales | `03-gestion-claves.md` |
| 4 a 6. TLS | Estado verificado: `ssl = off` por defecto; procedimiento de activación documentado | `04-tls.md` |
| 7. Reposo vs. tránsito | Tabla de mecanismos por situación | `07-comparacion.md` |
| 8. Escenario | Riesgos, mecanismos y problema más crítico (claves en SQL) | `08-analisis-escenario.md` |
| 10. Política de claves | 8 reglas (generación a eliminación) | `10-politica-claves.md` |

## 7. Problemas encontrados

- **TLS apagado por defecto:** la imagen `postgres:16` trae `ssl = off`; hay que generar un certificado, activar `ssl` y reiniciar el contenedor.
- **Pruebas por socket Unix:** las primeras ejecuciones del script de TLS se hicieron por el socket local, que no usa TLS, por eso `pg_stat_ssl` mostró `ssl = f`. Para probar TLS hay que conectarse por TCP (`host=localhost`) con `sslmode=require` o `verify-full`.
- **Comando dentro de psql:** en una sesión interactiva se escribió `psql "host=..."` como si fuera un comando de PowerShell y PostgreSQL devolvió un error de sintaxis; ese comando se ejecuta desde la terminal, no dentro de `psql`.
- **Clave incorrecta:** el error de `pgp_sym_decrypt` es el comportamiento esperado, no una falla.
- **Rutas con mayúsculas:** los comandos documentados usaban `Lab-02-...` y la carpeta se llama `lab-02-...`; se corrigió para que funcionen en cualquier sistema.

## 8. Conclusiones

Ningún mecanismo sustituye a los demás: el hash protege credenciales, el cifrado protege datos recuperables en reposo, TLS protege el tránsito y la gestión de claves sostiene el cifrado. En un entorno productivo aplicaría: hash con Argon2id/bcrypt desde la aplicación, cifrado de columnas sensibles con claves en un gestor de secretos, TLS obligatorio con `verify-full`, respaldos cifrados, revisión de secretos antes de cada commit y una política de rotación y revocación de claves.

## Preguntas de reflexión

1. **¿Por qué una contraseña no debe almacenarse como texto claro?** Porque una lectura de la tabla, un respaldo o una filtración entrega credenciales utilizables de inmediato, incluso en otros sistemas si la persona las reutiliza.
2. **¿Por qué un hash no es equivalente a un cifrado?** El cifrado es reversible con la clave; el hash es unidireccional y solo sirve para verificar. Una contraseña cifrada dejaría una clave que, si se expone, revela todas.
3. **¿Por qué el cifrado de una columna no sustituye al control de acceso?** Porque quien tiene permiso de ejecutar el descifrado con la clave (o la aplicación que la posee) obtiene el dato; además el cifrado no decide quién puede consultar qué objetos ni protege otras columnas.
4. **¿Por qué TLS no sustituye a los mecanismos de autorización de PostgreSQL?** TLS protege el canal; no define qué puede hacer cada usuario. Un usuario autenticado por una conexión cifrada sigue limitado solo por sus privilegios.
5. **¿Qué ocurriría si una organización pierde una clave utilizada para cifrar información?** Los datos cifrados quedarían irrecuperables. Por eso la política exige respaldo cifrado de las claves, en un lugar distinto al de los datos.
6. **¿Qué ocurriría si una clave criptográfica se publica accidentalmente en GitLab/GitHub?** Debe considerarse comprometida aunque se borre, porque permanece en el historial y en copias: se revoca, se rota, se recifran los datos y se revisan los accesos.
7. **¿Por qué un repositorio privado no debe considerarse un almacén de secretos?** Reduce la exposición, pero el secreto sigue en el historial, clones y copias, y queda disponible para todos los que tengan acceso.
8. **¿Qué diferencia existe entre proteger información almacenada y durante su transmisión?** Lo almacenado se protege con cifrado en reposo (columnas, discos, respaldos); lo que viaja se protege con TLS. Cada uno cubre un riesgo distinto.
9. **¿Por qué la gestión de claves es tan importante como el algoritmo criptográfico?** Los algoritmos son públicos y robustos; la seguridad depende de que la clave siga siendo secreta, disponible y rotada. Una clave expuesta anula cualquier algoritmo.
10. **¿Qué mecanismo adicional implementaría para proteger los respaldos?** Cifrar cada respaldo (por ejemplo `pg_dump` con `gpg` o `age`, o cifrado del almacenamiento), guardar las claves aparte, restringir el acceso al archivo y probar periódicamente la restauración.
