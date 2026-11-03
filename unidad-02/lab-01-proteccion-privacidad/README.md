# LAB-01 — Protección y privacidad de datos

Práctica de la materia **Gestión de Seguridad y Desempeño de Bases de Datos** (Unidad II, tema 2.3).<br>
**Estudiante:** Zamora Serrano Irvin Donovan<br>
**Grupo:** 4-3 <br>
**Motor:** PostgreSQL 16 en Docker (contenedor `postgres-lab`)
**Entrega:** repositorio de GitHub 


## Contenido del repositorio

| Ruta | Descripción |
|---|---|
| `sql/` | Scripts 01 a 05, uno por tema |
| `evidencias/` | PDF de evidencia por actividad (`img/` guarda las capturas usadas en el informe) |
| `informe.md` | Análisis, respuestas, conclusiones y reflexión |

| Script | Actividades |
|---|---|
| `01-clasificacion.sql` | 1 — Tabla `clientes` y datos de prueba |
| `02-enmascaramiento.sql` | 2 — Rol `soporte` y vista enmascarada |
| `03-seudonimizacion.sql` | 3 y 4 — Tokens, mapa en esquema `pii`, rol `analista` |
| `04-anonimizacion.sql` | 5 y 6 — Generalización, agregación y análisis de riesgo |
| `05-retencion.sql` | 7 — Consulta de retención (sin `DELETE`) |

## Manual de uso con VS Code

### Requisitos
- Docker Desktop abierto y funcionando.
- VS Code con el repositorio abierto (**Archivo → Abrir carpeta** → la carpeta del laboratorio).
- Un contenedor PostgreSQL 16 llamado `postgres-lab`.

### Paso 1. Abrir la terminal en la raíz del repositorio
En VS Code: **Ctrl + `(o Terminal → Nueva terminal)`**. El prompt debe terminar en la carpeta del laboratorio, por ejemplo `PS C:\Users\...\LAB-01-Proteccion-Datos>`. Los comandos usan rutas relativas (`sql/...`), así que deben ejecutarse desde ahí.

### Paso 2. Verificar el contenedor
```powershell
docker ps
```
Debe aparecer `postgres-lab` con estado `Up`. Si no existe, se crea con (ajusta la contraseña):
```powershell
docker run --name postgres-lab -e POSTGRES_PASSWORD=<contraseña> -p 5432:5432 -d postgres:16
```
Si existe pero está detenido: `docker start postgres-lab`.

### Paso 3. Guardar y ejecutar cada script
1. Guarda el archivo con **Ctrl + S**. El comando lee el archivo del disco: si tiene cambios sin guardar (punto ● en la pestaña), se ejecutará la versión anterior.
2. Ejecuta, en orden del 01 al 05:
```powershell
Get-Content sql/0X-nombre.sql | docker exec -i postgres-lab psql -U postgres
```
**Nota: en la terminal debes pasar la ruta completa donde esta el archivo, en caso de no estar enla carpeta donde se encuentra**
Por ejemplo: `Get-Content sql/01-clasificacion.sql | docker exec -i postgres-lab psql -U postgres` cuando estes dentro de la carpeta donde se encuentra el archivo

Por ejemplo: `Get-Content "<ruta-del-laboratorio>\sql\01-clasificacion.sql" | docker exec -i postgres-lab psql -U postgres` cuando no estes dentro de la carpeta donde se encuentra el archivo

### ¿Por qué se usa ese comando?

Los scripts están en mi computadora y PostgreSQL corre dentro del contenedor, que no ve mis carpetas. El comando conecta ambos mundos:

| Parte | Qué hace |
|---|---|
| `Get-Content sql/0X-nombre.sql` | Lee el contenido del script en mi equipo (PowerShell) |
| `\|` (pipe) | Envía ese contenido como entrada del siguiente comando |
| `docker exec` | Ejecuta un comando dentro de un contenedor que ya está corriendo |
| `-i` | Mantiene abierta la entrada estándar, necesaria para recibir el script por el pipe |
| `postgres-lab` | Nombre del contenedor |
| `psql -U postgres` | Cliente de PostgreSQL conectado como el usuario `postgres`; lee el SQL recibido y lo ejecuta |

Notas:
- No se usa `-t` (como en `-it`) porque con un pipe no hay terminal interactiva y Docker mostraría el error *"the input device is not a TTY"*. Para una sesión interactiva sí se usa `docker exec -it postgres-lab psql -U postgres`.
- Los scripts están escritos **sin acentos** para evitar problemas de codificación al pasar el texto por PowerShell hacia el contenedor.
- Alternativa equivalente: copiar el archivo al contenedor (`docker cp`) y ejecutarlo con `psql -f`. Se prefiere el pipe porque no deja archivos dentro del contenedor.

### Paso 4. Verificar los controles
Los roles `soporte` y `analista` son `NOLOGIN`, por lo que no se puede iniciar sesión con ellos. Se simulan con `SET ROLE` desde `postgres`:

```powershell
# Soporte: permitido (vista enmascarada) y rechazado (tabla original)
docker exec -i postgres-lab psql -U postgres -c "SET ROLE soporte; SELECT * FROM v_clientes_soporte;"
docker exec -i postgres-lab psql -U postgres -c "SET ROLE soporte; SELECT * FROM clientes;"

# Analista: permitido (datos seudonimizados) y rechazados (mapa y tabla original)
docker exec -i postgres-lab psql -U postgres -c "SET ROLE analista; SELECT * FROM analitica.clientes;"
docker exec -i postgres-lab psql -U postgres -c "SET ROLE analista; SELECT * FROM pii.mapa_cliente;"
docker exec -i postgres-lab psql -U postgres -c "SET ROLE analista; SELECT * FROM public.clientes;"

# Permisos aplicados
docker exec -i postgres-lab psql -U postgres -c "\dp clientes" -c "\dp v_clientes_soporte"
```
Los intentos rechazados deben mostrar `ERROR: permission denied ...`.

### Paso 5. Registrar el avance en Git
Desde el panel **Control de código fuente** de VS Code (o con la terminal):
```powershell
git add .
git commit -m "feat: descripcion del avance"
git push
```
Se hace un commit por etapa para dejar visible la evolución del trabajo.

## Repetir la práctica desde cero
- El `01` usa `DROP TABLE ... CASCADE`, lo que elimina también la vista del `02`. Después de volver a ejecutar el 01, hay que ejecutar de nuevo el 02, el 03, etc., en orden.
- El `03` se puede re-ejecutar sin errores (reinicia sus esquemas y el rol `analista`).
- Al re-ejecutar el `02`, el aviso `role "soporte" already exists` es esperado e inofensivo.

## Notas
- Todos los datos son ficticios.
- El umbral `COUNT(*) >= 5` de la anonimización es un parámetro didáctico: no garantiza anonimato.