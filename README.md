# DBA 19706 — Gestión de Seguridad y Desempeño de Bases de Datos

**Estudiante:** Zamora Serrano Irvin Donovan — Grupo 4-3
**Motor:** PostgreSQL 16 en Docker (contenedor `postgres-lab`)

**NOTA:** Se desarrollo otro repositorio para tener un nuevo orden en cuanto al desarrollo de cada practica

Repositorio con los laboratorios de la **Unidad II — Seguridad, privacidad y control de acceso**, organizados en orden y con la estructura que pide cada práctica.

## Laboratorios

| # | Laboratorio | Tema | Carpeta | Estado |
|---|---|---|---|---|
| 1 | LAB-01 | Protección y privacidad de datos | [`unidad-02/lab-01-proteccion-privacidad`](unidad-02/lab-01-proteccion-privacidad) | Entregado |
| 2 | LAB-02 | Cifrado, credenciales y comunicaciones seguras | [`unidad-02/lab-02-cifrado-credenciales`](unidad-02/lab-02-cifrado-credenciales) | Entregado |
| 3 | LAB-03 | Privacidad, cumplimiento y gobierno de datos | [`unidad-02/lab-03-privacidad-cumplimiento`](unidad-02/lab-03-privacidad-cumplimiento) | `<completar>` |
| 4 | LAB-04 | Hardening y configuración segura de PostgreSQL | [`unidad-02/lab-04-hardening`](unidad-02/lab-04-hardening) | `<completar>` |

## Historial de trabajo
El historial detallado de commits del desarrollo de cada práctica (octubre–noviembre de 2026) está en el repositorio de trabajo: <https://github.com/RaidenSkywalker/LAB-01-Proteccion-Datos>.
Este repositorio presenta los mismos laboratorios ya organizados.

## Orden de ejecución sugerido
Los laboratorios se apoyan unos en otros (la tabla `clientes` del LAB-01 se reutiliza en los siguientes):
LAB-01 → LAB-02 → LAB-03 → LAB-04. El LAB-04 modifica la configuración de acceso del contenedor, por lo que se realiza al final y después de respaldar.

Cada carpeta incluye su propio `README.md` con el procedimiento y las instrucciones de ejecución.
