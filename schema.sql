-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 03-09-2026 a las 21:07:37
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `taller_tracker`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `articulo`
--

CREATE TABLE `articulo` (
  `id` int(11) NOT NULL,
  `cliente_id` int(11) NOT NULL,
  `tipo` varchar(100) NOT NULL,
  `marca` varchar(100) DEFAULT NULL,
  `modelo` varchar(100) DEFAULT NULL,
  `serial` varchar(100) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `articulo`
--

INSERT INTO `articulo` (`id`, `cliente_id`, `tipo`, `marca`, `modelo`, `serial`, `creado_en`) VALUES
(1, 1, 'Taladro', 'DeWalt', 'DW505', 'SN12345', '2026-08-18 20:57:16'),
(2, 2, 'tala', 'dewalt', '333', '333', '2026-09-02 07:01:04');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cliente`
--

CREATE TABLE `cliente` (
  `id` int(11) NOT NULL,
  `nombre` varchar(150) NOT NULL,
  `telefono` varchar(20) NOT NULL,
  `cedula` varchar(20) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `cliente`
--

INSERT INTO `cliente` (`id`, `nombre`, `telefono`, `cedula`, `creado_en`) VALUES
(1, 'Juan Pérez', '3001234567', NULL, '2026-08-18 20:57:15'),
(2, 'cati', '311', NULL, '2026-09-02 07:01:04');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cotizacion`
--

CREATE TABLE `cotizacion` (
  `id` int(11) NOT NULL,
  `orden_id` int(11) NOT NULL,
  `repuestos` text DEFAULT NULL,
  `dictamen` text DEFAULT NULL,
  `monto` decimal(10,2) NOT NULL,
  `canal_aprobacion` enum('presencial','whatsapp') DEFAULT NULL,
  `descripcion` text DEFAULT NULL,
  `estado` enum('pendiente','aprobada','rechazada','sin_respuesta') NOT NULL DEFAULT 'pendiente',
  `fecha_registro` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_respuesta` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `cotizacion`
--

INSERT INTO `cotizacion` (`id`, `orden_id`, `repuestos`, `dictamen`, `monto`, `canal_aprobacion`, `descripcion`, `estado`, `fecha_registro`, `fecha_respuesta`) VALUES
(1, 8, '3 piezas de tornillos', 'falla electrica', 50000.00, 'presencial', NULL, 'aprobada', '2026-09-02 07:05:27', '2026-09-02 07:20:29');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `historial_estado`
--

CREATE TABLE `historial_estado` (
  `id` int(11) NOT NULL,
  `orden_id` int(11) NOT NULL,
  `estado` varchar(50) NOT NULL,
  `comentario` text DEFAULT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp(),
  `usuario_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `historial_estado`
--

INSERT INTO `historial_estado` (`id`, `orden_id`, `estado`, `comentario`, `fecha`, `usuario_id`) VALUES
(9, 8, 'recibido', 'Articulo recibido en recepcion', '2026-09-02 07:02:18', 1),
(10, 9, 'recibido', 'Articulo recibido en recepcion', '2026-09-02 07:03:00', 1),
(11, 8, 'en_diagnostico', '', '2026-09-02 07:04:36', 4),
(12, 8, 'cotizado', 'Cotización: falla electrica - $50000', '2026-09-02 07:05:27', 4),
(13, 8, 'cotizado', 'Intento de contacto #1 sin respuesta', '2026-09-02 07:08:44', 4),
(14, 8, 'en_reparacion', 'Cliente respondió: aprobada (via presencial)', '2026-09-02 07:20:29', 4),
(15, 8, 'esperando_repuesto', '', '2026-09-02 07:20:42', 4),
(16, 8, 'en_reparacion', '', '2026-09-02 07:20:43', 4),
(17, 8, 'esperando_repuesto', '', '2026-09-02 07:20:47', 4),
(18, 8, 'en_reparacion', '', '2026-09-02 07:20:52', 4),
(19, 8, 'finalizado_tecnico', '', '2026-09-02 07:20:53', 4),
(20, 8, 'en_revision_recepcion', '', '2026-09-02 07:21:04', 4),
(21, 8, 'listo_para_entregar', '', '2026-09-02 07:21:24', 1),
(22, 8, 'entregado', '', '2026-09-02 07:21:32', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `notificacion`
--

CREATE TABLE `notificacion` (
  `id` int(11) NOT NULL,
  `orden_id` int(11) NOT NULL,
  `mensaje` text NOT NULL,
  `estado` enum('pendiente','enviado','fallido') NOT NULL DEFAULT 'pendiente',
  `fecha` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `orden_servicio`
--

CREATE TABLE `orden_servicio` (
  `id` int(11) NOT NULL,
  `codigo_seguimiento` varchar(20) NOT NULL,
  `articulo_id` int(11) NOT NULL,
  `tipo` enum('mantenimiento','garantia') NOT NULL DEFAULT 'mantenimiento',
  `orden_original_id` int(11) DEFAULT NULL,
  `tecnico_asignado_id` int(11) DEFAULT NULL,
  `estado_actual` varchar(50) NOT NULL DEFAULT 'recibido',
  `fecha_ingreso` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_entrega` timestamp NULL DEFAULT NULL,
  `intentos_contacto_cliente` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `orden_servicio`
--

INSERT INTO `orden_servicio` (`id`, `codigo_seguimiento`, `articulo_id`, `tipo`, `orden_original_id`, `tecnico_asignado_id`, `estado_actual`, `fecha_ingreso`, `fecha_entrega`, `intentos_contacto_cliente`) VALUES
(8, 'TAL-CA2645', 2, 'mantenimiento', NULL, NULL, 'entregado', '2026-09-02 07:02:18', '2026-09-02 07:21:32', 1),
(9, 'TAL-393BDD', 2, 'garantia', NULL, NULL, 'recibido', '2026-09-02 07:03:00', NULL, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `rol` enum('recepcion','tecnico','admin') NOT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`id`, `nombre`, `email`, `password_hash`, `rol`, `creado_en`) VALUES
(1, 'Admin Prueba', 'admin@test.com', '$2y$10$Vnuxoi/43pcVsoHLoICCzuMVZ.83A4FrbXZWNc9K10S/9/Oc8UfHG', 'recepcion', '2026-08-08 04:27:02'),
(4, 'Carlos Técnico', 'tecnico@test.com', '$2y$10$mafxMcE81OrvHDy9gNcgduj3v7xgG9gOd9jtB8zDTDebWEo7W1zlu', 'tecnico', '2026-09-02 01:12:36');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `articulo`
--
ALTER TABLE `articulo`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cliente_id` (`cliente_id`);

--
-- Indices de la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `cotizacion`
--
ALTER TABLE `cotizacion`
  ADD PRIMARY KEY (`id`),
  ADD KEY `orden_id` (`orden_id`);

--
-- Indices de la tabla `historial_estado`
--
ALTER TABLE `historial_estado`
  ADD PRIMARY KEY (`id`),
  ADD KEY `usuario_id` (`usuario_id`),
  ADD KEY `idx_orden` (`orden_id`);

--
-- Indices de la tabla `notificacion`
--
ALTER TABLE `notificacion`
  ADD PRIMARY KEY (`id`),
  ADD KEY `orden_id` (`orden_id`);

--
-- Indices de la tabla `orden_servicio`
--
ALTER TABLE `orden_servicio`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `codigo_seguimiento` (`codigo_seguimiento`),
  ADD KEY `articulo_id` (`articulo_id`),
  ADD KEY `tecnico_asignado_id` (`tecnico_asignado_id`),
  ADD KEY `orden_original_id` (`orden_original_id`),
  ADD KEY `idx_codigo_seguimiento` (`codigo_seguimiento`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `articulo`
--
ALTER TABLE `articulo`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `cliente`
--
ALTER TABLE `cliente`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `cotizacion`
--
ALTER TABLE `cotizacion`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `historial_estado`
--
ALTER TABLE `historial_estado`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT de la tabla `notificacion`
--
ALTER TABLE `notificacion`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `orden_servicio`
--
ALTER TABLE `orden_servicio`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `articulo`
--
ALTER TABLE `articulo`
  ADD CONSTRAINT `articulo_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `cliente` (`id`);

--
-- Filtros para la tabla `cotizacion`
--
ALTER TABLE `cotizacion`
  ADD CONSTRAINT `cotizacion_ibfk_1` FOREIGN KEY (`orden_id`) REFERENCES `orden_servicio` (`id`);

--
-- Filtros para la tabla `historial_estado`
--
ALTER TABLE `historial_estado`
  ADD CONSTRAINT `historial_estado_ibfk_1` FOREIGN KEY (`orden_id`) REFERENCES `orden_servicio` (`id`),
  ADD CONSTRAINT `historial_estado_ibfk_2` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`);

--
-- Filtros para la tabla `notificacion`
--
ALTER TABLE `notificacion`
  ADD CONSTRAINT `notificacion_ibfk_1` FOREIGN KEY (`orden_id`) REFERENCES `orden_servicio` (`id`);

--
-- Filtros para la tabla `orden_servicio`
--
ALTER TABLE `orden_servicio`
  ADD CONSTRAINT `orden_servicio_ibfk_1` FOREIGN KEY (`articulo_id`) REFERENCES `articulo` (`id`),
  ADD CONSTRAINT `orden_servicio_ibfk_2` FOREIGN KEY (`tecnico_asignado_id`) REFERENCES `usuario` (`id`),
  ADD CONSTRAINT `orden_servicio_ibfk_3` FOREIGN KEY (`orden_original_id`) REFERENCES `orden_servicio` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
