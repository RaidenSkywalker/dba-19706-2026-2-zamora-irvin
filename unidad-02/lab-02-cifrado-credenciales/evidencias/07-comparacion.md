# Evidencia 07 — Protección en reposo vs. protección en tránsito

**Estudiante:** Zamora Serrano Irvin Donovan | **Fecha:** 2026-10-27

## Objetivo
Asociar cada situación con el mecanismo criptográfico apropiado y lo que protege.

## Resultado obtenido

| Situación | Mecanismo apropiado | ¿Qué protege? |
|---|---|---|
| Contraseña de usuario | Hash con sal mediante derivación de claves para contraseñas (bcrypt, scrypt o Argon2id; en el lab, `crypt()` + `gen_salt('bf')`) | Que una filtración de la base no revele la contraseña; solo permite verificarla |
| RFC almacenado en una tabla | Cifrado simétrico (`pgp_sym_encrypt`) con la clave fuera de la base | Confidencialidad del dato en reposo frente a lectura directa de tablas, archivos o respaldos |
| Consulta enviada desde un cliente al servidor | TLS (idealmente `sslmode=verify-full`) | Confidencialidad, integridad y autenticación del servidor durante la transmisión |
| Respaldo de una base de datos | Cifrado del respaldo (p. ej. `pg_dump` cifrado con `gpg`/`age` o cifrado del almacenamiento) más control de acceso al archivo | Datos en reposo contenidos en copias de seguridad |
| Clave criptográfica | Gestión de claves: gestor de secretos / KMS / HSM, separada de datos y código, con rotación y control de acceso | Que la protección criptográfica no se anule por exposición de la clave |

## Análisis
Los mecanismos protegen problemas distintos: hash para credenciales, cifrado para datos recuperables en reposo, TLS para datos en tránsito y gestión de claves para sostener todo lo anterior.

## Conclusión
Ningún mecanismo sustituye a los demás; la protección debe ser combinada y proporcional al riesgo.
