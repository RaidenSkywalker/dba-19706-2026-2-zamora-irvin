# Informe — LAB-04 Hardening y configuración segura de PostgreSQL

**Estudiante:** Zamora Serrano Irvin Donovan | **Fecha:** 2026-11-02

## Preguntas del informe

**1. ¿Cuál era la principal superficie de ataque?**
El servicio PostgreSQL accesible por red: el puerto 5432 escuchando en `listen_addresses = '*'` (todas las interfaces), junto con reglas de `pg_hba.conf` demasiado amplias (`host all all all` y `trust` en local y loopback), `ssl = off` y `postgres` (superusuario) como única cuenta con `LOGIN`.

**2. ¿Qué configuración representaba el mayor riesgo?**
La regla `host all all all scram-sha-256` (línea 128 de `pg_hba.conf`), que permite intentar autenticarse a cualquier usuario y base desde cualquier origen, combinada con `listen_addresses = '*'` y `ssl = off` (el intento viaja sin cifrar). Además, las reglas con método `trust` en local y loopback permiten entrar sin contraseña.

**3. ¿Qué cambio produjo la mayor reducción de exposición?**
Limitar `listen_addresses` a `localhost` y reemplazar las reglas amplias de `pg_hba.conf` por reglas específicas de base de datos + usuario + origen + método. El primer cambio elimina la exposición a otras redes; el segundo limita quién puede autenticarse incluso en el origen permitido. *Nota:* ambos están preparados (`ALTER SYSTEM` ejecutado y `pg_hba.hardened.conf` listo), pero la verificación posterior todavía muestra `listen_addresses = '*'` con `pending_restart = t` y las reglas originales, por lo que su efecto queda pendiente de comprobar. El cambio ya verificado con mayor efecto es la separación de cuentas con mínimo privilegio (`app_user` y `consulta_user` reciben `permission denied` en `DELETE`, lectura de `clientes` y DDL).

**4. ¿Qué diferencia existe entre firewall y `pg_hba.conf`?**
El firewall decide si el tráfico llega al puerto (control de red, antes de PostgreSQL). `pg_hba.conf` decide, cuando la conexión ya llegó, si un usuario puede autenticarse en una base desde un origen y con qué método. Se complementan: uno no sustituye al otro.

**5. ¿Qué diferencia existe entre autenticación y autorización?**
La autenticación verifica quién es el usuario (por ejemplo, usuario y contraseña). La autorización determina qué puede hacer después (privilegios sobre objetos). Una contraseña fuerte no limita lo que la cuenta puede hacer.

**6. ¿Por qué una cuenta de aplicación no debe ser SUPERUSER?**
Si la aplicación se compromete (por ejemplo, por una inyección SQL), el atacante hereda todos los privilegios: leer y borrar cualquier dato, crear roles, saltarse permisos y, en PostgreSQL, incluso ejecutar comandos en el servidor. Con privilegios mínimos, el daño se limita a lo que la función de la aplicación necesita.

**7. ¿Por qué cambiar el puerto de PostgreSQL no constituye hardening suficiente?**
Cambiar 5432 por otro puerto solo reduce el ruido de escaneos automáticos: un escaneo de puertos lo encuentra igualmente. No añade autenticación, autorización, restricción de origen ni cifrado.

**8. ¿Por qué `listen_addresses='*'` puede ser innecesario?**
Porque expone el servicio en todas las interfaces, incluso las que no necesita. Aunque `pg_hba.conf` y el firewall restrinjan, cada interfaz expuesta amplía la superficie. Si solo se necesita acceso local o desde una red concreta, se debe escuchar únicamente ahí.

**9. ¿Qué papel tiene el sistema operativo en la seguridad de PostgreSQL?**
Protege los archivos que `GRANT` y `REVOKE` no controlan: directorio de datos, `postgresql.conf`, `pg_hba.conf`, certificados y claves. También define la cuenta de servicio, el firewall del equipo y las actualizaciones. Si un usuario del sistema puede leer esos archivos, se salta los permisos SQL.

**10. ¿Qué controles deberían revisarse periódicamente?**
Reglas de `pg_hba.conf`, roles y privilegios (sobre todo superusuarios y cuentas sin uso), extensiones, parámetros de conexión y tiempos, certificados TLS y su caducidad, permisos de archivos del sistema operativo, versiones y parches, registros de conexión, y la capacidad de restaurar respaldos.

## Reflexión
**¿Qué cambiarías primero en un servidor PostgreSQL de producción ya en funcionamiento?**
Primero **observar sin cambiar nada** y respaldar: inventariar quién se conecta (`pg_stat_activity`, `log_connections`) y guardar copia de `pg_hba.conf`. El primer cambio sería **restringir la exposición de red y las reglas de `pg_hba.conf`** a los orígenes realmente necesarios, por esto:
- **Riesgo y exposición:** es lo que más reduce la probabilidad de un ataque remoto, porque quita la posibilidad de intentar autenticarse desde cualquier lugar.
- **Impacto y disponibilidad:** `pg_hba.conf` se recarga sin reiniciar y sin cortar las sesiones existentes, y es reversible de inmediato. Cambiar privilegios de las aplicaciones o exigir TLS puede romper clientes y requiere coordinación.
- **Continuidad:** con el inventario previo se evita bloquear una conexión legítima, y con el respaldo de la regla anterior se vuelve atrás en segundos.
- **Después:** separar cuentas y privilegios mínimos, luego SCRAM y TLS, y finalmente tiempos, registros y parches.

