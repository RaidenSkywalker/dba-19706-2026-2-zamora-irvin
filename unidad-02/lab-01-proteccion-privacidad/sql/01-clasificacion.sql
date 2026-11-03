-- ==========================================
-- ACTIVIDAD 1: PREPARACIÓN Y CLASIFICACIÓN
-- Estudiante: Zamora Serrano Irvin Donovan
-- Fecha: 2026-10-23
-- ==========================================

-- 1. Eliminar la tabla previa y sus dependencias si existen
DROP TABLE IF EXISTS clientes CASCADE;

-- 2. Crear la tabla de clientes en el esquema public
CREATE TABLE IF NOT EXISTS clientes (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    correo VARCHAR(150) NOT NULL,
    telefono VARCHAR(20),
    rfc VARCHAR(13),
    edad INTEGER,
    ciudad VARCHAR(80),
    codigo_postal VARCHAR(10),
    fecha_alta DATE DEFAULT CURRENT_DATE
);

-- 3. Insertar datos de prueba
INSERT INTO clientes (nombre, correo, telefono, rfc, edad, ciudad, codigo_postal)
VALUES
('Ana Lopez', 'ana.lopez@example.test', '6671234567', 'LOAA850315ABC', 41, 'Culiacan', '80000'),
('Carlos Perez', 'carlos.perez@example.test', '6672345678', 'PECA900720DEF', 35, 'Culiacan', '80100'),
('Maria Garcia', 'maria.garcia@example.test', '6673456789', 'GAMA780912GHI', 47, 'Mazatlan', '82000'),
('Luis Torres', 'luis.torres@example.test', '6674567890', 'TOLU920201JKL', 34, 'Los Mochis', '81200'),
('Laura Sanchez', 'laura.sanchez@example.test', '6675678901', 'SALA880525MNO', 38, 'Culiacan', '80200');

-- 4. Consultas de verificación
SELECT * FROM clientes;

  -- 5. Clasificacion registrada en la base de datos
  COMMENT ON COLUMN clientes.nombre IS 'Identificador directo - requiere proteccion';
  COMMENT ON COLUMN clientes.correo IS 'Identificador directo - requiere proteccion';
  COMMENT ON COLUMN clientes.telefono IS 'Identificador directo - requiere proteccion';
  COMMENT ON COLUMN clientes.rfc IS 'Identificador directo - requiere proteccion';
  COMMENT ON COLUMN clientes.edad IS 'Cuasi-identificador - requiere proteccion';
  COMMENT ON COLUMN clientes.ciudad IS 'Cuasi-identificador - requiere proteccion';
  COMMENT ON COLUMN clientes.codigo_postal IS 'Cuasi-identificador - requiere proteccion';