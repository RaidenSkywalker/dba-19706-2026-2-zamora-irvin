# Evidencia 10 — Política mínima de protección de claves

**Estudiante:** Zamora Serrano Irvin Donovan | **Fecha:** 2026-10-27

## Objetivo
Definir reglas básicas para la gestión del ciclo de vida de las claves criptográficas.

## Política

1. **Generación:** las claves se generan con fuentes aleatorias criptográficamente seguras y con la longitud recomendada; nunca se derivan de datos predecibles ni se inventan manualmente.
2. **Almacenamiento:** las claves se guardan en un gestor de secretos o KMS, separadas de los datos que protegen y fuera de repositorios, scripts y archivos de configuración versionados.
3. **Acceso:** solo las aplicaciones y personas que lo necesitan pueden usar una clave (mínimo privilegio), con identidad individual y registro de cada uso.
4. **Rotación:** las claves se rotan periódicamente y siempre que cambie el personal con acceso; los datos se recifran con la clave nueva.
5. **Respaldo:** las claves tienen copia de seguridad cifrada y guardada en un lugar distinto al de los datos, porque perder la clave equivale a perder la información cifrada.
6. **Revocación:** ante sospecha de compromiso, la clave se revoca de inmediato y se sustituye por una nueva.
7. **Exposición accidental:** si una clave aparece en un repositorio, correo o captura, se considera comprometida aunque se borre; se rota, se recifran los datos y se revisa el historial y los accesos.
8. **Eliminación:** cuando una clave se retira, se destruye de forma segura en todos sus almacenes y copias, tras confirmar que ya no hay datos que dependan de ella.

## Análisis
Las reglas cubren generación, almacenamiento, acceso, rotación, respaldo, revocación, exposición accidental y eliminación.

## Conclusión
La fortaleza del cifrado depende tanto de cómo se administran las claves como del algoritmo usado.
