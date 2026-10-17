-- Esquema de base de datos (solo estructura; sin datos)

CREATE TABLE IF NOT EXISTS `accesorio` (
  `id` int NOT NULL AUTO_INCREMENT,
  `articulo_id` int NOT NULL,
  `nombre` varchar(150) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `articulo_id` (`articulo_id`),
  CONSTRAINT `accesorio_ibfk_1` FOREIGN KEY (`articulo_id`) REFERENCES `articulo` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `articulo` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cliente_id` int NOT NULL,
  `tipo` varchar(100) NOT NULL,
  `marca` varchar(100) DEFAULT NULL,
  `modelo` varchar(100) DEFAULT NULL,
  `serial` varchar(100) DEFAULT NULL,
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `cliente_id` (`cliente_id`),
  CONSTRAINT `articulo_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `cliente` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `cliente` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(150) DEFAULT NULL,
  `telefono` varchar(60) DEFAULT NULL,
  `telefono_2` varchar(30) DEFAULT NULL,
  `cedula` varchar(20) DEFAULT NULL,
  `empresa` varchar(150) DEFAULT NULL,
  `correo` varchar(150) DEFAULT NULL,
  `direccion` varchar(255) DEFAULT NULL,
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `cotizacion` (
  `id` int NOT NULL AUTO_INCREMENT,
  `orden_id` int NOT NULL,
  `repuestos` text,
  `dictamen` text,
  `monto` decimal(12,2) NOT NULL,
  `abono` decimal(12,2) NOT NULL DEFAULT '0.00',
  `subtotal` decimal(12,2) DEFAULT NULL,
  `iva` decimal(12,2) DEFAULT '0.00',
  `canal_aprobacion` enum('presencial','whatsapp') DEFAULT NULL,
  `estado` enum('pendiente','aprobada','rechazada','sin_respuesta') NOT NULL DEFAULT 'pendiente',
  `fecha_registro` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_respuesta` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `orden_id` (`orden_id`),
  CONSTRAINT `cotizacion_ibfk_1` FOREIGN KEY (`orden_id`) REFERENCES `orden_servicio` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `cotizacion_detalle` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cotizacion_id` int NOT NULL,
  `item_n` int DEFAULT NULL,
  `codigo` varchar(50) DEFAULT NULL,
  `cantidad` decimal(10,2) NOT NULL DEFAULT '1.00',
  `descripcion` varchar(255) NOT NULL,
  `precio_unitario` decimal(12,2) DEFAULT NULL,
  `precio_total` decimal(12,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `cotizacion_id` (`cotizacion_id`),
  CONSTRAINT `cotizacion_detalle_ibfk_1` FOREIGN KEY (`cotizacion_id`) REFERENCES `cotizacion` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `historial_estado` (
  `id` int NOT NULL AUTO_INCREMENT,
  `orden_id` int NOT NULL,
  `estado` varchar(50) NOT NULL,
  `comentario` text,
  `fecha` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `usuario_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `usuario_id` (`usuario_id`),
  KEY `idx_orden` (`orden_id`),
  CONSTRAINT `historial_estado_ibfk_1` FOREIGN KEY (`orden_id`) REFERENCES `orden_servicio` (`id`),
  CONSTRAINT `historial_estado_ibfk_2` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `notificacion` (
  `id` int NOT NULL AUTO_INCREMENT,
  `orden_id` int NOT NULL,
  `mensaje` text NOT NULL,
  `estado` enum('pendiente','enviado','fallido') NOT NULL DEFAULT 'pendiente',
  `fecha` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `orden_id` (`orden_id`),
  CONSTRAINT `notificacion_ibfk_1` FOREIGN KEY (`orden_id`) REFERENCES `orden_servicio` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `orden_servicio` (
  `id` int NOT NULL AUTO_INCREMENT,
  `codigo_seguimiento` varchar(20) NOT NULL,
  `articulo_id` int NOT NULL,
  `tipo` enum('reparacion','garantia') NOT NULL DEFAULT 'reparacion',
  `orden_original_id` int DEFAULT NULL,
  `tecnico_asignado_id` int DEFAULT NULL,
  `estado_actual` varchar(50) NOT NULL DEFAULT 'recibido',
  `ubicacion_actual` varchar(150) DEFAULT NULL,
  `intentos_contacto_cliente` int NOT NULL DEFAULT '0',
  `observaciones` text,
  `fecha_ingreso` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_entrega` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `codigo_seguimiento` (`codigo_seguimiento`),
  KEY `articulo_id` (`articulo_id`),
  KEY `tecnico_asignado_id` (`tecnico_asignado_id`),
  KEY `orden_original_id` (`orden_original_id`),
  KEY `idx_codigo_seguimiento` (`codigo_seguimiento`),
  CONSTRAINT `orden_servicio_ibfk_1` FOREIGN KEY (`articulo_id`) REFERENCES `articulo` (`id`),
  CONSTRAINT `orden_servicio_ibfk_2` FOREIGN KEY (`tecnico_asignado_id`) REFERENCES `usuario` (`id`),
  CONSTRAINT `orden_servicio_ibfk_3` FOREIGN KEY (`orden_original_id`) REFERENCES `orden_servicio` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `usuario` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `rol` enum('recepcion','tecnico','admin') NOT NULL,
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