## Anexo A. Preguntas de las actividades

- **A1 — ¿Por qué conocer la superficie de ataque debe preceder al hardening?** Porque no se puede proteger lo que no se conoce. Cambiar sin inventario puede romper conexiones legítimas y dejar expuesto lo que se pasó por alto.
- **A2 — ¿Por qué importa la ubicación física de los archivos?** Permite distinguir datos, configuración, autenticación y registros, protegerlos con permisos del sistema operativo, incluirlos en respaldos y vigilar su modificación.
- **A3 — ¿Qué arquitectura reduce mejor la exposición?** La segunda: el servidor queda en una red privada detrás del firewall y no es alcanzable desde Internet. La primera deja el puerto 5432 expuesto aunque haya firewall, y una regla permisiva basta para exponerlo.
- **A7 — Autenticación vs autorización:** ver pregunta 5. **¿Qué protege `scram-sha-256`?** Evita enviar o almacenar la contraseña en claro o como un valor reutilizable: usa sal y desafío-respuesta, por lo que un hash capturado no sirve directamente para autenticarse. **¿Contraseña almacenada = cifrado reversible?** No: es un verificador (hash) del que no se recupera la contraseña. **¿Cuenta con permisos excesivos pero contraseña fuerte?** Sigue siendo peligrosa: si se compromete (aplicación vulnerable, phishing, reutilización), el atacante tiene todos esos permisos.
- **A8 — ¿Por qué no usar SUPERUSER en una aplicación?** Ver pregunta 6.
- **A9 — ¿Qué riesgo hay si la aplicación usa una cuenta administrativa?** Una vulnerabilidad de la aplicación se convierte en control total del servidor y de los datos, y se pierde trazabilidad por función.
- **A11 — ¿Por qué mantener conexiones abiertas indefinidamente?** Consumen memoria y conexiones, retienen bloqueos y pueden agotar `max_connections` (negación de servicio).
- **A12 — ¿Por qué no basta con `GRANT` y `REVOKE`?** Solo controlan el acceso a través de PostgreSQL. Con acceso al sistema operativo se pueden leer los archivos de datos y de configuración, copiar la base o ver claves y certificados.
- **A14 — Firewall vs `pg_hba.conf`:** ver `configuracion/cambios.md` §8.

## Anexo B. Caso integral (Actividad 18)

| # | Problema | Riesgo | Control propuesto |
|---|---|---|---|
| 1 | Acepta conexiones desde cualquier IPv4 | Ataques y fuerza bruta desde Internet | Allowlist de orígenes en `pg_hba.conf` y firewall |
| 2 | La aplicación web usa un usuario administrativo | Una inyección SQL da control total | Cuenta de aplicación con privilegios mínimos |
| 3 | `listen_addresses = '*'` | Servicio expuesto en todas las interfaces | Escuchar solo en la interfaz necesaria |
| 4 | El firewall permite 5432 desde cualquier origen | Puerto alcanzable globalmente | Permitir solo la red autorizada y denegar el resto |
| 5 | `pg_hba.conf` con `all/all` desde `0.0.0.0/0` | Cualquier usuario y base desde cualquier lugar | Reglas por base + usuario + origen + método, con `reject` final |
| 6 | Se confía solo en contraseñas fuertes | Falsa seguridad: no frena inyección SQL, robo de credenciales ni vulnerabilidades | Defensa en profundidad |
| 7 | No se menciona TLS | Credenciales y datos interceptables en tránsito | TLS obligatorio (`hostssl`) |
| 8 | No hay monitoreo ni registro de conexiones | No se detectan intentos ni abusos | `log_connections`, `log_disconnections` y alertas |
| 9 | Sin separación DBA / APP / CONSULTA | Privilegio excesivo; sin trazabilidad por función | Cuentas por función y mínimo privilegio |
| 10 | Sin límites de conexiones ni tiempos máximos | Agotamiento de recursos | `max_connections` por rol y timeouts |
| 11 | Archivos de configuración y sistema operativo sin revisar | Lectura o modificación de `pg_hba.conf` y datos | Permisos 600/700 y propietario `postgres` |
| 12 | Sin política de actualización | Vulnerabilidades conocidas sin parchear | Política y ventanas de mantenimiento |

**¿Es suficiente tener contraseñas fuertes?**
No. La contraseña es solo **autenticación**: no limita la **autorización** (una cuenta administrativa con contraseña fuerte sigue teniendo control total si la aplicación se compromete), no reduce la exposición de **red** (cualquiera puede intentar conectarse, atacar vulnerabilidades previas a la autenticación o provocar denegación de servicio), no corrige una **configuración** permisiva (`0.0.0.0/0`, `'*'`), no protege el **sistema operativo** (archivos legibles) y no ofrece **monitoreo** para detectar abusos. La seguridad depende de varias capas que se refuerzan entre sí.
