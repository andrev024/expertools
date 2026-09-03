-- Schema v2: Sistema de trazabilidad de reparaciones
-- Motor: MySQL 8+
-- Cambios respecto a v1: cotizacion ahora la hace el tecnico (repuestos, dictamen,
-- canal de aprobacion), y orden_servicio trackea intentos de contacto al cliente.

CREATE DATABASE IF NOT EXISTS taller_tracker
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE taller_tracker;

-- ============================================
-- USUARIO
-- ============================================
CREATE TABLE IF NOT EXISTS usuario (
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
CREATE TABLE IF NOT EXISTS cliente (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    cedula VARCHAR(20) NULL,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- ARTICULO
-- ============================================
CREATE TABLE IF NOT EXISTS articulo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    tipo VARCHAR(100) NOT NULL,
    marca VARCHAR(100),
    modelo VARCHAR(100),
    serial VARCHAR(100),
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES cliente(id)
);

-- ============================================
-- ORDEN_SERVICIO
-- ============================================
CREATE TABLE IF NOT EXISTS orden_servicio (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo_seguimiento VARCHAR(20) NOT NULL UNIQUE,
    articulo_id INT NOT NULL,
    tipo ENUM('mantenimiento', 'garantia') NOT NULL DEFAULT 'mantenimiento',
    orden_original_id INT NULL,
    tecnico_asignado_id INT NULL,
    estado_actual VARCHAR(50) NOT NULL DEFAULT 'recibido',

    -- NUEVO en v2: contador de intentos de contacto al cliente para la cotizacion.
    -- Al llegar a 3 sin respuesta, la orden pasa a estado 'sin_respuesta'.
    intentos_contacto_cliente INT NOT NULL DEFAULT 0,

    fecha_ingreso TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_entrega TIMESTAMP NULL,
    FOREIGN KEY (articulo_id) REFERENCES articulo(id),
    FOREIGN KEY (tecnico_asignado_id) REFERENCES usuario(id),
    FOREIGN KEY (orden_original_id) REFERENCES orden_servicio(id),
    INDEX idx_codigo_seguimiento (codigo_seguimiento)
);

-- ============================================
-- COTIZACION (v2: ahora la arma el tecnico, con repuestos + dictamen)
-- ============================================
CREATE TABLE IF NOT EXISTS cotizacion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    orden_id INT NOT NULL,

    -- NUEVO en v2: lo que antes no existia, ahora capturado explicitamente.
    repuestos TEXT,       -- referencias, cantidades y descripcion del repuesto
    dictamen TEXT,        -- diagnostico del tecnico: que fallo y por que

    monto DECIMAL(10,2) NOT NULL,

    -- NUEVO en v2: por cual canal se le informo/aprobo al cliente
    canal_aprobacion ENUM('presencial', 'whatsapp') NULL,

    estado ENUM('pendiente', 'aprobada', 'rechazada', 'sin_respuesta') NOT NULL DEFAULT 'pendiente',
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_respuesta TIMESTAMP NULL,
    FOREIGN KEY (orden_id) REFERENCES orden_servicio(id)
);

-- ============================================
-- HISTORIAL_ESTADO
-- ============================================
CREATE TABLE IF NOT EXISTS historial_estado (
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
-- NOTIFICACION
-- ============================================
CREATE TABLE IF NOT EXISTS notificacion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    orden_id INT NOT NULL,
    mensaje TEXT NOT NULL,
    estado ENUM('pendiente', 'enviado', 'fallido') NOT NULL DEFAULT 'pendiente',
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (orden_id) REFERENCES orden_servicio(id)
);
