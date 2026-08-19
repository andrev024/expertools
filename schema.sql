-- Schema: Sistema de trazabilidad de reparaciones
-- Motor: MySQL 8+

CREATE DATABASE IF NOT EXISTS taller_tracker
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE taller_tracker;

-- ============================================
-- USUARIO (recepcion, tecnico, admin)
-- ============================================
CREATE TABLE usuario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    rol ENUM('recepcion', 'tecnico', 'admin') NOT NULL,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- CLIENTE
-- ============================================
CREATE TABLE cliente (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    cedula VARCHAR(20) NULL,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- ARTICULO
-- ============================================
CREATE TABLE articulo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    tipo VARCHAR(100) NOT NULL,      -- taladro, pulidora, etc.
    marca VARCHAR(100),
    modelo VARCHAR(100),
    serial VARCHAR(100),
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES cliente(id)
);

-- ============================================
-- ORDEN_SERVICIO (el "ticket" principal)
-- ============================================
CREATE TABLE orden_servicio (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo_seguimiento VARCHAR(20) NOT NULL UNIQUE,  -- lo que ve el cliente
    articulo_id INT NOT NULL,
    tipo ENUM('mantenimiento', 'garantia') NOT NULL DEFAULT 'mantenimiento',
    orden_original_id INT NULL,       -- si es garantia, referencia a la orden anterior
    tecnico_asignado_id INT NULL,
    estado_actual VARCHAR(50) NOT NULL DEFAULT 'recibido',
    fecha_ingreso TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_entrega TIMESTAMP NULL,
    FOREIGN KEY (articulo_id) REFERENCES articulo(id),
    FOREIGN KEY (tecnico_asignado_id) REFERENCES usuario(id),
    FOREIGN KEY (orden_original_id) REFERENCES orden_servicio(id),
    INDEX idx_codigo_seguimiento (codigo_seguimiento)
);

-- ============================================
-- COTIZACION
-- ============================================
CREATE TABLE cotizacion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    orden_id INT NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    descripcion TEXT,
    estado ENUM('pendiente', 'aprobada', 'rechazada') NOT NULL DEFAULT 'pendiente',
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (orden_id) REFERENCES orden_servicio(id)
);

-- ============================================
-- HISTORIAL_ESTADO (la trazabilidad -- nunca se actualiza, solo se inserta)
-- ============================================
CREATE TABLE historial_estado (
    id INT AUTO_INCREMENT PRIMARY KEY,
    orden_id INT NOT NULL,
    estado VARCHAR(50) NOT NULL,
    comentario TEXT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_id INT NOT NULL,
    FOREIGN KEY (orden_id) REFERENCES orden_servicio(id),
    FOREIGN KEY (usuario_id) REFERENCES usuario(id),
    INDEX idx_orden (orden_id)
);

-- ============================================
-- NOTIFICACION (servicio desacoplado de WhatsApp)
-- ============================================
CREATE TABLE notificacion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    orden_id INT NOT NULL,
    mensaje TEXT NOT NULL,
    estado ENUM('pendiente', 'enviado', 'fallido') NOT NULL DEFAULT 'pendiente',
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (orden_id) REFERENCES orden_servicio(id)
);

