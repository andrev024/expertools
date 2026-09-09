-- ============================================================
-- MIGRACION ORDENES DE TRABAJO EXPERTOOLS -> nuevo esquema v2
-- Generado automaticamente. REVISAR antes de ejecutar en Aiven.
-- ============================================================

-- --- 1. Cambios de esquema necesarios antes de insertar ---

ALTER TABLE cliente
  ADD COLUMN empresa VARCHAR(150) NULL,
  ADD COLUMN correo VARCHAR(150) NULL,
  ADD COLUMN direccion VARCHAR(255) NULL,
  MODIFY COLUMN telefono VARCHAR(30) NULL,   -- 38 de 381 ordenes no traen telefono
  MODIFY COLUMN nombre VARCHAR(150) NULL;    -- 3 ordenes no traen nombre ni empresa

ALTER TABLE cotizacion
  ADD COLUMN subtotal DECIMAL(12,2) NULL,
  ADD COLUMN iva DECIMAL(12,2) NULL DEFAULT 0;

ALTER TABLE orden_servicio
  ADD COLUMN observaciones TEXT NULL;  -- campo libre "ACCESORIOS Y/O COMENTARIOS" del formato original

CREATE TABLE IF NOT EXISTS cotizacion_detalle (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cotizacion_id INT NOT NULL,
    item_n INT NULL,
    codigo VARCHAR(50) NULL,
    cantidad DECIMAL(10,2) NOT NULL DEFAULT 1,
    descripcion VARCHAR(255) NOT NULL,
    precio_unitario DECIMAL(12,2) NULL,
    precio_total DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (cotizacion_id) REFERENCES cotizacion(id) ON DELETE CASCADE
);

-- --- 2. Datos migrados desde el Excel (1 bloque por OT) ---

-- ===== OT 0824 (hoja original: 824-COT ENV) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES (NULL, 'INDUSTRIAS MARLO SAS', NULL, NULL, '3103324837-3162371812', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'MIKTA', 'GA7020', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0824', @articulo_id, 'COT ENV', NULL, '2026-02-19 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'INDUCIDO EN CORTO, SE COTIZA LAS PIEZAS PARA DEJAR FUNCIONAL LA MAQUINA', 283500.0, 283500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'INDUCIDO', 238000.0, 238000.0),
  (@cotizacion_id, 2, 'CB204', 1.0, 'ESCOBILLAS', 22000.0, 22000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'MANO DE OBRA Y MANTENIMIENTO', 23500.0, 23500.0);

-- ===== OT 0823 (hoja original: 823-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('LUIS ALBEIRO PEREA', NULL, '11707987', NULL, '3208552886', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'WSATTOOLS', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0823', @articulo_id, 'INGRESO', NULL, '2026-02-14 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA CON CINCEL ATASCADO, NECESARIO CAMBAIAR PORTA BROCAS, MANTENIMIENTO GENERAL', 103500.0, 103500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'PORTA BROCAS', NULL, 70000.0),
  (@cotizacion_id, 2, NULL, 1, 'ANILLO', NULL, 5000.0),
  (@cotizacion_id, 3, NULL, 1, 'SERVICIO DE MANTENIMIENTONYBMANO DE OBRA', NULL, 28500.0);

-- ===== OT 0822 (hoja original: 822-COT ENV) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES (NULL, 'SOLUCIONES Y AUTOMATIZACIONES', '900758272-5', NULL, '3138341759', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PISTOLA DE CALOR', 'SKILL', '8003', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0822', @articulo_id, 'COT ENV', 'NO ENCINDE SIN BOQUILLA CLAVIJA AVERIADA', '2026-02-19 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'NO JUSTIFICA REPARACIÓN, INTERRUPTOR CIRCUITO DE TARJETA CON COMPONENTE ELECTRONICO ABIERTO, RESISTENCIA PRESENTA FUSIBLE TERMICO ABIERTO.', 0.0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'TARJETA', NULL, 0),
  (@cotizacion_id, 2, NULL, 1, 'RESISTENCIA', NULL, 0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'COT ENV', 'INGRESO ENV'),
  (@orden_id, 'COT ENV', 'COT ENVI-23');

-- ===== OT 0821 (hoja original: 821-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES (NULL, 'SOLUCIONES Y AUTOMATIZACIONES', '900758272-5', NULL, '3138341759', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'TOTAL', 'UTH308268', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0821', @articulo_id, 'INGRESO', 'SIN ACCESORIOS SOLO INGRESA CON MANDRIL SDS- CLAVIJA AVERIADA NO ENCINDE', '2026-02-19 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 133500.0, 133500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'LAMINAS', 20000.0, 20000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'REVERSIBLE', 20000.0, 20000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'ESCOBILLAS', 12000.0, 12000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'CLAVIJA', 8000.0, 8000.0),
  (@cotizacion_id, 5, NULL, 1.0, 'MANDRIL', 45000.0, 45000.0),
  (@cotizacion_id, 6, NULL, 1, 'MANO DE OBRA', 28500.0, 28500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'INGRESO', 'INGRESO ENV');

-- ===== OT 0820 (hoja original: 820-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES (NULL, 'SOLUCIONES Y AUTOMATIZACIONES', '900758272-5', NULL, '3138341759', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'SOPLADORA', 'STANLEY', 'STPT600-B3', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0820', @articulo_id, 'INGRESO', 'SIN BOQUILLA - CABLE SIN CLAVIJA', '2026-02-19 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'INGRESO', 'INGRESO ENV');

-- ===== OT 0819 (hoja original:  819-COT ENV) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES (NULL, 'SOLUCIONES Y AUTOMATIZACIONES', '900758272-5', NULL, '3138341759', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4 1/2', 'INGCO', 'OAG1100383', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0819', @articulo_id, 'COT ENV', 'NO ENCIENDE / SIN ACCESORIOS CABLE AVERIADO', '2026-02-19 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA CON BOBINA RECALENTADA, RODAMIENTO FATIGADO, CALVIJA EN CORTESIA, SERVICIO DE LIMPIEZA Y MANTENIMIENTO GENERAL', 105500.0, 105500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'BOBINA', NULL, 70000.0),
  (@cotizacion_id, 2, NULL, 1, 'RODAMIENTO', NULL, 12000.0),
  (@cotizacion_id, 3, NULL, 1, 'CLAVIJA', NULL, 0),
  (@cotizacion_id, 4, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 23500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'COT ENV', 'INGRESO ENV'),
  (@orden_id, 'COT ENV', 'LISTA');

-- ===== OT 0818 (hoja original: 818-COT ENV) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES (NULL, 'SOLUCIONES Y AUTOMATIZACIONES', '900758272-5', NULL, '3138341759', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4 1/2', 'INGCO', 'OAG1100383', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0818', @articulo_id, 'COT ENV', 'NO ENCIENDE / SIN ACCSESORIOS', '2026-02-19 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA CON INDUCIDO QUEMADO, RODAMIENTO FATIGADO, ESCOBILLAS ARA CAMBIO EN UN MES , MANTENIMIENTO GENERAL', 123500.0, 123500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'INDUCIDO', NULL, 70000.0),
  (@cotizacion_id, 2, NULL, 1, 'RODAMIENTO 608', NULL, 12000.0),
  (@cotizacion_id, 3, NULL, 1, 'ESCOBILLAS', NULL, 18000.0),
  (@cotizacion_id, 4, NULL, 1, 'MANO DE OBRA Y MANTENIMIENTO', NULL, 23500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'COT ENV', 'INGRESO ENV');

-- ===== OT 0817 (hoja original: 817-ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('MAURICIO GARZON', NULL, '19437992', NULL, '3015818968', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'MAKITA', '9557PB', '1477419');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0817', @articulo_id, 'ENTREGADA', NULL, '2026-02-19 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 55500.0, 55500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'RODAMIENTO 607', 12000.0, 12000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'PIN DE BOTON', 2000.0, 2000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'BOTON', 2000.0, 2000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'MANO DE OBRA', 23500.0, 23500.0),
  (@cotizacion_id, 5, NULL, 1.0, 'ESCOBILLAS', 16000.0, 16000.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADA', 'ingreso enviado'),
  (@orden_id, 'ENTREGADA', 'COT ENV'),
  (@orden_id, 'ENTREGADA', 'ENTREGADA 20/02');

-- ===== OT 0815 (hoja original: 815-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('SILVIA', 'PINTOR ELÉCTROSTATICO', '900346300-5', 'facturacionpintorelectro@gmail.com', '3222115144', 'CR 47 132 21');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'TOTAL', NULL, '251416230344');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0815', @articulo_id, 'INGRESO', 'SIN ACCESORIOS', '2026-02-16 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0814 (hoja original: 814 -ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JOSE LUIS CEBALLOS', NULL, '79320818', 'jlccastrillon@hotmail.com', '3125605207', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'BOSH (GENERICO)', 'CBH-2-26 DFR', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0814', @articulo_id, 'ENTREGADA', 'SIN ACCESORIOS', '2026-02-16 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'EQUIPO CON DEMASIADO BOTE EN LA BROCA', 0.0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'KIT PORTABROCAS COMPLETPO', NULL, 0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADA', 'PAGADA 04/03/2026'),
  (@orden_id, 'ENTREGADA', 'ENTREGADA'),
  (@orden_id, 'ENTREGADA', 'ABONO 90.000'),
  (@orden_id, 'ENTREGADA', 'CV.1235');

-- ===== OT 0813 (hoja original: 813-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES (NULL, 'TECNIMOTOR JP', '900429531-7', NULL, '3124538636 - 3102044256', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO', 'MAKITA', 'DHP453', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0813', @articulo_id, 'ENTREGADA Y PAGADA', 'INGRESA SIN BATERIA', '2026-02-13 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA CON PIÑONES DE TRASNMISION AVERIADOS, SER REQUIERE CAMBIO COMPLETO DE LA CAJA DE ENGRANAJES', 280500.0, 280500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'CAJA ENGRANAJES', NULL, 257000.0),
  (@cotizacion_id, 2, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 23500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADA Y PAGADA', 'INGRESO ENVIADO 13/02'),
  (@orden_id, 'ENTREGADA Y PAGADA', 'PAGADA 27/04/2026'),
  (@orden_id, 'ENTREGADA Y PAGADA', 'ENTREGADA 11/4'),
  (@orden_id, 'ENTREGADA Y PAGADA', 'CV.1549'),
  (@orden_id, 'ENTREGADA Y PAGADA', 'PDT PAGO');

-- ===== OT 0812 (hoja original: 812-COT ENVIADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('SILVIA', 'PINTOR ELÉCTROSTATICO', '900346300-5', 'facturacionpintorelectro@gmail.com', '3222115144', 'CR 47 132 21');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'LIJADORA', 'MAKITA', 'M9207', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0812', @articulo_id, 'COT ENVIADA', 'INGRESA DESEMSAMBLADA', '2026-02-13 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA CON TORNILLO DE AJUSTE DE EXCENTRICA FRACTURADO EN EL EJE INTERNO DEL INDUCIDO, POR TAL MOTIVO ES NECESARIO EL CAMBIO DEL INDUCIDO QUE ES REFACCION DE ALTO VALOR', 142600.0, 142600.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'INDUCIDO', NULL, 83000.0),
  (@cotizacion_id, 2, NULL, 1, 'ESCOBILLAS', NULL, 15000.0),
  (@cotizacion_id, 3, NULL, 1, 'TORNILLO', NULL, 1200.0),
  (@cotizacion_id, 4, NULL, 1, 'PAD', NULL, 19900.0),
  (@cotizacion_id, 5, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 23500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'COT ENVIADA', 'INGRESO ENVIADO 13/02');

-- ===== OT 0811 (hoja original: 811-ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('WILLIAM GUTIERREZ', NULL, '80730916', 'william8073@hotmail.com', '3138898119', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'SIEFKEN', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0811', @articulo_id, 'ENTREGADA', NULL, '2026-02-12 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 35500.0, 35500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'RODAMIENTO', 12000.0, 12000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'MANO DE OBRA Y MANTENIMIENTO', 23500.0, 23500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADA', 'INGRESO ENV 12/02'),
  (@orden_id, 'ENTREGADA', 'ENTREGADA 23/02/2026');

-- ===== OT 0810 (hoja original: 810-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('CARLOS CARDONA', NULL, '19369045', NULL, '3107790771', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERFORADOR', 'BLACK&DECKER', 'DR320KG', '2007-41-50');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0810', @articulo_id, 'ENTREGADA Y PAGADA', NULL, '2026-02-12 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 23500.0, 23500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'MANTENIMIENTO', 23500.0, 23500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADA Y PAGADA', 'COT ENVIA-17/02/2026');

-- ===== OT 0809 (hoja original: 809-INGRESO ) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('EDWARD ARIZA', NULL, NULL, '3103324837', NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ESMERILADORA ANGULAR', 'DEWALT', 'DWE4315-B3', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0809', @articulo_id, 'INGRESO', NULL, '2026-02-11 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 379000.0, 379000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'CAMPO', 187000.0, 187000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'MANTENIMIENTO Y MANO DE OBRA', 23500.0, 23500.0),
  (@cotizacion_id, 3, NULL, 1.0, '(sin descripcion)', 150000.0, 150000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'ESCOBILLAS', 18500.0, 18500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'INGRESO', 'INGRESO ENV-11/02');

-- ===== OT 0808 (hoja original: 808-ENTREGADA SIN PAGAR) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('EDWARD ARIZA', NULL, NULL, '3103324837', NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'BLACK & DECKER', 'G720-B3', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0808', @articulo_id, 'ENTREGADA SIN PAGAR', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA CON INDUCIDO EN CORTO, ESCOBILLAS DESSGASTADAS, NECESARIO CAMBIO OBLIGATORIO', 88500.0, 88500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'INDUCIDO', NULL, 55000.0),
  (@cotizacion_id, 2, NULL, 1, 'ESCOBILLAS', NULL, 10000.0),
  (@cotizacion_id, 3, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 23500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADA SIN PAGAR', 'COT ENV-11/02'),
  (@orden_id, 'ENTREGADA SIN PAGAR', 'LISTA'),
  (@orden_id, 'ENTREGADA SIN PAGAR', 'ENTREGADA SIN PAGAR 13/02');

-- ===== OT 0807 (hoja original: 807-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JOSE OCHOA', NULL, NULL, NULL, '3213011433', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'LIJADORA', 'TRUPER', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0807', @articulo_id, 'INGRESO', NULL, '2026-02-11 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0806 (hoja original: 806-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES (NULL, 'FRENCHER SERVICIOS INDUSTRIALES LTDA', NULL, NULL, '3143479252', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'COMPRESOR', 'ELITE', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0806', @articulo_id, 'INGRESO', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'INGRESO', 'INGRESO ENV 11/02');

-- ===== OT 0805 (hoja original: 805-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('NICOLAS RAMIREZ', NULL, NULL, NULL, '3174320919', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'BOMBA PEDROLO CABALLO 4"', 'PEDROLO', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0805', @articulo_id, 'INGRESO', NULL, '2026-02-11 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUIONA NO ENCIENDE, FALLA ELECTRICA, SELLO MECANICO DESGASTADO., RODAMIENTOS FATIGADOS, REQUIERE REPARACION ELECTRICA Y CAMBIO DE SELLO Y RODAMIENTOS, MAS MANTENIMIENTO GENERAL', 200000.0, 200000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'RODAMIENTOS', NULL, 0),
  (@cotizacion_id, 2, NULL, 1, 'SELLO MECANICO', NULL, 0),
  (@cotizacion_id, 3, NULL, 1, 'REPARACION ELECTRICA, MANTEMINEINTO Y MANO DE OBRA', NULL, 0);

-- ===== OT 0804 (hoja original: 804-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('GABRIEL', 'INGECONS INGENIEROS CONSTRUCTORES Y CONSULTORES S.A.S', '830512329-6', NULL, '3123868912', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'TOTAL', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0804', @articulo_id, 'INGRESO', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'EQUIPO NO GOLPEA', 32500.0, 32500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 2.0, 'ORING', 2000.0, 4000.0),
  (@cotizacion_id, 2, NULL, 1, 'MANO DE OBRA/MANTENIMIENTO', 28500.0, 28500.0);

-- ===== OT 0803 (hoja original: 803-ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ARNULFO CASTELLANOS', 'INGELDAC S A S', '900312212-9', 'acastellanos@ingeldac.com / info@ingeldac.com', '3115847860', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'TRUPER', 'NO REGISTRA', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0803', @articulo_id, 'ENTREGADA', NULL, '2026-02-10 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 52500.0, 52500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 2.0, 'BALINES', 1000.0, 2000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'MANTENIMIENTO Y MANO DE OBRA', 28500.0, 28500.0),
  (@cotizacion_id, 3, NULL, 1.0, 'ESCOBILLAS', 22000.0, 22000.0);

-- ===== OT 0802 (hoja original: 802-ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES (NULL, 'EXHOSTOS DEL NORTE', NULL, NULL, '3227485225', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'MOTOETOOL', 'TRUPER', 'ESRE-1', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0802', @articulo_id, 'ENTREGADA', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'EQUIPO CON AFCECTACIONES GRAVES EN COMPONENTES ESCENCIALES COMO LA CARCAZA - PARA ESTE MODELO TRUPER NO MANEJA REFACCIONES POR LO CUAL NO PODEMOS REALIZAR LA REPARACION DE LA HERRAMIENTA', 0.0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'CARCAZA MOTOR', NULL, 0),
  (@cotizacion_id, 2, NULL, 1, 'RODAMIENTO 608', NULL, 0),
  (@cotizacion_id, 3, NULL, 1, 'CAPUCHON RODAMIENTO', NULL, 0),
  (@cotizacion_id, 4, NULL, 1, 'ESCOBILLAS', NULL, 0),
  (@cotizacion_id, 5, NULL, 1, 'PORTA ESCOBILLAS', NULL, 0),
  (@cotizacion_id, 6, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADA', 'COT ENVIADA'),
  (@orden_id, 'ENTREGADA', 'ENTREGADA 13/02/2026'),
  (@orden_id, 'ENTREGADA', 'SIN REPARACIÓN');

-- ===== OT 0801 (hoja original: 801 - ENTREAGADA PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('RODRIGO TALERO', 'ESTRUCTURAS EN MADERA TALERO', NULL, NULL, '3118875376', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO ESPADA', 'BOSH', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0801', @articulo_id, 'ENTREAGADA PAGADA', 'SIN ACCESORIOS', '2026-02-07 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'EQUIPO CON FALLA ELECTRICA, SE REALIZA REPARACION DE LINEAS Y FALSO CONTACTO, SE REALIZA MANTENIMIENTO GENERAL DEL EQUIPO', 23500.0, 23500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'MANTENIMIENTO GENERAL', NULL, 23500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREAGADA PAGADA', 'ENTREGADA Y PAGADA');

-- ===== OT 0800 (hoja original: 800-cot enviada) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES (NULL, 'COMERCIALIZADORA CASTAÑO CARDOZO', NULL, NULL, '3212817615', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'ELITE', 'AG-1165', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0800', @articulo_id, 'cot enviada', 'SIN ACCESORIOS', CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'INDUCIDO Y CAMPO EN CORTO - VALORES MUY ELVADOS NO JUSTIFICA REALIZAR REPARACIÓN', 253500.0, 253500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'INDUCIDO', NULL, 125000.0),
  (@cotizacion_id, 2, NULL, 1, 'BOBINA', NULL, 80000.0),
  (@cotizacion_id, 3, NULL, 1, 'ESCOBILLAS', NULL, 25000.0),
  (@cotizacion_id, 4, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 23500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'cot enviada', 'cot enviada');

-- ===== OT 0799 (hoja original: 799-ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('MARCO GIRALDO', NULL, '79872052', NULL, '3214086780 - 3133771951', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'BAUKER', 'EH10', '-');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0799', @articulo_id, 'ENTREGADA', 'SIN ACCESORIOS', '2026-02-10 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA ENCIENDE NO GENERA IMPACTO, SE DIAGNOSTICA EL KIT DE ANILLOS DE COMPRESIÓN, RODAMIENTOS CON FATICA, MANTENIMIENTO GENEARAL, CAMBIO DE LUBRICACIÓN: TENER PRESENTE QUE ESTA MARCA DISTRIBUIDA POR HOME CENTER NO GENERA SERVICIO DE POS VENTA POR LO CUAL NO SE CONSIGUEN REPUESTOS PARA ESTA.', 62500.0, 62500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'RODAMIENTO 607', 12000.0, 12000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'ANILLO DE COMPRESION', 10000.0, 10000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'RODAMIENTO 608', 12000.0, 12000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'MANO DE OBRA Y MANTENIMIENTO', 28500.0, 28500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADA', 'enviada cot 21/02'),
  (@orden_id, 'ENTREGADA', 'AUTORIZADO 21/02'),
  (@orden_id, 'ENTREGADA', 'ENTREGADA Y PAGADA');

-- ===== OT 0798 (hoja original: 798-ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('LUIS TORRES', 'KLIMATIZAR', '900770016', NULL, '3153180269', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERCUTOR', 'DEWALT', 'DCD7781 TYPE 1', '180026');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0798', @articulo_id, 'ENTREGADA', 'SIN ACCESORIOS', CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'TRANSMISION CON PIÑONES TOROS, OCASIONANDO QUE EL EQUIPO NO FUNCIONE EN VELOCIDAD 2', 259500.0, 259500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'CAJA DE ENGRANAJES', NULL, 236000.0),
  (@cotizacion_id, 2, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 23500.0);

-- ===== OT 0797 (hoja original: 797-ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('LUIS TORRES', 'KLIMATIZAR', '900770016', NULL, '3153180269', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERCUTOR', 'MAKITA', 'HP333', '354599Y');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0797', @articulo_id, 'ENTREGADA', 'SIN ACCESORIOS', CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA CON PIÑONERIA INTERNA FRACTURADA, POR TAL MOTIVO EL EQUIPO NO ACTUA EN VELOCIDAD # 2', 301865.0, 301865.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'TRANSMISION', 218365.0, 218365.0),
  (@cotizacion_id, 2, NULL, 1.0, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', 23500.0, 23500.0),
  (@cotizacion_id, 3, NULL, 1.0, 'MANDRIL +TORNILLO', 60000.0, 60000.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADA', 'ENTREGADA');

-- ===== OT 0796 (hoja original: 796-ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('LUIS TORRES', 'KLIMATIZAR', '900770016', NULL, '3153180269', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERCUTOR', 'MAKITA', 'DHP453', '1906742Y');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0796', @articulo_id, 'ENTREGADA', 'SIN ACCESORIOS', CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA CON EL MOTOR QUEMADO, NECESARIO REALIZAR SU CAMBIO.', 128163.0, 128163.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'MOTOR', 128163.0, 128163.0),
  (@cotizacion_id, 2, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADA', 'ENTREGADA');

-- ===== OT 0795 (hoja original: 795-ingreso) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES (NULL, 'Javier Clavijo', NULL, NULL, '3127264977', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PERCUTOR 12 V', 'BOSH', 'GSB 120-LI', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0795', @articulo_id, 'ingreso', NULL, '2025-02-10 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MOTOR RECALENTADO, MANTENIMIENTO GENERAL', 131500.0, 131500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'MOTOR', NULL, 108000.0),
  (@cotizacion_id, 2, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 23500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ingreso', 'cotizacion enviada');

-- ===== OT 0794 (hoja original: 794-ENTREGADA PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ARNULFO CASTELLANOS', 'INGELDAC S A S', '900312212-9', 'acastellanos@ingeldac.com / info@ingeldac.com', '3115847860', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'TRUPER', 'ROEL 60N', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0794', @articulo_id, 'ENTREGADA PAGADA', NULL, '2026-02-10 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MANTENIMIENTO GENERAL', 41500.0, 41500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'BALINES PORTA BROCAS', NULL, 3000.0),
  (@cotizacion_id, 2, NULL, 1, 'MANTENIMIENTO GENERAL', NULL, 38500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADA PAGADA', 'COTIZACION ENVIADA'),
  (@orden_id, 'ENTREGADA PAGADA', 'ENTREGADA 11/02');

-- ===== OT 0793 (hoja original: 793-pdte recoleccion y pago ) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('EDUARDO AGUILA', NULL, '19187774', NULL, '3134704930', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'MAKITA', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0793', @articulo_id, 'pdte recoleccion y pago', NULL, '2026-02-09 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA SUELTA EL DISCO EN OPERACION', 72500.0, 72500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'EJE', NULL, 25000.0),
  (@cotizacion_id, 2, NULL, 1, 'TUERCA', NULL, 0),
  (@cotizacion_id, 3, NULL, 1, 'BRIDA', NULL, 0),
  (@cotizacion_id, 4, NULL, 1, 'RODAMIENTO 6202', NULL, 24000.0),
  (@cotizacion_id, 5, NULL, 1, 'SERVICIO DE MANTENIIENTO Y MANO DE OBRA', NULL, 23500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'pdte recoleccion y pago', 'INGRESO ENVIADO 9/02');

-- ===== OT 0792 (hoja original: 792-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('CARLOS AMAYA', NULL, '1407474', NULL, '322770694', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'LLAVE DE IMPATCTO 400 N/M', 'TOTAL', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0792', @articulo_id, 'INGRESO', NULL, '2026-02-09 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'INGRESO', 'INGRESO ENVIADO 9/02');

-- ===== OT 0791 (hoja original: 791-ETREGADA Y PGDA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('HECTOR ARIAS', NULL, '1072420161', NULL, '3213356801', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'DEMOLEDOR', 'GENERICO', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0791', @articulo_id, 'ETREGADA Y PGDA', NULL, '2026-02-09 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 257000.0, 257000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'EMPAQUE', NULL, 15000.0),
  (@cotizacion_id, 2, NULL, 1, 'RODAMIENTO 6001', NULL, 18000.0),
  (@cotizacion_id, 3, NULL, 1, 'CABLE', NULL, 40000.0),
  (@cotizacion_id, 4, NULL, 1, 'RODAMIENTO 6201', NULL, 22000.0),
  (@cotizacion_id, 5, NULL, 1, 'ESCOBILLAS CB-204', NULL, 22000.0),
  (@cotizacion_id, NULL, NULL, 1, 'TAPA ESCOBILLAS', NULL, 12000.0),
  (@cotizacion_id, NULL, NULL, 1, 'PASA CABLE', NULL, 8000.0),
  (@cotizacion_id, NULL, NULL, 1, 'CAMPO', NULL, 60000.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ETREGADA Y PGDA', 'PAGADO 7/02'),
  (@orden_id, 'ETREGADA Y PGDA', 'ENTREGADO');

-- ===== OT 0790 (hoja original: 790-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JAVIER CAMARGO', NULL, '79371076', NULL, '3505226171', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'COMPRESOR', 'RANGER', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0790', @articulo_id, 'ENTREGADA Y PAGADA', 'INGRESA CON MANGUERA/ FUGA EN EL TANQUE EN LA PARTE DE ABAJO, ACOPLE DE COBRE CON FUGA , FILTRO CONTAMINADO, CARCAZA CUBRE CABEZAL ROTA', '2026-02-06 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'SE REALIZA MANTENIMIENTO AL EQUIPO SE CURAR LAS FUGAS DE ACOPLES, SE REALIZA EL REEMPLAZO DEL CHEQUE ANTIRETORNO, SE LE INFORMO AL CLIENTE QUE EL TANQUE PRESENTA FISURAS POR TAL MOTIVO SOLO SE LE REALIZA EL MANTENIMIENTO GENERAL.', 125000.0, 125000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'CHEQUE DE RETORNO', 45000.0, 45000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'MANTENIMIENTO Y MANO DE OBRA', 45000.0, 45000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'FILTRO', 35000.0, 35000.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADA Y PAGADA', 'INGR ENV-6/02'),
  (@orden_id, 'ENTREGADA Y PAGADA', 'COT ENV-24/03'),
  (@orden_id, 'ENTREGADA Y PAGADA', 'ENTREGADA Y PAGADA 26/03'),
  (@orden_id, 'ENTREGADA Y PAGADA', 'CV.1453');

-- ===== OT 0789 (hoja original: 789-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('DOBLADORA R Y S', NULL, '900213000-1', NULL, NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PUIDORA', 'MAKITA', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0789', @articulo_id, 'INGRESO', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 63500.0, 63500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'CARCAZA', NULL, 40000.0),
  (@cotizacion_id, 2, NULL, 1, 'SERVICIO DE MANO DE OBRA', NULL, 23500.0);

-- ===== OT 0788 (hoja original: 788-NO JUSTIFICA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('DOBLADORA R Y S', NULL, '900213000-1', NULL, NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PUIDORA', 'ELITE', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0788', @articulo_id, 'NO JUSTIFICA', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'NO JUSTIFICA  INDUCIDO +CABLE +ESCOBILLAS +PORTA ESCOBILLAS .', 0.0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();

-- ===== OT 0787 (hoja original:  787-LISTA PDT) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('DOBLADORA R Y S', NULL, '900213000-1', NULL, NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PUIDORA', 'TOTAL', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0787', @articulo_id, 'LISTA PDT', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 47500.0, 47500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '21200-6', 1.0, 'RODAMIENTO 608', 12000.0, 12000.0),
  (@cotizacion_id, 2, 'UTG10711556-SP-36', 1.0, 'ESCOBILLAS', 12000.0, 12000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'MANTENIMIENTO', 23500.0, 23500.0);

-- ===== OT 0786 (hoja original: 786-ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('DOBLADORA R Y S', NULL, '900213000-1', NULL, NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'TOTAL', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0786', @articulo_id, 'ENTREGADA', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'RODAMIENTO 608', 10000.0, 0),
  (@cotizacion_id, 2, NULL, 1, 'MANTENIMIENTO Y MANO DE OBRA', 23500.0, 0);

-- ===== OT 0785 (hoja original: 785-ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('OSCAR GOMEZ', NULL, '79714205', NULL, '3222167021', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ATORNILLADOR', 'BLACK&DECKER', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0785', @articulo_id, 'ENTREGADA', NULL, '2026-02-06 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0784 (hoja original: 784-COT ENVIADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ALEJANDRO OROZCO', NULL, '19432086', NULL, '3108531905', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERCUTOR', 'BOSCH', 'GSB550RE', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0784', @articulo_id, 'COT ENVIADA', NULL, '2026-02-06 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'FALSO CONTACTO EN PORTA ESCOBILLAS, ESCOBILLAS Y COLECTOR', 78500.0, 78500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'ESCOBILLAS Y PORTA ESCOBILLAS', NULL, 55000.0),
  (@cotizacion_id, 2, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 23500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'COT ENVIADA', 'INGRESO ENV');

-- ===== OT 0783 (hoja original: 783-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ALEJANDRO OROZCO', NULL, '19432086', NULL, '3108531905', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'LIJADORA', 'STANLEY', 'STGS7221-B3', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0783', @articulo_id, 'INGRESO', NULL, '2026-02-06 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA CON RODAMIENTO FATIGADO, SE REALIZA MANTENIMIENTO GENERAL, LA BASE INTERMEDIA SE ENCEUNTRA DESGASTADA, PERO AUN FUNCIONAL, RECOMENDACION USAR HASTA QUE SEA NECESARIA POR OBLIGATORIEDAD SER REEMPLAZADA.', 58500.0, 58500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'RODAMIENTO 608', NULL, 12000.0),
  (@cotizacion_id, 2, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 23500.0),
  (@cotizacion_id, 3, NULL, 1, 'BASE INTERMEDIA', NULL, 23000.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'INGRESO', 'INGRESO ENV');

-- ===== OT 0782 (hoja original: 782-COT ENV) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES (NULL, 'CONSTRUM CACERES S.A.S', '900.768.163-3', NULL, '3212744628 - 3046156395', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'STANLEY', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0782', @articulo_id, 'COT ENV', NULL, '2026-02-05 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 71500.0, 71500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'RODAMIENTO 608', 10000.0, 10000.0),
  (@cotizacion_id, 2, 'N910754', 1.0, 'ESCBILLAS', 20000.0, 20000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'PASA CABLES', 8000.0, 8000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'MANTENIMIENTO Y MANO DE OBRA', 23500.0, 23500.0),
  (@cotizacion_id, 5, NULL, 1.0, 'INTERRUPTOR', 10000.0, 10000.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'COT ENV', 'cot envi 06/02'),
  (@orden_id, 'COT ENV', 'cot enviada 17/02');

-- ===== OT 0781 (hoja original: 781-ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES (NULL, 'CONSTRUM CACERES S.A.S', '900.768.163-3', NULL, '3212744628 - 3046156395', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'TRUPER A12', 'A12', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0781', @articulo_id, 'ENTREGADA', NULL, '2026-02-05 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 35500.0, 35500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'ESCOBILLAS', 12000.0, 12000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'MANTENIMIENTO Y MANO DE OBRA', 23500.0, 23500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADA', 'COT ENV 06/02'),
  (@orden_id, 'ENTREGADA', 'CANCELADA - ENTREGADA'),
  (@orden_id, 'ENTREGADA', '10/02/2026+');

-- ===== OT 0780 (hoja original: 780-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('CRISTIAN GOMEZ / CRISTIAN CARDENAS', 'SOCIEDAD FERRETERA', NULL, NULL, NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'DEMOLEDOR', 'HILTI', 'TE500', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0780', @articulo_id, 'INGRESO', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'EQUIPO CON PROBLEMAS DE COMPRESIÓN, BIELA FRACTURADA Y PISTON DESGASTADO, SE PUEDEN IMPORTAR AMBOS REPUESTOS  SU COSTO ES ELEVADO, COMO OPCION ADICIONAL EL KIT DE EMPAQUES SE PUEDE SUPLIR CON FABRIACION LOCAL, PERO LA BIELA Y PISTON SI ES DE CARACTER OBLIGATORIO REALIZAR SU IMPORTACION', 0, NULL, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'KIT DE EMPAQUES (POR IMPORTACION )', 940000.0, 940000.0),
  (@cotizacion_id, 2, NULL, 1, 'BIELA Y PISTON (POR IMPORTACION)', 305000.0, 305000.0),
  (@cotizacion_id, 3, NULL, 1, 'GASTOS DE ENVÍO', 300000.0, 300000.0),
  (@cotizacion_id, NULL, NULL, 1, 'FABRICACION LOCAL DEL KIT DE EMPAQUES Y ANILLOS', 370000.0, 370000.0),
  (@cotizacion_id, 5, NULL, 1, 'SERVICIO DE MANO DE OBRA', 95000.0, 95000.0),
  (@cotizacion_id, 6, NULL, 1, ',', NULL, 0);

-- ===== OT 0779 (hoja original: 779 - ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('LUIS TORRES', 'KLIMATIZAR', '900770016', NULL, '3153180269', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERCUTOR 20V', 'TOTAL', 'TIDLI206681', '25137640144');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0779', @articulo_id, 'ENTREGADA Y PAGADA', '2 BATERIAS 20V 2 Ah  y CARGADOR', '2026-02-05 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA NO ENCIENTE, BATERIAS Y EQUIPO PRESENTAN SEÑALES DE OXIDO.', 153500.0, 153500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'MANDRIL', NULL, 80000.0),
  (@cotizacion_id, 2, NULL, 1, 'CARGADOR', NULL, 50000.0),
  (@cotizacion_id, 3, NULL, 1, 'SERVIIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 23500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADA Y PAGADA', 'FACT EXT 884'),
  (@orden_id, 'ENTREGADA Y PAGADA', 'ENTREGADA Y PAGADA'),
  (@orden_id, 'ENTREGADA Y PAGADA', 'CV.1642');

-- ===== OT 0778 (hoja original: 778-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ELKIN MENDEZ', NULL, '1117508549', NULL, '3115273495', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO', 'TOTAL', 'UTIDLI20602', '23428290235');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0778', @articulo_id, 'ENTREGADA Y PAGADA', NULL, '2026-02-05 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 85000.0, 85000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'MANDRIL TOTAL', NULL, 80000.0),
  (@cotizacion_id, 2, NULL, 1, 'SERVICIO DE CAMBIO MANDRIL', NULL, 5000.0);

-- ===== OT 0777 (hoja original: 777-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('BENANCIO ESTUPIÑAN', NULL, NULL, NULL, '3105709197', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'TOTAL', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0777', @articulo_id, 'INGRESO', NULL, '2026-02-05 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 33000.0, 33000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'ESCOBILLAS', 18000.0, 18000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'RODAMIENTO', 10000.0, 10000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'SERVICIO INSTALACIÓN', 5000.0, 5000.0);

-- ===== OT 0776 (hoja original: 776-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('FRDDY FRENCHER', NULL, NULL, NULL, '3006126023', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'TOTAL', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0776', @articulo_id, 'INGRESO', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0775 (hoja original:  775-COT ENV) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('NICOLAS BRAVO', NULL, '1020848807', NULL, '3013912974', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'HIDROLAVADORA', 'KARCHER', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0775', @articulo_id, 'COT ENV', NULL, '2026-02-05 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'SE EVIDENCIA EJE CENTRAL FRACTURADO POR LO CUAL SE NECESITA CAMBIO DE LA PIEZA COMPLETA, SE LE REALIZA MANTENIMIENTO GENERAL Y LIMPIEZA', 400000.0, 400000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, NULL, NULL, 1, 'EJE CENTRAL +PIÑONES +DOS CANASTILLAS +CAMBIO DE', NULL, 0),
  (@cotizacion_id, 1, NULL, 1.0, 'ACEITE', 330000.0, 330000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'MANTENIMIENTO Y MANO DE OBRA', 70000.0, 70000.0);

-- ===== OT 0774 (hoja original: 774-COT ENV) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('NICOLAS BRAVO', NULL, '1020848807', NULL, '3013912974', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'HIDROLAVADORA', 'KARCHER', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0774', @articulo_id, 'COT ENV', NULL, '2026-02-05 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 460000.0, 460000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, NULL, NULL, 1, 'CABEZAL INFERIOR +ESCOBILLAS +SELLOS DE ACEITE+NIVELACIÓN', NULL, 0),
  (@cotizacion_id, 1, NULL, 1.0, 'O CAMBIO DE ACEITE', 390000.0, 390000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'MANTENIMIENTO Y MANO DE OBRA', 70000.0, 70000.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'COT ENV', 'COT ENV 12/02');

-- ===== OT 0773 (hoja original: 773-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('GERMAN COBO', 'SEICO CONSTRUCCIONES', '79485260', NULL, '3003762054', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'DEMOLEDOR', 'MAKITA', 'HM1317CB', '40833E');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0773', @articulo_id, 'INGRESO', 'INGRESA CON MALETIN EMPUÑADURA EN D, UN CICNCEL Y 1 PAR DE ESCOBILLAS ADICIONALES.', '2026-02-04 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA NO ENCIENDE, CORTO EN LA UNION DEL PORTA ESCOBILLAS, SE REEMPLAZA LA PIEZA COMPLETA, SE HACE MANTENIMIENTO AL PORTA BROCAS Y SE REEMPLAZA CAPUCHON, TENER PRESENTE QUE ESTA MAQUINA REQUIERE MANTENIMIENTO GENERAL URGENTE, PARA GARANTIZAR SU CORRECTO FUNCIONAMIENTO Y ALARGAR LA VIDA UTIL DEL EQUIPO', 113000.0, 113000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'PORTA ESCOBILLAS', NULL, 50000.0),
  (@cotizacion_id, 2, NULL, 1, 'TORNILLERIA TARJETA', NULL, 2000.0),
  (@cotizacion_id, 3, NULL, 1, 'CAPUCHON', NULL, 13000.0),
  (@cotizacion_id, 4, NULL, 1, 'ANILLO PORTA BROCAS', NULL, 8000.0),
  (@cotizacion_id, 5, NULL, 1, 'SERVICIO MANO DE OBRA MINIMO DEMOLEDORES', NULL, 40000.0);

-- ===== OT 0772 (hoja original: 772-ENTREGADA Y PAGAD) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('IVAN CORREDOR', 'FUNDACIÓN COSME Y DAMIAN', '800053550-9', 'compras@cydbank.org', '3142970196', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'COMPRESOR', 'ELITE', 'CA2042', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0772', @articulo_id, 'ENTREGADA Y PAGAD', NULL, '2026-02-04 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA ENCIENDE, NO GENERA FLUJO CORRECTO DE AIRE, SE DIAGNOSTICA INGRESO DE PARTICULAS METALICAS, GENERANDO PERDIDA DE COMPRESION, SE REMPLAZAN LAS PIEZAS NECESARIAS, PARA GARANTIZAR SU CORRECTO FUNCIONAMIENTO.', 200000.0, 200000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'FILTRO DE AIRE', 10000.0, 10000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'CAJA FILTRO', 25000.0, 25000.0),
  (@cotizacion_id, 3, NULL, 2.0, 'ANILLOS DE PISTON', 35000.0, 70000.0),
  (@cotizacion_id, 4, NULL, 4.0, 'FLAPERS', 12000.0, 48000.0),
  (@cotizacion_id, 5, NULL, 1.0, 'LLAVE DE PASO', 35000.0, 0),
  (@cotizacion_id, 6, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', 47000.0, 47000.0);

-- ===== OT 0771 (hoja original: 771-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('DAVID BERNAL', NULL, '1019082384', NULL, '3152742944', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'SKIL', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0771', @articulo_id, 'INGRESO', NULL, '2026-02-03 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA NO ENCIENDE, RODAMIENTO ESTALLADO Y COMPONENTES METALICOS  OXIDADOS , REALIZA MANTENIMIENTO GENERAL', 35500.0, 35500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'RODAMIENTO 608', NULL, 12000.0),
  (@cotizacion_id, 2, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 23500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'INGRESO', 'cot enviada 12/02/2026');

-- ===== OT 0770 (hoja original: 770-NO AUTORIZADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('GERARDO ARCOS', NULL, '98137198', NULL, '3146195159', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ASPIRADORA', 'KARCHER', 'WD1', '48531');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0770', @articulo_id, 'NO AUTORIZADA', NULL, '2026-02-03 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'INDUCIDO EN CORTO, YA QUE EL VENTILADOR FRACTURO HELICES Y LOS RESIDUOS GENERARON LAS AFECTACIONES, LAS PARTES AFECTADAS NO SE DISTRIBUYEN POR SEPARADO, LA MARCA KARCHER SOLO DISTRIBUYE EL MOTOR COMPLETO', 665000.0, 665000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'MOTOR COMPLETO', NULL, 540000.0),
  (@cotizacion_id, 2, NULL, 1, 'FILTRO', NULL, 85000.0),
  (@cotizacion_id, 4, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 40000.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'NO AUTORIZADA', 'NO AUTORIZADA');

-- ===== OT 0769 (hoja original: 769-NO JUDTIFICA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('GERARDO ARCOS', NULL, '98137198', NULL, '3146195159', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'SKILL', '1559', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0769', @articulo_id, 'NO JUDTIFICA', NULL, '2026-02-03 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'NO SE JUSTIFICA LA REPARACIÓN DE ESTE EQUIPO YA QUE NO SE CONSIGUEN LOS REPUESTOS DE LA BOBINA Y LAS ESCOBILLAS.', 138500.0, 138500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'ANILLO PESO MUERTO', 10000.0, 10000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'KIT CAPUCHON', 70000.0, 70000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'BOBINA', NULL, 0),
  (@cotizacion_id, 4, NULL, 1.0, 'ESCOBILLAS', NULL, 0),
  (@cotizacion_id, 5, NULL, 1.0, 'RODAMIENTO 607', 12000.0, 12000.0),
  (@cotizacion_id, 6, NULL, 1.0, 'RODAMIENTO 6001', 18000.0, 18000.0),
  (@cotizacion_id, 7, NULL, 1.0, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 28500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'NO JUDTIFICA', 'cot env -3/03');

-- ===== OT 0768 (hoja original: 768-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES (NULL, 'RM DISEÑO Y CONSTRUCCIÓN S.A.S', '90149120-1', 'contabilidad@rmdisenoyconstruccion.com', '3166252850', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'UBERMANN', 'ERH1500', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0768', @articulo_id, 'ENTREGADA Y PAGADA', NULL, '2026-02-03 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, ',MAQUINA NO ENCIENDE, FALLA EN ESCOBILLAS, SE REALIZA RECTIFIACION DE COLECTOR, SE EVIDENCIA MOTOR CON INDICIOS DE SOBRE CALENTAMIENTO, SE MANTENIMIENTO AL PORTABROCAS', 43500.0, 43500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'ESCOBILLAS HOMOLOGAS', NULL, 20000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'SERVICIO MINIMO MANO DE OBRA ROTOMARTILLO', NULL, 23500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADA Y PAGADA', 'contactado 21/02'),
  (@orden_id, 'ENTREGADA Y PAGADA', 'ENTREGADA 19-03-2026'),
  (@orden_id, 'ENTREGADA Y PAGADA', 'CV1406'),
  (@orden_id, 'ENTREGADA Y PAGADA', 'FACT EXT 714');

-- ===== OT 0767 (hoja original: 767-COT ENV) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES (NULL, 'INOVOMETALMEC SAS', '901516019', NULL, '3108520625', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'COMPRESOR', 'DEWALT', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0767', @articulo_id, 'COT ENV', NULL, '2026-02-03 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA ENCIENDE SONIDO EXTRAÑO, AL MOMENTO DE REVISAR SE DIAGNOSTICA FALLA PRINCIPAL INDUCIDO EN CORTO , VENTILADOR  FRACTURADO, ANILLO DESGASTADOS , EMPAQUE MEMBARANA RASGADO, MANTENIMIENTO GENERAL Y LIMPIEZA.', 712000.0, 712000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, NULL, NULL, 1, 'MOTOR COMPLETO', NULL, 0),
  (@cotizacion_id, 1, NULL, 1.0, '(INDUCIDO + ANILLO+EMPAQUE DEL BLOQUE +MANGUERA +VENTILADOR)', 652000.0, 652000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'MANO DE OBRA Y MANTENIMIENTO', 60000.0, 60000.0);

-- ===== OT 0766 (hoja original: 766-ENTREGADA SIN REPARAR) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES (NULL, 'TECNIMOTOR JP', '900429531-7', NULL, '3124538636 - 3102044256', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ASPIRADORA', 'TRUPER', 'ASP-165', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0766', @articulo_id, 'ENTREGADA SIN REPARAR', NULL, '2026-02-03 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MOTOR CON PASO DE CORRIENTE INTERRUMPIDO, HACIENDO EL DICTAMEN SE EVIDENCIA QUE ESTE NO SE DEJA INTERVENIR POR LO QUE SE RECOMIENDA CAMBIO DE MOTOR, TENIENDO EN CUENTA QUE TRUPER NO DISTRIBUYE REPUESTOS  SE COTIZA UN MOTOR HOMOLOGO', 143500.0, 143500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'MOTOR GENERICO', 120000.0, 120000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'MANTENIMIENTO Y MANO DE OBRA', 23500.0, 23500.0);

-- ===== OT 0765 (hoja original: 765-ENTREGADA Y PGDA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ALEXANDER FRANCO', NULL, '19389567', NULL, '3114449290', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO', 'BAUKER', 'ID750E', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0765', @articulo_id, 'ENTREGADA Y PGDA', NULL, '2026-02-03 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'INTERRUPTOR EN CORTO, SE REALIZA MANTENIMIENTO GENERAL Y LIMPIEZA', 58500.0, 58500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'INTERRUPTOR', 35000.0, 35000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'MANTENIMIENTO Y MANO DE OBRA', 23500.0, 23500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADA Y PGDA', 'ENTREGADA Y PAGADA 05/02/2026'),
  (@orden_id, 'ENTREGADA Y PGDA', 'CV1120');

-- ===== OT 0764 (hoja original: 764-ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('HERNAN DÍAS', 'MEDIO LIMÓN', NULL, NULL, '3214310433-3203800164', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERCUTOR', 'DEWALT', 'DW505C-B3', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0764', @articulo_id, 'ENTREGADA', NULL, '2026-02-03 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'NO GENERA FALLA, SE REALIZA LIMPIEZA. SIN COSTO', 0.0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADA', 'ENTREGADA 6/02/2026');

-- ===== OT 0763 (hoja original: 763-NO JUSTIFICA+) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('MARTIN EMILIO GOMEZ', NULL, '79394580', NULL, '3108945508', 'CR 23 # 11 - 19 SUR');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'GENERICA AZUL', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0763', @articulo_id, 'NO JUSTIFICA+', 'SIN ACCESORIOS', '2026-02-02 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA EN CORTO NO JUSTIFICA REPARACION', 0.0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'NO JUSTIFICA+', 'PDT PULIDORA'),
  (@orden_id, 'NO JUSTIFICA+', 'PULIDORA GENERICA GRIS OSCURA'),
  (@orden_id, 'NO JUSTIFICA+', 'TRAIDA 5/02/2026'),
  (@orden_id, 'NO JUSTIFICA+', 'ENTREGADAS 10/04/2026');

-- ===== OT 0762 (hoja original: 762-COT) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('MARTIN EMILIO GOMEZ', NULL, '79394580', NULL, '3108945508', 'CR 23 # 11 - 19 SUR');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'POLICHADORA', 'DEWALT', 'DWP849X-B3', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0762', @articulo_id, 'COT', 'MANGO AUXILIAR', '2026-02-02 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 46500.0, 46500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'N398321', 1.0, 'ESCOBILLAS', 38500.0, 38500.0),
  (@cotizacion_id, 2, 'N024448', 2.0, 'TAPA ESCOBILLAS', 4000.0, 8000.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'COT', 'CONTACTADO 5/02');

-- ===== OT 0761 (hoja original: 761-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JACKSON NIETO', NULL, '5981381', NULL, '3163024319', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'TOTAL', 'UTG1091156', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0761', @articulo_id, 'INGRESO', 'MANGO AUXILIAR', '2026-02-02 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'ESCOBILLAS ACTUALES CON EL 50% DE VIDA UTIL', 40500.0, 40500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'UTH1091156-SP-41', 1, 'BOTON HUELLERO', NULL, 5000.0),
  (@cotizacion_id, 2, NULL, 1, 'RODAMIENTO 626', NULL, 12000.0),
  (@cotizacion_id, 3, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 23500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'INGRESO', 'cotizacion enviada');

-- ===== OT 0760 (hoja original: 760-COT ENV) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('WILLIAM GUTIERREZ', NULL, '80730916', 'william8073@hotmail.com', '3138898119', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'BOSH', NULL, '108000263');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0760', @articulo_id, 'COT ENV', 'SIN ACCESOSRIOS', '2026-02-02 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 119500.0, 119500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '21074-7', 1.0, 'RODAMIENTO 607', 12000.0, 12000.0),
  (@cotizacion_id, 2, '211491-2', 1.0, 'RODAMIENTO 609', 12000.0, 12000.0),
  (@cotizacion_id, 3, '1610210187-000', 1.0, 'ORING', 12000.0, 12000.0),
  (@cotizacion_id, 4, NULL, 1.0, '(sin descripcion)', 28500.0, 28500.0),
  (@cotizacion_id, 5, NULL, 1.0, 'VENTILADOR', 10000.0, 10000.0),
  (@cotizacion_id, 6, 'EXPT-0026', 1.0, 'RODAMIENTO EXENTRICO', 45000.0, 45000.0),
  (@cotizacion_id, 7, 'UTH3082668-2-SP-73', 1.0, 'PIÑON CORONA', 20000.0, 20000.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'COT ENV', 'cot enviada 17/02/2026');

-- ===== OT 0759 (hoja original: 759-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('WILLIAM GUTIERREZ', NULL, '80730916', 'william8073@hotmail.com', '3138898119', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'BOSH', 'GBH2-28D', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0759', @articulo_id, 'INGRESO', 'SIN ACCESORIOS', '2026-02-02 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA NO ENCIENDE, FALLA ELECTRICA POR RECALENTAMIENTO, FALSO CONTACTO EN PORTA ESCOBILLAS Y ESCOBILLAS', 0.0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();

-- ===== OT 0758 (hoja original: 758-COT ENV) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JACKSON NIETO', NULL, '5981381', NULL, '3163024319', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'TOTAL', 'UTH110266', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0758', @articulo_id, 'COT ENV', NULL, '2026-02-02 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA NO ENCIENDE, PROBLEMA EN EL CABLE DE PODER, SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', 63500.0, 63500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'CABLE DE PODER', NULL, 25000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'CAPUCHON', NULL, 10000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 28500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'COT ENV', 'cotizacion enviada'),
  (@orden_id, 'COT ENV', 'AUTORIZADA'),
  (@orden_id, 'COT ENV', 'LISTA');

-- ===== OT 0757 (hoja original: 757-COT ENV) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('GUSTAVO BARRERA', 'INDENSA ING SAS', '901291142-3', 'indensa.ing@gmail.com', '3108091745', 'CR 53D # 127D-53');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'TRUPER', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0757', @articulo_id, 'COT ENV', NULL, '2026-02-02 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'REVISIÓN POR GARANTÍA', 0.0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();

-- ===== OT 0756 (hoja original: 756-COT ENVI) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('GUSTAVO BARRERA', 'INDENSA ING SAS', '901291142-3', 'indensa.ing@gmail.com', '3108091745', 'CR 53D # 127D-53');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'TRUPER', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0756', @articulo_id, 'COT ENVI', NULL, '2026-02-02 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'CAMBIO DE ESCOBILLAS Y MANTENIMIENTO GENERAL', 12000.0, 12000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'ESCOBILLAS', 12000.0, 12000.0);

-- ===== OT 0755 (hoja original: 755-ENTREGADA PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JEFER RAMIREZ', NULL, '1015429983', NULL, '3105825503', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', NULL, NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0755', @articulo_id, 'ENTREGADA PAGADA', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 42500.0, 42500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 2.0, 'ANILLOS', 3000.0, 6000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'CAPUCHON', 8000.0, 8000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'MANTENIMIENTO Y MANO DE OBRA', 28500.0, 28500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADA PAGADA', 'ENTREGADA');

-- ===== OT 0754 (hoja original: 754-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JEFER RAMIREZ', NULL, '1015429983', NULL, '3105825503', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'TOTAL', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0754', @articulo_id, 'INGRESO', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0753 (hoja original: 753-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JEFER RAMIREZ', NULL, '1015429983', NULL, '3105825503', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'MAKITA', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0753', @articulo_id, 'INGRESO', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'CAJA ENGRANAJE DESGASTADA POR USO, EVITANDO CORRECTO FUNCIONAMIENTO DEL PIN DE BLOQUEO , ESCOBILLAS CON 25% DE VIDA UTIL , CAMBIO DE LUBRIACION  MANTENIMIENTO Y LIMIPIEZA GENERAL', 84500.0, 84500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'ESCOBILLAS CB-325', NULL, 16000.0),
  (@cotizacion_id, 2, NULL, 1, 'CAJA ENGRANAJE', NULL, 35000.0),
  (@cotizacion_id, 3, NULL, 1, 'RESORTE , PIN , TAPA', NULL, 10000.0),
  (@cotizacion_id, 4, NULL, 1, 'MANO DE OBRA', NULL, 23500.0);

-- ===== OT 0752 (hoja original: 752-COT ENV) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('DANIEL RAMOS', 'CAR CENTER', NULL, NULL, '3024108263', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'RACHET', 'TOTAL', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0752', @articulo_id, 'COT ENV', NULL, '2026-01-30 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA NO ENCIENDE POR ATASCAMINTO DEBIDO A SOBRE FORZAMIENTO, EJE DE MOTOR TORCIDO, CAJA ENGRANAJES CON DIENTES DE PIÑONES FRACTURADOS', 203500.0, 203500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'TRASMICION COMPLETA', 140000.0, 140000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'MOTOR', 40000.0, 40000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'MANO DE OBRA Y MANTENIMIENTO', 23500.0, 23500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'COT ENV', 'NO TIENE WHATSAPP');

-- ===== OT 0751 (hoja original: 751- AUTORIZADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ELKIN CARDENAS', 'SEGARA CONSTRUCCIONES Y DECORACIONES S.A.S', '901733364-1', NULL, '322371211', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'EINHELL', 'TE-AG I15/750 DP', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0751', @articulo_id, 'AUTORIZADA', NULL, '2026-01-30 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA NO ENCIENDE BOBINA CON PASO DE CORRIENTE INTERRUMPIDO, ESCOBILLAS CON DESGASTE AL 60% DE VIDA UTIL , ESTE REPUESTO NO SE ENCUENTRA DISPONIBLE PARA REPARACIÍON INMEDIATA POR LO QUE TENEMOS UN ESTIMADO DE 5 DIAS HABILES PARA LA LLEGADA DE ESTE.', 100500.0, 100500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'BOBINA', 50000.0, 50000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'ESCOBILLAS', 15000.0, 15000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'RODAMIENTO 607', 12000.0, 12000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'MANO DE OBRA', 23500.0, 23500.0);

-- ===== OT 0750 (hoja original: 750.INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JAIRO GARZON', NULL, NULL, NULL, '3228088334', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'TOTAL', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0750', @articulo_id, 'INGRESO', 'SIN ACCESORIOS', CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'PIN DE BLOQUEO ROTO', 30000.0, 30000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'CAJA ENGRANAJE', NULL, 30000.0);

-- ===== OT 0749 (hoja original: 749-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES (NULL, 'VIOLETA TALLER CREATIVO SAS', '90136087-8', 'marcavioleta.tc@gmail.com', '3192734711-3195409998', 'CRA 25#24A25 piso 1');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PISTOLA DE CALOR', 'BAUKER', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0749', @articulo_id, 'INGRESO', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'FALLA EN LA RESISTENCIA', 90000.0, 90000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'RESISTENCIA', NULL, 66500.0),
  (@cotizacion_id, 2, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 23500.0);

-- ===== OT 0748 (hoja original: 748-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES (NULL, 'VIOLETA TALLER CREATIVO SAS', '90136087-8', 'marcavioleta.tc@gmail.com', '3192734711-3195409998', 'CRA 25#24A25 piso 1');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PISTOLA DE CALOR', 'MAKITA', 'HG6530V', '190301047');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0748', @articulo_id, 'INGRESO', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'COMO SE INFOMRA VIA WHATSAPP, LA REPARACIÓN NO CUENTA CON GARANTÍA YA QUE LA REPARACION  BUSCA PROLONGAR LA VIDA UTIL, PERO UN TRABAJO EXCESIVO GENERARÁ FALLA,, NO GEERAR REFLUJO DE CALOR NI JORNADAS EXCESIVAS DE TRABAJO', 50000.0, 50000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'REPARACION DE RESISTENCIA y MANO DE OBRA', NULL, 50000.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'INGRESO', 'PAGADA 03/02');

-- ===== OT 0747 (hoja original: 747-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES (NULL, 'VIOLETA TALLER CREATIVO SAS', '90136087-8', 'marcavioleta.tc@gmail.com', '3192734711-3195409998', 'CRA 25#24A25 piso 1');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PISTOLA DE CALOR', 'DEWALT', 'D26411-B3', '42637');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0747', @articulo_id, 'INGRESO', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'REPARACION ELECTRICA A LA ALTURA EDL CABLE DE PODER', 23500.0, 23500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 23500.0);

-- ===== OT 0746 (hoja original: 746-ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('MANUEL OSPINA', NULL, '79523395', NULL, '3208493880', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ATORNILLADOR', 'HYPERTOUGH', '99307', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0746', @articulo_id, 'ENTREGADA', 'INGRESA CON CARGADOR', '2026-01-28 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA ENCINDE NO RECIBE CARGA SE DIGTAMINA LA MAQUINA EN CONJUNTO CON SU BATERIA Y CARGADOR Y SE EVIDENCIA FALLA  EN LA BATERIA YA QUE SUS COMPONENTES ELECTRONICOS SE ENCUENTRAN AISLADOS Y SULFATADOS, CON MEDIDAS ERRONEAS. TENER EN CUENTA QUE ESTA MAQUINA ES IMPORTADA Y DISTRIBUIDA POR WALMART POR LO QUE EL PROCESO DE CONSEGUIR ESTA  BATERIA SERIA IMPORTANDOLA CON NOSOTROS.', 143500.0, 143500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'BATERIA', 120000.0, 120000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'MANO DE OBRA Y MANTENIMIENTO', 23500.0, 23500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADA', 'COT ENVIA 02/02/2026'),
  (@orden_id, 'ENTREGADA', 'ENTREGADA 5/02/2026');

-- ===== OT 0745 (hoja original: 745-ENTREGADA ) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JAVIER BRIEVA', NULL, NULL, 'javierbrieva@gmail.com', '3208410884', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'TOTAL', 'UTRHLI202287', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0745', @articulo_id, 'ENTREGADA', NULL, '2026-01-23 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 58500.0, 58500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'RODAMIENTO 608', 12000.0, 12000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'BUJE DE AGUJA', 18000.0, 18000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'MANO DE OBRA Y MANTENIMEINTO', 28500.0, 28500.0);

-- ===== OT 0744 (hoja original: 744-ENTREGDA Y PGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ESTEBAN MARTINEZ', NULL, NULL, NULL, '3115937905', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ATORNILLADOR', 'MAKITA', 'PH03', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0744', @articulo_id, 'ENTREGDA Y PGADA', 'INGRESA CON DOS PILAS Y CARGADOR', '2026-01-22 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA NO ENCIENDE, SE DIAGNOSTICA MOTOR RECALENTADO BATERIA CON FALLA ( CARGADOR NO REALIZA LECTURA DE BATERIA, PERO EN REALIDAD ES FALLA DE LA BATERIA)', 218500.0, 218500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'MOTOR', 45000.0, 45000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'BATERIA  REFURBY (OPCIONAL)', 150000.0, 150000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'SERVICIO MANO DE OBRA', 23500.0, 23500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGDA Y PGADA', 'PAGADA Y ENTREGADA 4/2/2026');

-- ===== OT 0743 (hoja original: 743-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JAIRO GARZÓN', NULL, '79966911', NULL, '3228088334', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'TOTAL', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0743', @articulo_id, 'ENTREGADA Y PAGADA', 'PULIDORA CON DISCO ATASCADO', '2026-01-22 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 10000.0, 10000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'RODAMIENTO 608', 10000.0, 10000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'MANO DE OBRA Y MANTENIMIENTO', 0.0, 0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADA Y PAGADA', 'ENTREGADA Y PAGADA 23/01/2026');

-- ===== OT 0742 (hoja original: 742-PDT AUTORIZACÓN ) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ORLANDO JAIMES', NULL, NULL, NULL, '3142630610', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERCUTOR', 'BAUKER', 'ID900', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0742', @articulo_id, 'PDT AUTORIZACÓN', NULL, '2026-01-21 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA NO ENCIENDE INTERRUPTOR CON FALLA, PARA ESTA MARCA BAUKER NO SE CONSIGUEN REPUESTOS ORGINALES, SE REALIZA UNA HOMOLOGACIÓN DEL INTERRUPTOR', 60500.0, 60500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'INTERRUPTOR GENERICO', 45000.0, 45000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'MANO DE OBRA ELECTRICA', 15500.0, 15500.0);

-- ===== OT 0741 (hoja original: 741-ENTREGADA Y PGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('GERMAN LICEAGA', NULL, NULL, NULL, '3152857569', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'MOTOTOOL', 'DREMEL', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0741', @articulo_id, 'ENTREGADA Y PGADA', NULL, '2026-01-21 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 70000.0, 70000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'REVERSIBLE', 67500.0, 67500.0),
  (@cotizacion_id, 2, NULL, 1.0, 'MANO DE OBRA Y MANTENIMIENTO', NULL, 0);

-- ===== OT 0740 (hoja original: 740-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('CAMILO HERNANDEZ', NULL, NULL, NULL, '3245445782', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PLICHADORA', 'TOTAL', 'UTP11418018', '25126930070');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0740', @articulo_id, 'INGRESO', NULL, '2026-01-21 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA ENCIENDE SONIDO MECANICO EXTRAÑO , SE EVIDENCIA PIÑON CORONA FRACTURADO', 50000.0, 50000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'PIÑON CORONA', 35000.0, 35000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'MANO DE OBRA Y MANTENIMIENTO', 15000.0, 15000.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'INGRESO', 'PEDIR PIÑON CORONA HOYOS'),
  (@orden_id, 'INGRESO', 'cot env/08/04');

-- ===== OT 0739 (hoja original: 739-PDT) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('DANIEL ZORRO', NULL, NULL, NULL, '305 9150243', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'SIERRA DE MANO', 'MILWAUKEE', NULL, '780A403140044');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0739', @articulo_id, 'PDT', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA ENCIENDE PARCIALMENTE/ INTERMITENTE FALLA EN ESCOBILLAS SE REALIZA REPARACIÓN ELECTRICA Y MANTENIMIENTO GENERAL.', 61000.0, 61000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'ESCOBILLAS', 15000.0, 15000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'PASA CABLE', 8000.0, 8000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'MANO DE OBRA Y MANTENIMIENTO ELECTRICO', 38000.0, 38000.0);

-- ===== OT 0738 (hoja original: 738-PDT) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('DANIEL ZORRO', NULL, NULL, NULL, '305 9150243', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ESMERILADORA ANGULAR', 'DEWALT TIPO1', 'DWE4010-B3', '320766');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0738', @articulo_id, 'PDT', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 81500.0, 81500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'CARCASA', 25000.0, 25000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'HUELLERO', NULL, 5000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'ESCOBILLAS', 16000.0, 16000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'RODAMIENTO 607', 12000.0, 12000.0),
  (@cotizacion_id, 5, NULL, 1.0, 'MANTENIMIENTO Y MANO DE OBRA', 23500.0, 23500.0);

-- ===== OT 0737 (hoja original: 737-PDT) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('DANIEL ZORRO', NULL, NULL, NULL, '305 9150243', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERCUTOR', 'DEWALT', 'DWD024-B3', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0737', @articulo_id, 'PDT', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 103000.0, 103000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'PIÑON CORONA', 33000.0, 33000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'BLOQUE INTERMEDIO PERCUTOR', 38000.0, 38000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'RODAMIENTO 6001', 10000.0, 10000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'RODAMIENTO 6008', 10000.0, 10000.0),
  (@cotizacion_id, 5, NULL, 1.0, 'LLAVE CON SELECTOR PERCUTOR', 6000.0, 6000.0),
  (@cotizacion_id, 6, NULL, 1.0, '(sin descripcion)', 6000.0, 6000.0);

-- ===== OT 0736 (hoja original: 736-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('SR MAURICIO REINA', 'DOBLADORA RYS', '900213000-1', 'dobladorarys@hotmail.com', '3143575809', 'calle 182 # 8d - 17');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'ELITE', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0736', @articulo_id, 'INGRESO', NULL, '2026-01-20 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0735 (hoja original: 735-COTIZADA PDT) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('SR MAURICIO REINA', 'DOBLADORA RYS', '900213000-1', 'dobladorarys@hotmail.com', '3143575809', 'calle 182 # 8d - 17');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'TOTAL', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0735', @articulo_id, 'COTIZADA PDT', NULL, '2026-01-20 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 49500.0, 49500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '210200-6', 1.0, 'RODAMIENTO 608', 12000.0, 12000.0),
  (@cotizacion_id, 2, '211092-6', 1.0, 'RODAMIENTO 629', 12000.0, 12000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'ORING', 2000.0, 2000.0),
  (@cotizacion_id, 4, NULL, 1, 'MANO DE OBRA YV MANTENIMIENTO', 23500.0, 23500.0);

-- ===== OT 0734 (hoja original: 734-COT ) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES (NULL, 'SOCIEDAD FERRETERA', NULL, NULL, NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'DEMOLEDOR', 'HILTI', 'NO REGISTRA', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0734', @articulo_id, 'COT', NULL, '2025-09-09 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'EQUIPO ENCIENDE PERO NO GENERA IMPACTO, SE REAIZA LA EVALUACIÓN COMPLETA DE LA MAQUINA Y SE EVIDENCIA ANILLOS DE COMPRESIÓN DESGASTADOS Y AMORTIGUADOR FRACTURADO, OCASIONADO QUE LA CAMARA NO GENERE COMPRESION Y SE PIERDA LA FUERZA DE GOLPE, ADICIONALMENTE EL RESORTE QUE L EDA ESTABILIDAD AL SISTEMA ANTI-VIBRATORIO SE ENCUENTRA FRACTURADO.                                                                                                                                                                                                                                                                                                                                                NOTA:  HILTI COLOMBIA NO REALIZA LA DISTRIBUCIÓN DE REFACCIONES, POR LO CUAL LA ALTERNATIVA VIABLE ES LA FABRICACION DE DICHOS EMPAQUES EN EL MERCADO LOCAL, LABOR QUE YA ESTAMOS GESTIONANDO, TENIENDO EN CUENTA QUE EL MATERIAL ES ESPECIAL (FLUORURO).', 540000.0, 540000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'EXPT-0039', 1.0, 'ANILLO PESO MUERTO', 160000.0, 160000.0),
  (@cotizacion_id, 2, 'EXPT-0040', 1.0, 'ANILLO PISTON', 160000.0, 160000.0),
  (@cotizacion_id, 3, 'EXPT-0041', 1.0, 'AMORTIGUADOR', 50000.0, 50000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'RESORTE AVT', 50000.0, 50000.0),
  (@cotizacion_id, 5, NULL, 1.0, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', 120000.0, 120000.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'COT', 'FACT EXT #859');

-- ===== OT 0733 (hoja original: 733-PAGADA Y  ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('WILSON BLANDON', NULL, '80112925', NULL, '3204628909', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'DEWALT TIPO 15', 'D25133-B3', '51304');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0733', @articulo_id, 'PAGADA Y  ENTREGADA', 'HACER MANTENIMIENTO TAMBIEN', '2026-01-21 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA DIRECTA CON INTYERRUPTOR EN CORTO ESCOBILLAS CON DESGASTE Y MANTENIMIENTO Y MANO DE OBRA', 150500.0, 150500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'ESCOBILLAS', 25000.0, 25000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'INTERRUPTOR', 90000.0, 90000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'ANILLO PESO MUERTO', 7000.0, 7000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'MANO DE OBRA Y MANTENIMIENTO', 28500.0, 28500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'PAGADA Y  ENTREGADA', 'lista 9/02'),
  (@orden_id, 'PAGADA Y  ENTREGADA', 'PAGADA Y ETREGADA 9/02/2026'),
  (@orden_id, 'PAGADA Y  ENTREGADA', 'AUTORIZADA 21/01/2026'),
  (@orden_id, 'PAGADA Y  ENTREGADA', 'ABONO 80.000 22/01/2026'),
  (@orden_id, 'PAGADA Y  ENTREGADA', 'SALDO 70.500');

-- ===== OT 0732 (hoja original: 732-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JORGE', 'LUSH DETAILING', NULL, NULL, '3106976231', 'CR 45 A # 131 - 36');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'POLICHADORA', 'GENERICA', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0732', @articulo_id, 'INGRESO', NULL, '2026-01-20 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'SE EVIDENCIA BOBINA RECALENTADA, PUEDE SER OCASIONADA POR FORZAMIENTO DE LA MAQUINA , GENERANDO OLOR A QUEMADO', 0.0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'BOBINA', NULL, 0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'INGRESO', 'informacion enviada');

-- ===== OT 0731 (hoja original: 731-ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('GABRIEL', 'INGECONS INGENIEROS CONSTRUCTORES Y CONSULTORES S.A.S', '830512329-6', NULL, '3123868912', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'BOSCH', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0731', @articulo_id, 'ENTREGADA', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 88500.0, 88500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'ANILLO PESO MUERTO', 15000.0, 15000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'BOTON COMPETO', 45000.0, 45000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'MANTENIMIENTO Y MANO DE OBRA', 28500.0, 28500.0);

-- ===== OT 0730 (hoja original: 730-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('SAMUEL  RAMIREZ', 'MONTALLANTAS BOMBA', '1019020693', NULL, '3213412454', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'SIN CLASIFICAR', 'UYUSTOOLS', 'UY-PSC2000', '20241100766');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0730', @articulo_id, 'INGRESO', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0729 (hoja original: 729-COT ENVIADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('DIDIER JOSE TORTELLO OSTIL', NULL, '1065619493', NULL, '3212462161', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'SIN CLASIFICAR', 'LITHIUM', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0729', @articulo_id, 'COT ENVIADA', NULL, '2026-01-19 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA  CON INTERRUPTOR INTERMITENTE', 50000.0, 50000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'INTERRUPTOR', 40000.0, 40000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'MANO DE OBRA', 10000.0, 10000.0);

-- ===== OT 0728 (hoja original: 728-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('AUTO SAFE S.A', 'AUTO SAFE S.A', '811034722-8', 'info@autosafe.com.co', NULL, 'CR 23 71 A 36');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'SEGETA NEUMATICA', 'RONGPENG', NULL, 'RP23070029');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0728', @articulo_id, 'INGRESO', NULL, '2026-01-17 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0727 (hoja original: 727-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('SEBASTIAN CASTILLO', 'FERRE CASTILLO', NULL, NULL, '3192075139', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'BOSCH', 'GBH2-28 DFV', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0727', @articulo_id, 'INGRESO', NULL, '2026-01-16 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0726 (hoja original: 726-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ANDERSON', 'FULL SOLUCIONES', '901246642-3', NULL, '3203002393', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'DEWALT CHINO', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0726', @articulo_id, 'INGRESO', 'INGRESA CON MALETIN', '2026-01-16 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0725 (hoja original: 725-ENTREGADO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('CRISTIAN PAEZ', NULL, '1016031937', NULL, '3003459046', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO INALAMBRICO', 'DEWALT', 'DCD796 TIPO 3', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0725', @articulo_id, 'ENTREGADO', 'SIN BATERIA NI CARGADOR', '2026-01-16 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 23500.0, 23500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'TRASMICIÓN', 399000.0, 0),
  (@cotizacion_id, 2, NULL, 1.0, 'MANO DE OBRA Y MANTENIMIENTO', 23500.0, 23500.0);

-- ===== OT 0724 (hoja original: 724-ENTREGADA SIN REP) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('SILVIA', 'PINTOR ELÉCTROSTATICO', '900346300-5', 'facturacionpintorelectro@gmail.com', '3222115144', 'CR 47 132 21');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4/12', 'DONGCHENG', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0724', @articulo_id, 'ENTREGADA SIN REP', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA NO ENCIENDE SE DIAGNOSTICA REPARACIÓN DE TERMINAL ELECTRICO, RODAMIENTO FATIGADO, CAPUCHON CON DESGASTE, ESCOBILLAS AL 50% DE VIDA UTIL', 59500.0, 59500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'RODAMIENTO 6007', 12000.0, 12000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'CAPUCHON DE RODAMIENTO', 10000.0, 10000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'ESCOBILLAS (OPCIONAL)', 14000.0, 14000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'MANO DE OBRA Y MANTENIMIENTO', 23500.0, 23500.0);

-- ===== OT 0723 (hoja original: 723-ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('SILVIA', 'PINTOR ELÉCTROSTATICO', '900346300-5', 'facturacionpintorelectro@gmail.com', '3222115144', 'CR 47 132 21');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4/2', 'MAKITA', '9557HP', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0723', @articulo_id, 'ENTREGADA', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUIANA ENCIENDE SONIDO EXTRAÑO, SE PROCEDE A REALIZAR EL DESENSAMBLE DEL EQUIPO Y SE EVIDENCIA INDUCIO CON DELGA', 235000.0, 235000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '510083F7', 1.0, 'INDUCIDO', 120000.0, 120000.0),
  (@cotizacion_id, 2, 'CB325', 1.0, 'ESCOBIOLLAS', 16000.0, 16000.0),
  (@cotizacion_id, 3, NULL, 2.0, 'PORTA ESCOBILLAS X2 UNIDADES', 7000.0, 14000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'BOBINA DE CAMPO', 85000.0, 85000.0);

-- ===== OT 0722 (hoja original: 722-AUTORIZADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('SILVIA', 'PINTOR ELÉCTROSTATICO', '900346300-5', 'facturacionpintorelectro@gmail.com', '3222115144', 'CR 47 132 21');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'MAKITA', 'M9507', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0722', @articulo_id, 'AUTORIZADA', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA NO ENCIENDE BOBINA EN CORTO, ESCOBILLAS NO ORIGINALES Y DESGASTADAS, INTERRUPTOR INTERMITENTE SIN PASO DE CORRIENTE.', 171500.0, 171500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'BOBINA', 121000.0, 121000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'INTERRUPTOR', 15000.0, 15000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'ESCOBILLAS', 12000.0, 12000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'MANO DE OBRA Y MANTENIMIENTO', 23500.0, 23500.0);

-- ===== OT 0721 (hoja original: 721-ENTREGADA PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JOSE RODRIGO JARA', 'SANTA MARIA Y CASTRO', '900158284-9', NULL, '3042161381', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERCUTOR', 'STANLEY', 'STDH8013-B3', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0721', @articulo_id, 'ENTREGADA PAGADA', NULL, '2026-01-16 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA SIN ESCOBILLAS, NO ENCIENDE, SE DIAGNOSTICA COLLECTOR DEFISIENTE, SE REALIZA MANTYENIMIENTO GENERAL CON CAMBIO DE GRASA Y LUBRICACIÓN.', 155500.0, 155500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'ESCOBILLAS', 6000.0, 6000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'INDUCIDO (OPCIONAL)', 116000.0, 116000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'RODAMIENTO 6008', 10000.0, 10000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'MANTENIMIENTO GENERAL', 23500.0, 23500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADA PAGADA', 'AUTORIZADA 20/01/2026'),
  (@orden_id, 'ENTREGADA PAGADA', 'ENTREGADA Y PAGADA 27/01/2026');

-- ===== OT 0720 (hoja original: 720-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('GERARDO GONZALES', NULL, NULL, NULL, '3112048623', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'BOSCH', 'CHINA', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0720', @articulo_id, 'INGRESO', 'INGRESA CON EMPUÑADURA SIN BRIDA Y TUERCA', '2026-01-07 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0719 (hoja original: 719-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ANA ROMERO', NULL, NULL, NULL, '3227587284', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'DEWALT', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0719', @articulo_id, 'INGRESO', NULL, '2026-01-14 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 23500.0, 23500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'MANTENIMIENTO Y MANO DE OBRA', 23500.0, 23500.0);

-- ===== OT 0718 (hoja original: 718-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('HECTOR MOLINA TRIANA', NULL, NULL, NULL, '3204657653', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO', 'MAKITA', 'BL1813G', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0718', @articulo_id, 'INGRESO', 'INGRESA CON BATERIA', '2026-01-15 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 211374.0, 211374.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'SWITCH', 195874.0, 195874.0),
  (@cotizacion_id, 2, NULL, 1.0, 'MANO DE OBRA Y MANTENIMIENTO', 15500.0, 15500.0);

-- ===== OT 0717 (hoja original: 717-ENTREGADO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ANDERSON', 'FULL SOLUCIONES', '901246642-3', NULL, '3203002393', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'MAKITA', 'HR2470', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0717', @articulo_id, 'ENTREGADO', NULL, '2026-01-13 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 148000.0, 148000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '210200-6', 1.0, 'RODAMIENTO 6008', 10000.0, 10000.0),
  (@cotizacion_id, 2, '210028-2', 1.0, 'RODAMIENTO 606', 10000.0, 10000.0),
  (@cotizacion_id, 3, '2322399', 3.0, 'RESORTES', 8000.0, 24000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'BOTON PALANCA COMPLETO', 16500.0, 16500.0),
  (@cotizacion_id, 5, '1634307', 1.0, 'BLOQUEO METALICO', 9400.0, 9400.0),
  (@cotizacion_id, 6, '4177960', 1.0, 'BLOQUEO PLASTICO', 2600.0, 2600.0),
  (@cotizacion_id, NULL, '213227-5', 1.0, '(sin descripcion)', 5000.0, 5000.0),
  (@cotizacion_id, NULL, '331992-5', 1.0, '(sin descripcion)', 42000.0, 42000.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADO', 'ENTREGA 11/02');

-- ===== OT 0712 (hoja original: 712-ENTREGADO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ANDERSON', 'FULL SOLUCIONES', '901246642-3', NULL, '3203002393', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'MAKITA', 'HR2810', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0712', @articulo_id, 'ENTREGADO', NULL, '2026-01-13 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 128500.0, 128500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, '(sin descripcion)', 28500.0, 28500.0),
  (@cotizacion_id, 2, NULL, 1.0, 'cilindro', 92000.0, 92000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'anillo', 8000.0, 8000.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADO', 'ENTREGADO');

-- ===== OT 0716 (hoja original: 716-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JULIO PIRAGAUTA', NULL, NULL, NULL, NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERCUTOR', 'WORX', 'PDI13QE-1', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0716', @articulo_id, 'INGRESO', NULL, '2026-01-14 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0715 (hoja original: 715-ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ARMANDO RAMIREZ', NULL, '3026740', NULL, '3115710361', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO', 'SIN MARCA', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0715', @articulo_id, 'ENTREGADA', NULL, '2026-01-15 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MATRIMONIO DE PIÑONES DESGASTADO POR SER UNA MARCA GENERICA NO SE CONSIGUEN REPUESTOS, POR LO CUAL NO TENDRÍA REPARACIÓN.', 0.0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'MATRIMONIO PIÑONES ( descontinuando)', NULL, 0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADA', 'DIAGNOSTICO ENVIADO 23/01/2026');

-- ===== OT 0714 (hoja original: 714-ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ARMANDO RAMIREZ', NULL, '3026740', NULL, '3115710361', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO', 'BAUKER', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0714', @articulo_id, 'ENTREGADA', NULL, '2026-01-15 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA NO ENCIENDE, PROBLEMA EN EL CABLE DE PODER POR LO QUE SE REQUIERE CAMBIO, MANTENIMIENTO GENERAL', 48500.0, 48500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'PASA CABLE', 8000.0, 8000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'CABLE DE PODER ECONOMICO', 25000.0, 25000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'MANO DE OBRA ELECTRICA', 15500.0, 15500.0);

-- ===== OT 0713 (hoja original: 713-ENTREGADA SIN REPARAR) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ENRIQUE CASTAÑO', NULL, NULL, NULL, '3016071567', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO', 'MAKITA', 'HP2070', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0713', @articulo_id, 'ENTREGADA SIN REPARAR', NULL, '2026-01-14 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 314500.0, 314500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'inducido', 204500.0, 204500.0),
  (@cotizacion_id, 2, NULL, 1.0, 'escobillas', 16000.0, 16000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'porta escobillas', 64700.0, 64700.0),
  (@cotizacion_id, 4, NULL, 1.0, 'selector', 5800.0, 5800.0),
  (@cotizacion_id, 5, NULL, 1.0, 'mantenimiento y mano de obra', 23500.0, 23500.0);

-- ===== OT 0711 (hoja original: 711-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('WILLIAM POLO', NULL, '7603394', 'POLOWILLIAM@HOTMAIL.COM', '3123120248', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'DEMOLEDOR', 'TOTAL', 'UTHT217068', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0711', @articulo_id, 'ENTREGADA Y PAGADA', NULL, '2026-01-13 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA ENCIENDE INDUCIDO EN CORTO ESCOBILLAS A UN 30% DE VIDA UTIL, RODAMIENTOS FATIGADOS, ESTA REFERENCIA DE MAQUINA ACTUALMENTE SE ENCUENTRAN AGOTADOS LOS REPUESTOS ,EL TIEMPO DE REPARACIÓN ES DE UNA ESPERA DE 25 DÍAS, DESPUES DE UN ABONO DEL 50%', 409500.0, 409500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'INDUCIDO', 250000.0, 250000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'ESCOBILLAS', 25000.0, 25000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'KIT DE ANILLOS', 25000.0, 25000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'PASADOR', 25000.0, 25000.0),
  (@cotizacion_id, 5, NULL, 1.0, 'MANO DE OBRA Y MANTENIMIENTO', 48500.0, 48500.0),
  (@cotizacion_id, 6, NULL, 2.0, 'RODAMIENTOS 6001', 18000.0, 36000.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADA Y PAGADA', 'ABONO 200.000 11/02/2026'),
  (@orden_id, 'ENTREGADA Y PAGADA', 'ENTREGADA Y PAGADA 31/03/2026'),
  (@orden_id, 'ENTREGADA Y PAGADA', 'CV.1480'),
  (@orden_id, 'ENTREGADA Y PAGADA', 'FACT.742');

-- ===== OT 0710 (hoja original: 710-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES (NULL, 'CINCO ARQUITECTOS SAS', '900601689', 'contabilidad@cincoarquitectos.com', '3332454668', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'MARTILLO DEMOLEDOR', 'DEWALT', 'D25810-B3', '2691');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0710', @articulo_id, 'INGRESO', 'INGRESA CON MALETIN', '2026-01-06 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA CON DESGASTE EN SUS ANUILLOS DE COMPRESION, RODAMIENTO CON FATIGA, BIELA CON LIGERO DESGASTE, MANTENIMIENTO GENERAL, LIMPIEZA Y CAMBIO DE LUBRICACIÓN.', 225500.0, 225500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'N443604', 1.0, 'ESCOBILLAS', 40000.0, 40000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'BIELA+ANILLO+PISTÓN (OPCIONAL)', 114000.0, 114000.0),
  (@cotizacion_id, 3, '1610210157-000', 1.0, 'ANILLO PISTÓN (OPCIÓN 1)', NULL, 0),
  (@cotizacion_id, 4, 'N446544', 1.0, 'ANILLO PESO MUERTO', 18000.0, 18000.0),
  (@cotizacion_id, 5, '211131-12', 1.0, 'RODAMIENTO 6001', 18000.0, 18000.0),
  (@cotizacion_id, 6, NULL, 1.0, 'MANTENIMIENTO Y MANO DE OBRA', 35500.0, 35500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'INGRESO', 'OPCIÓN 2 KIT : 225.000'),
  (@orden_id, 'INGRESO', 'OPCION 1 SIN BIELA 129500');

-- ===== OT 0709 (hoja original: 709-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('LUIS ARIAS', NULL, '1010185191', NULL, '3102163316', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'LLAVE DE IMPACTO', 'GENERICA', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0709', @articulo_id, 'INGRESO', 'INGRESA CON BATRERIA Y CARGADOR', '2026-01-06 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'INTERRUTOR Y MODULO EN CORTO , SE REQUIERE CAMBIO DE LAS PIZAS YA QUE SE ESTALLO EL MODULO, PARA ESTA MAQUIA GENERICA,NO SE MANEJAN REFACCION, SE REQUIERE REALIZAR MODIFICACIONES EN LA ESTRUCTURA DE LA MAQUINA', 103500.0, 103500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'MODULO GENERICO', NULL, 45000.0),
  (@cotizacion_id, 2, NULL, 1, 'INTERRUPTOR', NULL, 35000.0),
  (@cotizacion_id, 3, NULL, 1, 'MANO DE OBRA', NULL, 23500.0);

-- ===== OT 0708 (hoja original: 708-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JAMES RUSSI', NULL, '79921600', NULL, '3203561309', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'TRUPER', '-', '-');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0708', @articulo_id, 'INGRESO', 'SIN ACCESORIOS', '2025-12-27 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'SUENAN FEO LOS ENGRANAJES, NO LLEGA A FUNCION PERFORAR, COTIZAR MANGO AUXILIAR', 0.0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();

-- ===== OT 0707 (hoja original: 707-ENTREGADA PDT PAGO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('RICARDO OLIVEROS', 'CIENTO ONCE SUPPORT SERVICES SAS', '901113968-8', 'CIENTOONCE.SAS@GMAIL.COM', '3134951511', 'AUTONORTE 215-27');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'LIJADORA MAKITA', NULL, NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0707', @articulo_id, 'ENTREGADA PDT PAGO', NULL, '2025-12-26 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA ENCIENDE SONIDO EXTRAÑO, RODAMIENTOS CON FATIGA, RESORTES FRACTURADOS Y MANTENIMIENTO Y LIMPIEZA GENERAL', 96100.0, 96100.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 8.0, 'ORING', 600.0, 4800.0),
  (@cotizacion_id, 2, '1622792', 2.0, 'RESORTES', 10000.0, 20000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'RODANIENTO 6202', 20000.0, 20000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'RODAMIENTO 6200', 15000.0, 15000.0),
  (@cotizacion_id, 5, NULL, 1.0, 'RODAMIENTO 6007', 12000.0, 12000.0),
  (@cotizacion_id, 6, NULL, 4.0, 'ESPUMAS', 200.0, 800.0),
  (@cotizacion_id, 7, NULL, 1.0, '(sin descripcion)', 23500.0, 23500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADA PDT PAGO', 'ENTREGADA PDT PAGO 1295');

-- ===== OT 0706 (hoja original: 706-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('RICARDO OLIVEROS', 'CIENTO ONCE SUPPORT SERVICES SAS', '901113968-8', 'CIENTOONCE.SAS@GMAIL.COM', '3134951511', 'AUTONORTE 215-27');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'RUTEADORA', 'TRUPER', 'ROU-A3', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0706', @articulo_id, 'INGRESO', NULL, '2025-12-26 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA NO ENCIENDE, INDUCIDIO EN CORTO , BOBINA EN CORTO, REGULADOR ESTALLADO POR VOLTAJE,  NO SE JUSTIFICA REPARACIÓN YA QUE EL 80% DE COMPUESTOS DEL EQUIPO NO FUNCIONAN Y ESTOS NO SE CONSIGUEN  ACTUALMENTE.', 0.0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'INDUCIDO', NULL, 0),
  (@cotizacion_id, 2, NULL, 1, 'ESCOBILLAS', NULL, 0),
  (@cotizacion_id, 3, NULL, 1, 'MODULO', NULL, 0),
  (@cotizacion_id, 4, NULL, 1, 'BOBINA', NULL, 0);

-- ===== OT 0705 (hoja original: 705-ENTREGADA PDT PAGO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('RICARDO OLIVEROS', 'CIENTO ONCE SUPPORT SERVICES SAS', '901113968-8', 'CIENTOONCE.SAS@GMAIL.COM', '3134951511', 'AUTONORTE 215-27');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'RUTEADORA', 'TOTAL', 'UTR111226', '20142540584');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0705', @articulo_id, 'ENTREGADA PDT PAGO', NULL, '2025-12-26 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA CON RODAMIENTO FATIGADO, ESCOBILLAS REVENTADAS POR LO CUAL SE EVIDENCIABA UN MAL CONTACTO CON EL RESOPRTE', 61000.0, 61000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '654197-3', 1.0, 'RESORTE DE PORTAESCOBILLAS', 4000.0, 4000.0),
  (@cotizacion_id, 2, '211326-7', 1.0, 'RODAMIENTO 6004', 33500.0, 33500.0),
  (@cotizacion_id, 3, NULL, 1.0, 'MANO DE OBRA Y MANTENIMIENTO', 23500.0, 23500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADA PDT PAGO', 'ENTREGADA PDT PAGO 1295');

-- ===== OT 0704 (hoja original: 704-AUTORIZADO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('DUVER HINCAPIE', NULL, '79856710', 'DUVERHINCAPIE74@HOTMAIL.COM', '3104366280', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ATORNILLADOR INALMBRICO V', 'MAKITA', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0704', @articulo_id, 'AUTORIZADO', NULL, '2025-12-23 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA FUNCIONA CAJA ENGRANAJE CON BUJE SUELTO ANBIL CON DESGASTE y SE COTIZA EL SEGURO PARA ASEGURAR EL ACCESORIO.', 121300.0, 121300.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '14', 1.0, 'CARCAZA CAJA ENGRANAJE', 48200.0, 48200.0),
  (@cotizacion_id, 2, '15', 1.0, 'ORING-ARANDELA', 1400.0, 1400.0),
  (@cotizacion_id, 3, '17', 1.0, 'ANBIL', 37200.0, 37200.0),
  (@cotizacion_id, 4, '216019-1', 2.0, 'ESFERA', 1000.0, 2000.0),
  (@cotizacion_id, 5, '231965-7', 1.0, 'ANILLO', 1000.0, 1000.0),
  (@cotizacion_id, 6, '2671433', 1.0, 'ARANDELA', 1000.0, 1000.0),
  (@cotizacion_id, 7, '9', 1.0, '(sin descripcion)', 7000.0, 7000.0),
  (@cotizacion_id, 8, NULL, 1.0, '(sin descripcion)', 23500.0, 23500.0);

-- ===== OT 0703 (hoja original: 703-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES (NULL, 'MEKACAR', NULL, NULL, '3502108603', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'LIJADORA NEUMATICA', NULL, NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0703', @articulo_id, 'INGRESO', 'INGRESA LLAVE- ACOPLES', '2025-12-23 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0702 (hoja original: 702-PAGADA YE NTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('DANIEL AVEDAÑO', 'STOP CENTER', NULL, NULL, '3223644557', 'CRA 46 #128A-10');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'LIJADORA ORBITAL', 'MAKITA', 'M9204', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0702', @articulo_id, 'PAGADA YE NTREGADA', 'SIN ACCESORIOS', '2025-12-22 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'RODAMIENTOS CON FATIGA, PAD VELCRO DESGASTADO, INTERRUPTOR CON PASE DE CORRIENTE INTERRUMPIDO, FRENO Y CAZUELA CON DESGASTE CONSIDERABLE POR FALTA DE MANTENIMIENTO', 104000.0, 104000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'RODAMIENTO 6001', 18000.0, 18000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'RODAMIENTO 607', 12000.0, 12000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'RODAMIENTO 609', 12000.0, 12000.0),
  (@cotizacion_id, NULL, NULL, 1.0, '(sin descripcion)', NULL, 20000.0),
  (@cotizacion_id, 4, '651527-9', 1.0, 'INTERRUPTOR', 12000.0, 12000.0),
  (@cotizacion_id, 5, '318304-9', 1.0, 'CAZUELA', 30000.0, 30000.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'PAGADA YE NTREGADA', 'ENTREGADA Y PAGADA 20-03-2026'),
  (@orden_id, 'PAGADA YE NTREGADA', 'PAGADA NEQUI');

-- ===== OT 0701 (hoja original: 701-NO JUSTIFICA-ENTRGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('MELBIN GRASS', NULL, '19343089', NULL, '3017302840', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PERCUTROR INSLAMBRICO', 'BAUKER', 'SD-GS1041', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0701', @articulo_id, 'NO JUSTIFICA-ENTRGADA', 'UNA BATERIA 12', '2025-12-20 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'BATERIA SIN CARGA, MAQUINA PRESENTA FALLA EN LA TRANSMICIÓN, PIÑONES DESENGRANADOS Y FRACTUROS, NO PERMITE GENERAR MOVIMIENTO MECANICO, FALLA EN MANDRIL ATASCADO POR OXIDACIÓN. NO JUSTIFICA LA REPARACIÓN YA QUE PARA ESTE EQUIPO NO SE ENCUENTRAN REPUESTOS ESPECIFICOS Y ESENCIALES COMO LA CAJA DE ENGRAJE.', 0.0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'NO JUSTIFICA-ENTRGADA', 'ENTREGADA 19/01/2026');

-- ===== OT 0700 (hoja original: 700-ENTREGADA SIN REP) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('VLADIMIR ARZUZA', NULL, '79295082', NULL, '3008547075', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4 1/2', 'SIEFKEN', 'GD1108', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0700', @articulo_id, 'ENTREGADA SIN REP', 'SIN ACCESORIOS', '2025-12-20 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'HERRAMIENTA QUEMADA YA QUE ENTRA EN CORTO, CARCASA DERRETIDA, NO JUSTIFICA REPARACIÓN', 0.0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'INDUCIDO', NULL, 0),
  (@cotizacion_id, 2, NULL, 1, 'CAJA MOTOR', NULL, 0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADA SIN REP', 'ENTREGADA SIN REPARACIÓN 03/02');

-- ===== OT 0699 (hoja original: 699-PDT) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('PABLO BEDOYA', 'BEDOYA VALLEJO PUBLICIDAD SAS', '901904623-7', 'GERENCIA@BEDOYAPUBLICIDAD.COM', '3143957594', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ESMERILADORA ANGULAR', 'TRUPER', 'ESMA-4-1/2A12', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0699', @articulo_id, 'PDT', NULL, '2025-12-18 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA ENCIENDE, SE EVIDENCIA ARRASTRRE DE INDUCIDO Y BOBINA, ESCOBILLAS A UN 15% DE VIDA UTIL.', 87500.0, 87500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'RODAMIENTO 607', NULL, 12000.0),
  (@cotizacion_id, 2, NULL, 1, 'ESCOBILLAS A 12', NULL, 14000.0),
  (@cotizacion_id, 3, NULL, 1, 'RESORTE BLOQUEO DISCO', NULL, 3000.0),
  (@cotizacion_id, 4, NULL, 1, 'CAJA ENGRANAJE, BOTON EJE  Y RESORTE', NULL, 35000.0),
  (@cotizacion_id, 5, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 23500.0);

-- ===== OT 0698 (hoja original: 698-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('PABLO BEDOYA', 'BEDOYA VALLEJO PUBLICIDAD SAS', '901904623-7', 'GERENCIA@BEDOYAPUBLICIDAD.COM', '3143957594', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ESMERILADORA ANGULAR', 'DEWALT', 'DWE4120-B3', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0698', @articulo_id, 'ENTREGADA Y PAGADA', NULL, '2025-12-18 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA ENCIENDE, SE EVIDENCIA PIÑONES DESGASTADOS, ESCOBILLAS CON 25% DE VIDA UTIL', 101500.0, 101500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'PIÑON Y CORONA', NULL, 35000.0),
  (@cotizacion_id, 2, NULL, 1, 'ESCOBILLAS', NULL, 23000.0),
  (@cotizacion_id, 3, NULL, 1, 'PALANCA INTERRUPTOR', NULL, 8000.0),
  (@cotizacion_id, 4, NULL, 1, 'RODAMIENTO 607', NULL, 12000.0),
  (@cotizacion_id, 5, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 23500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADA Y PAGADA', 'informada 13/03/2026'),
  (@orden_id, 'ENTREGADA Y PAGADA', 'ENTREGADA Y PAGADA 24/03');

-- ===== OT 0697 (hoja original: 697-PDT PAGO ENTREGADO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES (NULL, 'TECNIMOTOR JP', NULL, NULL, '3124538636 - 3102044256', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'DEMOLEDOR', 'GLOBALMEK', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0697', @articulo_id, 'PDT PAGO ENTREGADO', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA ENCIENDE GOLPEA, PERO PRESENTA MUCHA CHISPA Y TEMPERATURA POR PORTA ESCOBILLAS EN MAL ESTADO, TIENE FISURA EN LA CAMARA DE COMPRESIÓN, MANTENIMIENTO GENERAL, CAMBIO DE ANILLOS.', 212000.0, 212000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'PORTA ESCOBILLAS', 65000.0, 65000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'ESCOBILLAS', NULL, 0),
  (@cotizacion_id, 3, NULL, 1.0, 'TAPA ESCOBILLAS', NULL, 0),
  (@cotizacion_id, 4, NULL, 1.0, 'ANILLO PESO MUERTO', 30000.0, 30000.0),
  (@cotizacion_id, 5, NULL, 1.0, 'EMPAQUE DE RECAMARA', 15000.0, 15000.0),
  (@cotizacion_id, 6, NULL, 1.0, 'PASA CABLE', 8000.0, 8000.0),
  (@cotizacion_id, 8, NULL, 2.0, '(sin descripcion)', 12000.0, 24000.0),
  (@cotizacion_id, 9, NULL, 1.0, '(sin descripcion)', 70000.0, 70000.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'PDT PAGO ENTREGADO', 'ENTREGADA PDT PAGO 23/1/2026');

-- ===== OT 0696 (hoja original: 696-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('MIGUEL TORRES', NULL, '79110137', NULL, '3002001735', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'MULTIHERRAMIENTA OSCILANTE', 'RIDGID', 'R2851-SERIE B', 'CS15524DD6045-CS18036NB40197');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0696', @articulo_id, 'INGRESO', NULL, '2025-12-17 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'INGRESO', 'ENVIADO');

-- ===== OT 0695 (hoja original: 695-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('MIGUEL TORRES', NULL, '79110137', NULL, '3002001735', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'MULTIHERRAMIENTA OSCILANTE', 'RIDGID', 'R2851-SERIE B', 'CS15522N010181-CS18044NK58130');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0695', @articulo_id, 'INGRESO', 'INGRESA CON MALETIN', '2025-12-17 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'INGRESO', 'NO SE PUEDE REPARAR');

-- ===== OT 0694 (hoja original: 694-ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JOSE BARON', NULL, '79240194', 'DIEGOALE1907@HOTMAIL.ES', '3115335927', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO', 'BLACK & DECKER', 'BCD704', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0694', @articulo_id, 'ENTREGADA', 'INGRESA CON DOS BATERIAS', '2025-12-15 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0693 (hoja original: 693-PGADA ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ALBERTO BARRETO', 'FOCUS ENERGY S.A.S.', '901146880-0', 'contabilidad@focusenergy.com.co', '3102129985', 'AV 3 9 73 OF 401');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'BOSCH', 'GBH2-24D', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0693', @articulo_id, 'PGADA ENTREGADA', 'INGRESA CON CAJA-MANGO AUXILIAR/ CLIENTE INFORMA QUE ES PARA MANTENIMIENTO, PASA CABLE ESTA SUELTO', '2025-12-15 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MANTENIMIENTO GENERAL, RODAMIENTO CON FATIGA Y ANILLO DESGASTADO.', 55500.0, 55500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'RODAMIENTO 607', 12000.0, 12000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'ANILLO PESO MUERTO', 15000.0, 15000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'MANTENIMIENTO Y MANO DE OBRA', 28500.0, 28500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'PGADA ENTREGADA', 'ENTREGADA Y PAGADA 23/01/2026');

-- ===== OT 0692 (hoja original: 692-PAGADA ENTREGADA ) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('LUIS ALEJANDRO', 'ARAR REPRESENTACIONES SAS', NULL, NULL, '3057278423', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'GUADAÑA', 'HUSQVARNA', '453RS', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0692', @articulo_id, 'PAGADA ENTREGADA', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'CARBURADOR DESCOMPENSADO, CON DESGASTES EN AGUJA Y CHICLER, SE  CAMBIAN FILTROS PARA MITIGAR CONTAMINACION EN CARBURADOR NUEVO, ANILLOS PARA AUMENTAR COMPRESIÓN', 422000.0, 422000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'CARBURADOR', NULL, 280000.0),
  (@cotizacion_id, 2, NULL, 1, 'FILTRO DE AIRE', NULL, 25000.0),
  (@cotizacion_id, 3, NULL, 1, 'FILTRO DE GASOLINA', NULL, 22000.0),
  (@cotizacion_id, 5, NULL, 1, 'MEMBANA MOTOR', NULL, 35000.0),
  (@cotizacion_id, 6, NULL, 1, 'SERVICIO DE MANO DE OBRA', NULL, 60000.0);

-- ===== OT 0691 (hoja original: 691 - INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('freddy', 'FAROLAS FREDDY', NULL, NULL, '3138055799', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERCUTOR', 'BOSH', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0691', @articulo_id, 'INGRESO', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 45500.0, 45500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'PORTA ESCOBILLAS + ESCOBILLAS', NULL, 30000.0),
  (@cotizacion_id, 2, NULL, 1, 'MANO DE OBRA MINIMA', NULL, 15500.0);

-- ===== OT 0690 (hoja original: 690-AUTORIZADO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('WILSON REYES', NULL, '4223648', NULL, '3212343907', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO 1050', 'TOTAL', 'UTH11', '23182040285');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0690', @articulo_id, 'AUTORIZADO', 'INGRESA CON MALETIN Y CINCEL', '2025-12-12 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'Maquina enciende suena rora, presenta fracturas en las piezas, se realiza el cambio por la piezas originales.', 20000.0, 20000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'UTH110266-SP-50', 1.0, 'CIGUEÑAL', 35000.0, 35000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'RODAMIENTO 6002', 25000.0, 25000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'BALINERAS X2  (GARANTÍA)', 5000.0, 5000.0),
  (@cotizacion_id, 4, 'UTH110266-SP-1', 1.0, 'BUMPER', 5000.0, 5000.0),
  (@cotizacion_id, 5, 'UTH110266-SP-3', 1.0, 'CAPUCHON (GARANTÍA)', 10000.0, 10000.0),
  (@cotizacion_id, 6, NULL, 1.0, 'MANO DE OBRA Y MANTENIMIENTO (GARANTÍA)', 28500.0, 28500.0),
  (@cotizacion_id, NULL, NULL, 1, 'GOLPEADOR', NULL, 15000.0),
  (@cotizacion_id, NULL, NULL, 1, 'BALINERAS GOLPEADOR', NULL, 5000.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'AUTORIZADO', 'GARANTÍA');

-- ===== OT 0689 (hoja original: 689-ENTREGADA Y PGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES (NULL, 'R&G HOME', '900882963-6', 'facturas@rghome.co', '3102319255', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'RECORTADORA', 'MAKITA', NULL, '8616847');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0689', @articulo_id, 'ENTREGADA Y PGADA', NULL, '2025-12-11 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'RODAMIENTO FRACTURTADO, GENERA DERRETIMIENTO DE CARCASA Y ANILLO.- AJUSTE BASICO SI LA M,AQUINA SE AVERIA NUEVAMENTE ES NECESARIO CAMBIAR PIEZAS DE ALTO VALOR', 35500.0, 35500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'RODAMIENTO 607', NULL, 12000.0),
  (@cotizacion_id, 2, NULL, 1, 'ANILLO RODAMIENTO', NULL, 8000.0),
  (@cotizacion_id, 3, NULL, 1, 'SERVICIO MANO DE OBRA MINIMA', NULL, 15500.0);

-- ===== OT 0688 (hoja original: 688-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('SANDRA CASTAÑEDA', 'FERRE AUTOGENA', NULL, NULL, '3123041103', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ESMERILADORA ANGULAR', 'DEWALT', NULL, 'ILEGIBLE');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0688', @articulo_id, 'INGRESO', NULL, '2025-12-11 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'INTERRUPTOR NO GENERA PASO DE CORRIENTE, ESCOBILLAS A UN 15% DE VIDA UTIL, RODAMIENTOS FATIGADOS', 165000.0, 165000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'PORTA ECOBILLAS', NULL, 18000.0),
  (@cotizacion_id, 2, NULL, 1, 'ESCOBILAS', NULL, 30000.0),
  (@cotizacion_id, 3, NULL, 1, 'INTERRUPTOR', NULL, 38000.0),
  (@cotizacion_id, 4, NULL, 1, 'REPARACION BOBINA', NULL, 40000.0),
  (@cotizacion_id, NULL, NULL, 1, 'RODAMIENTO 607', NULL, 12000.0),
  (@cotizacion_id, 5, NULL, 1, 'RODAMIENTO 608', NULL, 12000.0),
  (@cotizacion_id, 6, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 15000.0);

-- ===== OT 0687 (hoja original: 687-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES (NULL, 'TECNIMOTOR JP', '900429531-7', NULL, '3124538636 - 3102044256', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'DEWALT', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0687', @articulo_id, 'INGRESO', 'INGRESA DESARMADA', '2025-12-11 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0686 (hoja original: 686-ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES (NULL, 'TECNIMOTOR JP', '900429531-7', NULL, '3124538636 - 3102044256', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'BOSCH', 'GWS7-115', '46900279');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0686', @articulo_id, 'ENTREGADA', NULL, '2025-12-11 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA ENCIENDE DAÑO EN PALANCA Y EN HUELLE ENCENDIDO DE MAQUINA, ESTE MODELO DE MAQUINA ES MUY ANTIGUO POR LO CUAL NOS TOCA CON REFACCIONES REFURBY .', 70500.0, 70500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'PALANCA', 25000.0, 25000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'BOTON HUELLERO', 10000.0, 10000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'RODAMIENTO 607 X1', 12000.0, 12000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'MANTENIMIENTO GENERAL', 23500.0, 23500.0);

-- ===== OT 0685 (hoja original: 685-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES (NULL, 'JL GESTIONES Y CONSTRUCCIONES  SAS', '901355146-9', 'JLCONTRATISTA@HOTMAIL.COM', '3112290246', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'DEMOLEDOR', 'TOTAL', 'UTH220502', '24379010027');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0685', @articulo_id, 'INGRESO', NULL, '2025-12-11 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0684 (hoja original: 684-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES (NULL, 'JL GESTIONES Y CONSTRUCCIONES  SAS', '901355146-9', 'JLCONTRATISTA@HOTMAIL.COM', '3112290246', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'DEMOLEDOR', 'TOTAL', 'UTH220502', '25236140043');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0684', @articulo_id, 'INGRESO', NULL, '2025-12-11 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 25000.0, 25000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'UTH220502-SP-6', 1.0, 'ESCOBILLAS', 25000.0, 25000.0);

-- ===== OT 0683 (hoja original: 683-COT ENVIADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ARMANDO RODRIGUEZ SUAREZ', NULL, '80360381', NULL, '3104810961', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA INALAMNRICA', 'MILWAUKEE', 'M18 FUEL', 'F33CO1721OCC007');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0683', @articulo_id, 'COT ENVIADA', NULL, '2025-12-11 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA NO ENCIENDE DEBIDO A FALLA EN MODULO ELECTRONICO QUE SE ENCARGA DE REGULAR LA POLARIDAD DE LA CORRIENTE, ESTE MODULO TIENE UN ALTO VALOR EN EL MERCADO YA QUE VIENE CON ESTATOR ( BOBINA) EN UNA MISMA PIEZA.', 703500.0, 703500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'MODULO ELECTRONICO+ESTATOR', 680000.0, 680000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'MANO DE OBRA Y MANTENIMIENTO', 23500.0, 23500.0);

-- ===== OT 0682 (hoja original: 682-COT ENVIADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ARMANDO RODRIGUEZ SUAREZ', NULL, '80360381', NULL, '3104810961', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO INALAMBRICO', 'DEWALT', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0682', @articulo_id, 'COT ENVIADA', 'INGRESA BATERIA DEWALT 68VF 6AH LI-ION / 2 PUNTAS ESTRELLA', '2025-12-11 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA NO ENCIENDE, SE REALIZAN PRUEBAS ELECTRICAS Y EL INTERRUPTOR PRESENTA INTERMITENCIA EN PASO DE CORRIENTE. BATERIA NO PRESENTA CARGA , SE RECOMIENDA TRAER CARGADOR PARA REVISAR.', 223500.0, 223500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'INTERRUPTOR', 40000.0, 40000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'BATERIA', 160000.0, 160000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'MANO DE OBRA Y MANTENIMIENTO', 23500.0, 23500.0);

-- ===== OT 0681 (hoja original: 681-ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('MIGUEL TORRES', NULL, '79110137', NULL, '3002001735', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'BOSCH', 'GBH2-26DRE', '4060000');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0681', @articulo_id, 'ENTREGADA', 'SIN ACCSESORIOS', '2025-12-11 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'FRACTURA DE RODAMIENTO, GENERA DERRETIMIENTO DE CARCASA, ESCOBILLASS Y PORTA ESCOBILLAS CON DESGASTE EXCESIVO', 396200.0, 396200.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'EXPT-0044', 1.0, 'ORING PESO MUERTO', 15000.0, 15000.0),
  (@cotizacion_id, 2, 'EXPT-0043', 1.0, 'CAJA CAMPO', 279000.0, 279000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'ESCOBILLAS', 33200.0, 33200.0),
  (@cotizacion_id, 4, NULL, 1.0, 'RODAMIENTOS', 12000.0, 12000.0),
  (@cotizacion_id, 5, NULL, 1.0, 'PORTA ESCOBILLAS', 28500.0, 28500.0),
  (@cotizacion_id, 6, NULL, 1.0, 'SERVICIO MANO OBRA', 28500.0, 28500.0);

-- ===== OT 0680 (hoja original: 680-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JUAN CARLOS VALENCIA', 'JV REMODELACIONES', '901572538-2', NULL, '3134947743', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'DEMOLEDOR', 'MAKITA (GENERICO)', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0680', @articulo_id, 'INGRESO', 'MANGO AUXILIAR', '2025-12-10 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'EQUIPO PARA MANTENMIENTO, PASADOR USA AMARRE', 160000.0, 160000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'MANTENIMIENTO GENERAL', 50000.0, 50000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'PASADOR COMPLETO', 110000.0, 110000.0);

-- ===== OT 0679 (hoja original: 679-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES (NULL, 'CONSTRUM CACERES S.A.S', '900.768.163-3', NULL, '3212744628 - 3046156395', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'DEMOLEDOR', 'TOTAL', 'UTH220502', '24379010041');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0679', @articulo_id, 'INGRESO', NULL, '2025-12-11 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'REVISAR GARANTÍA', 0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();

-- ===== OT 0678 (hoja original: 678-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('AUTOSAFE', NULL, NULL, NULL, NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO DE ARBOL', 'BLACK & DECKER', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0678', @articulo_id, 'INGRESO', 'MANDRIL', CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'VALOR BASE FABRICACION ARTESANAL $180.000', 132000.0, 132000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'CORREA', NULL, 12000.0),
  (@cotizacion_id, 2, NULL, 1, 'CAPACITOR', NULL, 35000.0),
  (@cotizacion_id, 3, NULL, 1, 'CABLE DE PODER DEWALT', NULL, 45000.0),
  (@cotizacion_id, 4, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO', NULL, 40000.0),
  (@cotizacion_id, 5, NULL, 1, 'BASE ORIGINAL AGOTADA', NULL, 0);

-- ===== OT 0677 (hoja original: 677-LISTA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('CARLOS EDUARDO FLORES AVILA', NULL, '19207110', 'carlosfloresayala@yahoo.com', '3106012631', 'calle100 #47a-42 ap.103');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'EINHELL', 'TC-RH 900/1', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0677', @articulo_id, 'LISTA', 'EMPUÑADURA AUXILIAR - CINCEL PALA 1" Y CINCEL PALA 2"', CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'INTERRUPTOR FALLA POR INGRESO DE PARTICULAS,  OCASIONANDO FALLA EN UNA LINEA.', 70000.0, 70000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'INTERRUPTOR', NULL, 55000.0),
  (@cotizacion_id, 2, NULL, 1, 'SERVICIO MINIMO ELECTRICO', NULL, 15000.0);

-- ===== OT 0676 (hoja original: 676-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ARNULFO CASTELLANOS', 'INGELDAC S A S', '900312212-9', 'acastellanos@ingeldac.com / info@ingeldac.com', '3115847860', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'TRUPER', NULL, 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0676', @articulo_id, 'INGRESO', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 55500.0, 55500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '101708', 1.0, 'INTERRUPTOR', 40000.0, 40000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'MANO DE OBRA Y LIMPIEZA', 15500.0, 15500.0);

-- ===== OT 0675 (hoja original: 675 - ingreso) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('DUVER HINCAPIE', NULL, '79856710', 'DUVERHINCAPIE74@HOTMAIL.COM', '3104366280', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERCUTOR', 'TOTAL', 'UTIDLI20031', '211931781024');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0675', @articulo_id, 'ingreso', NULL, '2025-12-06 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'EQUIPO ROTO EJE CAJA ENGRANAJE', 153500.0, 153500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, '(sin descripcion)', 130000.0, 130000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'MANO DE OBRA', 23500.0, 23500.0);

-- ===== OT 0674 (hoja original: 674-ENV COT-AUTORIZADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JULIAN ARIAS', NULL, NULL, NULL, NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERCUTOR', 'MAKITA', 'HP1630', '1199503');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0674', @articulo_id, 'ENV COT-AUTORIZADA', NULL, '2025-12-04 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA FUNCIONAL SIUN PERCUTOR DESGASTE EN PIEZAS DEL PERCUTOR, MANDRIL ATASCADO. MANTENIMEINTO Y LIIMPIEZA GENERAL', 142986.0, 142986.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'BLOQUE INTERMEDIO', 73423.0, 73423.0),
  (@cotizacion_id, 2, NULL, 1.0, 'PIÑON CORNA', 46063.0, 46063.0),
  (@cotizacion_id, 3, NULL, 1.0, 'MANTENIMIENTO Y MANO DE OBRA', 23500.0, 23500.0),
  (@cotizacion_id, 4, NULL, 1.0, 'MANDRIL  TOTAL (OPCIONAL)', NULL, 0);

-- ===== OT 0673 (hoja original: 673-LISTA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('GABRIEL', 'INGECONS INGENIEROS CONSTRUCTORES Y CONSULTORES S.A.S', '830512329-6', NULL, '3123868912', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TRONZADORA', 'TOTAL', 'UTS92035526', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0673', @articulo_id, 'LISTA', NULL, '2025-12-05 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'INTERRUPTOR RECALENTADO POR VARIACION DE VOLTAJE', 40500.0, 40500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'INTERRUPTOR UTS92035526-SP-80', NULL, 25000.0),
  (@cotizacion_id, 2, NULL, 1, 'SERVICIO MINIMO ELECTRICO', NULL, 15500.0);

-- ===== OT 0672 (hoja original: 672-ENTREGADA Y PGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('LUZ MARINA', NULL, NULL, NULL, '3203962450', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'HIDROLAVADORA K4', 'KARCHER', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0672', @articulo_id, 'ENTREGADA Y PGADA', NULL, '2025-12-04 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 100000.0, 100000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'REPARACIÓN ELECTRICA', 20000.0, 20000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'MANTENIMIENTO', 80000.0, 80000.0);

-- ===== OT 0671 (hoja original: 671-COT ENV) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES (NULL, 'R&G HOME', '900882963-6', 'facturas@rghome.co', '3102319255', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'REBORDEADORA', 'MAKITA', '3709', '810083');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0671', @articulo_id, 'COT ENV', NULL, '2025-12-04 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 349395.9, 349395.9, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '3709 / 2657718', 1.0, 'PERILLA AJUSTE', 9401.0, 9401.0),
  (@cotizacion_id, 2, '3709/3901', 1.0, 'RUEDA PIÑON', 4641.0, 4641.0),
  (@cotizacion_id, 3, '3709/MB0370', 4.0, 'TORNILLO', 1190.0, 4760.0),
  (@cotizacion_id, 4, '3709/41911384', 1.0, 'BASE', 66045.0, 66045.0),
  (@cotizacion_id, 5, '3709/3700B', 1.0, 'PERILLA TRASERA', 3332.0, 3332.0),
  (@cotizacion_id, 6, '3606/ 9411519', 1.0, 'ARANDELA PLANA', 1190.0, 1190.0),
  (@cotizacion_id, 7, '5007NK/9411014', 1.0, 'ARANDELA PLANA', 1190.0, 1190.0),
  (@cotizacion_id, 8, '3709/2526525', 1.0, 'TUERCA', 2975.0, 2975.0),
  (@cotizacion_id, 9, 'M3700/4589743', 1.0, 'PLACA DE LA BASE', 15446.2, 15446.2),
  (@cotizacion_id, 10, '5102740', 1.0, 'INDUCIDO', 187103.7, 187103.7);

-- ===== OT 0670 (hoja original: 670-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('GABRIEL', 'INGECONS INGENIEROS CONSTRUCTORES Y CONSULTORES S.A.S', '830512329-6', NULL, '3123868912', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO 1500W', 'TOTAL', 'UTH1153226', '24495140274');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0670', @articulo_id, 'INGRESO', NULL, '2025-12-03 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0659 (hoja original: 659-lista) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('GABRIEL', 'INGECONS INGENIEROS CONSTRUCTORES Y CONSULTORES S.A.S', '830512329-6', NULL, '3123868912', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO 1500W', 'TOTAL', 'UTH1153226', '24495140075');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0659', @articulo_id, 'lista', NULL, '2025-12-03 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'DAÑO EN BALINES Y PORTA BROCAS GENERAN DAÑOS EN LOS ACCESORIOS, SE REALIZA EL CAMBIO DE ESTAS PIEZAS', 73000.0, 73000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'UTH1153226-SP-3', 1.0, 'CAPUCHON', 10000.0, 10000.0),
  (@cotizacion_id, 2, 'UTH1153226-SP-1', 1.0, 'BUMPER', 5000.0, 5000.0),
  (@cotizacion_id, 3, 'UTH110286-SP-11', 1.0, 'PORTA BROCAS', 37000.0, 37000.0),
  (@cotizacion_id, 4, 'UTH1153226-SP-17', 1.0, 'GOLPEADOR', 15000.0, 15000.0),
  (@cotizacion_id, 5, NULL, 1.0, 'BALINES X2', 6000.0, 6000.0),
  (@cotizacion_id, 6, NULL, 1.0, 'MANO DE OBRA Y MANTENIMIENTO', 28500.0, 28500.0);

-- ===== OT 0658 (hoja original: 658-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('XELINO LAYTON', NULL, NULL, NULL, '3203780915', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ESMERILADORA ANGULAR', 'DEWALT', 'DWE4020-D3', '67938');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0658', @articulo_id, 'INGRESO', NULL, '2025-12-03 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 60500.0, 60500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'RODAMIENTON  607', 12000.0, 12000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'CABLE DE PODER', 25000.0, 25000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'MANO DE OBRA Y MANTENIMIENTO', 23500.0, 23500.0);

-- ===== OT 0657 (hoja original: 657-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('XELINO LAYTON', NULL, NULL, NULL, '3203780915', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PISTOLA DE CALOR', 'MAKITA', 'HG6020', '7039');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0657', @articulo_id, 'INGRESO', NULL, '2025-12-03 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'LA PIEZA QUE TIENE DAÑADA YA NO SE CONSIGUE POR LO CUAL EL EQUIPO YA NO TIENE REPARACIÓN.', 23500.0, 23500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'BLOQUE ELECTRONICO (DESCONTINUADO)', 0.0, 0),
  (@cotizacion_id, 2, NULL, 1.0, 'MANO DE OBRA', 23500.0, 23500.0);

-- ===== OT 0656 (hoja original: 656-LISTA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('CARLOS LOPEZ', 'COMERCIALIZADORA ECUACOL SAS', '79806234', NULL, '3105595511', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ESMERILADORA ANGULAR', 'TRUPER', 'ESMA-4-1/2A12', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0656', @articulo_id, 'LISTA', NULL, '2025-12-04 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'VENTILADOR FRACTURADO, SE REALIZA EL CAMBIO POR UNA PIEZA ORIGINAL.', 35500.0, 35500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'VENTILADOR', NULL, 20000.0),
  (@cotizacion_id, 2, NULL, 1, 'SERVICIO MINIMO DE MANO DE OBRA', NULL, 15500.0);

-- ===== OT 0655 (hoja original: 655-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('LUIS GARCIA', NULL, NULL, NULL, '3125842963', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERCUTOR/ATORNILLADOR ELECTRICO', 'DEWALT', 'DCD7781', '87868');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0655', @articulo_id, 'ENTREGADA Y PAGADA', 'INGRESA CON BATERIA DCB203-B3 Y CARGADOR DCB107', '2025-12-03 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA NO ENCIENDE, SE REALIZA EL DIAGNOSTICO A SUS COMPONENTES ELECTRONICOS Y SE EVIDENCIA PERDIDA DE CONTINUIDAD A LA ALTURA DEL MODULO', 344500.0, 344500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'INTERRUPTOR (INCLUYE MODULO)', NULL, 321000.0),
  (@cotizacion_id, 2, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 23500.0);

-- ===== OT 0654 (hoja original: 654- LISTA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('OSCAR CACERES', NULL, NULL, NULL, '3223076065', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERCUTOR', 'DEWALT', 'DW508-B3', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0654', @articulo_id, 'LISTA', 'INGRESA CON LLAVE DE MANDRIL', '2025-12-02 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'FALLA EN EL REVERSIBLE DEL INTERRUPTOR, PAA ES MODELO YA FUE DESCONTINUADO NO SE CONSIGUE', 57500.0, 57500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'INTERRUPTOR', NULL, 0),
  (@cotizacion_id, 2, NULL, 2.0, 'RODAMIENTO 608', 12000.0, 24000.0),
  (@cotizacion_id, 3, '148809-00', 1.0, 'PASA CABLE', 8000.0, 10000.0),
  (@cotizacion_id, 4, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 23500.0);

-- ===== OT 0653 (hoja original: 653-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('OSCAR OVALLE', NULL, '80049225', 'oscar.j.ovalle@hotmail.com', '3044296256', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'atornillador', 'bosh', 'JH21E0', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0653', @articulo_id, 'INGRESO', NULL, '2025-12-03 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA NO ENCIENDE SE DIAGNOSTICA Y SE EVIDENCIA CELDA DE ALMACENAMIENTO DE CARGA ABIERTA ADICIONAL EVIDENCIAMOS UNA RUPTURA DEL INTERRUPTOR.', 68500.0, 68500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '18650', 1.0, 'CELDA DE LITIO', 45000.0, 45000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'MANO DE OBRA', 23500.0, 23500.0);

-- ===== OT 0652 (hoja original: 652-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JAVIER CHAMORRO', 'ESTRUCTURA Y CONSTRUCCCIONES CIVILES SAS', NULL, NULL, '3134605059 - 3114500763', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'DISCOVER', 'ERH106', '498014501');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0652', @articulo_id, 'INGRESO', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA NO ENCIENDE FALLO ELECTRICO EN EL CABLE DE PODER, SE EVIDENIA INDUCIDO RECALENTADO Y EN CORTO.', 123500.0, 123500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'UTH308268-2-SP-77', 1.0, 'INDUCIDO', 80000.0, 80000.0),
  (@cotizacion_id, 2, 'UTH308268-2-SP-89', 1.0, 'ESCOBILLAS', 10000.0, 10000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'CABLE DE PODER TH', 25000.0, 25000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'MANO DE OBRA Y MANTENIMIENTO', 8500.0, 8500.0);

-- ===== OT 0651 (hoja original: 651-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('GERMAN BARBOSA', NULL, '80429070', 'g_barbosacctv@hotmail.com', '3046798941', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'MAKITA', 'HR2470', '2694993Y');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0651', @articulo_id, 'INGRESO', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 26500.0, 26500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '2010P28-2', 1.0, 'RODAMIENTO', 10000.0, 10000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'BOTÓN', 16500.0, 16500.0);

-- ===== OT 0650 (hoja original: 650-COT ENVI-SALIDA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('PAOLA JOYA', 'CONJUNTO RESIDENCIAL ATABANZA UNIDAD I - PROPIEDAD HORIZONTAL', '800171624-0', NULL, '3203048708', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERCUTOR', 'BOSCH', 'GSB180-LI', '124002136');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0650', @articulo_id, 'COT ENVI-SALIDA', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA INGRESA PARA MANTENIMIENTO GENERAL, SE EVIDENCIA SONIDO EXTRAÑO DE VIBRACIÓN EN EL INTERIOR DEL EQUIPO, PARA ARREGLAR LA FALLA SE REQUIERE EL CAMBIO DE LA TRASMICIÓN COMPLETA, ESTA TIENE UN ALTO COSTO EN EL MERCADDO, POR LO CUAL SE RECOMIENDA USAR EL EQUIPO HASTA FINALIZAR LA VIDA UTIL DE LA TREASMICIÓN, SOLO SE GENERARA MANTENIMIENTO PREVENTIVO.', 23500.0, 23500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 2, NULL, 1.0, 'MANTENIMIENTO GENERAL Y LINMPIEZA', 23500.0, 23500.0);

-- ===== OT 0649 (hoja original: 649-pte precios) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('CARLOS BARRAGAN', NULL, NULL, NULL, '3102253866', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 5"', 'MAKITA', 'GA5020', '86899A');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0649', @articulo_id, 'pte precios', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'SE EVIDENCIA QUE EL INTERRUPTOR TIENE EL PASO DE CORRIENTE INTERRUMPIDO, ESCOBILLAS CON DESGASTE Y RODAMEINTO CON FATIGA. SE REALIZA MANTENIMIENTO Y LIMPIEZA GENERAL.', 118000.0, 118000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '194996-6', 1.0, 'ESCOBILLAS', 19000.0, 19000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'INTERRUPTOR', 65500.0, 65500.0),
  (@cotizacion_id, 3, NULL, 1.0, 'RODAMIENTO 608', 10000.0, 10000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'SERVICIO MANO DE OBRA', 23500.0, 23500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'pte precios', 'SOLO COTIZAR PRECIO');

-- ===== OT 0648 (hoja original: 648) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ESTRUCTUAS Y ACABADOS NIÑO', NULL, NULL, NULL, NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO DE ARBOL', NULL, NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0648', @articulo_id, 'INGRESO', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'queda pendiente fabricar una manija', 280000.0, 280000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'EJE MANDRIL Y PIN BLOQUEO', NULL, 150000.0),
  (@cotizacion_id, 2, NULL, 1, 'CORREAS', NULL, 15000.0),
  (@cotizacion_id, 3, NULL, 1, 'PERNOS Y TORNILLOS', NULL, 15000.0),
  (@cotizacion_id, 4, NULL, 1, 'SERVICIO DE LIMPIEZA Y MaNO DE OBRA', NULL, 100000.0);

-- ===== OT 0647 (hoja original: 647-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('GABRIEL', 'INGECONS INGENIEROS CONSTRUCTORES Y CONSULTORES S.A.S', '830512329-6', NULL, '3123868912', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO 1500W', 'TOTAL', 'UTH1153226', '25062481004');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0647', @articulo_id, 'ENTREGADA Y PAGADA', 'EL CLIENTE INFORMO QUE NO SUELTA LA BROCA', '2025-11-26 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA PRESENTA TASCAMINETO, SE REALIZA EL DESEMNSAMBLE DEL EQUIPO, SE EVIDENCIA RODAMIENTO ATASCADO OCASIONANDO PERDIDA DEL CENTRE DEL INDUCIDOELEVANDO LA TEMPERATURA Y GENERANDO Falla ( inducido en corto).  SE REALIZA MANTENIMIENTO, LUBRICACIÓN Y LIMPIEZA GENERAL. TENER EN CUENTA QUE EN EL ANTERIOR INGRESO SOLMANETE SE LE REALIZO EL CAMBIO DEL PORTABROCAS', 111500.0, 111500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'INDUCIDO', 70000.0, 70000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'ESCOBILLAS', 15500.0, 15500.0),
  (@cotizacion_id, 3, NULL, 1.0, 'RODAMIENTO 608', 10000.0, 10000.0),
  (@cotizacion_id, 4, NULL, 2.0, 'ANILLOS', 8000.0, 16000.0),
  (@cotizacion_id, 5, NULL, 1, 'SERVICIO MANO DE OBRA', 23500.0, 0);

-- ===== OT 0645-A (hoja original: 646-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JAVIER CHAMORRO', 'ESTRUCTURA Y CONSTRUCCCIONES CIVILES SAS', NULL, NULL, '3134605059 - 3114500763', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'TOTAL', 'UTH308368', 'SIN SERIAL');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0645-A', @articulo_id, 'INGRESO', 'MANGO AUXILIAR', '2025-11-26 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'GIRA AL REVES REVISAR, AL PARECER EL EQUIPO FUE DESENSAMBLADO SE EVIDENCIA TAPA MAL PUESTA', 0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();

-- ===== OT 0645-B (hoja original: 645-PAGADA Y ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JAVIER CHAMORRO', 'ESTRUCTURA Y CONSTRUCCCIONES CIVILES SAS', NULL, NULL, '3134605059 - 3114500763', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'TOTAL', 'UTH308368', 'SIN SERIAL');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0645-B', @articulo_id, 'PAGADA Y ENTREGADA', 'MANGO AUXILIAR / GIRA AL REVES REVISAR, AL PARECER EL EQUIPO FUE DESENSAMBLADO SE EVIDENCIA TAPA MAL PUESTA', '2025-11-26 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'SE EVIDENCIA QUE EL EQUIPO SOLO ENCIENDE PARA EL SENTIDO IZQUIERDO POR FALSO CONTACTO EN EL PORTAESCOBILLAS Y LAMINA PARA EL SENTIDO DERECHO, SE EVIDENCIA QUE LAS ESCOBILLAS TIENEN UN DESGASTE DE TAMÑANO. SE REALIZA  MANTENIMIENTO Y LIMPIEZA GENERA. SE RECOMIENDA REALIZAR LA LIMPIEZA DEL EQUIPO LUEGO DE CADA JORNADA DE  TRABAJO.', 50000.0, 50000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'UTH308268-2-SP-87', 1.0, 'PORTAESCOBILLAS', 20000.0, 20000.0),
  (@cotizacion_id, 2, 'UTH308268-2', 1.0, 'ESCOBILLAS', 10000.0, 10000.0),
  (@cotizacion_id, 3, 'EXPT-0074', 1.0, 'LAMINA PORTAESCOBILLAS', 20000.0, 20000.0),
  (@cotizacion_id, 4, 'SERVMO', 1.0, 'SERVICIO MANO OBRA', 0.0, 0);

-- ===== OT 0644 (hoja original: 644- entragada y pagada) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('FELIPE CONTRERAS', NULL, '1096197530', NULL, '3043844032', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ASPIRADORA', 'KARCHER', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0644', @articulo_id, 'entragada y pagada', NULL, '2025-11-26 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'FALLA ELECTRICA EN UNA LIENA DEL CABLE DE PODER,  SE REALIZAN AJUSTES PARA CORREGIR LA NOVEDAD', 30000.0, 30000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'SERVICIO DE MANTENIMIENTO', NULL, 30000.0);

-- ===== OT 0643 (hoja original: 643- PDT) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('WILSON FAGUA', NULL, '1019090565', NULL, '3184741110', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO', 'DEWALT', 'D25123', 'ILEGIBLE');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0643', @articulo_id, 'PDT', NULL, '2025-11-26 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'BOBINA RECALENTADA EN CORTO, RODAMIENTOS COIN FATIGA ESCOBILLAS BUMPER Y ANILLO POR MANTENIMIENTO GENERAL.', 181000.0, 181000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'ESCOBILLAS', 46000.0, 46000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'BOBINA (descontinuada)', 85000.0, 85000.0),
  (@cotizacion_id, 3, '211491-2', 1.0, 'RODAMIENTO 609', 12000.0, 12000.0),
  (@cotizacion_id, 4, '210034-7', 1.0, 'RODAMIENTO 607', 12000.0, 12000.0),
  (@cotizacion_id, 5, NULL, 1.0, 'BUMPER', 20000.0, 20000.0),
  (@cotizacion_id, 6, NULL, 1.0, 'ANILLO', 6000.0, 6000.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'PDT', '//ULTIMO RECORDATORIO 17/07/2026');

-- ===== OT 0642 (hoja original: 642- NO JUSTIFICA-ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('SILVIA', 'PINTOR ELÉCTROSTATICO', '900346300-5', 'facturacionpintorelectro@gmail.com', '3222115144', 'CR 47 132 21');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4-1/2"', 'GENERICA', 'NO REGISTRA', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0642', @articulo_id, 'NO JUSTIFICA-ENTREGADA', 'INGRESA SIN BRIDA Y TUERCA Y DESEMSABLADA EN LA TAPA PORTAESCOBILLAS', '2025-11-26 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'NO JUSTIFICA REPARACION., MAQUINA EN CORTO DAÑO EN MOTOR.', 0.0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();

-- ===== OT 0641 (hoja original: 641- COT- ENVIDA ENTREGADA ) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('SILVIA', 'PINTOR ELÉCTROSTATICO', '900346300-5', 'facturacionpintorelectro@gmail.com', '3222115144', 'CR 47 132 21');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 9"', 'DEWALT GENERICO', 'D28414', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0641', @articulo_id, 'COT- ENVIDA ENTREGADA', 'INGRESA SIN BRIDA Y TUERCA', '2025-11-26 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA NO ENCIENDE LLEGA SIN ESCOBILLAS.', 18000.0, 18000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'UTG12018026-SP-38', 1.0, 'ESCOBILLA', 18000.0, 18000.0);

-- ===== OT 0640 (hoja original: 640- COT-ENVI) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('SILVIA', 'PINTOR ELÉCTROSTATICO', '900346300-5', 'facturacionpintorelectro@gmail.com', '3222115144', 'CR 47 132 21');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 9"', 'MAKITA', 'M0920', 'ILEGIBLE');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0640', @articulo_id, 'COT-ENVI', 'INGRESA SIN BRIDA Y TUERCA', '2025-11-26 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA NO ENCIENDE, DAÑO DE ESCOBILLAS GENERA PERDIDA DE CONTACNTO ESCOBILLA-COLECTOR .', 333700.0, 333700.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'CAJA CAMPO (NUEVA)', 145700.0, 145700.0),
  (@cotizacion_id, 2, 'CB-204', 1.0, 'ESCOBILLAS', 26000.0, 26000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'CAJA CAMPO DE SEGUNDA', 90000.0, 90000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'INTERRUPTOR', 48500.0, 48500.0),
  (@cotizacion_id, 5, NULL, 1.0, 'MANO DE OBRA Y MANTENIMIENTO', 23500.0, 23500.0);

-- ===== OT 0639 (hoja original: 639- INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('CAUCHOS ACME', NULL, NULL, NULL, '3118402487', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERCUTOR', 'SKIL', '6438', 'F012643830');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0639', @articulo_id, 'INGRESO', NULL, '2025-11-25 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 65500.0, 65500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'reversible', NULL, 36000.0),
  (@cotizacion_id, 2, NULL, 1, 'palanca', NULL, 6000.0),
  (@cotizacion_id, 3, NULL, 1, 'servicio de mantenimiento y mano de obra', NULL, 23500.0);

-- ===== OT 0638 (hoja original: 638- ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ALEXANDER FRANCO', NULL, NULL, NULL, '3114449290', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4-1/2"', 'SKILL', '9004', 'F0129004110');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0638', @articulo_id, 'ENTREGADA', 'INGRESA CON BRIDA Y TUERCA', '2025-11-25 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'CAMPO DESCONTINUADO PARA ESTE MODELO, SE PUEDE BOBINAR COSTO (75.0000) - LA REPARACIÓN SUPERA EL 50% DEL VALOR DE UN EQUIPO NUEVO', 182500.0, 182500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'INDUCIDO', NULL, 66000.0),
  (@cotizacion_id, 2, NULL, 1, 'CAMPO', NULL, 75000.0),
  (@cotizacion_id, 3, NULL, 1, 'ESCOBILLAS', NULL, 18000.0),
  (@cotizacion_id, 4, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 23500.0);

-- ===== OT 0637 (hoja original: 637-NO AUTORIZADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ALEXANDER FRANCO', NULL, NULL, NULL, '3114449290', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ATORNILLADOR', 'DEWALT', 'DC970', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0637', @articulo_id, 'NO AUTORIZADA', 'INGRESA CON BATERÍA DC9096', '2025-11-25 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'SE EVIDENCIA EQUIPO FUNCIONAL, MOTOR RECALENTADO, EL MOTOR ES SELLADO Y NO PERMITE EL CAMBIO DE LAS ESCOBILLAS.', 193500.0, 193500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'MOTOR', 170000.0, 170000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0636 (hoja original: 636 - LISTA-cot.env) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ALEXANDER FRANCO', NULL, NULL, NULL, '3114449290', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO', 'MILWAUKEE', 'NO REGISTRA', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0636', @articulo_id, 'LISTA-cot.env', NULL, '2025-11-25 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'CAMBIO DE MANDRIL', 35000.0, 35000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'TAC451301.1', 1.0, 'MANDRIL TOTAL', 30000.0, 30000.0),
  (@cotizacion_id, 2, 'SERVMO', 1.0, 'SERVICIO MANO OBRA', 5000.0, 5000.0);

-- ===== OT 0635 (hoja original: 635 - ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ARNULFO CASTELLANOS', 'INGELDAC S A S', '900312212-9', 'acastellanos@ingeldac.com / info@ingeldac.com', '3115847860', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'TRUPER', 'ROEL 60N', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0635', @articulo_id, 'ENTREGADA Y PAGADA', 'caja de accesorios, esruche plarico, guaya', '2025-11-25 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 40500.0, 40500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'UTH1153226-93', 1.0, 'ESCOBILLAS', 25000.0, 25000.0),
  (@cotizacion_id, 2, 'SERVMO', 1.0, 'SERVICIO MANO DE OBRA (AJUSTE ELECTRICO)', 15500.0, 15500.0);

-- ===== OT 0634-A (hoja original: 634 - ingreso) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('NELSON MURILLO', 'TEM COLOMBIA', '830050372-1', 'nmurillo@tem.colombia.com', '3204192917', 'cr 47 # 134 a - 67');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'motortool', 'total', 'utg501032', '2024570000');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0634-A', @articulo_id, 'ingreso', 'caja de accesorios, esruche plarico, guaya', '2025-11-25 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0634-B (hoja original: 634 -INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('SIN NOMBRE', NULL, NULL, NULL, NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'MOTORTUL', 'TOTAL', 'UTH1153226', '25063481004');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0634-B', @articulo_id, 'INGRESO', 'EL CLIENTE INFORMA QUE NO SUELTA LA BROCA', '2025-11-26 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0633 (hoja original: 633 -ENTREGADA Y PTE PAGO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('TECNIMOTOR JP', NULL, NULL, NULL, NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 7"', 'EMTOP', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0633', @articulo_id, 'ENTREGADA Y PTE PAGO', 'GUARDA, DISCO, EMPUÑADURA !', '2025-11-24 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA NO ENCIENDE, CONTAMINACION EXCESIVA POR CONCRETO.', 47500.0, 47500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'UTG12018026-SP-40', 1.0, 'PAR PORTA ESCOBILLAS', 6000.0, 6000.0),
  (@cotizacion_id, 2, 'UTG12018026-SP-38', 1.0, 'PAR ESCOBILLAS', 18000.0, 18000.0),
  (@cotizacion_id, 3, 'SERVMO', 1.0, 'SERVICIO MANO DE OBRA', 23500.0, 23500.0);

-- ===== OT 0632 (hoja original: 632 - SE ENTREGA SIN REPARAR) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('MIGUEL MORALES', NULL, '79540540', 'miguelmoralescruz28@gmail.com', '3057278423', 'cr 59 # 152 b - 74');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'cargador dewalt', 'DEWALT', 'DCB107', '202110PQ');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0632', @articulo_id, 'SE ENTREGA SIN REPARAR', NULL, '2025-11-24 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'NO ENERGIZA', 0.0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();

-- ===== OT 0631 (hoja original: 631 - COT ENV) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('LUZ MARINA TORRES', NULL, '39774564', NULL, '3203962450', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERFORADOR 3/8', 'GENERICO', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0631', @articulo_id, 'COT ENV', 'BATERIA "DEWALT" 12 V 1.5 AH Y CARGADOR DE PLUG', '2025-11-24 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'SE EVIDENCIA MOTOR RECALENTADO, SE RECOMIENDA DAR USO AL EQUIPO HASTA QUE FALLE POR COMPLETO. EL VALOR DE LA REPARACIÓN ES ELEVADO A COMPARACIÓN DE  UN NUEVO EQUIPO.', 68500.0, 68500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'MOTOR', 45000.0, 45000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0630 (hoja original: 630-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ARMANDO RODRIGUEZ SUAREZ', NULL, '80360381', 'ARMANDOROD2010@HOTMAIL.COM', '3104810961', 'TRV 88 145 - 49');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'REBORDEADORA', 'MAKITA (GENERICA)', 'M3600B', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0630', @articulo_id, 'ENTREGADA Y PAGADA', 'BASE, TUERCA Y COLLECT Y FRESA', '2025-11-21 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'ESCOBILLAS Y TAPA ESCOBILLAS !', 18000.0, 18000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'UTS92035526-SP-37', 1.0, 'ESCOBILLAS', 18000.0, 18000.0);

-- ===== OT 0629 (hoja original: 629-NO SE PUEDE REPARAR-ENTREGA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ARMANDO RODRIGUEZ SUAREZ', NULL, '80360381', 'ARMANDOROD2010@HOTMAIL.COM', '3104810961', 'TRV 88 145 - 49');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'REBORDEADORA', 'DEWALT (GENERICA)', 'DWE6000', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0629', @articulo_id, 'NO SE PUEDE REPARAR-ENTREGA', 'BASE, TUERCA Y COLLECT', '2025-11-21 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'SE EVIDENCIA DESGASTE EN EL EJE DEL INDUCIDO, NO TIENE REPARACION YA QUE ES MARCA GENERICA', 0.0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();

-- ===== OT 0628 (hoja original: 628 - DEVOLUCIÓN ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ANDERSON', 'FULL SOLUCIONES SAS', '901246642-3', NULL, '320300393', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4-1/2"', 'BOSCH', 'GWS 7-115', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0628', @articulo_id, 'DEVOLUCIÓN ENTREGADA', 'INGRESA CON BRIDA Y TUERCA', '2025-11-20 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0627 (hoja original: 627 - PAGADA Y ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ANDERSON', 'FULL SOLUCIONES SAS', '901246642-3', NULL, '320300393', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4-1/2"', 'DEWALT', 'NO REGISTRA', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0627', @articulo_id, 'PAGADA Y ENTREGADA', 'INGRESA CON BRIDA Y TUERCA', '2025-11-20 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 183500.0, 183500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'INDUCIDO', 125000.0, 125000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'ESCOBILLAS', 35000.0, 35000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'MANTENIMIENTO Y MANO DE OBRA', 23500.0, 23500.0);

-- ===== OT 0626 (hoja original: 626 - PAGADA Y ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ANDERSON', 'FULL SOLUCIONES SAS', '901246642-3', NULL, '320300393', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4 - 1/2"', 'MAKITA', '9557HN', '00058841K');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0626', @articulo_id, 'PAGADA Y ENTREGADA', 'INGRESA CON BRIDA Y TUERCA', '2025-11-20 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 159500.0, 159500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '510083-7', 1.0, 'INDUCIDO', 120000.0, 120000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'ESCOBILLAS', 16000.0, 16000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'MANTENIMIENTO , MANO DE OBRA', 23500.0, 23500.0);

-- ===== OT 0625 (hoja original: 625 - PAGADA Y ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ELKIN CARDENAS', 'SEGARA CONSTRUCCIONES Y DECORACIONES S.A.S', '901733364-1', NULL, '3155526940', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PISTOLA DE CALOR', 'BOSCH', 'GHG180', '223000667 03/2022');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0625', @articulo_id, 'PAGADA Y ENTREGADA', NULL, '2025-11-20 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'DAÑO EN RESITENCIA, CIRCIUTO ABIERTO', 138500.0, 138500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'RESISTENCIA', NULL, 115000.0),
  (@cotizacion_id, 2, NULL, 1, 'SERVICIO DE MANTENIIENTO Y MANO DE OBRA', NULL, 23500.0);

-- ===== OT 0624 (hoja original: 624 - INGRESO ) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('EQUIPOS Y MEDICIONES TECNICAS SAS', 'EQUIPOS Y MEDICIONES TECNICAS SAS', '830100716-5', 'proyectos@equiposymediciones.com', '3155603502', 'CL 124 7 35 OF 601');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'MAKITA', 'DGA458', '0005064Y');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0624', @articulo_id, 'INGRESO', NULL, '2025-11-20 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 95000.0, 95000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'INTERRUPTOR', 95000.0, 95000.0);

-- ===== OT 0623 (hoja original: 623 - ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ALEJANDRO PALACIOS', NULL, '80183772', NULL, '3134925277', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'TOTAL', 'TRHLI20208', '24045112279');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0623', @articulo_id, 'ENTREGADA Y PAGADA', NULL, '2025-11-20 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA NO GENERA CAMBIO DE MODO A PERFORADOR, SE DESENSAMBLA MECANIAMENTE EL EQUIPO EVIDENCIANDO FRACTURA DE LOS TORNILLOS DEL EJE DE CAMBIOS, OCASIONANDO FRACTURA DE PIEZAS ADYACENTES , ACTUALMENTE NO SE CUENTA CON TODO EL INVENTARIO DE REFACCIONES NECESARIAS PARA SU REPARACIÓN .', 201000.0, 201000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'BASE INTERMEDIA', NULL, 115000.0),
  (@cotizacion_id, 2, NULL, 2.0, 'TORNILLO ARBOL DE LEVAS', 2000.0, 4000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'EJE', NULL, 10000.0),
  (@cotizacion_id, 4, NULL, 1, 'LAMINA CAMBIOS #1', NULL, 9000.0),
  (@cotizacion_id, 5, NULL, 1, 'LAMINA CAMBIOS #2', NULL, 12000.0),
  (@cotizacion_id, NULL, NULL, 1, 'LAMINA CAMBIOS #3', NULL, 10500.0),
  (@cotizacion_id, NULL, NULL, 1, 'RODAMIENTO 607', NULL, 12000.0),
  (@cotizacion_id, 6, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 28500.0);

-- ===== OT 0622 (hoja original: 622 - ENTREGADA Y PAGADA ) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ANGELICA CARDENAS', 'INELTEK SAS', '900552172-1', NULL, '3213797525 - 3229074703', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4-1/2"', 'MAKITA GENERICA', 'GA4030', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0622', @articulo_id, 'ENTREGADA Y PAGADA', 'INGRESA CON BRIDA Y TUERCA', '2025-11-20 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'FALLA EN EL VARIADOR DE VELOCIDAD POR PASO DE CORRIENTE INTERRUMPIDA', 15500.0, 15500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'REPARACIÓN ELÉCTRICA', 15500.0, 15500.0);

-- ===== OT 0621 (hoja original: 621 - ENTREGADA ) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('GRACIELA ROMERO', NULL, '35250297', 'graciela1225@hotmail.com', '3506955838 - 3112795139', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'taladro percutor 20 V', 'TOTAL', 'UTIDLI20031', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0621', @articulo_id, 'ENTREGADA', 'SIN ACCESOROS', '2025-11-20 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'PARECE QUE EL EQUIPO SOLO SE ENCUENTRA EN PERCUTOR', 0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADA', 'SIN REPARACIÓN'),
  (@orden_id, 'ENTREGADA', 'ENTREGADA 21/01/2026');

-- ===== OT 0620 (hoja original: 620 - ENTREGADA PTD PGO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ALBERTO BARRETO', 'FOCUS ENERGY S.A.S.', '901146880-0', 'contabilidad@focusenergy.com.co', '3102129985', 'AV 3 9 73 OF 401');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO ATORNILLADOR', 'DEWALT', 'DCD771', 'DQWBFL');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0620', @articulo_id, 'ENTREGADA PTD PGO', 'INGRESA CON 2 BATERÍAS20V 2AH, 1 CARGADOR DCB107 Y MALETA PLÁSTICA NEGRA', '2025-11-19 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 23500.0, 23500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'SERVICIO MANO DE OBRA', 23500.0, 23500.0);

-- ===== OT 0619 (hoja original: 619-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('XELINO LAYTON', NULL, NULL, NULL, '3203780915', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4- 1/2"', NULL, NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0619', @articulo_id, 'INGRESO', NULL, '2025-11-19 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0618 (hoja original: 618-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('CARLOS LOPEZ', 'COMERCIALIZADORA ECUACOL SAS', '79806234', NULL, '3105595511', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4-1/2"', 'TOTAL', 'UTG10912556', '22109');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0618', @articulo_id, 'ENTREGADA Y PAGADA', 'INGRESA CON TUERCA', '2025-11-18 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'ESCOBILLAS GENERAN MAL CONCTACTO AL COLECTOR, GENERANDO INTERETIENCIA ELECTRICA SE REALIZA RECTIFICACION DE COLECTOR Y AJUSTE DE CHISPA', 27000.0, 27000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'ESCOBILLAS', NULL, 12000.0),
  (@cotizacion_id, 2, NULL, 1, 'SERVICIO DE LIMPIEZA', NULL, 15000.0);

-- ===== OT 0610 (hoja original: 610-SALIDA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('LEONARDO CASTRO', NULL, '79950258', 'lemardeco@hotmail.com', '3152956918', 'calle 161 a # 20 - 17');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'RUTEADORA', 'STANLEY', 'SRR1200-B3', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0610', @articulo_id, 'SALIDA', 'TUERCA Y COLLECT FRACTURADO', '2025-11-15 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'EQUIPO CON EL COLLET FRACTURADO.', 40000.0, 40000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'COLLET', 40000.0, 40000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'REPARACIÓN CABLE DE PODER', 0.0, 0);

-- ===== OT 0617 (hoja original: 617-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('CARLOS LOPEZ', 'COMERCIALIZADORA ECUACOL SAS', '79806234', NULL, '3105595511', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4-1/2"', 'TRUPER', 'ESMA-45110', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0617', @articulo_id, 'INGRESO', 'INGRESA CON BRIDA Y TUERCA', '2025-11-18 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0616 (hoja original: 616-ENTREGADA Y PTE PAGO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('SILVIA', 'PINTOR ELÉCTROSTATICO', '900346300-5', 'facturacionpintorelectro@gmail.com', '3222115144', 'CR 47 132 21');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERCUTOR', 'DEWALT', 'DWE5010-B3', '027633');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0616', @articulo_id, 'ENTREGADA Y PTE PAGO', NULL, '2025-11-15 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 15500.0, 15500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'REPARACIÓN ELÉCTRICA', 15500.0, 15500.0);

-- ===== OT 0615 (hoja original: 615-ENTREGADA SIN REP) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('SILVIA', 'PINTOR ELÉCTROSTATICO', '900346300-5', 'facturacionpintorelectro@gmail.com', '3222115144', 'CR 47 132 21');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4-1/2"', 'MAKITA', 'NO REGISTRA', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0615', @articulo_id, 'ENTREGADA SIN REP', 'INGRESA CON BRIDA Y TUERCA', '2025-11-15 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0614 (hoja original: 614-ENTREGADO SIN REPARAR) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('IGNACIO AREVALO', NULL, NULL, NULL, '3144580618', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'NIVEL LASER', 'MAKITA GENERICO', 'SK313GD', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0614', @articulo_id, 'ENTREGADO SIN REPARAR', NULL, '2025-11-18 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0613 (hoja original: 613-COT.ENV) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('FREDY FRENCHER', NULL, NULL, NULL, '3006126023', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4-1/2"', 'MAKITA', 'NO REGISTRA', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0613', @articulo_id, 'COT.ENV', 'INGRESA CON 1 DISCO Y EMPUÑADURA', '2025-11-18 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA NO ENCIENDE, INTERRUPTOR EN CORTO, CABLE DE PODER CON FISURAS, ESCOBILLAS CON 20% DE VIDA UTIL, INDUCIDO Y COLECTOR CON UN 10% DE VIDA UTIL. SE REALIZA MANTENIMIENTO, LUBRICACIÓN Y LIMPIEZA GENERAL.', 157950.0, 157950.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'INTERRUPTOR', 65450.0, 65450.0),
  (@cotizacion_id, 2, NULL, 1.0, 'INDUCIDO (OPCIONAL)', 231200.0, 0),
  (@cotizacion_id, 3, NULL, 1.0, 'ESCOBILLAS', 19000.0, 19000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'RODAMIENTO 608', 10000.0, 10000.0),
  (@cotizacion_id, 5, NULL, 1.0, 'CABLE PODER', 40000.0, 40000.0),
  (@cotizacion_id, 6, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0612 (hoja original: 612-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('LEONARDO CASTRO', NULL, '79950258', 'lemardeco@hotmail.com', '315295691', 'calle 161 a # 20 - 17');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'INGLETEADORA', 'CRAFTMAN', '13712371', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0612', @articulo_id, 'ENTREGADA Y PAGADA', 'GUARDA PLASTICA', '2025-11-15 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA SE REALIZA CAMBIO DE ESCOBILLAS, SE LE REALIZA MANTENIMIENTO GENERAL  -  EL LASER NO SE PUEDE REPARAR', 54500.0, 54500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'ESCOBILLAS CB-204', NULL, 26000.0),
  (@cotizacion_id, 2, NULL, 1, 'MANTENIMIENTO GENERAL', NULL, 28500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADA Y PAGADA', 'ENTREGADA Y OAGADA 26/03/2026'),
  (@orden_id, 'ENTREGADA Y PAGADA', 'CV.1451');

-- ===== OT 0611 (hoja original: 611-LISTA-COT.ENV.) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('LEONARDO CASTRO', NULL, '79950258', 'lemardeco@hotmail.com', '315295691', 'calle 161 a # 20 - 17');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4 1/2"', 'TOTAL', 'UTG10912556', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0611', @articulo_id, 'LISTA-COT.ENV', 'SIN ACCESORIOS', '2025-11-15 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'AJUSTE ELÉCTRICO', 23500.0, 23500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0),
  (@cotizacion_id, 2, NULL, 1.0, 'CABLE DE PODER (OPCIONAL)', 25000.0, 0);

-- ===== OT 0608 (hoja original: 608 -ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JAIME ORTIZ', NULL, NULL, NULL, '3144513583', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'MAKITA', 'HR2470', '1983561Y');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0608', @articulo_id, 'ENTREGADA Y PAGADA', 'MAQUINA EN CORTO', '2025-11-14 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'EQUIPO CON BOBINA RECALENTADA, INDUCIDO EN CORTO, LAS ESCOBILLAS SE DEBEN CAMBIAR PORQUE EL INDUCIDO ES NUEVO. SE REALIZA MANTENIMIENTO, LUBRICACIÓN Y LIMPIEZA GENERAL.', 412000.0, 433500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '515286-8', 1.0, 'INDUCIDO', 194000.0, 194000.0),
  (@cotizacion_id, 2, '626576-5', 1.0, 'BOBINA', 185000.0, 185000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'BUMPER', 5000.0, 5000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'ANILLO PESO MUERTO', 5000.0, 5000.0),
  (@cotizacion_id, 5, NULL, 1.0, 'ESCOBILLAS', 16000.0, 16000.0),
  (@cotizacion_id, 6, NULL, 1.0, 'SERVICIO MANO OBRA', 28500.0, 28500.0);

-- ===== OT 0609 (hoja original: 609 - ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ANDERSON GUTIERREZ', 'FULL SOLUCIONES', NULL, NULL, '3203002393', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PISTOLA DE CALOR', 'DEWALT', 'D26411-B3', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0609', @articulo_id, 'ENTREGADA Y PAGADA', NULL, '2025-11-07 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'RESISTENCIA QUE PASO DE CORRIENTE INTERRUMPIDA, SE REALIZA MANTENIMIENTO Y LIMPIEZA GENERAL.', 136500.0, 136500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'N020654', 1.0, 'RESISTENCIA', 113000.0, 113000.0),
  (@cotizacion_id, 2, 'SERVMO', 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0607 (hoja original: 607 -ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('NICOLAS RAMIREZ', NULL, NULL, NULL, '3174320919', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'MOTOSIERRA', 'STIHL', 'MS170', '1130967330105');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0607', @articulo_id, 'ENTREGADA Y PAGADA', 'EL CLIENTE INFORMA QUE ES PARA MANTENIMIENTO, REVISAR SI SE PUEDE CAMBIAR EL CHOQUE  Y LIJADA DE CADENA', '2025-11-14 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'LA MOTOSIERRA ENTRA CON DESGASTE EN LA CAMPANA ESO SE DEBE POR USO DE TRABAJO, LA BUJÍA ESTA CARBONADA, EL CARBURADOR LOS EMPAQUES ESTÁN CRISTALIZADOS, LOS RESORTES DEL EMBRAGUE YA ESTÁN CEDIDOS EL CUAL AFECTA LA FUERZA DEL MOTOR, LA VARILLA CHOQUE VINE PARTIDA Y REQUIERE CAMBIO PARA SU ENCENDIDO. ESTO SUCEDE POR EL MANEJO Y USO CONTINUO DE LA MÁQUINA, SE RECOMIENDA HACER LIMPIEZA A LOS FILTROS CADA 2 MESES PARA EVITAR DAÑOS EN EL CARBURADOR. SE REALIZA LIMPIEZA Y MANTENIMIENTO.', 245500.0, 245500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'BUJIA', 14000.0, 14000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'CAMPANA 3/8', 60000.0, 60000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'KIT DIAFRAGMA CARBURADOR', 33500.0, 33500.0),
  (@cotizacion_id, 4, NULL, 2.0, 'TUERCAS CARBURADOR', 2000.0, 4000.0),
  (@cotizacion_id, 5, NULL, 3.0, 'RESORTE EMBRAGUE', 5000.0, 15000.0),
  (@cotizacion_id, 6, NULL, 1.0, 'VARILLA CHOQUE', 34000.0, 34000.0),
  (@cotizacion_id, 7, NULL, 1.0, 'SERVICIO MANO OBRA', 85000.0, 85000.0);

-- ===== OT 0606 (hoja original: 606 -ENTREGADA PDT PAGO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JULIAN QUINTERO', 'GREEN WALL SAS', NULL, NULL, '3142236250', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'CORTASETOS', 'MAKITA', 'UH007G', '1195K');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0606', @articulo_id, 'ENTREGADA PDT PAGO', 'INGRESA CON 1 BATERÍA BL4040 4AH', '2025-11-12 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA ENCIENDE SONIDO EXTRAÑO SE DESENSAMBLA EL EQUIPO SE EVIDENCIA FRACTURA DE MATRIMONIO DE PIÑONES ( ROTOR-PIÑON CORONA) MANTENIMIENTO GENERAL, LUBRICACIÓN CAMBIO DE PIEZAS RODAMIENTO Y BUJE', 294000.0, 294000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '210200-6', 1.0, 'RODAMIENTO 608', 10000.0, 10000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'BUJE DEL RODAMIENTO', 15000.0, 15000.0),
  (@cotizacion_id, 3, '5196953', 1.0, 'ROTOR YH007G', 113000.0, 113000.0),
  (@cotizacion_id, 4, '141C490', 1.0, 'ENGRANAJE UH007G', 101000.0, 101000.0),
  (@cotizacion_id, 5, NULL, 1.0, 'MANO DE OBRA Y MANTENIMIENTO', 30000.0, 30000.0),
  (@cotizacion_id, 6, NULL, 1.0, 'EXTRACCION DE BUJE TORNO', 25000.0, 25000.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADA PDT PAGO', 'ENTRAGADA 12/02'),
  (@orden_id, 'ENTREGADA PDT PAGO', 'FACTURA EXT # 624'),
  (@orden_id, 'ENTREGADA PDT PAGO', 'COT ENV-03/02');

-- ===== OT 0605 (hoja original: 605 - AUTORIZADO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('IVAN MISNAZA', NULL, '79652368', 'ivanmisnaza72@gmail.com', '3134457791 - 3164747416', 'cll 128 c # 49 a -13');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO', 'MAKITA', 'HR2450', '0351422Y');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0605', @articulo_id, 'AUTORIZADO', NULL, '2025-11-12 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 175500.0, 175500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '650508-0', 1.0, 'INTERRUPTOR', 160000.0, 160000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'SERVICIO MANO OBRA', 15500.0, 15500.0);

-- ===== OT 0604 (hoja original: 604 - ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ARNULFO CASTELLANOS', 'INGELDAC S A S', '900312212-9', 'acastellanos@ingeldac.com / info@ingeldac.com', '3115847860', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 9"', 'TRUPER', 'ESMA-9N3', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0604', @articulo_id, 'ENTREGADA Y PAGADA', 'INGRESA CON 1 DISCO', '2025-11-12 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'EQUIPO NO ENCIENDE, CABLE CON CORRIENTE INTERRUMPIDA, SE REALIZA MANTENIMIENTO Y LIMPIEZA GENERAL', 43500.0, 43500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '682559-5', 1.0, 'PASACABLE', 8000.0, 8000.0),
  (@cotizacion_id, 2, '211092-6', 1.0, 'RODAMIENTO 629', 12000.0, 12000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0603 (hoja original: 603 - ENTREGADA - PTE PAGO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JULIO PIRAGAUTA', NULL, NULL, NULL, NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'DEWALT', 'ILEGIBLE', 'ILEGIBLE');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0603', @articulo_id, 'ENTREGADA - PTE PAGO', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 455500.0, 455500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'NA205326', 1.0, 'INDUCIDO', 340000.0, 340000.0),
  (@cotizacion_id, 2, 'N035691', 1.0, 'SET ESCOBILLA', 37000.0, 37000.0),
  (@cotizacion_id, 3, 'N106196', 2.0, 'PORTA ESCOBILLA', 23000.0, 46000.0),
  (@cotizacion_id, 4, 'N111898', 2.0, 'TAPA ESCOBILLA', 4500.0, 9000.0),
  (@cotizacion_id, 5, 'SERVMO', 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0602 (hoja original: 602 - INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('SIN NOMBRE', NULL, NULL, NULL, NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'SIN CLASIFICAR', NULL, NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0602', @articulo_id, 'INGRESO', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0601 (hoja original: 601 - INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ERICK GARCÍA', NULL, NULL, NULL, '3124811566', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'BOSCH', 'NO REGISTRA', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0601', @articulo_id, 'INGRESO', 'INGRESO CON CARGADOR Y BATERÍA', '2025-11-11 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA CON RODAMIENTO ESTALLADO, LO CUAL CAUSO AVERIA DE CAJA, (TODO ES UN CONJUNTO CAJA Y RODAMIENTO )', 101000.0, 101000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'TAPA RODAMIENTO', NULL, 60000.0),
  (@cotizacion_id, 2, NULL, 1, 'SERVICIO MANTENIMIENTO Y MANO DE OBRA', NULL, 23500.0),
  (@cotizacion_id, 3, NULL, 1, 'SERVICIO FLETE', NULL, 17500.0);

-- ===== OT 0600 (hoja original: 600 - INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('CARLOS (BARBERIA)', NULL, NULL, NULL, NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO ATORNILLADOR', 'HILTI', 'SBT 4-A22', '2181485');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0600', @articulo_id, 'INGRESO', 'INGRESO CON CARGADOR Y BATERÍA', CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0599 (hoja original: 599 - INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ANDRES RIVERA', 'MAQUINAGRO DICAR', '20627144-7', 'dianacardenasnova@gmail.com', '3223099339', 'CR 5 #1-08');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'LLAVE DE IMPACTO', 'MILWAUKEE', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0599', @articulo_id, 'INGRESO', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 44500.0, 44500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'SERVMO', 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0),
  (@cotizacion_id, 2, 'FLT', 1.0, 'FLETE', 12200.0, 12200.0),
  (@cotizacion_id, 3, 'FLT', 1.0, 'FLETE', 8800.0, 8800.0);

-- ===== OT 0598 (hoja original: 598 - PTE COTIZAR) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('PINTOR ELECTROSTATICO', NULL, NULL, NULL, NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERCUTOR', 'BOSH', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0598', @articulo_id, 'PTE COTIZAR', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA ENCIENDE, GENERA MUCHA CHISPA, SE IDENTIFICA INDUCIDO CON DELGA LEVANTADA, MANDRIL FRACTURADO Y SIN DIENTES DE AJUSTE, MANTENIMIENTO GENERAL', 40000.0, 40000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'INDUCIDO', NULL, 0),
  (@cotizacion_id, 2, NULL, 1, 'ESCOBILLAS', NULL, 0),
  (@cotizacion_id, 3, NULL, 1, 'MANDRIL  TOTAL', NULL, 30000.0),
  (@cotizacion_id, 4, NULL, 1, 'PASA CABLE', NULL, 10000.0),
  (@cotizacion_id, 5, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 0);

-- ===== OT 0597 (hoja original: 597 - INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('DAVID MOLINA', 'CORTINAS VALERY', '1000459478', 'WALTER MOLINA645@GMAIL.COM', '3227518993', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'INGLETEADORA', 'DEWALT /GENERICA', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0597', @articulo_id, 'INGRESO', 'DISCO', '2025-11-10 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'REVISION GENERAL Y MANTENIMIENTO', 100000.0, 100000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'TORNO + VENTILADOR', 30000.0, 30000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'ESCOBILLAS MAKITA CB-155', 32000.0, 32000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'MANTENIMIENTO, MANO DE OBRA, LIMPIEZA', 38000.0, 38000.0);

-- ===== OT 0596 (hoja original: 596-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('HUGO ARELLANA', NULL, NULL, NULL, '3203338774', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'CORTACETOS DE MANO', 'HYPER HECHO', 'MJ7902', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0596', @articulo_id, 'INGRESO', 'SE QUEDA PEGADO EL INTERRUPTOR', '2025-11-10 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 15500.0, 15500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'MANO DE OBRA Y MANTENIMIENTO', 15500.0, 15500.0);

-- ===== OT 0595 (hoja original: 595-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JAIME ORTIZ', NULL, NULL, NULL, '3144513583', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'MAKITA', 'HR2470', '5672623B');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0595', @articulo_id, 'ENTREGADA Y PAGADA', 'INGRESA CON 1 BATERÍA DCB203-B3 20V Y 1 CARGADOR DCB107. FALLA EN EL CARDADOR NO CARGA LA BATERÍA', '2025-11-08 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'EQUIPO ENCIENDE CON SONIDO EXTRAÑO, RODAMIENTOS CON FATIGA, DAÑO MECANICO A LA ALTURA DEL EJE DE CAMBIO DE FUNCIONES. SE REALIZA MANTENIMIENTO, LUBRICACIÓN Y LIMPIEZA GENERAL.', 118500.0, 118500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'CAPUCHON', 5000.0, 5000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'ANILLO BASE INTERMEDIA', 9000.0, 9000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'ANILLO PISTON', 5000.0, 5000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'RODAMIENTO 606', 10000.0, 10000.0),
  (@cotizacion_id, 5, NULL, 1.0, 'RODAMIENTO 608', 10000.0, 10000.0),
  (@cotizacion_id, 6, NULL, 1.0, 'ESCOBILLAS', 16000.0, 16000.0),
  (@cotizacion_id, 7, NULL, 1.0, 'BULÓN', 13000.0, 13000.0),
  (@cotizacion_id, 8, NULL, 1.0, 'JUEGO COMPLETO PALANCA CAMBIOS', 16500.0, 16500.0),
  (@cotizacion_id, 9, NULL, 1.0, 'RESORTE', 3000.0, 3000.0),
  (@cotizacion_id, 10, NULL, 1.0, 'PIN DE SEGURIDAD', 2500.0, 2500.0);

-- ===== OT 0594 (hoja original: 594-entregado) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('FRANCISCO CAÑON', NULL, NULL, NULL, '3102278072', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERCUTOR', 'DEWALT', 'DCD7781', '047646');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0594', @articulo_id, 'entregado', 'INGRESA CON 1 BATERÍA DCB203-B3 20V Y 1 CARGADOR DCB107. FALLA EN EL CARDADOR NO CARGA LA BATERÍA', '2025-11-08 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'CARGADOR EN CORTO, EL MODULO ELÉCTRONICO NO INDUCE CARGA,', 420000.0, 420000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'CARGADOR', NULL, 180000.0),
  (@cotizacion_id, 2, NULL, 1, 'BATERIA 20 V - 2 AH', NULL, 240000.0);

-- ===== OT 0593 (hoja original: 593-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ARMANDO PEDRAZA', NULL, NULL, NULL, '3152384860', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'NIVEL LASER', 'BOSCH', 'GLL 2-50', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0593', @articulo_id, 'INGRESO', 'EL NIVEL ENCIENDE, NO AUTONIVELA Y COTIZAR LOS VIDRIOS', '2025-11-07 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0592 (hoja original: 592-COT ENV) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JL GESTIONES Y CONSTRUCCIONES SAS', 'JL GESTIONES Y CONSTRUCCIONES SAS', '901355146-9', 'JLCONTRATISTA@HOTMAIL.COM', '3112290246', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'DEMOLEDOR', 'DEWALT', 'D2590', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0592', @articulo_id, 'COT ENV', 'EL CLIENTE INFORMA QUE NO GOLPEA', '2025-11-06 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 657329.0, 657329.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '579B-32-00', 1.0, 'EJE BOSIN D25900K', 138450.0, 138450.0),
  (@cotizacion_id, 2, '49667B-00', 1.0, '(sin descripcion)', 61889.0, 61889.0),
  (@cotizacion_id, 3, '4B7287-00', 1.0, '(sin descripcion)', 34759.0, 34759.0),
  (@cotizacion_id, 4, '323711-15', 1.0, '(sin descripcion)', 2953.0, 2953.0),
  (@cotizacion_id, 5, '48729B-00', 1.0, '(sin descripcion)', 16562.0, 16562.0),
  (@cotizacion_id, 6, 'N542567', 1.0, '(sin descripcion)', 26171.0, 26171.0),
  (@cotizacion_id, 7, '48726B-00', 1.0, '(sin descripcion)', 8726.0, 8726.0),
  (@cotizacion_id, 8, '4877268-00', 1.0, '(sin descripcion)', 25482.0, 25482.0),
  (@cotizacion_id, 9, '323711-41', 1.0, '(sin descripcion)', 3893.0, 3893.0),
  (@cotizacion_id, 10, '4B7297-00', 1.0, '(sin descripcion)', 18526.0, 18526.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'COT ENV', 'cot env 24/03'),
  (@orden_id, 'COT ENV', 'ABONO 320.000'),
  (@orden_id, 'COT ENV', 'SALDO: 337.300');

-- ===== OT 0591 (hoja original: 591) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('OSCAR CACERES', NULL, '79946209', 'ojcg.contacto@gmail.com', '3223076065', 'calle 128 # 88 - 08');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'LIJADORA ORBITAL', 'TOTAL', 'UTF2231106', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0591', @articulo_id, 'INGRESO', NULL, '2025-11-06 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 52000.0, 52000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'BASE', NULL, 25000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'PAD', NULL, 12000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'SERVICIO MINIMO MANO DE OBRA', NULL, 15000.0);

-- ===== OT 0590 (hoja original: 590 - ENTREGADO - PTE PAGO ) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('FOCUS ENERGY', NULL, NULL, NULL, NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'MOTOR TOOL', 'DEWALT', 'DW887', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0590', @articulo_id, 'ENTREGADO - PTE PAGO', NULL, '2025-11-06 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'EQUIPO ENCIENDE, CON MOVIMIENTOS INADECUADOS, EJE Y CAMISA METALICA CON DESGASTE, RODAMIENTOS CON FATIGA. SE REALIZA MANTENIMIENTO Y LIMPIEZA GENERAL.', 94500.0, 94500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'N115813', 1.0, 'EJE', 39000.0, 39000.0),
  (@cotizacion_id, 2, NULL, 2.0, 'RODAMIENTO 6000', 10000.0, 20000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'CAJA METALICA', NULL, 0),
  (@cotizacion_id, 4, NULL, 1.0, 'PISACABLE', 12000.0, 12000.0),
  (@cotizacion_id, 5, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0589 (hoja original: 589-ENTREGADA Y PTE DE PAGO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('TECNIMOTOR JP', NULL, NULL, NULL, NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERCUTOR 12 V', 'DEWALT', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0589', @articulo_id, 'ENTREGADA Y PTE DE PAGO', NULL, '2025-11-06 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'EL MANDRIL NO ASEGURA LOS ACCESORIOS, SUENA RARO Y ESTA FATIGADO.', 88500.0, 88500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'N311560', 1.0, 'MANDRIL', 65000.0, 65000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0588 (hoja original: 588 -ENTREGADA Y PTE DE PAGO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('TECNIMOTOR JP', NULL, NULL, NULL, NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERCUTOR', 'dewalt', 'DW505', '799430');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0588', @articulo_id, 'ENTREGADA Y PTE DE PAGO', 'LLAVE DE MANDRIL', '2025-11-06 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA ENCIENDE FUNCIONAL, EN PERCUTOR EL GOLPE ES MUY LEVE, RODAMIENTOS CON FATIGA , MANTENIMIENTO GENERAL', 43500.0, 43500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '210200+6', 2.0, 'RODAMIENTO 608', 10000.0, 20000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'BLOQUE Y ARANDELA PERCUTOR (OPCIONAL)', 210000.0, 0),
  (@cotizacion_id, 3, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0587 (hoja original: 587-ENTREGADAPGA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JHON EDISON IBARRA', NULL, NULL, NULL, '3203095622 - 3212602791', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'HIDROLAVADPRA A COMBUSTIÓN', 'POWER', '2700 PSI', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0587', @articulo_id, 'ENTREGADAPGA', NULL, '2025-11-06 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'SE EVIDENCIA DETERIORO Y DESGASTE EN TODAS LAS PIEZAS MENCIONADAS   ESTO POR USO NORMAL DE LAS MÁQUINAS,  ES NECESARIO EL CAMBIO DE ESTAS PIEZAS PARA SU DEBIDO FUNCIONAMIENTO, SE  REALIZA MANTENIMIENTO, CALIBRACIÓN, AJUSTE, LIMPIEZA, PINTURA (REQUERIDA EN ALGUNAS PARTES) DE CADA MÁQUINA', 730000.0, 730000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'EMPAQUE CULATA, BUJIA, ACEITE, ARREGLO CARBURADOR, ARREGLO PISTOLA, ARREGLO ARRANQUE (CUERDA), FILTRO DE AIRE, PINTURA', 660000.0, 660000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'SERVICIO MANO OBRA', 70000.0, 70000.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADAPGA', 'ENTREGADA 4/02');

-- ===== OT 0586 (hoja original: 586-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('FABIO PEREZ', NULL, NULL, NULL, '3001547728', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'CARGADOR', 'DEWALT', 'DCB107', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0586', @articulo_id, 'INGRESO', 'INGRESA CON TALADRO ATORNILLADOR Y BATERIA 20V 1,5AH', '2025-11-06 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 190000.0, 190000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'CARGADOR NUEVO', NULL, 190000.0),
  (@cotizacion_id, 2, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 0);

-- ===== OT 0585 (hoja original: 585-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('GIOVANNY', 'CONTINENTE S.A.S.', '890101279-7', NULL, '3123194783', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO', 'EINHELL', 'TECD18-2', '2021/4/ECO-20-2101');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0585', @articulo_id, 'ENTREGADA Y PAGADA', 'INGRESA CON BATERIA 18V 2AH', '2025-11-05 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA CON ENCENDIDO INTERMITENTE, SE REALIZA MANTENIMIENTO, LUBRICACIÓN Y LIMPIEZA GENERAL', 79500.0, 79500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'INTERRUPTOR', 56000.0, 56000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0584 (hoja original: 584- ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('SIN NOMBRE', NULL, NULL, NULL, NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'MOTORTOOL', 'DREMEL', '4000', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0584', @articulo_id, 'ENTREGADA Y PAGADA', 'BOLSA RECOLECTORA DE POLVO', '2025-10-30 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 71000.0, 71000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'TARJETA VARIABLE 4000', 71000.0, 71000.0);

-- ===== OT 0583 (hoja original: 583-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('WILLMER BELTRAN', NULL, NULL, NULL, '3212200864', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'LIJADORA ROTO ORBITAL', 'TOTAL', 'UTF2031256', '21211101740');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0583', @articulo_id, 'ENTREGADA Y PAGADA', 'BOLSA RECOLECTORA DE POLVO', '2025-11-05 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA ENCIENDE, INDUCIDO FATIGADO, SE REALIZA EL CAMBIO DEL RODAMIENTO DE LA BASE , MANTENIMIENTO Y LIMPIEZA GENERAL.', 92000.0, 92000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'RODAMIENTO', 21500.0, 21500.0),
  (@cotizacion_id, 2, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0),
  (@cotizacion_id, 3, NULL, 1.0, 'ESCOBILLAS (2da vez)', 12000.0, 12000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'PAD', 35000.0, 35000.0);

-- ===== OT 0582 (hoja original: 582) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('DOBLADORA R Y S', NULL, '900213000-1', NULL, NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO - DOBLE MANDRIL', 'TOTAL', 'UTH', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0582', @articulo_id, 'INGRESO', 'SIN ACCESORIOS', '2025-11-04 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'ESTA SIN FUERZA', 44500.0, 44500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 2.0, 'ANILLO RODAMIENTO', 8000.0, 16000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'MANTENIMIENTO Y MANO DE OBRA', 28500.0, 28500.0);

-- ===== OT 0581 (hoja original: 581-PDT RECOGER) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('HENRY PINEDA ARQUITECTOS ASOCIADOS SAS', 'HENRY PINEDA ARQUITECTOS ASOCIADOS SAS', '900948143-9', 'pinedaarq@hotmail.com', '3118988810', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PUILIDORA', 'DEWALT', '-', '-');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0581', @articulo_id, 'PDT RECOGER', 'BRIDA Y TUERCA', '2025-10-04 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'EQUIPO ENCIENDE, LLEGA SIN ESCOBILLAS INSTALADAS, SE EVIDENCIA FATIGA DE RODAMIENTOS. SE REALIZA MANTENIMIENTO, LUBRICACIÓN Y LIMPIEZA GENERAL.', 124000.0, 124000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'RODAMIENTO 6202', 25000.0, 25000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'RODAMIENTO 6000', 10000.0, 10000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'JUEGO ESCOBILLAS', 40500.0, 40500.0),
  (@cotizacion_id, 4, NULL, 1.0, 'INTERRUPTOR', NULL, 25000.0),
  (@cotizacion_id, 5, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'PDT RECOGER', 'LISTA EN ESPERA DE RECOGER 30/01');

-- ===== OT 0580 (hoja original: 580 - lista) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('IVAN', 'INOVOMETAL', NULL, NULL, NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4 1/2"', 'ELITE', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0580', @articulo_id, 'lista', 'MANGO AUXILIAR', '2025-11-04 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'terminal averiada por  flujo corriente  irregular', 15500.0, 15500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'reparacion electrica minima', NULL, 15500.0);

-- ===== OT 0579 (hoja original: 579 - ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('IVAN', 'INOVOMETAL', NULL, NULL, NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4 1/2"', 'STANLEY', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0579', @articulo_id, 'ENTREGADA', 'MANGO AUXILIAR', '2025-11-04 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA NO ENCIENDE, CABLE DETERIOIRADO, RODAMIENTOS CON FATIGA, SIN PASA CABLE, ESCOBILLAS AL 20% DE VIDA UTIL. MANTENIMIENTO GENERAL Y CAMBIO DE LUBRICACIÓN', 90000.0, 90000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'RODAMIENTO 608', NULL, 10000.0),
  (@cotizacion_id, 2, NULL, 1, 'RODAMIENTO 607', NULL, 12000.0),
  (@cotizacion_id, 3, NULL, 1, 'ESCOBILLAS', NULL, 22000.0),
  (@cotizacion_id, 4, NULL, 1, 'CABLE', NULL, 38000.0),
  (@cotizacion_id, 5, NULL, 1, 'PASACABLE', NULL, 8000.0),
  (@cotizacion_id, 6, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 0);

-- ===== OT 0578 (hoja original: 578-LISTA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('SILVIA', 'PINTOR ELÉCTROSTATICO', '900346300-5', 'facturacionpintorelectro@gmail.com', '3222115144', 'CR 47 132 21');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 9"', 'DEWALT GENERICA', 'NO REGISTRA', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0578', @articulo_id, 'LISTA', NULL, '2025-11-04 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'LA MAQUINA INGRESA CON ENCENDIDO INTERMITENTE, ESCOBILLAS DESGASTADAS DIAGONALMENTE, SE EVIDENCIA QUE LA BASE DEL PORTAESCOBILLAS ESTA FRACTURADA Y SE REALIZA UNA REPARACIÓN CON EPÓXICO. SE REALIZA MANTENIMIENTO, LUBRICACIIÓN Y LIMPIEZA GENERAL.', 38500.0, 38500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'EXPT-0051', 1.0, 'ESCOBILLAS', 15000.0, 15000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0577 (hoja original: 577-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('HERNAN AGUIRRE', NULL, NULL, NULL, '3188783826', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4-1/2', 'TRUPER', 'ESMA-4-1/2A9', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0577', @articulo_id, 'ENTREGADA Y PAGADA', 'EL EQUIPO ESTA DIRECTO', '2025-11-04 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 49500.0, 49500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'interruptor', 0.0, 14000.0),
  (@cotizacion_id, 2, NULL, 1, 'rodamiento 607', NULL, 12000.0),
  (@cotizacion_id, 3, NULL, 1, 'servicio de mantenimiento y mano de obra', NULL, 23500.0);

-- ===== OT 0576 (hoja original: 576-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JAIME SANDOVAL', NULL, NULL, NULL, '3108870352', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'LIJADORA ORBITAL', 'BLACK & DECKER', 'QS800-B3', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0576', @articulo_id, 'ENTREGADA Y PAGADA', NULL, '2025-11-04 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA CON BASE FRACTURADA, SIN PAD, RODAMIENTOS CON FATIGA.', 102500.0, 102500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'RODAMIENTO 608', 10000.0, 10000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'RODAMIENTO 607', 10000.0, 10000.0),
  (@cotizacion_id, 3, '90500275', 2.0, 'PAD  + BASE PLASTICA', 20000.0, 40000.0),
  (@cotizacion_id, 4, '90500252', 2.0, 'POSTES', 9500.0, 19000.0),
  (@cotizacion_id, 5, 'SERVMO', 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0575 (hoja original: 575-NO SE PUEDE REPARAR-cot.env) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JL GESTIONES Y CONSTRUCCIONES SAS', 'JL GESTIONES Y CONSTRUCCIONES SAS', '901355146-9', 'JLCONTRATISTA@HOTMAIL.COM', '3112290246', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO', 'DEWALT', 'ILEGIBLE', '0035');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0575', @articulo_id, 'NO SE PUEDE REPARAR-cot.env', 'INGRESA CON 1 BATERÍA DWCB96-B3', '2025-10-31 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'SE REALIZAN PRUEBAS DE FUNCIONAMIENTO DEL EQUIPO Y FUNCIONA AL 100%. LA BATERÍA NO ALMACENAN LA CARGA. SIN EMBARGO POR SER UN MODELO ANTIGUO NO SE LOGRAN CONSEGUIR NI LA BATERÍA NI EL CARGADOR.', 0.0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();

-- ===== OT 0574 (hoja original: 574-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JL GESTIONES Y CONSTRUCCIONES SAS', 'JL GESTIONES Y CONSTRUCCIONES SAS', '901355146-9', 'JLCONTRATISTA@HOTMAIL.COM', '3112290246', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'BOSCH', 'NO REGISTRA', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0574', @articulo_id, 'ENTREGADA Y PAGADA', NULL, '2025-10-31 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'EL EQUIPO PRESENTA UN RODAMIENTO ATASCADO Y FRACTURADO OCASIONANDO EL DERRETIMIENTO DEL ANILLO DEL RODAMIENTO, EQUIPO CON POCO IMPACTO, SE SUGIERE CAMBIAR LA EMPAQUETADURA PARA MEJORAR EL GOLPE. SE REALIZA MANTENIMIENTO, LUBRICACIÓN Y LIMPIEZA GENERAL.', 221500.0, 221500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '210034-7', 1.0, 'RODAMIENTO 607', 12000.0, 12000.0),
  (@cotizacion_id, 2, '210200-6', 1.0, 'RODAMIENTO 608', 10000.0, 10000.0),
  (@cotizacion_id, 3, 'EXPT-0062', 1.0, 'GOMA DE RODAMIENTO', 17000.0, 17000.0),
  (@cotizacion_id, 4, 'EXPT-0063', 1.0, 'ESCOBILLAS', 45500.0, 45500.0),
  (@cotizacion_id, 5, 'EXPT-0064', 1.0, 'ANILLO PESO MUERTO', 14500.0, 14500.0),
  (@cotizacion_id, 6, 'EXPT-0061', 2.0, 'ANILLO BASE INTERMEDIA', 10000.0, 20000.0),
  (@cotizacion_id, 7, NULL, 1.0, 'CAPUCHON', 37000.0, 37000.0),
  (@cotizacion_id, 8, NULL, 1.0, 'BUMPER', 37000.0, 37000.0),
  (@cotizacion_id, 9, 'SERVMO', 1.0, 'SERVICIO MANO OBRA', 28500.0, 28500.0);

-- ===== OT 0573 (hoja original: 573 - LISTA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('SANTIAGO CORREDOR', 'CAISAN INGENIERIA', '90161130-7', 'proyectos@caisaningenieria.com', '3176598221', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'TOTAL', 'UTH110286', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0573', @articulo_id, 'LISTA', 'SIN ACCESORIOS', '2025-11-04 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'EQUIPO USADO 100% EN DEMOLICION, OCASIONANDO DESGASTE CON EL PISTON EN UN COSTRADO DEL CILINDRO.', 50000.0, 50000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'CILINDRO', NULL, 50000.0),
  (@cotizacion_id, 2, NULL, 1, 'SERVICIO DE MANO DE OBRA', NULL, 0);

-- ===== OT 0572 (hoja original: 572-COT.ENV.) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('freddy', 'FAROLAS FREDDY', NULL, NULL, '3138055799', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'LIJADORA ROTO ORBITAL', 'UYUSTOOLS', 'UY-LJR125', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0572', @articulo_id, 'COT.ENV', 'BOLSA RECOLECTORA', CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'SE EVIDENCIA RODAMIENTO FATIGADO, MAQUINA SIN FRENO, Y EL PAD SE DEJA OPCIONAL PORQUE ESTA FUNCIONAL PERO EL CAMBIO AYUDA A MEJORAR LAS VIBRACIONES DEL EQUIPO. SE REALIZA MANTENIMIENTO Y LIMPIEZA GENERAL.', 60500.0, 60500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'RODAMIENTO 629', 12000.0, 12000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'FRENO', 25000.0, 25000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'PAD (OPCIONAL)', 30000.0, 0),
  (@cotizacion_id, 4, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0571 (hoja original: 571-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('MARTIN EMILIO GOMEZ', NULL, '79394580', NULL, '3108945508', 'CR 23 # 11 - 19 SUR');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'POLICHADORA', 'DEWALT', 'DWP849X-B3', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0571', @articulo_id, 'ENTREGADA Y PAGADA', 'TUERCA DE SEGURODAD , MANGO', '2025-10-30 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 362500.0, 362500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'N089178', 1.0, 'MODULO', 157000.0, 157000.0),
  (@cotizacion_id, 2, 'N024326', 1.0, 'INTERRUPTOR', 85000.0, 85000.0),
  (@cotizacion_id, 3, 'N084855', 1.0, 'RAMAL DE CABLES', 97000.0, 97000.0),
  (@cotizacion_id, 4, 'N036455', 1.0, 'VARIADOR REGULADOR (OPCIONAL)', 44000.0, 0),
  (@cotizacion_id, 5, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0570 (hoja original: 570-COT.ENV.) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('PROYECTOS Y CONSTRUCCIONES DAMASCO S.A.S.', 'PROYECTOS Y CONSTRUCCIONES DAMASCO S.A.S.', '900065118-4', 'contabilidaddamasco2022@gmail.com', '3143181181', 'CL 93 B 18 12 OF 605');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'HIDROLAVADORA', 'EVANS', 'HI08L15ME200', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0570', @articulo_id, 'COT.ENV', 'INGRESA CON PISTOLA Y MANGUERA DE ALIMENTACIÓN', '2025-10-29 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'SE EVIDENCIA DETERIORO Y DESGASTE EN TODAS LAS PIEZAS MENCIONADAS   ESTO POR USO NORMAL DE LAS MÁQUINAS,  ES NECESARIO EL CAMBIO DE ESTAS PIEZAS PARA SU DEBIDO FUNCIONAMIENTO, SE  REALIZA MANTENIMIENTO, CALIBRACIÓN, AJUSTE, LIMPIEZA, PINTURA (REQUERIDA EN ALGUNAS PARTES) DE CADA MÁQUINA. EL MANOMETRO SI NO SE CONSIGUE”  SE DESCUENTA $190.000.', 975000.0, 975000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'SELLOS DE ACEITE, 6 VALVULAS, ACEITE, ARREGLO LANZA', 700000.0, 700000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'RELOJ MANOMETRO GLICERINA', 190000.0, 190000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'SERVICIO MANO OBRA', 85000.0, 85000.0);

-- ===== OT 0569 (hoja original: 569-COT.ENV.) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('PROYECTOS Y CONSTRUCCIONES DAMASCO S.A.S.', 'PROYECTOS Y CONSTRUCCIONES DAMASCO S.A.S.', '900065118-4', 'contabilidaddamasco2022@gmail.com', '3143181181', 'CL 93 B 18 12 OF 605');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'HIDROLAVADORA', 'KARCHER', 'NO REGISTRA', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0569', @articulo_id, 'COT.ENV', 'INGRESA CON LANZA,PISTOLA Y LA MANGUERA DE ALIMENTACIÓN ESTA FRACTURADA, INGRESA PARA MANTENIMIENTO,', '2025-10-29 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'SE EVIDENCIA DETERIORO Y DESGASTE EN TODAS LAS PIEZAS MENCIONADAS   ESTO POR USO NORMAL DE LAS MÁQUINAS,  ES NECESARIO EL CAMBIO DE ESTAS PIEZAS PARA SU DEBIDO FUNCIONAMIENTO, SE  REALIZA MANTENIMIENTO, CALIBRACIÓN, AJUSTE, LIMPIEZA, PINTURA (REQUERIDA EN ALGUNAS PARTES) DE CADA MÁQUINA.', 432000.0, 432000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'CABEZAL INFERIOR, SELLOS DE ACEITE, EJE CENTRAL, PIÑONES PLASTICOS, ARREGLO MANGUERA, ACEITE', 372000.0, 372000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'SERVICIO MANO OBRA', 60000.0, 60000.0);

-- ===== OT 0568 (hoja original: 568-ENTREGADA- PDT PAGO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('SR MAURICIO REINA', 'DOBLADORA RYS', '900213000-1', 'dobladorarys@hotmail.com', '3143575809', 'calle 182 # 8d - 17');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TRONZADORA', 'ELITE', 'CS1425', '0088');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0568', @articulo_id, 'ENTREGADA- PDT PAGO', 'NO ENCIENDE Y ESTA DIRECTA', '2025-10-29 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 35500.0, 35500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'UTS92035526-SP-80', 1.0, 'INTERRUPTOR TOTAL', 20000.0, 20000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'MANTENIMIENTO Y MANO DE OBRA', 15500.0, 15500.0);

-- ===== OT 0567 (hoja original: 567-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('SR MAURICIO REINA', 'DOBLADORA RYS', '900213000-1', 'dobladorarys@hotmail.com', '3143575809', 'calle 182 # 8d - 17');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERCUTOR INALAMBRICO', 'TOTAL', 'NO REGISTRA', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0567', @articulo_id, 'INGRESO', 'INGRESA SIN BATERÍA NI CARGADOR, SOLO FUNCIONA EL PERCUTOR', '2025-10-29 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0566 (hoja original: 566-PDT.PAGO ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('TECNIMOTOR JP', 'TECNIMOTOR JP', NULL, NULL, '3124538636 - 3102044256', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'SIERRA CIRCULAR', 'BLACK & DECKER', 'CS1034-B3', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0566', @articulo_id, 'PDT.PAGO ENTREGADA', NULL, '2025-10-29 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'INDUCIDO EN CORTO, ESCOBILLAS DESGASTADAS, PATA ESCOBILLAS NO AJUSTAN CORRRECTAMENTE', 266000.0, 266000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '90568782', 1.0, 'INDUCIDO', 198000.0, 198000.0),
  (@cotizacion_id, 2, '90568794-90568789', 2.0, 'TAPA ESCOBILLA', 15000.0, 30000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', 38000.0, 38000.0);

-- ===== OT 0565 (hoja original: 565-ENTREGADA SIN REPARAR) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('TECNIMOTOR JP', 'TECNIMOTOR JP', NULL, NULL, '3124538636 - 3102044256', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'SIERRA CALADORA', 'DEWALT', 'DW341-B3', '02613');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0565', @articulo_id, 'ENTREGADA SIN REPARAR', NULL, '2025-10-29 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MODELO DESCONTINUADO, NO SE CONSIGUEN REFACCIONES.', 0.0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'EJE', 0.0, 0),
  (@cotizacion_id, 2, NULL, 2.0, 'ARANDELAS FILTRO', NULL, 0),
  (@cotizacion_id, 3, NULL, 1.0, 'PORTA CUCHILLA', NULL, 0),
  (@cotizacion_id, 4, NULL, 1.0, 'ARANDELA FILTRO', NULL, 0),
  (@cotizacion_id, 5, NULL, 1.0, 'ESCOBILLAS', NULL, 0),
  (@cotizacion_id, 6, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0564 (hoja original: 564-ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('SILVIA', 'PINTOR ELÉCTROSTATICO', '900346300-5', 'facturacionpintorelectro@gmail.com', '3222115144', 'CR 47 132 21');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 5"', 'TOTAL', 'UTG11512526', '24497600176');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0564', @articulo_id, 'ENTREGADA', NULL, '2025-10-29 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'DAÑO EN CLAVIJA, VIDA DE LAS ESCOBILLAS DEL 20%, SE REALIZA LIMPIEZA GENERAL', 0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'EXPT-0017', 1.0, 'CLAVIJA  PEQUEÑA', 0.0, 0);

-- ===== OT 0563 (hoja original: 563-LISTA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('IVAN', 'INOVOMETALMEC SAS', '901516019-3', 'ivanarielvargasguerra@gmail.com', '3108520625', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERCUTOR', 'DEWALT', 'DCD776', '246549');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0563', @articulo_id, 'LISTA', 'INGRESA CON 1 BATERÍA 20V 2AH -  EQUIPO NO ENCIENDE', '2025-10-29 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'EQUIPO NO ENCIENDE, MOTOR RECALENTADO Y QUEMADO, PRESENTA FALLA DE FORZAMIENTO,  SE REALIZA MANTENIMIENTO, LUBRICACIÓN Y LIMPIEZA GENERAL.', 173500.0, 173500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'UTIDLI20031-SP-8', 1.0, 'MOTOR', 150000.0, 150000.0),
  (@cotizacion_id, 2, 'SERVMO', 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0562 (hoja original: 562-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('VICTOR CASTILLO', NULL, '1019055286', 'c.victor_100@hotmail.com', '3176985823', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'TRUPER', 'TALI--18N2', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0562', @articulo_id, 'INGRESO', 'INGRESA CON 1 BATERÍA  BAT-182N2 18V, FALLA REVERSIBLE', '2025-10-29 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0560-A (hoja original: 561) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JAVIER DIAZ ALARADO', 'ESTRUCTURARTE SAS', '901964328-5', 'javierdiazalvarado@gmail.com', '3132284908', 'sutatausa');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERCUTOR 3/8', 'MAKITA (GENERICO)', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0560-A', @articulo_id, 'INGRESO', 'SIN ACCESORIOS', '2025-10-29 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MANDRIL ATASCADO, CAMBIO DE MANDRIL', 30000.0, 30000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'MANDRIL 3/8 - INSTALADO', NULL, 30000.0);

-- ===== OT 0560-B (hoja original: 560) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JAVIER DIAZ', 'ESTRUCTURARTE SAS', NULL, NULL, NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERCUTOR 1/2', 'A&B', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0560-B', @articulo_id, 'INGRESO', 'SIN ACCESORIOS', '2025-10-29 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0559 (hoja original: 559) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JAVIER DIAZ ALARADO', 'ESTRUCTURARTE SAS', '901964328-5', 'javierdiazalvarado@gmail.com', '3132284908', 'sutatausa');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDOA 4 1/2"', 'BLACK & DECKER', 'GB720 B3', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0559', @articulo_id, 'INGRESO', 'SIN ACCESORIOS', '2025-10-29 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'SE REALIZA MANTENIMIENTO GENERAL DE LA MAQUINA Y SE AJUSTA CONEXION ELECTRICA', 38500.0, 38500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'TUERCA Y BRIDA', NULL, 15000.0),
  (@cotizacion_id, 2, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 23500.0);

-- ===== OT 0558 (hoja original: 558) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('IVAN MISNAZA', NULL, '79652368', 'ivanmisnaza72@gmail.com', '3134457791 - 3164747416', 'cll 128 c # 49 a -13');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'taladro perforador', 'ingco', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0558', @articulo_id, 'INGRESO', 'bateria 20 v  2 AH', '2025-10-27 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'INTERRUPTOR NO REGULA', 73500.0, 73500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'INTERRIUPTOR COMPLETO', NULL, 50000.0),
  (@cotizacion_id, 2, NULL, 1, 'MANTENIMIENTO Y MANO DE OBRA', NULL, 23500.0);

-- ===== OT 0557 (hoja original: 557 - no se puede reparar) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('IVAN MISNAZA', NULL, '79652368', 'ivanmisnaza72@gmail.com', '3134457791 - 3164747416', 'cll 128 c # 49 a -13');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'taladro perforador', 'truper', 'TALI-12A2', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0557', @articulo_id, 'no se puede reparar', 'bateria 1.3 AH', '2025-10-27 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MOTOR RECALENTADO, MOTOR EN CORTO', 183500.0, 183500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '101183', 1, 'INTERRUPTOR', NULL, 100000.0),
  (@cotizacion_id, 2, NULL, 1, 'MOTOR', NULL, 60000.0),
  (@cotizacion_id, 3, NULL, 1, 'MANTENIMIENTO Y MANO DE OBRA', NULL, 23500.0);

-- ===== OT 0556 (hoja original: 556-ENTREGADA SIN REPARAR) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('HECTOR FABIO COPETE', NULL, NULL, NULL, '3025280279', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'GRAPADORA', 'SATA', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0556', @articulo_id, 'ENTREGADA SIN REPARAR', 'EL CLIENTE TRAE LA GRAPADORA DESARMADA', '2025-10-27 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0555 (hoja original: 555-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('SILVIA', 'PINTOR ELÉCTROSTATICO', '900346300-5', 'facturacionpintorelectro@gmail.com', '3222115144', 'CR 47 132 21');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4 1/2', 'DEWALT', 'DWE4120-B3', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0555', @articulo_id, 'ENTREGADA Y PAGADA', 'TUERCA', '2025-10-24 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA CON ESCOBILLAS DESGASTADAS, MANTENIMIENTO GENERAL Y LIMPIEZA', 42100.0, 42100.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'N097696', 1, 'ESCOBILLAS', NULL, 18600.0),
  (@cotizacion_id, 2, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 23500.0);

-- ===== OT 0554 (hoja original: 554 - entregada y pagada) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES (NULL, 'ALVARO DELGADO', NULL, NULL, NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'BOSH', 'GSB 20-2', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0554', @articulo_id, 'entregada y pagada', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 53000.0, 53000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'EXPT-0055', 1, 'INTERRRUPTOR', NULL, 38000.0),
  (@cotizacion_id, 2, NULL, 1, 'MANO DE OBRA MINIMA ELECRTRICA', NULL, 15000.0);

-- ===== OT 0553 (hoja original: 553-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('SANTIAGO CORREDOR', 'CAISAN INGENIERIA', '90161130-7', 'proyectos@caisaningenieria.com', '3176598221', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 7"', 'TOTAL', 'UTG12018026', '-');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0553', @articulo_id, 'ENTREGADA Y PAGADA', 'GUARDA, MAGO AUXILIAR, TUERCA Y BRIDA,', '2025-10-24 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'ENCIENDE INTERMITENTEMENTE, SE REALIZA EL CAMBIO DEL INTERRUPTOR', 58500.0, 58500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'UTG12223026-SP-44/47', 1, 'INTERRUPTOR', NULL, 35000.0),
  (@cotizacion_id, 2, 'SERVMO', 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 23500.0);

-- ===== OT 0552 (hoja original: 552-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('SANTIAGO CORREDOR', 'CAISAN INGENIERIA', '90161130-7', 'proyectos@caisaningenieria.com', '3176598221', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4 1/2"', 'BLACK & DECKER', 'G720 B3', '-');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0552', @articulo_id, 'ENTREGADA Y PAGADA', 'TUERCA Y BRIDA', '2025-10-24 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'SUENA MUY FEO, SE REALIZA LA REVISION SE EVIDEMNCIA RODAMIENTO CON FATIGA Y ESCOBILLAS DESGASTADAS', 45500.0, 45500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '90604792', 1, 'ESCOBILLAS', NULL, 10000.0),
  (@cotizacion_id, 2, '210034-7', 1, 'RODAMIENTO 607', NULL, 12000.0),
  (@cotizacion_id, 3, 'SERVMO', 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 23500.0);

-- ===== OT 0551 (hoja original: 551-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('SANTIAGO CORREDOR', 'CAISAN INGENIERIA', '90161130-7', 'proyectos@caisaningenieria.com', '3176598221', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4 1/2"', 'TOTAL', '750 W', '-');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0551', @articulo_id, 'ENTREGADA Y PAGADA', 'GUARDA, TUERCA Y BRIDA', '2025-10-24 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'REVISION INDUCIDO, BOTA MUCHA CHISPA', 95500.0, 95500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'UTG109125565-SP-26', 1, 'INDUCIDO', NULL, 60000.0),
  (@cotizacion_id, 2, 'UTG10711556-SP-36', 1, 'ESCOBILLAS', NULL, 12000.0),
  (@cotizacion_id, 3, 'SERVMO', 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 23500.0);

-- ===== OT 0550 (hoja original: 550-ENTREGADA Y PTE DE PAGO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('SANTIAGO CORREDOR', 'CAISAN INGENIERIA', '90161130-7', 'proyectos@caisaningenieria.com', '3176598221', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'DEMOLEDOR', 'TRUPER', 'MADE - 6NX', '-');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0550', @articulo_id, 'ENTREGADA Y PTE DE PAGO', 'EMPUÑADURA AUXILIAR TIPO BOTELLA', '2025-10-24 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA ENCIENDE, NO AJUSTA EL ACCESORIO SE EVIDENCIA CON SONIDO EXTRAÑO, AL DESEMBLAR EL EQUIPO SE EVIDENCIAN MAL ENSAMBLAJE A LA ALTURA DEL PORTA BROCAS,  PARTICULAS METALICAS EN SU INTERIOR,  DADA LA FACTURA DE LA ARANDELA METALICA DE AJUSTE DE GOLPEADOR,  AL CAMBIAR ESTA PIEZA SE TENDRA FUCIONAMIENTO DE LA  MAQUINA, PERO NO SE GARANTIZA UNA LARGA VIDA UTIL, YA QUE SE AVERIARON DE CONSIDERACIÓN OTRAS PARTES DEL EQUIPO,  TENER PRESENTE QUE TRUPER NO DISTRIBUYE REFACCIONES PARA ESTE MODELO, POR LO QUE SE CONSIDERA LA FABRICACION NACIONAL DE LAS PIEZAS NECESARIAS.', 160500.0, 160500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'EXPT-0070', 1.0, 'ARANDELA', 80000.0, 80000.0),
  (@cotizacion_id, 2, 'EXPT-0068', 1.0, 'AMORTIGUADO (ANILLO)', 12000.0, 12000.0),
  (@cotizacion_id, 3, '210200-6', 1.0, 'RODAMIENTO 608', 12000.0, 12000.0),
  (@cotizacion_id, 4, 'EXPT-0069', 1.0, 'ANILLO DE TAPA', 10000.0, 10000.0),
  (@cotizacion_id, 5, '682559-5', 1.0, 'PASACABLE', 8000.0, 8000.0),
  (@cotizacion_id, 6, 'SERVMO', 1.0, 'SERVICIO MANO OBRA', 38500.0, 38500.0);

-- ===== OT 0549 (hoja original: 549) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('RAFAEL FALLA', 'PRIDE', NULL, NULL, '3108744698', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'RUTEADORA', 'MAKITA', 'RP1800', '82554');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0549', @articulo_id, 'INGRESO', 'FRESA RECTA DE 1/2"', '2025-10-24 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'VALIDACION TUERCA Y COLLECT', 0.0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();

-- ===== OT 0548 (hoja original: 548-NO SE JUSTIFICA-COT.ENV.) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('WILLIAM ALEXANDER SALCEDO', NULL, '79866463', NULL, '3209095541', 'CALLE 129 # 89 B - 28');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'BOSH', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0548', @articulo_id, 'NO SE JUSTIFICA-COT.ENV', NULL, '2025-10-23 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'INDUCIDO EN CORTO, BOBINA RECALENTADA, RODAMIENTO DE COLECTOR ATASCADO GENERANDO DERRETIMIENTO EN LA CAJA CAMPO. SE REALIZA MANTENIMIENTO, LUBRICACIIÓN Y LIMPIEZA GENERAL.', 663400.0, 663400.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'INDUCIDO', 231600.0, 231600.0),
  (@cotizacion_id, 2, NULL, 1.0, 'BOBINA', 83300.0, 83300.0),
  (@cotizacion_id, 3, NULL, 1.0, 'ESCOBILLAS', 25000.0, 25000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'CAJA CAMPO', 280000.0, 280000.0),
  (@cotizacion_id, 5, NULL, 1.0, 'ANILLO PESO MUERTO', 15000.0, 15000.0),
  (@cotizacion_id, 6, NULL, 1.0, 'SERVICIO MANO OBRA', 28500.0, 28500.0);

-- ===== OT 0547 (hoja original: 547-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ARNULFO CASTELLANOS', 'INGELDAC S A S', '900312212-9', 'acastellanos@ingeldac.com / info@ingeldac.com', '3115847860', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'POWER TOOLS', 'NEEH-01', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0547', @articulo_id, 'ENTREGADA Y PAGADA', NULL, '2025-10-23 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'EQUIPO ENCIENDE, FUNCIONAL SE REALIZA MANTENIMIENTO, LUBRICACIÓN Y MANTENIMIENTO GENERAL.', 86500.0, 86500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'EXPT-0039', 1.0, 'ANILLO PESO MUERTO', 10000.0, 10000.0),
  (@cotizacion_id, 2, 'EXPT-0023', 1.0, 'ANILLO GOLPEADOR', 10000.0, 10000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'PASACABLE REFURBI', 3000.0, 3000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'SERVICIO MANO OBRA', 38500.0, 38500.0),
  (@cotizacion_id, 6, NULL, 1.0, 'EMPUÑADURA', 25000.0, 25000.0);

-- ===== OT 0546 (hoja original: 546-Entregada y Pagada) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('EDUARD MUÑOZ', NULL, '79747107', NULL, '3125784837', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'DEWALT', 'DWE4010-B3', '230399');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0546', @articulo_id, 'Entregada y Pagada', 'INGRESA CON BRIDA, TUERCA Y 1 DISCO. SUELTA LAS BRIDAS Y SUENA RARO EN LOS PIÑONES', '2025-10-23 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA CON BRIDA Y TUERCAS DESGATADAS, SOLO SIRVEN LAS OIGINALES, ESCOBILLAS TAMBIEN CON ALTO GRADO DE DESGASTE, LIMPIEZA Y MANTENIMIENTO GENERAL', 84000.0, 84000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'TUERCA', NULL, 21000.0),
  (@cotizacion_id, 2, NULL, 1, 'BRIDA', NULL, 17500.0),
  (@cotizacion_id, 3, '939539-00', 1, 'ESCOBILLAS', NULL, 22000.0),
  (@cotizacion_id, 4, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 23500.0);

-- ===== OT 0545 (hoja original: 545-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('EQUIPOS Y MEDICIONES TECNICAS SAS', 'EQUIPOS Y MEDICIONES TECNICAS SAS', '830100716-5', 'proyectos@equiposymediciones.com', '3155603502', 'CL 124 7 35 OF 601');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'MAKITA', '9557HPG', '55629K');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0545', @articulo_id, 'ENTREGADA Y PAGADA', 'INGRESA CON BRIDA Y TUERCA, SIN EMPUÑADURA', '2025-10-22 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'EQUIPO CONTAMINADO AL 90%, SE REALIZA MANTENIMIENTO Y LIMPIEZA GENERAL.', 23500.0, 23500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0544 (hoja original: 544-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('EQUIPOS Y MEDICIONES TECNICAS SAS', 'EQUIPOS Y MEDICIONES TECNICAS SAS', '830100716-5', 'proyectos@equiposymediciones.com', '3155603502', 'CL 124 7 35 OF 601');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'MAKITA', 'DGA458', '0005064Y');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0544', @articulo_id, 'ENTREGADA Y PAGADA', 'INGRESA CON BRIDA Y TUERCA', '2025-10-22 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'LA MAQUINA ENCIENDE, PERO SE DETECTA UN SONIDO EXTRAÑO, ATASCAMIENTO DE RODAMIENTO LO QUE GENERO EL DERRETIMIENTO EN LA BASE DEL RODAMIENTO UBICADA EN LA CARCASA MOTOR, LO AANTERIOR OCASIONO FALLAS ADICIONALES COMO INDUCIDO NO ALINEADO (ARRASTRE DE INDUCIDO CONTRA LA BOBINA). SE REALIZA MANTENIMIENTO Y LIMPIEZA GENERAL.', 35500.0, 35500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '210034-7', 1.0, 'RODAMIENTO 607 (OBLIGATORIO)', 12000.0, 12000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'CARCASA MOTOR (OPCIONAL)', 71000.0, 0),
  (@cotizacion_id, 3, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0),
  (@cotizacion_id, 5, NULL, 1, 'EL EQUIPO SE ENCUENTRA CONTAMINADO AL 100%, SE RECOMIENTA REALIZAR LIMPIEZA DESPUES DE CADA JORNADA DE TRABAJO', NULL, 0);

-- ===== OT 0543 (hoja original: 543-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('EQUIPOS Y MEDICIONES TECNICAS SAS', 'EQUIPOS Y MEDICIONES TECNICAS SAS', '830100716-5', 'proyectos@equiposymediciones.com', '3155603502', 'CL 124 7 35 OF 601');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'LIJADORA', 'MAKITA', 'XOB01', '0114875Y');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0543', @articulo_id, 'ENTREGADA Y PAGADA', 'INGRESA CON PAD', '2025-10-22 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'LA MAQUINA ENCIENDE, TIENE EL RODAMIENTO DE BASE ATASCADO ESTO GENERA VIBRACIÓN EN PIEZAS INTERNAS GENERANDO DESGASTE EN LA CARCASA MOTOR, CONTAMINACIÓN EN EL 90% DEL EQUIPO, BASE CON LIJAS PEGADAS CON BOXER Y ESTO GENERA UNA BASE MAS RIGIDA Y ALTA VIBRACIÓN EN EL EQUIPO. SE REALIZA MANTENIMIENTO Y LIMPIEZA GENERAL. LA CARCASA MOTOR TIENE UN TIEMPO DE IMPORTACIÓN DE 30 A 90 DÍAS.', 47500.0, 47500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '211228-7', 1.0, 'RODAMIENTO 6202 (OBLIGATORIO)', 24000.0, 24000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'PAD-BASE VELCRO (OPCIONAL)', 110000.0, 0),
  (@cotizacion_id, 3, NULL, 1.0, 'CARCASA MOTOR', 67000.0, 0),
  (@cotizacion_id, 4, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0542 (hoja original: 542-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('EQUIPOS Y MEDICIONES TECNICAS SAS', 'EQUIPOS Y MEDICIONES TECNICAS SAS', '830100716-5', 'proyectos@equiposymediciones.com', '3155603502', 'CL 124 7 35 OF 601');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'LIJADORA', 'MAKITA', 'BO5030', '1670963A');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0542', @articulo_id, 'ENTREGADA Y PAGADA', 'INGRESA CON PAD', '2025-10-22 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'SE EVIDENCIA QUE EL EQUIPO ESTA FUNCIONAL CON ALTA VIBRACIÓN, CONTAMINACIÓN EN EL 90% DEL EQUIPO, RODAMIENTOS FATIGADOS, BASE CON LIJAS PEGADAS CON BOXER Y ESTO GENERA UNA BASE MAS RIGIDA Y ALTA VIBRACIÓN EN EL EQUIPO. SE REALIZA MANTENIMIENTO Y LIMPIEZA GENERAL.', 71500.0, 71500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'PAD-BASE VELCRO (OPCIONAL)', 110000.0, 0),
  (@cotizacion_id, 2, '211228-7', 1.0, 'RODAMIENTO 6202', 24000.0, 24000.0),
  (@cotizacion_id, 3, '210034-7', 1.0, 'RODAMIENTO 607', 12000.0, 12000.0),
  (@cotizacion_id, 4, '211092-6', 1.0, 'RODAMIENTO 629', 12000.0, 12000.0),
  (@cotizacion_id, 5, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0541 (hoja original: 541-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('EQUIPOS Y MEDICIONES TECNICAS SAS', 'EQUIPOS Y MEDICIONES TECNICAS SAS', '830100716-5', 'proyectos@equiposymediciones.com', '3155603502', 'CL 124 7 35 OF 601');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'LIJADORA', 'MAKITA', 'DBO180', '0529018Y');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0541', @articulo_id, 'ENTREGADA Y PAGADA', 'INGRESA CON PAD', '2025-10-22 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'EQUIPO CONTAMINADO AL 90%, BASE CON LIJAS PEGADAS CON BOXER Y ESTO GENERA UNA BASE MAS RIGIDA Y ALTA VIBRACIÓN EN EL EQUIPO. SE REALIZA MANTENIMIENTO Y LIMPIEZA GENERAL.', 23500.0, 23500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'PAD-BASE VELCRO (OPCIONAL)', 110000.0, 0),
  (@cotizacion_id, 2, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0540 (hoja original: 540-ENTREGADO Y PTE DE PAGO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('TECNIMOTOR JP', 'TECNIMOTOR JP', NULL, NULL, '3124538636 - 3102044256', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'DEMOLEDOR', 'CHINO', 'NO REGISTRA', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0540', @articulo_id, 'ENTREGADO Y PTE DE PAGO', 'brida y tuerca', '2025-10-20 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA NO ENCIENDE POR FALLA EN CONTACTO EN TERMINAL PORTAESCOBILLA, EQUIPO EN BUENAS CONDICIONES, SOLO SE REALIZA RETANQUEO EN LA CAMARA DE ACEITE', 41500.0, 41500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 2.0, 'RESORTE PORTA ESCOBILLAS', 4000.0, 8000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'RETANQUEO DE ACEITE', 10000.0, 10000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'REPARACIÓN ELÉCTRICA', 23500.0, 23500.0);

-- ===== OT 0539 (hoja original: 539-ENTREGADA Y PTE DE PAGO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('SILVIA', 'PINTOR ELÉCTROSTATICO', '900346300-5', 'facturacionpintorelectro@gmail.com', '3222115144', 'CR 47 132 21');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4 1/2', 'MAKITA', '9557NB', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0539', @articulo_id, 'ENTREGADA Y PTE DE PAGO', 'BRIDA', CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA CON ENCENDIDO FIJO, INDUCIDO RECALENTADO, BOBINA CON DAÑO EN EL BOBINADO, NO TIENE BOTÓN. SE REALIZA MANTENIMIENTO, LUBRICACIÓN Y LIMPIEZA GENERAL.', 281500.0, 281500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '510083-7', 1.0, 'INDUCIDO', 142000.0, 142000.0),
  (@cotizacion_id, 2, '621706-3', 1.0, 'CAMPO', 85000.0, 85000.0),
  (@cotizacion_id, 3, '418728-0', 1.0, 'PALANCA INTERRUPTOR', 10000.0, 10000.0),
  (@cotizacion_id, 4, '419566-3', 1.0, 'BOTON INTERRUPTOR', 5000.0, 5000.0),
  (@cotizacion_id, 5, '195001-2', 1.0, 'ESCOBILLAS', 16000.0, 16000.0),
  (@cotizacion_id, 6, 'SERVMO', 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0538 (hoja original: 538-NO AUTORIZADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('TECNIMOTOR JP', 'TECNIMOTOR JP', '900429531-7', NULL, '3124538636 - 3102044256', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'BOSCH', 'NO REGISTRA', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0538', @articulo_id, 'NO AUTORIZADA', 'brida y tuerca', '2025-10-20 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MATRIMONIO DE PIÑONES FRACTURADOS, RODAMIENTO FATIGADO. SE REALIZA MANTENIMIENTO, LUBRICACIÓN Y LIMPIEZA GENERAL', 143500.0, 143500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'KIT COMPLETO PIÑONES', 110000.0, 110000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'RODAMIENTO 608', 10000.0, 10000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0537 (hoja original: 537) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('LEONARDO JIMENEZ', 'ACERO Y CROMO', NULL, NULL, '3213475859', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'CARGADOR', 'DEWALT', 'DCB112', '-');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0537', @articulo_id, 'INGRESO', 'SIN ACCESORIOS', '2025-10-20 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA CON INDUCIDO EN CORTO,', 0.0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();

-- ===== OT 0536 (hoja original: 536-AUTORIZADO-PTE RPTOS) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('PEDRO MORENO', NULL, NULL, NULL, '3133796549', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4 1/2', 'MAKITA', '9557HPG', '-');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0536', @articulo_id, 'AUTORIZADO-PTE RPTOS', 'SIN ACCESORIOS', '2025-10-20 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA CON INDUCIDO EN CORTO, OCASIONADO POR USO DE ESCOBILLAS NO ORIGINALES.', 181900.0, 181900.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '510083-7', 1, 'INDUCIDO', NULL, 142400.0),
  (@cotizacion_id, 2, NULL, 1, 'ESCOBILLAS', NULL, 16000.0),
  (@cotizacion_id, 3, NULL, 1, 'MANTENIMIENTO Y MANO DE OBRA', NULL, 23500.0);

-- ===== OT 0535 (hoja original: 535-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ANDRES RIVERA', 'MAQUINAGRO DICAR', '20627144-7', 'dianacardenasnova@gmail.com', '3223099339', 'CR 5 #1-08');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'HILTI', 'NO REGISTRA', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0535', @articulo_id, 'INGRESO', NULL, '2025-10-16 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0534 (hoja original: 534-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ANDRES RIVERA', 'MAQUINAGRO DICAR', '20627144-7', 'dianacardenasnova@gmail.com', '3223099339', 'CR 5 #1-08');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'MAKITA', 'M0901', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0534', @articulo_id, 'INGRESO', NULL, '2025-10-16 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0533 (hoja original: 533-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JL GESTIONES Y CONSTRUCCIONES SAS', 'JL GESTIONES Y CONSTRUCCIONES SAS', '901355146-9', 'JLCONTRATISTA@HOTMAIL.COM', '3112290246', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO BOSH', 'BOSCH', '611236', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0533', @articulo_id, 'INGRESO', 'MANGO AUXILIAR', '2025-10-16 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 145000.0, 145000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'BOTON', NULL, 15000.0),
  (@cotizacion_id, 2, NULL, 1, 'ESCOBILLAS', NULL, 60000.0),
  (@cotizacion_id, 3, NULL, 2.0, 'ANILLOS', 20000.0, 40000.0),
  (@cotizacion_id, 4, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 30000.0);

-- ===== OT 0532 (hoja original: 532-ENTREGADA ) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JL GESTIONES Y CONSTRUCCIONES SAS', 'JL GESTIONES Y CONSTRUCCIONES SAS', '901355146-9', 'JLCONTRATISTA@HOTMAIL.COM', '3112290246', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'SIERRA CIRCULAR', 'BOSCH', 'GKS 150', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0532', @articulo_id, 'ENTREGADA', 'DISCO DE CORTE Y TUERCA', '2025-10-16 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 413000.0, 413000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'BOBINA', 118400.0, 118400.0),
  (@cotizacion_id, 2, NULL, 1.0, 'ESCOBILLAS', 33000.0, 33000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'PIÑON CORONA', 53000.0, 53000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'INDUCIDO', 180600.0, 180600.0),
  (@cotizacion_id, 5, NULL, 1.0, 'SERVICIO MANO OBRA', 28000.0, 28000.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'ENTREGADA', 'cv.1285'),
  (@orden_id, 'ENTREGADA', 'FACT EXT 676');

-- ===== OT 0531 (hoja original: 531-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JL GESTIONES Y CONSTRUCCIONES SAS', 'JL GESTIONES Y CONSTRUCCIONES SAS', '901355146-9', 'JLCONTRATISTA@HOTMAIL.COM', '3112290246', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'BOSCH', 'GBH 2-20 D', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0531', @articulo_id, 'ENTREGADA Y PAGADA', 'SIN ACCESORIOS, EQUIPO NO GOLPEA', '2025-10-16 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA ENCIENDE, NO PERCUTA, FALLA PRINCIPAL POR RUPTURA EN RODAMIENTO EXENTRICO LO QUE OCASIONA  UNA RUPTURA EN LAS PIEZAS SIGUIENTES. SE REALIZA MANTENIMIENTO, LUBRICACIÓN Y LIMPIEZA GENERAL.', 351000.0, 351000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'EXPT-0058', 1.0, 'BALERO - RODAMIENTO EXENTRICO', 196500.0, 196500.0),
  (@cotizacion_id, 2, 'EXPT-0059', 1.0, 'CILINDRO PISTON', 75500.0, 75500.0),
  (@cotizacion_id, 3, 'EXPT-0065', 1.0, 'BULÓN - PASADOR', 19000.0, 19000.0),
  (@cotizacion_id, 4, NULL, 2.0, 'ARANDELAS DEL PASADOR', 9500.0, 19000.0),
  (@cotizacion_id, 5, 'EXPT-0060', 1.0, 'ORING PESO MUERTO', 12500.0, 12500.0),
  (@cotizacion_id, 6, 'SERVMO', 1.0, 'SERVICIO MANO OBRA', 28500.0, 28500.0);

-- ===== OT 0530 (hoja original: 530-pte precios) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('GUSTAVO ORTIZ', 'SERVI HIDRAULICOS', '901170174-1', 'SERVIHIDRAULICOSGOT@HOTMAIL.COM', '3015791770', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'DEWALT', 'D25213', '068078');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0530', @articulo_id, 'pte precios', NULL, '2025-10-15 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'INDUCIDO EN CORTO, BOBINA RECALENTADA, RODAMIENTOS FATIGADOS. SE REALIZA MANTENIMIENTO , LUBRICACIÓN Y LIMPIEZA GENERAL.', 0.0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'INDUCIDO', NULL, 0),
  (@cotizacion_id, 2, NULL, 1.0, 'CAMPO', NULL, 0),
  (@cotizacion_id, 3, NULL, 1.0, 'ESCOBILLAS', NULL, 0),
  (@cotizacion_id, 4, NULL, 1.0, 'ANILLO PESO MUERTO', NULL, 0),
  (@cotizacion_id, 5, NULL, 1.0, 'BUMPER', NULL, 0),
  (@cotizacion_id, 6, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0529 (hoja original: 529-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('LUIS CARLOS ARIAS', NULL, NULL, NULL, '3102163316', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO ROTOMARTILLO 05 SDS PLUS 1500 WTS', 'TOTAL', 'UTH1153226', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0529', @articulo_id, 'INGRESO', 'EQUIPO MUY CALIENTE Y HUELE QUEMADO. INGRESA POR GARANTÍA CV No. 0500', '2025-10-15 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0528 (hoja original: 528-ENTREGADA-PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JULIAN QUINTERO', 'GREEN WALL SAS', NULL, NULL, '3142236250', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'CORTASETOS', 'MAKITA', 'DUH751', '0003354Y');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0528', @articulo_id, 'ENTREGADA-PAGADA', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA ENCIENDE, CON ATASCAMEINTO, FRACTURA DE RODAMIENTO', 33500.0, 33500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'RODAMIENTO 608', 10000.0, 10000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'SERVICIO MANO DE OBRA', 23500.0, 23500.0);

-- ===== OT 0527 (hoja original: 527-PTE PRECIOS) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JORGE', 'LUSH DETAILING', NULL, NULL, '3106976231', 'CR 45 A # 131 - 36');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'SHINE MATE', 'NO REGISTRA', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0527', @articulo_id, 'PTE PRECIOS', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA CON INDUCIDO EN CORTO. SE REALIZA MANTENIMIENTO, LUBRICACIÓN Y LIMPIEZA GENERAL.', 31500.0, 31500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'INDUCIDO', NULL, 0),
  (@cotizacion_id, 2, NULL, 1.0, 'ESCOBILLAS', NULL, 0),
  (@cotizacion_id, 3, '682559-5', 1.0, 'PASACABLE', 8000.0, 8000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0526 (hoja original: 526-NO AUTORIZADA-entregada) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('SILVIA', 'PINTOR ELÉCTROSTATICO', '900346300-5', 'facturacionpintorelectro@gmail.com', '3222115144', 'CR 47 132 21');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'MAKITA', '9046', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0526', @articulo_id, 'NO AUTORIZADA-entregada', 'MAQUINA ENCIENDE E INDUCIDO EN CORTO', '2025-10-14 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'INDUCIDO EN CORTO, ESCOBILLAS NO ORIGINALES CAUSAN LA FALLA DEL EQUIPO. SE REALIZA MANTENIMIENTO, LUBRICACIÓN Y LIMPIEZA GENERAL.', 371100.0, 371100.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'INDUCIDO', 317000.0, 317000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'ESCOBILLAS', 22600.0, 22600.0),
  (@cotizacion_id, 3, NULL, 2.0, 'TAPA ESCOBILLAS', 4000.0, 8000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0),
  (@cotizacion_id, 5, NULL, 1, 'EL INDUCIDO ESTA AGOTADO, EL TIEMPO DE IMPORTACIÓN ES DE 30 A 90 DÍAS.', NULL, 0);

-- ===== OT 0525 (hoja original: 525-ENTRTEGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('GUSTVA ORTIZ', 'SERVI HIDRAULICOS', '901170174-1', 'SERVIHIDRAULICOSGOT@HOTMAIL.COM', '3015791770', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'DEMOLEDOR', 'TOTAL', 'UTH215456', '24183840740');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0525', @articulo_id, 'ENTRTEGADA Y PAGADA', 'INGRESA CON ESTUCHE PLÁSTICO Y 2 CINCELES', '2025-10-10 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'REPARACIÓN ELÉCTRICA Y LIMPIEZA', 23500.0, 23500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0524 (hoja original: 524-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('VICTOR SOLORZANO', 'TECNO HIDRAHULICA EXPRESS', '900777215-6', 'TECNIHIDRAHULICAEXPRESS@GMAIL.COM', '3202737874', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'MULTIHERRAMIENTA INALAMBRICA OSCILANTE 20V', 'TOTAL', 'TMLI2001', '20121220114');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0524', @articulo_id, 'INGRESO', 'SIN ACCESORIOS', '2025-10-10 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'NO ACCIONA OSCILANTE', 151500.0, 151500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'CONJUNTO VENTILADOR Y RODAMIENTO', NULL, 28000.0),
  (@cotizacion_id, 2, NULL, 1, 'CAJA DE ENGRANAJES COMPLETA', NULL, 100000.0),
  (@cotizacion_id, 3, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE ORA', NULL, 23500.0);

-- ===== OT 0523 (hoja original: 523-LISTA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('SR MAURICIO REINA', 'DOBLADORA RYS', '900213000-1', 'dobladorarys@hotmail.com', '3143575809', 'calle 182 # 8d - 17');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4 1/2"', 'TOTAL', 'NO REGISTRA', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0523', @articulo_id, 'LISTA', 'INGRESA CON BRIDA Y TUERCA, EL EQUIPO NO PRENDE', CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'INDUCIDO EN CORTO DEBIDO A QUE TIENE UNAS ESCOBILLAS NO ORIGINALES. SE REALIZA MANTENIMIENTO, LUBRICACIÓN Y LIMPIEZA GENERAL.', 95500.0, 95500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'INDUCIDO', 60000.0, 60000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'ESCOBILLAS', 12000.0, 12000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0522 (hoja original: 522-REINTEGRO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('SR MAURICIO REINA', 'DOBLADORA RYS', '900213000-1', 'dobladorarys@hotmail.com', '3143575809', 'calle 182 # 8d - 17');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4 1/2"', 'MAKITA', '9557NB', '524511B');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0522', @articulo_id, 'REINTEGRO', 'INGRESA COPN 1 DISCO, BRIDA Y TUERCA. INFORMAN QUE EL BOTÓN DE ACCIONAMIENTO NO SE ACTIVA', CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'RODAMIENTO FATIGADOS, POR SOLICITUD DEL CLEINTE SE REALIZA COTIZACIÓN DE LA CARCAZA. SE REALIZA MANTENIMIENTO, LUBRICACIÓN Y LIMPIEZA GENERAL.', 82500.0, 82500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '143990-5', 1.0, 'CAJA MOTOR', 25000.0, 25000.0),
  (@cotizacion_id, 2, '419566-3', 1.0, 'BOTON HUELLERO', 1500.0, 1500.0),
  (@cotizacion_id, 3, NULL, 1.0, 'ESCOBILLAS', 16000.0, 16000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'RODAMIENTO 607', 12000.0, 12000.0),
  (@cotizacion_id, 5, '421868-5', 1.0, 'ANILLO RODAMIENTO', 4500.0, 4500.0),
  (@cotizacion_id, 6, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0521 (hoja original: 521-NO SE PUEDE REPARAR-ENTREGA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('NESTOR MALDONADO', NULL, NULL, NULL, '3182918367', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'RUTEADORA', 'CRAFTSMAN', '3202767', 'S1644@X00466');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0521', @articulo_id, 'NO SE PUEDE REPARAR-ENTREGA', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'LA MARCA NO MANEJA REFACCIONES EN COLOMBIA Y DEBIDO A ESTO NO SE PUEDE REPARAR EL EQUIPO.', 0.0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'INDUCIDO', NULL, 0),
  (@cotizacion_id, 2, NULL, 1.0, 'ESCOBILLAS', NULL, 0),
  (@cotizacion_id, 3, NULL, 1.0, 'SERVICIO MANO OBRA', NULL, 0);

-- ===== OT 0520 (hoja original: 520-LISTA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ARIAS DELGADILLO JULIAN YAHIR', 'ARIAS DELGADILLO JULIAN YAHIR', '1053347289-5', NULL, '3107034366', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'DEMOLEDOR', 'BOSCH', 'NO REGISTRA', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0520', @articulo_id, 'LISTA', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'INDUCIDO EN CORTO, EL CLIENTE ENTREGA EL REPUESTO PARA EL CAMBIO. SE REALIZA MANTENIMIENTO , LUBRICACIIÓN Y LIMPIEZA GENERAL.', 44500.0, 44500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'PASACABLE', 6000.0, 6000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'SERVICIO MANO OBRA', 38500.0, 38500.0);

-- ===== OT 0519 (hoja original: 519-LISTA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ARIAS DELGADILLO JULIAN YAHIR', 'ARIAS DELGADILLO JULIAN YAHIR', '1053347289-5', NULL, '3107034366', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERCUTOR', 'MAKITA', 'DHP453', 'ILEGIBLE');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0519', @articulo_id, 'LISTA', 'INGRESA SIN BATERÍA', CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'FRACTURA EN VENTILADOR Y MOTOR RECLANETADO, MANTENIMIENTO GENERAL, LUBRICACIÓN Y LIMPIEZA', 153500.0, 153500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '629937-8', 1, 'MOTOR', NULL, 130000.0),
  (@cotizacion_id, 2, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 23500.0);

-- ===== OT 0518 (hoja original: 518-LISTA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ARIAS DELGADILLO JULIAN YAHIR', 'ARIAS DELGADILLO JULIAN YAHIR', '1053347289-5', NULL, '3107034366', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4 1/2', 'MAKITA', NULL, 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0518', @articulo_id, 'LISTA', 'INGRESA SIN BRIDA Y TUERCA', CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MANTENIMIENTO GENERAL, RODAMIENTOS CON FATIGA', 47500.0, 47500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'RODAMIENTO 607', 12000.0, 12000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'RODAMIENTO 629', 12000.0, 12000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', 23500.0, 23500.0),
  (@cotizacion_id, 4, '256486-8', 1.0, 'PIN', 0.0, 0);

-- ===== OT 0517 (hoja original: 517-LISTA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ARIAS DELGADILLO JULIAN YAHIR', 'ARIAS DELGADILLO JULIAN YAHIR', '1053347289-5', NULL, '3107034366', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4 1/2', 'DEWALT', 'DWE4212-B3', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0517', @articulo_id, 'LISTA', 'INGRESA SIN BRIDA Y TUERCA', CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA FUNCIONAL, GENERA MUCHA CHISPA, MAQUINA MANIPULADA ADAPTADA CON CARTON PARA PRESIONAR LA ESCOBILLAS', 82500.0, 82500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'ESCOBILLAS', NULL, 35000.0),
  (@cotizacion_id, 2, NULL, 1, 'RODAMIENTO 607', NULL, 12000.0),
  (@cotizacion_id, 3, NULL, 1, 'RODAMIENTO 6001', NULL, 12000.0),
  (@cotizacion_id, 4, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 23500.0);

-- ===== OT 0516 (hoja original: 516) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JONATHAN SAGA', NULL, NULL, NULL, NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ATORNILLADOR DE IMPACTO', 'DEWALT', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0516', @articulo_id, 'INGRESO', 'SIN ACCESORIOS', '2025-10-09 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'ESCOBILLAS DESGATADAS Y RECALENTADAS, INTERRUPTOR SIN VARIADOR DE VELOCIDAD', 236500.0, 236500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'N359999', 1, 'INTERRUPTOR', NULL, 177000.0),
  (@cotizacion_id, 2, 'N093746', 1, 'ESCOBILLAS', NULL, 36000.0),
  (@cotizacion_id, 3, NULL, 1, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', NULL, 23500.0);

-- ===== OT 0515 (hoja original: 515-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('GABRIEL', 'INGECONS INGENIEROS CONSTRUCTORES Y CONSULTORES S.A.S', '830512329-6', NULL, '3123868912', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'TOTAL', 'NO REGISTRA', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0515', @articulo_id, 'INGRESO', 'MAQUINA ENCIENDE', '2025-10-08 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0514 (hoja original: 514) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('TECMETALICOS', 'ORLANDO RUEDA', NULL, NULL, NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 9"', 'MAKITA', 'GA7060', '31474R');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0514', @articulo_id, 'INGRESO', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 22500.0, 22500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'SERVICIO MANO DE OBRA - BRIDA ATASCADA', NULL, 15000.0),
  (@cotizacion_id, 2, NULL, 1, 'BRIDA', NULL, 7500.0);

-- ===== OT 0513 (hoja original: 513-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('MARIA ISABEL BARRIOS', NULL, '52624362', 'mariai.barriosortiz@gmail.com', '3053150676', 'calle 131 a - 53 b 15');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'taladro', 'black & decker', 'bh100-b3', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0513', @articulo_id, 'INGRESO', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 23500.0, 23500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'SERVICIO DE MANTENIMINETO Y MANO DE OBRA', NULL, 23500.0);

-- ===== OT 0512 (hoja original: 512-ENTREGADA SIN REPARAR) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('OMAR CHAVES', NULL, '79295772', NULL, '3219810241', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO', 'MAKITA', 'M0801', '0070137K');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0512', @articulo_id, 'ENTREGADA SIN REPARAR', NULL, '2025-10-06 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'BOINA EN CORTO, ESCOBILLAS DESGASTADAS, PALANCA DE CAMBIOS DESGASTADA Y CON ATASCAMIENTO. SE REALIZA MANTENIMIENTO, LUBRICACIÓN Y LIMPIEZA GENERAL.', 175000.0, 175000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'CAMPO', 85500.0, 85500.0),
  (@cotizacion_id, 2, NULL, 1.0, 'SOPORTE INTERMEDIO', 45700.0, 45700.0),
  (@cotizacion_id, 3, NULL, 1.0, 'PALANCA DE CAMBIO', 3000.0, 3000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'ESCOBILLAS', 17300.0, 17300.0),
  (@cotizacion_id, 5, NULL, 1.0, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', 23500.0, 23500.0);

-- ===== OT 0511 (hoja original: 511-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('GABRIEL', 'INGECONS INGENIEROS CONSTRUCTORES Y CONSULTORES S.A.S', '830512329-6', NULL, '3123868912', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'TOTAL', 'UTH1153226', '25062481004');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0511', @articulo_id, 'ENTREGADA Y PAGADA', NULL, '2025-10-03 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA ENCIENDE, SE EVIDENCIA QUE EL EQUIPO HA TENIDO UN TRABAJO EXCESIVO, CONTAMINADA A UN 80%, PORTABROCAS DESGASTADO DEBIDO A LA FRINCCIÓN DE PARTICULAS (POLVILLO Y PALANQUEO), SE REALIZA MANTENIMIENTO, LUBRICACIÓN Y LIMPIEZA GENERAL.', 96500.0, 96500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'UTH110286-SP-11', 1.0, 'PORTABROCAS', 50000.0, 50000.0),
  (@cotizacion_id, 2, 'UTH1153226-SP-26', 2.0, 'ANILLO PESO MUERTO', 4000.0, 8000.0),
  (@cotizacion_id, 3, 'SERVMO', 1.0, 'SERVICIO MANO OBRA', 38500.0, 38500.0);

-- ===== OT 0510 (hoja original: 510-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ARNULFO CASTELLANOS', 'INGELDAC S A S', '900312212-9', 'acastellanos@ingeldac.com / info@ingeldac.com', '3115847860', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'TRUPER', 'ILEGIBLE', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0510', @articulo_id, 'ENTREGADA Y PAGADA', 'MAQUINA ENCIENDE', '2025-10-03 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA ENCIENDE, FALLA EN PALANCA DE CAMBIOS DE MODO, RODAMIENTOS FATIGADOS. SE REALIZA MANTENIMIENTO, LUBRICANCIÓN Y LIMPIEZA GENERAL.', 98500.0, 98500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'EXPT-0052', 1.0, 'KIT DE ANILLOS', 30000.0, 30000.0),
  (@cotizacion_id, 2, '210200-6', 1.0, 'RODAMIENTO 608', 10000.0, 10000.0),
  (@cotizacion_id, 3, '210102-6', 1.0, 'RODAMIENTO 6001', 10000.0, 10000.0),
  (@cotizacion_id, 4, 'EXPT-0051', 1.0, 'ESCOBILLAS', 20000.0, 20000.0),
  (@cotizacion_id, 5, NULL, 1.0, 'SERVICIO MANO OBRA', 28500.0, 28500.0);

-- ===== OT 0509 (hoja original: 509-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ARNULFO CASTELLANOS', 'INGELDAC S A S', '900312212-9', 'acastellanos@ingeldac.com / info@ingeldac.con', '3115847860', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4 1/2"', 'TRUPER', 'ERGO-458Q', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0509', @articulo_id, 'ENTREGADA Y PAGADA', 'NO PRENDE, INGRESA CON BRIDA Y GUARDA', '2025-10-03 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'LA MAQUINA NO ENCIENDE, INTERRUPTOR INTERMITENTE POR EXCESO DE POLVILLO INTERNO, ESCOBILLAS DESGASTADAS AL 90%. SE REALIZA MANTENIMIENTO, LUBRICACIÓN Y LIMPIEZA GENERAL.', 133500.0, 133500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'EXPT-0051', 1.0, 'ESCOBILLAS', 20000.0, 20000.0),
  (@cotizacion_id, 2, 'EXPT-0027', 1.0, 'INTERRUPTOR', 40000.0, 40000.0),
  (@cotizacion_id, 3, '210200-6', 2.0, 'RODAMIENTOS 608', 10000.0, 20000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0),
  (@cotizacion_id, NULL, 'EXPT-0014', 3.0, 'TUERCA 5/8', 5000.0, 15000.0),
  (@cotizacion_id, NULL, 'EXPT-0013', 3.0, 'BRIDA 5/8', 5000.0, 15000.0),
  (@cotizacion_id, 5, NULL, 1, 'EL INTERRUPTOR SE ENCUENTRA AGOTADO, APROXIMADAMENTE DE 8 A 10 DÍAS PARA QUE LLEGUE LA PIEZA.', NULL, 0);

-- ===== OT 0508 (hoja original: 508-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ARNULFO CASTELLANOS', 'INGELDAC S A S', '900312212-9', 'acastellanos@ingeldac.com / info@ingeldac.con', '3115847860', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4 1/2"', 'BLACK & DECKER', 'G720-B3', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0508', @articulo_id, 'ENTREGADA Y PAGADA', 'NO PRENDE', '2025-10-03 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'LA MAQUINA NO ENCIENDE, INTERRUPTOR INTERMITENTE, FALLA EN LA PALANCA Y SIN HUELLERO, ESCOBILLAS DESGASTADAS AL 50%. SE REALIZA MANTENIMIENTO, LUBRICACIÓN Y LIMPIEZA GENERAL.', 66500.0, 66500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'EXPT-0049', 1.0, 'HUELLERO', 10000.0, 10000.0),
  (@cotizacion_id, 2, 'EXPT-0050', 1.0, 'PALANCA HUELLERO', 6000.0, 6000.0),
  (@cotizacion_id, 3, '90604789', 1.0, 'INTERRUPTOR', 15000.0, 15000.0),
  (@cotizacion_id, 4, '90604792', 1.0, 'ESCOBILLAS', 12000.0, 12000.0),
  (@cotizacion_id, 5, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0507 (hoja original: 507-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ARNULFO CASTELLANOS', 'INGELDAC S A S', '900312212-9', 'acastellanos@ingeldac.com / info@ingeldac.com', '3115847860', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIUDORA 4 1/2"', 'TRUPER', 'ERGO-458Q', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0507', @articulo_id, 'ENTREGADA Y PAGADA', 'NO PRENDE', '2025-10-03 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'LA MAQUINA NO ENCIENDE POR FALLA ELÉCTRICA EN EL CABLE DE PODER, ESCOBILLAS DESGASTADAS AL 70%, RODAMIENTOS FATIGADOS. SE REALIZA MANTENIMIENTO, LUBRICACIÓN Y LIMPIEZA GENERAL.', 70500.0, 85500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'EXPT-0002', 1.0, 'CABLE DE PODER CHINO', 25000.0, 25000.0),
  (@cotizacion_id, 2, '15414', 1.0, 'ESCOBILLAS', 15000.0, 15000.0),
  (@cotizacion_id, 3, '210034-7', 1.0, 'RODAMIENTO 607', 12000.0, 12000.0),
  (@cotizacion_id, 4, '210200-6', 1.0, 'RODAMIENTO 608', 10000.0, 10000.0),
  (@cotizacion_id, 5, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0506 (hoja original: 506-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('HERMES MORENO', NULL, '194553345', NULL, '3174563345', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'SIERRA DE BANCO', 'EINHELL', 'TC-TS 2025/1 U', '2018/05/ECO-18-2013');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0506', @articulo_id, 'ENTREGADA Y PAGADA', 'DISCO, LLAVES FIJAS', '2025-10-02 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'EQUIPO NO ENCIENDE, INDUCIDO Y BOBINA EN CORTO Y RECALENTADO, CAJA CAMPO DERRETIDA A LA ALTURA DEL PORTAESCOBILLAS Y PORTAESCOBILLAS DERRETEDIDO. SE REALIZA MANTENIMIENTO, LUBRICACIPON Y LIMPIEZA GENERAL.', 400000.0, 400000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '4340492010651', 1.0, 'INDUCIDO', 210000.0, 210000.0),
  (@cotizacion_id, 2, '434054901053', 1.0, 'BOBINA', 60000.0, 60000.0),
  (@cotizacion_id, 3, '434054002075', 1.0, 'CAJA CAMPO', NULL, 40000.0),
  (@cotizacion_id, 4, '434054002070-2', 1.0, 'ESCOBILLAS', 20000.0, 20000.0),
  (@cotizacion_id, 5, '434054002071', 1.0, 'PORTAESCOBILLAS', 7500.0, 15000.0),
  (@cotizacion_id, 6, '210200-6', 1, 'RODAMIENTO 608', NULL, 12000.0),
  (@cotizacion_id, 7, 'SERVMO', 1.0, 'SERVICIO MANO OBRA', 43000.0, 43000.0);

-- ===== OT 0505 (hoja original: 505-ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ALEXANDER FRANCO', NULL, NULL, NULL, '3114449290', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'SKILL', '9004', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0505', @articulo_id, 'ENTREGADA', NULL, '2025-10-01 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA ENCIENDE, RODAMIENTO FATIGADO, SE DETECTA QUE LA BOBINA ESTA RECALENTADA. SE REALIZA MANTENIMIENTO, LUBRICACIÓN Y LIMPIEZA GENERAL.', 43500.0, 43500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'RODAMIENTO 6201', 20000.0, 20000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0504 (hoja original: 504-COT.ENV.) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('CLAUDIA MELO', NULL, NULL, NULL, '3005452825', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ASPIRADORA', 'ELECTROLUX', 'STK10', '0350499');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0504', @articulo_id, 'COT.ENV', 'EL EQUIPO SUENA FEO', '2025-10-01 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA ENCIENDE CON SONBIDO EXTRAÑO, SE EVIDENCIA FRACTURA DE RODAMIENTO, SE RElALIZA EL CAMBIO Y LIMPIEZA GENERAL.', 33500.0, 33500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'RODAMIENTO 697', 10000.0, 10000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'FILTRO X 2 OPCIONAL', 70000.0, 0),
  (@cotizacion_id, 3, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0503 (hoja original: 503-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('GUSTVA ORTIZ', 'SERVI HIDRAULICOS', '901170174-1', 'SERVIHIDRAULICOSGOT@HOTMAIL.COM', '3015791770', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'BOSH', 'GBH 2 24', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0503', @articulo_id, 'ENTREGADA Y PAGADA', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 178000.0, 178000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'CARCASA', NULL, 130000.0),
  (@cotizacion_id, 2, 'SP-26', 1, 'ANILLO RODAMIENTO', NULL, 7500.0),
  (@cotizacion_id, 3, NULL, 1, 'RODAMIENTO', NULL, 12000.0),
  (@cotizacion_id, 4, NULL, 1, 'MANTENIMIENTO Y MANO DE OBRA', NULL, 28500.0);

-- ===== OT 0502 (hoja original: 502-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('RAFAEL SOPO', NULL, '79311572', NULL, '3103413826', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'MAKITA', 'GA4530', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0502', @articulo_id, 'ENTREGADA Y PAGADA', 'GUARDA Y SUENA FEO AL ENCENDER', '2025-10-01 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA CON INDUCIDO EN CORTO, SE REQUIERE CAMBIAR LA PIEZA ORIGINAL JUNTO CON LAS ESCOBILLAS PARA EL CORRECTO FUNCIONAMIENTO DEL EQUIPO. SE REALIZA MANTENIMIENTO, LUBRICACIÓN Y MANTENIMIENTO GENERAL.', 163500.0, 163500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '517646-0', 1.0, 'INDUCIDO', 125000.0, 125000.0),
  (@cotizacion_id, 2, '195025-8', 1.0, 'ESCOBILLAS', 15000.0, 15000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0501 (hoja original: 501-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('GERMAN BARBOSA', NULL, '80429070', 'g_barbosacctv@hotmail.com', '3046798941', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'MAKITA', 'HR2470', '2694993Y');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0501', @articulo_id, 'ENTREGADA Y PAGADA', 'MAQUINA EN CORTO', '2025-10-01 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA CON INDUCIDO EN CORTO, FALTA DE MANTENIMIENTO, GRASA DETERIORADA. SE REQUIERE CAMBIAR LA PIEZA ORIGINAL JUNTO CON LAS ESCOBILLAS PARA EL CORRECTO FUNCIONAMIENTO DEL EQUIPO. SE REALIZA MANTENIMIENTO, LUBRICACIÓN Y MANTENIMIENTO GENERAL.', 299000.0, 299000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '515286-8', 1.0, 'INDUCIDO', 230500.0, 230500.0),
  (@cotizacion_id, 2, '195001-2', 1.0, 'ESCOBILLAS', 16000.0, 16000.0),
  (@cotizacion_id, 3, '213227-5', 1.0, 'ANILLO PESO MUERTO', 4000.0, 4000.0),
  (@cotizacion_id, 4, '417629-9', 1.0, 'CAPUCHON', 5000.0, 5000.0),
  (@cotizacion_id, 5, '286263-4', 1.0, 'BUMPER', 5000.0, 5000.0),
  (@cotizacion_id, 6, '210200-6', 1.0, 'RODAMIENTO 608', 10000.0, 10000.0),
  (@cotizacion_id, 7, 'SERVMO', 1.0, 'SERVICIO MANO OBRA', 28500.0, 28500.0);

-- ===== OT 0500 (hoja original: 500-REINGRES0) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('FERNANDO LOZANO', NULL, '1116992910', 'fercho9671@hotmail.com', '3202760158', 'CLL 128C #46A-25');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'LIJADORA', 'BOSCH', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0500', @articulo_id, 'REINGRES0', 'LA MAQUINA NO ENCIENDE, LLEGA DESTAPADA', '2025-10-01 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA NO ENCIENDE DEBIDO A FALLAS EN EL PORTAESCOBILLAS Y ESCOBILLAS, RODAMIENTOS CON FATIGA. SE REALIZA MANTENIMIENTO Y LIMPIEZA GENERAL. LAS PIEZAS OPCIONALES PUEDEN PRESENTAR FALLAS EN UN FUTURO ES RECOMENDABLE REALIZAR EL CAMBIO, SIN EMBARGO NO ES NECESARIO CAMBIARLAS DEBIDO A QUE LA MAQUINA QUEDARIA FUNCIONAL.', 70500.0, 70500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 2.0, 'RODAMIENTO 608', 10000.0, 20000.0),
  (@cotizacion_id, 3, 'EXPT-0045', 1.0, 'ESCOBILLAS + PORTAESCOBILLAS', 27000.0, 27000.0),
  (@cotizacion_id, 5, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'REINGRES0', 'REINGRESO 9/12/2025');

-- ===== OT 0449 (hoja original: 449-NO SE PUEDE REPARAR-COT.ENV) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('GUILLERMO', NULL, '79302114', NULL, '3193451357', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'LLAVE DE IMPACTO 20V', 'SIEFKEN', 'NO REGISTRA', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0449', @articulo_id, 'NO SE PUEDE REPARAR-COT.ENV', 'INGRESA EN MALETA DE TELA ROJA CON UNA BATERÍA DE 4.0 AH Y UN CARGADOR 20V', '2025-09-27 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA CON INTERVENCIONES ANTERIORES MAL REALIZADAS, CABLEADO RASGADO Y PLACA ELÉCTRONICA CON MODIFICACIONES, TENER EN CUENTA QUE DE ESTA MARCA NO SE MANEJAN REFACCIONES DEBIDO A LO ANTERIOR NO SE PUEDE RERALIZAR LA REPARACION.', 0.0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();

-- ===== OT 0448 (hoja original: 448-PTE LA GARANTÍA CON HOYOS) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('LUIS CARLOS ARIAS', NULL, '1010185191', NULL, '3102163316', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'TOTAL', 'UTH1153226', '25180090862');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0448', @articulo_id, 'PTE LA GARANTÍA CON HOYOS', 'INGRESA POR GARANTÍA - COMPROBANTE DE VENTA No. 0427. INGRESA CON ESTUCHE PLÁSTICO, 2 CENCELES UNO DE PALA Y OTRO DE PUNTA, EL EQUIPO ESTA QUEMADO', '2025-09-26 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0447 (hoja original: 447-ENTREGADA Y PTE DE PAGO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('TECNIMOTOR JP', 'TECNIMOTOR JP', NULL, NULL, '3124538636 - 3102044256', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'BOSCH', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0447', @articulo_id, 'ENTREGADA Y PTE DE PAGO', NULL, '2025-09-26 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA ENCIENDE, NO PERCUTA DEBIDO A QUE EL EJE DE TRANSMISIÓN ESTA DESGASTADO.', 138500.0, 138500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'EXPT-0028', 1.0, 'BUJE DE AGUJAS', 10000.0, 10000.0),
  (@cotizacion_id, 2, 'EXPT-0026', 1.0, 'EXENTRICA', 50000.0, 50000.0),
  (@cotizacion_id, 3, 'EXPT-0029', 1.0, 'EJE', 30000.0, 30000.0),
  (@cotizacion_id, 4, 'EXPT-0023', 1.0, 'ANILLO PESO MUERTO', 3000.0, 3000.0),
  (@cotizacion_id, 5, '211491-2', 1.0, 'RODAMIENTO 609', 12000.0, 12000.0),
  (@cotizacion_id, 6, NULL, 1.0, 'BOTON CAMBIOS', 15000.0, 0),
  (@cotizacion_id, 7, 'UTH1153226-SP-1', 1.0, 'CAPUCHON', 5000.0, 5000.0),
  (@cotizacion_id, 8, 'SERVMO', 1.0, 'SERVICIO MANO OBRA', 28500.0, 28500.0);

-- ===== OT 0446 (hoja original: 446-NO AUTORIZADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('HELVERT MELO', NULL, NULL, NULL, '3197388423', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'STANLEY', 'STEL503-B3', '2016-38-58');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0446', @articulo_id, 'NO AUTORIZADA', NULL, '2025-09-25 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA CON INDUCIDO EN CORTO, ESCOBILLAS RECALENTADAS, SE REALIZA MANTENIMIENTO Y LIMPIEZA GENERAL.', 248500.0, 248500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'INDUCIDO', 160000.0, 160000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'ESCOBILLAS', 35000.0, 35000.0),
  (@cotizacion_id, 3, NULL, 2.0, 'PORTAESCOBILLAS', 10000.0, 20000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'ANILLO PESO MUERTO', 5000.0, 5000.0),
  (@cotizacion_id, 5, NULL, 1.0, 'SERVICIO MANO OBRA', 28500.0, 28500.0);

-- ===== OT 0445 (hoja original: 445-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('jose', 'AUTOSAFE', NULL, NULL, NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4 1/2"', 'STANLEY', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0445', @articulo_id, 'ENTREGADA Y PAGADA', 'BRIDA Y TUERCA', '2025-09-25 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA NO ENCIENDE,PIÑONERIA DESGASTADA.', 15000.0, 15000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'REPARACIÓN ELÉCTRICA', 15000.0, 15000.0);

-- ===== OT 0444 (hoja original: 444-entregado ok) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('WILSON MORENO', NULL, '79344964', NULL, '3219178550', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'CHINA', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0444', @articulo_id, 'entregado ok', NULL, '2025-09-25 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA INGRESA DESARMANDA, RODAIENTO FRACTURADO, SE REALIZA MANTENIMIENTO, LUBRICACIÓN Y LIMPIIEZA GENERAL.', 53500.0, 53500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'RODAMIENTO 6000', 8000.0, 8000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'RODAMIENTO 608', 12000.0, 12000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'ESCOBILLAS CHINAS', 8000.0, 8000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'TAPA ESCOBILLA', 2000.0, 2000.0),
  (@cotizacion_id, 5, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0443 (hoja original: 443-NO JUSTIFICA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ELKIN CARDENAS', 'SEGARA CONSTRUCCIONES Y DECORACIONES S.A.S', '901733364-1', NULL, '3155526940', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO 680W (1/2") CON PERCUTOR', 'TOTAL', 'UTG1061356', '23254710361');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0443', @articulo_id, 'NO JUSTIFICA', 'EL CLIENTE INFORMA QUE NO ENCIENDE', '2025-09-25 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0442 (hoja original: 442-PTE REPUESTOS) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ELKIN CARDENAS', 'SEGARA CONSTRUCCIONES Y DECORACIONES S.A.S', '901733364-1', NULL, '3155526940', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'BOSCH', 'GBH 2-24 D', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0442', @articulo_id, 'PTE REPUESTOS', 'EL CLIENTE INFORMA QUE LA HERRAMIENTA NO TIENE FUERZA', '2025-09-25 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 367700.0, 367700.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'EXPT-0044', 1.0, 'ORING PESO MUERTO', 15000.0, 15000.0),
  (@cotizacion_id, 2, 'EXPT-0043', 1.0, 'CAJA CAMPO', 279000.0, 279000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'ESCOBILLAS', 33200.0, 33200.0),
  (@cotizacion_id, 4, NULL, 1.0, 'RODAMIENTOS', 12000.0, 12000.0),
  (@cotizacion_id, 5, NULL, 1.0, 'SERVICIO MANO OBRA', 28500.0, 28500.0);

-- ===== OT 0441 (hoja original: 441-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('AUTO SAFE S.A', 'AUTO SAFE S.A', '811034722-8', 'info@autosafe.com.co', NULL, 'CR 23 71 A 36');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA NEUMATICA', 'APAC', 'NO REGISTRA', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0441', @articulo_id, 'INGRESO', NULL, '2025-09-25 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'SE EVIDENCIA HERRAMIENTA CON PIÑON SPICK Y PIÑON CORONA DAÑADO.', 0.0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'INGRESO', 'ENTREGA 17/04/2026'),
  (@orden_id, 'INGRESO', 'CV.1595');

-- ===== OT 0440 (hoja original: 440-INGRESO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('WILSON MORENO', NULL, '79344964', NULL, '3219178550', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'BLACK & DECKER', 'G720-B3', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0440', @articulo_id, 'INGRESO', 'EL EQUIPO NO ENCIENDE, CABLE DE PODER AVERIADO', '2025-09-25 00:00:00');
SET @orden_id = LAST_INSERT_ID();

-- ===== OT 0439 (hoja original: 439-LISTA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('HENRY PINEDA ARQUITECTOS ASOCIADOS SAS', 'HENRY PINEDA ARQUITECTOS ASOCIADOS SAS', '900948143-9', 'pinedaarq@hotmail.com', '3118988810', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'NIVEL LASER', 'DEWALT', 'DW087', '419248');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0439', @articulo_id, 'LISTA', 'EL EQUIPO NO ENCIENDE, INGRESA EN ESTUCHE PLÁSTICO Y SUS 3 PILAS.', '2025-09-25 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'EQUIPO NO ENCIENDE Y SE EVIDENCIA QUE NO LE LLEGA VOLTAJE DEBIDO A QUE LAS TERMINALES ESTAN EN MAL ESTADO. SE REALIZARIA EL INTENTO DE RESCATAR EL EQUIPO MANDANDO A FABRICAR LOS TERMINALES ESPERANDO QUE EL RESULTADO SEA POSITIVO.', 113500.0, 113500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'ADAPTACIÓN DE RESORTES TERMINALES', 90000.0, 90000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0438 (hoja original: 438-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('HENRY PINEDA ARQUITECTOS ASOCIADOS SAS', 'HENRY PINEDA ARQUITECTOS ASOCIADOS SAS', '900948143-9', 'pinedaarq@hotmail.com', '3118988810', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'BOSCH', 'GBH 2-20 D', '902051576');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0438', @articulo_id, 'ENTREGADA Y PAGADA', 'EL EQUIPO ENCIENDE, EL CLIENTE INDFORMA QUE ES PARA MANTENIMIENTO', '2025-09-25 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'EQUIPO ENCIENDE, FUNCIONAL, CON MUCHA VIBRACIÓN, SE REALIZA EL CAMBIO DEL ANILLO, MANTENIMIENTO Y LIMPIEZA GENERAL.', 30500.0, 30500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'ANILLO', 2000.0, 2000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'SERVICIO MANO OBRA', 28500.0, 28500.0);

-- ===== OT 0437 (hoja original: 437-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('HENRY PINEDA ARQUITECTOS ASOCIADOS SAS', 'HENRY PINEDA ARQUITECTOS ASOCIADOS SAS', '900948143-9', 'pinedaarq@hotmail.com', '3118988810', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'BOSCH', 'GBH 2-20 D', '806055492');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0437', @articulo_id, 'ENTREGADA Y PAGADA', 'EL EQUIPO ENCIENDE, EL CLIENTE INFORMA QUE ES PARA MANTENIMIENTO', '2025-09-25 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'EQUIPO FUNCIONAL SOLO SE REALIZA MANTENIMIENTO Y LIMPIEZA GENERAL.', 28500.0, 28500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'SERVICIO MANO OBRA', 28500.0, 28500.0);

-- ===== OT 0436 (hoja original: 436-COT. ENV.) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('HENRY PINEDA ARQUITECTOS ASOCIADOS SAS', 'HENRY PINEDA ARQUITECTOS ASOCIADOS SAS', '900948143-9', 'pinedaarq@hotmail.com', '3118988810', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERCUTOR', 'MILWAUKEE', '2404-20', 'E28DO14497763');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0436', @articulo_id, 'COT. ENV', 'EL EQUIPO ENCIENDE, EL CLIENTE INDFORMA QUE ES PARA MANTENIMIENTO, INGRESA CON EL CARGADOR 48-59-2401 Y 3 BATERÍAS 12 V.', '2025-09-25 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA CON FUNCIONAMIENTO INTERMITENTE POR FALLA ELÉCTRONICA, TENER PRESENTE QUE LA MARCA SOLO DISTRIBUYE LA PIEZA COMPLETA Y POR ESO EL COSTO TAN ELEVADO.', 503500.0, 503500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'MODULO + INTERRUPTOR + STATOR', 480000.0, 480000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0435 (hoja original: 435-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JORGE', 'LUSH DETAILING', NULL, NULL, '3106976231', 'CR 45 A # 131 - 36');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'POLICHADORA', 'MAKITA', '9237CB', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0435', @articulo_id, 'ENTREGADA Y PAGADA', NULL, '2025-09-24 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA ENCIENDE PERO ARROJA MUCHA CHISPA DEBIDO A QUE UNA DELGA DEL INDUCIDO TIENE UNA DEFORMACIÓN POR ALTAS TEMPERATURAS.', 317500.0, 317500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '516306-1', 1.0, 'INDUCIDO', 265000.0, 265000.0),
  (@cotizacion_id, 2, '194996-6', 1.0, 'ESCOBILLAS', 17000.0, 17000.0),
  (@cotizacion_id, 3, '210067-2', 1.0, 'RODAMIENTO 6000', 12000.0, 12000.0),
  (@cotizacion_id, 4, 'SERVMO', 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0434 (hoja original: 434-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('MAGIVISION INTERAKTO SAS', 'MAGIVISION INTERAKTO SAS', '860509847-8', NULL, '3125199366', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'RUTEADORA', 'FESTOOL', 'OF 1400 EQ', '13758');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0434', @articulo_id, 'ENTREGADA Y PAGADA', 'CON FRESA ATASCADA,', '2025-09-24 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA FUNCIONAL, INTERVENIDA ANTERIORMENTE Y SE EVIDENCIA QUE MODIFICARON EL VARIADOR DE VELOCIDAD, TENER EN CUENTA QUE ESTA MARCA NO TIENE REPRESENTACION EN REPUESTOS, SE REALIZA MANTENIMIENTO Y LIMPIEZA GENERAL.', 28500.0, 28500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'SERVICIO MANO DE OBRA', 28500.0, 28500.0);

-- ===== OT 0433 (hoja original: 433-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('MAGIVISION INTERAKTO SAS', 'MAGIVISION INTERAKTO SAS', '860509847-8', NULL, '3125199366', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'RUTEADORA', 'DEWALT', 'DWP690 TYPE 1', '999410');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0433', @articulo_id, 'ENTREGADA Y PAGADA', 'TUERCA Y COLLECT SIN BASE ACRILICA', '2025-09-24 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA FUNCIONAL,  RODAMIENTOS FATIGADOS, ESCOBILLAS CON DESGASTE,  SE REALIZA MANTENIMIENTO Y LIMPIEZA GENERAL.', 118500.0, 118500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'N030459', 1.0, 'ESCOBILLAS', 30000.0, 30000.0),
  (@cotizacion_id, 2, '608-2RSH/C3S', 1.0, 'RODAMIENTO DEL INDUCIDO', 30000.0, 30000.0),
  (@cotizacion_id, 3, '211228-7', 1.0, 'RODAMIENTO 6202 DEL INDUCIDO', 30000.0, 30000.0),
  (@cotizacion_id, 4, 'SERVMO', 1.0, 'SERVICIO MANO OBRA', 28500.0, 28500.0);

-- ===== OT 0432 (hoja original: 432-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('OSCAR AYALA', NULL, '79125214', NULL, '3106588801 - 3106252195', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO 1/2"', 'GENERICO POWER ACTION', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0432', @articulo_id, 'ENTREGADA Y PAGADA', 'SIN ACCESORIOS', '2025-09-24 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'EQUIPO CON ESCOBILLAS DESGASTADAS Y NO GENERAN BUEN CONTACTO, SE REALIZA MANTENIMIENTO, LUBRICACIÓN Y LIMPIEZA GENERAL.', 28500.0, 28500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'ESCOBILLAS', 5000.0, 5000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0431 (hoja original: 431-ENTREGADA SIN REPARAR) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('OSCAR AYALA', NULL, '79125214', NULL, '3106588801 - 3106252195', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ATORNILLADOR 8 V', 'BLACK&DECKER', 'LD008 TYPE 1', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0431', @articulo_id, 'ENTREGADA SIN REPARAR', 'MAQUINA Y CARGADOR', '2025-09-24 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA NO ENCIENDE, DEBIDO A QUE NO ALMACENA LA CARGA DEBIDO A LA MALA MANIOULACIPON EN EL TERMINAL DE CARGA, SE REALIZARIA MANTENIMEINTO Y LIMPIEZA GENERAL.', 98500.0, 98500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'PLACA ELÉCTRONICA + INTERRUPTOR', 75000.0, 75000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0430 (hoja original: 430-ENTREGADA SIN REPARAR) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('OSCAR AYALA', NULL, '79125214', NULL, '3106588801 - 3106252195', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ATORNILLADOR 9,6 V', 'BLACK&DECKER', 'CD961B3 TYPE 3', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0430', @articulo_id, 'ENTREGADA SIN REPARAR', 'UNA BATERIA Y CARGADOR', '2025-09-24 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA NO ENCIENDE, MOTOR RECALENTADO Y BATERÍA POR SUS CELDAS EN NICD YA NO ALMACENAN CARGA. POR SER UN MODELO ANTIGUO YA NO SE CONSIGUEN REPUESTOS.', 0.0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'BATERÍA', 0.0, 0),
  (@cotizacion_id, 2, NULL, 1.0, 'MOTOR', 0.0, 0);

-- ===== OT 0429 (hoja original: 429-ENTREGADA Y PTE PAGO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('LUIS', 'ARAR REPRESENTACIONES + SISTEMAS SAS', '830128661-0', NULL, '3102961407', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ASPIRADORA', 'KARCHER', 'DS5500', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0429', @articulo_id, 'ENTREGADA Y PTE PAGO', 'EL CLIENTE INFORMA QUE ES PARA REVISIÓN ELÉCTRICA, INGRESA CON MANGUERA.', '2025-09-23 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 55000.0, 55000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'W01331640265', 1.0, 'FILTRO', 20000.0, 20000.0),
  (@cotizacion_id, 2, 'SERVMO', 1.0, 'SERVICIO MANO OBRA', 35000.0, 35000.0);

-- ===== OT 0428 (hoja original: 428-ENTREGADA Y PTE PAGO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('LUIS', 'ARAR REPRESENTACIONES + SISTEMAS SAS', '830128661-0', NULL, '3102961407', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ASPIRADORA', 'KARCHER', 'WD.3.250', '028086');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0428', @articulo_id, 'ENTREGADA Y PTE PAGO', 'EL CLIENTE INFORMA QUE ES PARA REVISIÓN ELÉCTRICA, INGRESA CON MANGUERA.', '2025-09-23 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 35000.0, 35000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'SERVMO', 1.0, 'SERVICIO MANO OBRA', 35000.0, 35000.0);

-- ===== OT 0427 (hoja original: 427-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('LUIS', 'ARAR REPRESENTACIONES + SISTEMAS SAS', '830128661-0', NULL, '3102961407', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'GUADAÑA', 'HUSQVARNA', '543RS', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0427', @articulo_id, 'ENTREGADA Y PAGADA', 'EL CLIENTE INFORMA QUE ES PARA CAMBIAR LA CUERDA  DEL YOYO.', '2025-09-23 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA CON FRACTURA DE TAPA DE YOYO, GENERANDO DAÑO EN PIEZAS ADICIONALES, TENER PRESENTE QUE ESTA PIEZA LA VENDEN COMPLETA. ESTAMOS A LA ESPERA DE QUE EL IMPORTADORA NOS CONFIRME DISPONIBILIDAD, ACTUALMENTE AGOTADAS.', 355000.0, 355000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '528706201', 1.0, 'YOYO', 150000.0, 150000.0),
  (@cotizacion_id, 2, '579111101', 1.0, 'ACOPLE CAMPANA', 150000.0, 150000.0),
  (@cotizacion_id, 3, 'EXPT-0071', 1.0, 'MANGUERAS ALIMENTACIÓN', 20000.0, 20000.0),
  (@cotizacion_id, 5, 'SERVMO', 1.0, 'SERVICIO MANO', 35000.0, 35000.0);

-- ===== OT 0426 (hoja original: 426-ENTREGADA-PTE PAGO) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('COMERCIALIZADORA CASTAÑO CARDOZO', 'COMERCIALIZADORA CASTAÑO CARDOZO', '900590296-8', NULL, '7257653', 'CLL 134 # 45B-57 Local 3');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'TOTAL', 'NO REGISTRA', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0426', @articulo_id, 'ENTREGADA-PTE PAGO', 'NO ENCIENDE, CABLE DE PODER AVERIADO', '2025-09-23 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA NO ENCIENDE, CABLE EN CORTO, INTERRUPTOR CON PASO DE CORRIENTE INTERRUMPIDO POR EXCESO DE POLVILLO. SE REALIZA CAMBIO DE LAS PIEZAS PARA GARANTIZAR SU CORRECTO FUNCIONAMIENTO Y MANTENIMIENTO Y LIMPIEZA GENERAL.', 108500.0, 108500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'UTG1252306-SP45/48/49', 1.0, 'INTERRUPTOR', 35000.0, 35000.0),
  (@cotizacion_id, 2, '664891-9', 1.0, 'CABLE MAKITA', 50000.0, 50000.0),
  (@cotizacion_id, 3, 'SERVMO', 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0425 (hoja original: 425-AUTORIZADA-PTE REF.) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('TECNIMOTOR JP', 'TECNIMOTOR JP', NULL, NULL, '3124538636 - 3102044256', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'ELITE', 'NO LEGIBLE', 'M26040233');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0425', @articulo_id, 'AUTORIZADA-PTE REF', NULL, '2025-09-22 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'SE EVIDENCIA QUE LA HERRAMIENTA NO ENCIENDE, ESCOBILLAS DESGASTADAS NO GENERAN CONTACTO CON EL COLECTOR, SE REALIZARIA EL CAMBIO DE LOS REPUESTOS NECESARIOS PARA GARANTIZAR EL CORRECTO FUNCIONAMIENTO DEL EQUIPO, MANTENIMIENTO, LUBRICACIÓN Y LIMPIEZA GENERAL.', 96500.0, 96500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'ESCOBILLAS', 38000.0, 38000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'KIT DE ANILLOS x 5', 30000.0, 30000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'SERVICIO MANO OBRA', 28500.0, 28500.0);

-- ===== OT 0424 (hoja original: 424-ENTREGADA SIN REPARAR) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('TECNIMOTOR JP', 'TECNIMOTOR JP', NULL, NULL, '3124538636 - 3102044256', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'MILWAUKEE', '2612-20', '14500480');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0424', @articulo_id, 'ENTREGADA SIN REPARAR', 'INGRESA CON UN CARGADOR 48-59-1812  Y UNA BATERÍA 4.0 AH', '2025-09-22 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA NO ENCIENDE DEBIDO A QUE LAS ESCOBILLAS YA FINALIZARON SU VIDA UTIL, SE REALIZARIA MANTENIMIENTO, LUBRICACIÓN Y LIMPIEZA GENERAL.', 143500.0, 143500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'BULOM', 17000.0, 17000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'BUMPER', 7000.0, 7000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'PORTA ESCOBILLAS Y ESCOBILLAS', 45000.0, 45000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'ANILLO', 15000.0, 15000.0),
  (@cotizacion_id, 5, NULL, 1.0, 'RETENEDOR', 14000.0, 14000.0),
  (@cotizacion_id, 6, NULL, 1.0, 'EMPAQUE', 17000.0, 17000.0),
  (@cotizacion_id, 7, NULL, 1.0, 'SERVICIO MANO OBRA', 28500.0, 28500.0);

-- ===== OT 0423 (hoja original: 423-COT.ENV.-PTE RESPUESTA CLIE) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('CARLOS VALDERRAMA', 'POLIPASTOS Y PUENTES GRUA INGEVAL SAS', '900584921-9', NULL, '3138367928', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'MAKITA', 'GA7063R', '1037Y');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0423', @articulo_id, 'COT.ENV.-PTE RESPUESTA CLIE', NULL, '2025-09-20 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA CON EL INDUCIDO EN CORTO, SE REALIZA EL CAMBIO DE LOS REPUESTOS NECESARIOS PARA SU CORRECTO FUNCIONAMIENTO, SE REALIZA MANTENIMIENTO , LUBRICACIÓN Y LIMPIEZA GENERAL.', 500000.0, 500000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '513447-4', 1.0, 'INDUCIDO', 400000.0, 400000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'ESCOBILLAS', 20000.0, 20000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'CABLE DE PODER', 56500.0, 56500.0),
  (@cotizacion_id, 4, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'COT.ENV.-PTE RESPUESTA CLIE', '197128-4');

-- ===== OT 0422 (hoja original: 422-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('AUTO SAFE S.A', 'AUTO SAFE S.A', '811034722-8', 'info@autosafe.com.co', NULL, 'CR 23 71 A 36');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO DE IMPACTO', 'BOSCH', 'GSB 19-2 RE', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0422', @articulo_id, 'ENTREGADA Y PAGADA', 'EL CLIENTE INFORMA QUE NO ENCIENDE', '2025-09-22 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'SE EVIDENCIA QUE LA MAQUINA NO ENCIENDE, INTERRUPTOR CON PASO DE CORRIENTE INTERRUMPIDA. SE REALIZA MANTEMIENTO Y LIMPIEZA GENERAL.', 23500.0, 23500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'INTERRUPTOR', NULL, 0),
  (@cotizacion_id, 2, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0421 (hoja original: 421-ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('GUSTAVO BARRERA', 'INDENSA ING SAS', '901291142-3', 'indensa.ing@gmail.com', '3108091745', 'CR 53D # 127D-53');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4 1/2', 'TRUPER', 'NO REGISTRA', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0421', @articulo_id, 'ENTREGADA', 'INGRESA SIN INTERRUPTOR', '2025-09-19 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 65500.0, 65500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'Ecobillas', NULL, 14000.0),
  (@cotizacion_id, 2, NULL, 1, 'Rodamiento 607', NULL, 12000.0),
  (@cotizacion_id, 3, NULL, 1, 'Set Porta escobillas', NULL, 16000.0),
  (@cotizacion_id, 4, NULL, 1, 'Servicio mantenimiento y mano de obra', NULL, 23500.0);

-- ===== OT 0420 (hoja original: 420-ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('GUSTAVO BARRERA', 'INDENSA ING SAS', '901291142-3', 'indensa.ing@gmail.com', '3108091745', 'CR 53D # 127D-53');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4 1/2', 'TRUPER', 'ESMA-41/2A9', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0420', @articulo_id, 'ENTREGADA', 'INGRESA SIN INTERRUPTOR', '2025-09-19 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'cable de poder en corto, rodamientos con fatiga, sin pasa cable y escobillas desgastadas, limieza y mantenimineto general.', 49500.0, 49500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 2, NULL, 1.0, 'rodamiento 608', 12000.0, 12000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'escobillas', 14000.0, 14000.0),
  (@cotizacion_id, 5, NULL, 1.0, 'mantenimiento ,mano de obra , limpieza', 23500.0, 23500.0);

-- ===== OT 0419 (hoja original: 419-ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('GUSTAVO BARRERA', 'INDENSA ING SAS', '901291142-3', 'indensa.ing@gmail.com', '3108091745', 'CR 53D # 127D-53');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4 1/2', 'TRUPER', 'NO REGISTRA', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0419', @articulo_id, 'ENTREGADA', NULL, '2025-09-19 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'maquina no enciende, se realiza reparaci´electrica, inducio recalentado, genera mucha chispa en la escobillas, se recomienda usar hasta que el inducido agote su vida util, para justificar el cambio por un inducido nuevo, rodamiento agotado, escobillas desgastadas, maquina sin pasa cable, limpieza y mantenimiento general.', 57500.0, 57500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'rodamiento 608', 12000.0, 12000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'escobillas', 14000.0, 14000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'pasa cable', 8000.0, 8000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'mantenimiento ,mano de obra , limpieza', 23500.0, 23500.0);

-- ===== OT 0418 (hoja original: 418-NO JUSTIFICA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('GUSTAVO BARRERA', 'INDENSA ING SAS', '901291142-3', 'indensa.ing@gmail.com', '3108091745', 'CR 53D # 127D-53');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4 1/2', 'TRUPER', 'ESMA-41/2A9', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0418', @articulo_id, 'NO JUSTIFICA', 'INGRESA SIN INTERRUPTOR', '2025-09-19 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'Pulidora enciede, motor funcional, repuestos necesarios para correcto funcionamiento no se manejan, maquina usada por artes para hablitar las otras 3  herramientas !', 0.0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'boton ajuste disco , eje y resorte', NULL, 0),
  (@cotizacion_id, 2, NULL, 1, 'boton bloqueo', NULL, 0),
  (@cotizacion_id, 3, NULL, 1, 'escobillas', NULL, 0),
  (@cotizacion_id, 4, NULL, 1, 'set porta escobilas', NULL, 0);

-- ===== OT 0417 (hoja original: 417-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('GUSTAVO ORTIZ', 'SERVI HIDRAULICOS', '901170174-1', 'SERVIHIDRAULICOSGOT@GMAIL.COM', '3015791770', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'DEMOLEDOR', 'HM1203C', 'MAKITA', '0019445Y');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0417', @articulo_id, 'ENTREGADA Y PAGADA', 'INGRESA CON CINCEL DE PALA', '2025-09-17 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 830000.0, 831650.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '424165-8', 1.0, 'BOQUILLA', 10800.0, 10800.0),
  (@cotizacion_id, 2, '233973-4', 1.0, 'ANILLO RETENEDOR', 2300.0, 2300.0),
  (@cotizacion_id, 3, '213720-9', 1.0, 'ANILLO', 3000.0, 3000.0),
  (@cotizacion_id, 4, '213079-4', 1.0, 'ANILLO', 9700.0, 9700.0),
  (@cotizacion_id, 5, '213980-3', 1.0, 'ANILLO PERCUTOR', 16700.0, 16700.0),
  (@cotizacion_id, 6, '213431-6', 1.0, 'ANILLO FIBRA PERCUTOR', 60000.0, 60000.0),
  (@cotizacion_id, 7, '213394-6', 1.0, 'ANILLO ROJO', 2200.0, 2200.0),
  (@cotizacion_id, 8, '213499-2', 1.0, 'ANILLO PISTON', 17400.0, 17400.0),
  (@cotizacion_id, 9, '213581-7', 1.0, 'ANILLO', 24620.0, 24620.0),
  (@cotizacion_id, 10, '213499-2', 1.0, 'ANILLO PISTON', 17400.0, 17400.0);

-- ===== OT 0416 (hoja original: 416-COT.ENV - NO JUSTIFICA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('COLLISION', 'NESTOR SANCHEZ', 'COLLISION SAS', NULL, '3002156498', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO', 'MAKITA', '6413', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0416', @articulo_id, 'COT.ENV - NO JUSTIFICA', 'EL CLIENTE INFORMA QUE GIRA EL MOTOR PERO EL MANDRIL NO.', '2025-09-18 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'FRACTURA DE DIENTES DEL PIÑON CORONA Y PIÑON INDUCIDO, SE DEBEN REEMPLAZAR LAS REFACCIONES PARA GARANTÍZAR EL CORRECTO FUNCIONAMIENTO. TENER PRESENTE QUE EL VALOR DE LA REPARACIÓN ES BASTANTE ALTA , NO SE JUSTIFICA LA REPARACIÓN.', 258500.0, 258500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'INDUCIDO', 140500.0, 140500.0),
  (@cotizacion_id, 2, NULL, 1.0, 'CORONA', 102000.0, 102000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'ESCOBILLAS', 16000.0, 16000.0);
INSERT INTO historial_estado (orden_id, estado, comentario) VALUES
  (@orden_id, 'COT.ENV - NO JUSTIFICA', 'STOCK');

-- ===== OT 0415 (hoja original: 415-ENTREGADA Y PADADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JULY', 'CLUB BACATA', NULL, NULL, '3107169437', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERCUTOR', 'BOSCH', 'GSB 180-LI', '225002977');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0415', @articulo_id, 'ENTREGADA Y PADADA', 'EL CLIENTE INFORMA QUE PARA CAMBIO DE ESCOBILLAS, INGRESA CON UNA BATERÍA 18V - 2,0AH', '2025-09-18 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MOTOR RECALENTADO, ESCOBILLAS CON 30% DE VIDA ÚTIL, SE RECOMIENDA CAMBIAR EL MOTOR, PARA GARANTIZAR EL CORRECTO FUNCIONAMIENTO. SE REALIZARIA MANTENIMIENTO, LUBRICACIÓN Y LIMPIEZA GENERAL.', 183500.0, 183500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'EXPT-0032', 1.0, 'MOTOR (INCLUYE ESCOBILLAS)', 160000.0, 160000.0),
  (@cotizacion_id, 2, 'SERVMO', 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0414 (hoja original: 414-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('CARLOS CARDONA', NULL, '19369045', NULL, '3107790771', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA DE 4-1/2"', 'RYOBI', 'AG4031G', 'ON22102D005624');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0414', @articulo_id, 'ENTREGADA Y PAGADA', 'EL CLIENTE INFORMA QUE PARA MANTENIMIENTO', '2025-09-17 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'LA HERRAMIENTA ENCIENDE, SE EVIDENCIA QUE EL BOTON BLOQUEO DE DISCO ESTA FRACTURADO, TENER PRESENTE QUE PARA ESTA MARCA NO SE CONSIGUEN REPUESTOS. SE REALIZA MANTENIMIENTO, LUBRICACIÓN Y LIMPIEZA GENERAL.', 23500.0, 23500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0413 (hoja original: 413-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('FRANCIA MUÑOZ', 'MAZUREN 5', NULL, NULL, '3158921599', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'HIDROLAVADORA', 'KARCHER', NULL, NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0413', @articulo_id, 'ENTREGADA Y PAGADA', 'EL CLIENTE INFORMA QUE ES SOLO PARA CAMBIO DE ACEITE Y MANTENIMIENTO, INGRESA CON UNA BOQUILLA DE ABANICO', '2025-09-17 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA ENCIENDE CON  BUENA PRESION , INTERNAMENTE SE EVIDENCIA  REPARACIONES INADECUADAS , SE CAMBIAN TERMINALES ELECTRICAS YA QUE SE ENCUENTRAN DETERIORADAS , CAMBIO DE ACEITE A LA BOMBA , LIMPIEZA GENETAL ,SE RECOMIENDA CAMBIAR EL FILTRO ATRAPA AGUA YA QUE SE ENCUENTRA BASTANTE CONTAMINADO', 181000.0, 181000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '279530', 1.0, 'FILTRO AGUA', 50000.0, 50000.0),
  (@cotizacion_id, 2, '279691', 1.0, 'KIT BOQUILLAS  x 5', 70000.0, 70000.0),
  (@cotizacion_id, 3, NULL, 2.0, 'TORNILLOS', 500.0, 1000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'SERVICIO MANO OBRA', 60000.0, 60000.0);

-- ===== OT 0412 (hoja original: 412-NO JUSTIFICA-ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ANDRES HERNANDEZ', 'MOBIN MOBILIARIO INTERIOR S.A.S.', '79711196', 'ANDREHUERTAS23@HOTMAIL.COM', '3164729680 - 3188391738', 'CALLE 108 # 55 - 32');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERCUTOR', 'BAUKER', 'ID500', '508005581');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0412', @articulo_id, 'NO JUSTIFICA-ENTREGADA', 'SIN ACCESORIOS, EQUIPO SUENA RARO AL ENCENDER', '2025-09-16 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'NO JUSTIFICA  REPARACION, YA QUE ES UNA MARCA QUE NO CUENTA CON REPUESTOS, PIÑON CON DIENTES FRACXTURADOS , PORTAESCOBILLAS RECALENTADOS', 0.0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();

-- ===== OT 0411 (hoja original: 411-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ANDRES HERNANDEZ', 'MOBIN MOBILIARIO INTERIOR S.A.S.', '79711196', 'ANDREHUERTAS23@HOTMAIL.COM', '3164729680 - 3188391738', 'CALLE 108 # 55 - 32');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO INALAMBRICO', 'BOSH', 'GSR 1000 SAMRT', '508005581');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0411', @articulo_id, 'ENTREGADA Y PAGADA', 'SIN ACCESORIOS, EQUIPO NO ENCIENDE', '2025-09-16 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'SE EVIDENCIA QUE LA BATERÍA NO ALMACENA LA CARGA LO CUAL NO PERMITE EL CORRECTO FUNCIONAMIENTO DEL EQUIPO.', 133500.0, 133500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'EXPT-0030', 1.0, 'BATERÍA', 110000.0, 110000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0410 (hoja original: 410-ENTREGADA SIN REPARAR) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ANDRES HERNANDEZ', 'MOBIN MOBILIARIO INTERIOR S.A.S.', '79711196', 'ANDREHUERTAS23@HOTMAIL.COM', '3164729680 - 3188391738', 'CALLE 108 # 55 - 32');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO INALAMBRICO', 'BOSH', 'GSR 1000 SAMRT', '224152146');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0410', @articulo_id, 'ENTREGADA SIN REPARAR', 'INGRESA CON CARGADOR PARA PRUEBAS, EQUIPO NO ENCIENDE', '2025-09-16 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'ATORNILLADOR DE MODELO ANTIGUO TIENE DIFERENCIAS CON EL MODELO ACTUAL (PLUG DEL CARGADOR MAS GRANDE , BATERÍA E INTERRUPTOR UNIDOS), ESTA PIEZA VIENE EN CONJUNTO. EL EQUIPO TIENE EL PASO DE CORRIENTE INTERMITENTEMENTE.', 233500.0, 233500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'BATERÍA + INTERRUPTOR', 210000.0, 210000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0409 (hoja original: 409-ENTREGADA Y PÁGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ANDRES HERNANDEZ', 'MOBIN MOBILIARIO INTERIOR S.A.S.', '79711196', 'ANDREHUERTAS23@HOTMAIL.COM', '3164729680 - 3188391738', 'CALLE 108 # 55 - 32');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERCUTOR INALAMBRICO', 'DEWALT', 'DCD776 TYPE 1', '-');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0409', @articulo_id, 'ENTREGADA Y PÁGADA', 'SIN ACCESORIOS, EQUIPO NO ENCIENDE', '2025-09-16 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'SE EVIDENCIA QUE EL MOTOR ESTA SIN CONTINUIDAD, SE REALIZARIA MANTENIMIENTO, LUBRICACIÓN Y LIMPIEZA GENERAL.', 198500.0, 198500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'N376649', 1.0, 'MOTOR', 175000.0, 175000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0408 (hoja original: 408-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ROBINSON BOLIVAR', NULL, '1020756030', NULL, '3238061034', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'BOSCH', 'GBH2-26DFR', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0408', @articulo_id, 'ENTREGADA Y PAGADA', 'ENCIENDE, SUENA FEO EL SISTEMA MECANICO, SIN ACCESORIOS Y CABLE REMENDADO.', '2025-09-15 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'RODAMIENTO FRACTURADO CON PERDIDA DE ESFERAS, BALERO DEFORMADO POR DESGASTE, ESCOBILLAS CON TERMINAL DESPRENDIDA, INDUCIDO RECALENTADO PERO AUN FUNCIONA., SE RECOMIENDA CAMBIAR A FUTURO', 130500.0, 130500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'BALERO', NULL, 70000.0),
  (@cotizacion_id, 2, NULL, 1, 'RODAMIENTO 609', NULL, 12000.0),
  (@cotizacion_id, 3, NULL, 1, 'BUJE DE AGUJAS', NULL, 10000.0),
  (@cotizacion_id, 4, NULL, 1, 'ESCOBILLAS', NULL, 10000.0),
  (@cotizacion_id, 5, NULL, 1, 'MANTENIMIENTO Y MANO DE OBRA', NULL, 28500.0);

-- ===== OT 0407 (hoja original: 407-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('LUIS QUIÑONES', NULL, '79684642', NULL, '3138595424', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO', 'MAKITA REPLICA', 'DHP453Z', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0407', @articulo_id, 'ENTREGADA Y PAGADA', 'INGRESA CON BATERÍA 24V', '2025-09-15 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'INTERRUPTOR CON PASO DE CORRIENTE INERMITENTE, SE DEBE REALIZAR EL CAMBIO PARA EL CORRECTO FUNCIONAMIENTO DEL EQUIPO.', 48500.0, 48500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'EXPT-0027', 1.0, 'INTERRUPTOR', 25000.0, 25000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0406 (hoja original: 406-OK ENTREGADA Y PAG) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('CRISTIAN GOMEZ / CRISTIAN CARDENAS', 'SOCIEDAD FERRETERA', NULL, NULL, NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'DEMOLEDOR', 'HILTI', 'NO REGISTRA', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0406', @articulo_id, 'OK ENTREGADA Y PAG', 'EL CLIENTE INFORMA QUE ES SOLO PARA MANTENIMIENTO', '2025-09-12 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'EQUIPO FUNCIONAL, PIERDE EL GOLPE INTERMITENTEMENTE. SE REALIZA MANTENIMIENTO, LUBRICACIÓN Y LIMPIEZA GENERAL.', 145000.0, 145000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'KIT DE ANILLOS', 50000.0, 50000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'GRASA SUPER KOTE', 35000.0, 35000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'SERVICIO MANO OBRA', 60000.0, 60000.0);

-- ===== OT 0405 (hoja original: 405-COT.ENV) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JULIETH', 'COLLISION', NULL, NULL, '3175004322', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'POLICHADORA', 'RANGER PRO', '2017920', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0405', @articulo_id, 'COT.ENV', 'TUERCA Y BRIDA, DOS MANGOS AUXILIARES', '2025-09-10 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'SE EVIDENCIA QUE LA HERRAMIENTA NO ENCIENDE, MODULO CON PASO DE CORRIENTE INTERRUMPIDA, PARA ESTA MARCA DE HERRAMIENTAS NO SE CONSIGUEN REFACCIONES, SE DEJA LA MAQUINA TRABAJANDO A MAXIMA REVOLUCIÓN.', 10000.0, 10000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'MODULO', 0.0, 0),
  (@cotizacion_id, 2, NULL, 1.0, 'SERVIVIO MANO OBRA', 10000.0, 10000.0);

-- ===== OT 0404 (hoja original: 404-) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('PALOMINO', NULL, NULL, NULL, NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4 1/2', 'MAKITA', 'GA4530', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0404', @articulo_id, 'INGRESO', NULL, CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'SE REALIZA LA EVALUACIÓN DE LA MAQUINA EVIDENCIANDO INDUCIDO CON EJE DESGASTADO, PIÑON SPICK DESGASTADO SEVERAMENTE, CAJA ENGRANAJE AVERIADA EN BOTON DE BLOQUEO.  MAQUINA CON ALTO VALOR EN LA REPRACIÓN  ES MODELO ORIGINAL JUSTIFICA REPARAR, O POR EL PRECIO DE LA REPARACION HAY MODELOS  NUEVOS EN MARCA TOTAL', 203000.0, NULL, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'INDUCIDO', 123200.0, 123200.0),
  (@cotizacion_id, 2, NULL, 1.0, 'PIÑON SPICK', 16200.0, 16200.0),
  (@cotizacion_id, 3, NULL, 1.0, 'TUERCA', 1000.0, 1000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'CAJA ENGRANAJES', 61600.0, 61600.0),
  (@cotizacion_id, 5, NULL, 1.0, 'TAPA BOTON', 1000.0, 1000.0),
  (@cotizacion_id, 6, NULL, 1.0, 'ESCOBILLAS', 12000.0, 12000.0),
  (@cotizacion_id, 7, NULL, 1.0, 'SERVICIO MANO DE OBRA', 23500.0, 23500.0);

-- ===== OT 0403 (hoja original: 403-ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('CONSTRUM CACERES S.A.S.', NULL, '900.768.163-3', NULL, '3212744628', 'CR 9 CL 27 45');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'ROTOMARTILLO', 'TOTAL', 'UTH308268-2', 'SIN');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0403', @articulo_id, 'ENTREGADA', 'MAQUINA CON EMPUÑADURA, ENCIENDE NO GOLPEA', CURRENT_TIMESTAMP);
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'INGRESA COMO GARANTÍA', 0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'UTH308268-2-SP-55', 1.0, 'PISTON', 0.0, 0),
  (@cotizacion_id, 2, 'UTH308268-2-SP-54', 1.0, 'ANILLO PISTON', 0.0, 0);

-- ===== OT 0402 (hoja original: 402-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JUANITA REY', NULL, NULL, NULL, '3043794712', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'MOTOTOOL 1,7 AMP', 'FOREDOM', NULL, 'G14');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0402', @articulo_id, 'ENTREGADA Y PAGADA', NULL, '2025-09-12 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'EQUIPO CON MOTOR FUNCIONAL, TRANSMISIÓN ROTA (GUAYA), SE RECOMIENDA REEMPLAZAR LA PIEZA DEFECTUOSA POR SU GUAYA ORIGINAL.', 173500.0, 173500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'S-93', 1.0, 'GUAYA COMPLETA', 150000.0, 150000.0),
  (@cotizacion_id, 2, 'SERVMO', 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0401 (hoja original: 401-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JUANITA REY', NULL, NULL, NULL, '3043794712', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'MOTOTOOL', 'DREMEL', '3000', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0401', @articulo_id, 'ENTREGADA Y PAGADA', NULL, '2025-09-12 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA CON BOBINA REPARADA ANTERIORMENTE, TERMINALES RECALENTADAS NO PERMITEN EL CORRECTO FUNCIONAMIENTO DEL EQUIPO, PARA UNA REPARACIÓN IDONEA SE DEBE REEMPLAZAR LAS REFACCIONES AFECTADAS. SE REALIZARIA MANTENIMIENTO Y LIMPIEZA GENERAL.', 96000.0, 96000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'EXPT-0031 / EXPT-0033', 1.0, 'BOBINA', NULL, 43000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'ESCOBILLAS', NULL, 35000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'MANTENIMIENTO Y MANO DE OBRA', NULL, 18000.0);

-- ===== OT 0400 (hoja original: 400-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('MAGIVISION INTERAKTO SAS', 'MAGIVISION INTERAKTO SAS', '860509847-8', NULL, '3125199366', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'APUNTILLADORA NEUMATICA', 'SENCO', 'SFW05-AT', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0400', @articulo_id, 'ENTREGADA Y PAGADA', NULL, '2025-09-12 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'EL EQUIPO NO BOTA EL GANCHO PORQUE NO DEVUELVE LA LENGUETA POR FALLA DE UN  EMPAQUE, AL DESEMSAMBLAR TODA LA MAQUINA EVIDENCIAMOS QUE HAY EMPAQUES ADHERIDOS CON SILICONA Y AL QUITARLOS SE RASGAN. SE REALIZARIA MANTENIMEINTO Y LIMPIEZA GENERAL.', 88500.0, 88500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'KIT EMPAQUETADURAS', 25000.0, 25000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'ANILLOS', 20000.0, 20000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'MEMBRANAS', 20000.0, 20000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0399 (hoja original: 399-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('MAGIVISION INTERAKTO SAS', 'MAGIVISION INTERAKTO SAS', '860509847-8', NULL, '3125199366', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'RUTEADORA', 'MAKITA', 'RP1800', '82554E');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0399', @articulo_id, 'ENTREGADA Y PAGADA', NULL, '2025-09-12 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'SE EVIDENCIA QUE LA HERRAMIENTA ENCIENDE, EL COLLECT PRESENTA ANOMALIAS DEBIDO A UN MAL USO, RODAMIENTOS EN BUENAS CONDICIONES, SE REALIZA MANTENIMIENTO Y LIMPIEZA GENERAL.', 178500.0, 178500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'EXPT-0025', 1.0, 'COLLECT', 150000.0, 150000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'SERVICIO MANO DE OBRA', 28500.0, 28500.0);

-- ===== OT 0398 (hoja original: 398-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('PRIDE DISEÑO SAS', 'PRIDE DISEÑO SAS', '900482007-3', NULL, '3125199366', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'RUTEADORA', 'DEWALT', 'DW616', '860804');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0398', @articulo_id, 'ENTREGADA Y PAGADA', NULL, '2025-09-12 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'SE EVIDENCIA QUE LA HERRAMIENTA NO ENCIENDE, EL CABLE DE PODER CON PASO INTERRUMPIDO DE CORRIENTE A LA ALTURA DEL ACOPLE, RODAMIENTOS CON FATIGA GENERANDO VIBRACIÓN DEL EQUIPO Y ESCOBILLAS DESGASTADAS.', 210500.0, 210500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '399063-02', 1.0, 'CABLE DE PODER', 100000.0, 100000.0),
  (@cotizacion_id, 2, '398139-01', 1.0, 'ESCOBILLAS', 42000.0, 42000.0),
  (@cotizacion_id, 3, '146555-01  Y 605040-20', 2.0, 'RODAMIENTOS DE ALTA FRICCIÓN', 20000.0, 40000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'SERVICIO MANO DE OBRA', 28500.0, 28500.0);

-- ===== OT 0397 (hoja original: 397-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('JORGE HERNANDEZ', 'INGENIERIA DE COLOMBIA NC SAS', '901436540-6', 'ingenieriadecolombianc@outlook.com', NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'DEMOLEDOR', 'HILTI', 'NO REGISTRA', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0397', @articulo_id, 'ENTREGADA Y PAGADA', 'EL CLIENTE INFORMA QUE ES SOLO PARA MANTENIMIENTO', '2025-09-09 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'EQUIPO ENCIENDE PERO NO GENERA IMPACTO, SE REAIZA LA EVALUACIÓN COMPLETA DE LA MAQUINA Y SE EVIDENCIA ANILLOS DE COMPRESIÓN DESGASTADOS Y AMORTIGUADOR FRACTURADO, OCASIONADO QUE LA CAMARA NO GENERE COMPRESION Y SE PIERDA LA FUERZA DE GOLPE.                                                                                                                                                                                                                                                                                                                                                       NOTA:  HILTI COLOMBIA NO REALIZA LA DISTRIBUCIÓN DE REFACCIONES, POR LO CUAL LA ALTERNATIVA VIABLE ES LA FABRICACION DE DICHOS EMPAQUES EN EL MERCADO LOCAL, LABOR QUE YA ESTAMOS GESTIONANDO, TENIENDO EN CUENTA QUE EL MATERIAL ES ESPECIAL (FLUORURO).', 380000.0, 380000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'EXPT-0039', 1.0, 'ANILLO PESO MUERTO', 120000.0, 120000.0),
  (@cotizacion_id, 2, 'EXPT-0040', 1.0, 'ANILLO PISTON', 120000.0, 120000.0),
  (@cotizacion_id, 3, 'EXPT-0041', 1.0, 'AMORTIGUADOR', 50000.0, 50000.0),
  (@cotizacion_id, 4, NULL, 1.0, 'SERVICIO DE MANTENIMIENTO Y MANO DE OBRA', 90000.0, 90000.0);

-- ===== OT 0396 (hoja original: 396) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('RICARDO', 'RIDER DECALS', NULL, NULL, NULL, NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PISTOLA DE CALOR', 'MAKITA', 'HG6530', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0396', @articulo_id, 'INGRESO', 'LLEGA SIN CABLE DE PODER', '2025-09-09 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'SE EVIDENCIA QUE LA HERRAMIENTA NO ENCIENDE.', 0.0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();

-- ===== OT 0395 (hoja original: 395-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('AUTO SAFE S.A', 'AUTO SAFE S.A', '811034722-8', 'info@autosafe.com.co', NULL, 'CR 23 71 A 36');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA', 'DEWALT', 'DWE4120', NULL);
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0395', @articulo_id, 'ENTREGADA Y PAGADA', 'LLEGA CON DISCO DE WURTH', '2025-09-09 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'SE EVIDENCIA QUE LA HERRAMIENTA NO ENCIENDE.', 72000.0, 72000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'ESCOBILLAS', NULL, 26500.0),
  (@cotizacion_id, 2, NULL, 1, 'RODAMIENTO 607', NULL, 12000.0),
  (@cotizacion_id, 3, NULL, 1, 'RODAMIENTO 608', NULL, 10000.0),
  (@cotizacion_id, 4, NULL, 1, 'Servicio de mantenimiento y mano de obra', NULL, 23500.0);

-- ===== OT 0394 (hoja original: 394-ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('CARLOS LOPEZ', NULL, '79806234', NULL, '3105595511', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4-1/2"', 'TRUPER', '45110', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0394', @articulo_id, 'ENTREGADA', NULL, '2025-09-08 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'SE EVIDENCIA QUE LA HERRAMIENTA TENIA EL RODAMIENTO FRACTURADO, SE REALIZA EL CAMBIO, MANTENIMIENTO Y LIMPIEZA GENERAL.', 12000.0, 12000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'RODAMIENTO 6000', 12000.0, 12000.0);

-- ===== OT 0393 (hoja original: 393-NO SE JUSTIFICA, ENV.COT) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('NELSON CHICA', NULL, '79856303', NULL, '3236837058', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO ATOTNILLADOR 12V', 'REPLICA MAKITA', 'NO REGISTRA', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0393', @articulo_id, 'NO SE JUSTIFICA, ENV.COT', NULL, '2025-09-08 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'NO JUSTIFICA LA REPARACION DEBIDO A QUE LOS REPUESTOS SON MAS COSTOSOS QUE UNA HERRAMIENTA NUEVA', 0.0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'INTERRUPTOR EN CORTO', NULL, 0),
  (@cotizacion_id, 2, NULL, 1, 'MOTOR RECALENTADO', NULL, 0);

-- ===== OT 0392 (hoja original: 392-Entregada y Pagada) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('PEDRO SOLER', NULL, NULL, NULL, '3005655390', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'TALADRO PERCUTOR', 'BLACK & DECKER', 'TM500-B3', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0392', @articulo_id, 'Entregada y Pagada', NULL, '2025-09-08 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 18000.0, 18000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'Le realizamos una reparación eléctrica y mantenimiento sencillo', 18000.0, 18000.0);

-- ===== OT 0391 (hoja original: 391-ENTREGADA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('CAUCHOS LA 130', 'VIDAL LINARES', '79816083', 'vidallinarres@hotmail.com', '3134868180', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'esmeril 8', 'MAKITA', 'GB 801', '9812110014');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0391', @articulo_id, 'ENTREGADA Y PAGADA', '4 BRIDAS Y 2 TUERCAS', '2025-09-09 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'SE EVIDENCIA QUE LA MAQUINA ESTA EN CORTO, NO ENCIENDE, CON MODIFICACIONES EN PLATINERA, INTERRUPTOR, PRESENTA REPARACIONES DE TAPAS,. ES UNA REPARACIÓN DE ALTO VALOR DEBIDO A QUE LA BOBINA DE CAMPO PRESENTA CORTO Y RECALENTAMIENTO.', 100000.0, 107300.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'CAPACITOR', 45200.0, 45200.0),
  (@cotizacion_id, 2, NULL, 1.0, 'INTERRUPTOR', 24800.0, 24800.0),
  (@cotizacion_id, 3, NULL, 1.0, 'PLACA DE MONTAJE', 13800.0, 13800.0),
  (@cotizacion_id, 4, NULL, 1.0, 'BOBINA', 883000.0, 0),
  (@cotizacion_id, 5, NULL, 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0390 (hoja original: 390-ENTREGADA SIN REP) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ORLANDO RUEDA', 'TECMETALICOS', '19341222', 'tecmetalicos.taller@hotmail.com', '2717656', 'CL 129 - 56-20');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4 1/2"', 'HILTI', NULL, 'SIN SERIAL');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0390', @articulo_id, 'ENTREGADA SIN REP', NULL, '2025-09-09 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'NO HAY REPARA', 0.0, 0.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'PIÑON CORONA', NULL, 0),
  (@cotizacion_id, 2, NULL, 1.0, 'PIÑON SPICK', NULL, 0),
  (@cotizacion_id, 3, NULL, 1.0, 'ESCOBILLAS', NULL, 0),
  (@cotizacion_id, 4, NULL, 1, 'Servicio de mantenimiento y mano de obra', NULL, 0);

-- ===== OT 0389 (hoja original: 389-entregada) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ORLANDO RUEDA', 'TECMETALICOS', '19341222', 'tecmetalicos.taller@hotmail.com', '2717656 - 3153351518', 'CL 129 - 56-20');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4 1/2"', 'MILWAUKEE', NULL, 'SIN SERIAL');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0389', @articulo_id, 'entregada', 'BRIDA Y TUERCA', '2025-09-09 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA CON SONIDO MUY FUERTE', 45500.0, 45500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'ESCOBILLAS TOTAL', 20000.0, 20000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'MANTENIMIENTO, MANO DE OBRA', 25500.0, 25500.0);

-- ===== OT 0388 (hoja original: 388-ENTREAGDA Y PAGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('ORLANDO RUEDA', 'TECMETALICOS', '19341222', 'tecmetalicos.taller@hotmail.com', '2717656', 'CL 129 - 56-20');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'PULIDORA 4 1/2"', 'DEWALT', NULL, 'SIN SERIAL');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0388', @articulo_id, 'ENTREAGDA Y PAGADA', 'BRIDA Y TUERCA', '2025-09-09 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA CON SONIDO MUY FUERTE', 192000.0, 192000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, 'N899443', 1.0, 'INDUCIDO', 150000.0, 150000.0),
  (@cotizacion_id, 2, 'NA121629', 1.0, 'ESCOBILLAS', 18500.0, 18500.0),
  (@cotizacion_id, 3, 'SERVMO', 1.0, 'Servicio de mantenimiento y mano de obra', 23500.0, 23500.0);

-- ===== OT 0387 (hoja original: 387-ENTREGADA) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('COMERCIALIZADORA CASTAÑO CARDOZO', 'COMERCIALIZADORA CASTAÑO CARDOZO', '900590296-8', NULL, '7257653', 'CLL 134 # 45B-57 Local 3');
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'SOPLADORA', 'BAUKER', 'BL600F', 'NO REGISTRA');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0387', @articulo_id, 'ENTREGADA', NULL, '2025-09-08 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'SE EVIDENCIA QUE LA HERRAMIENTA TIENE UN SONIDO EXTRAÑO, RODAMIENTOS CON FATIGA Y NECESITA UN AJUSTE ELÉCTRIO. SE REALIZA MANTENIMIENTO Y LIMPIEZA GENERAL', 53000.0, 53000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, '210200-6', 1.0, 'RODAMIENTO 608', 10000.0, 10000.0),
  (@cotizacion_id, 2, '210023-2', 1.0, 'RODAMIENTO 627', 13000.0, 13000.0),
  (@cotizacion_id, 3, 'EXPT-0017', 1.0, 'CLAVIJA PEQUEÑA', 6500.0, 6500.0),
  (@cotizacion_id, 4, 'SERVMO', 1.0, 'SERVICIO MANO OBRA', 23500.0, 23500.0);

-- ===== OT 0386 (hoja original: 386) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('santiago hernandez', NULL, '1033097087', 'danielshc08@gmail.com', '3157195100 - 3125181512', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'SIN CLASIFICAR', 'BOSCH', 'GWS 7-115', '806132116');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0386', @articulo_id, 'INGRESO', NULL, '2025-09-08 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, NULL, 60500.0, 60500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1.0, 'ESCOBILLAS', 25000.0, 25000.0),
  (@cotizacion_id, 2, NULL, 1.0, 'RODAMIENTO 608', 12000.0, 12000.0),
  (@cotizacion_id, 3, NULL, 1.0, 'Servicio de mantenimiento y mano de obra', 23500.0, 23500.0);

-- ===== OT 0385 (hoja original: 385-lista) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('santiago hernandez', NULL, '1033097087', 'danielshc08@gmail.com', '3157195100 - 3125181512', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'SIN CLASIFICAR', 'MAKITA', 'GA4530', '0363465Y');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0385', @articulo_id, 'lista', 'BRIDA Y TUERCA', '2025-09-08 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA CON CIRCUITO ABIERTO, RODAMIENTOS FATIGADOS, ESCOBILLAS DESGASTADAS.', 59500.0, 59500.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'Rodamiento 629', NULL, 12000.0),
  (@cotizacion_id, 2, NULL, 1, 'Rodamiento 607', NULL, 12000.0),
  (@cotizacion_id, 3, NULL, 1, 'Escobillas CB - 458', NULL, 12000.0),
  (@cotizacion_id, 4, NULL, 1, 'Servicio de mantenimiento y mano de obra', NULL, 23500.0);

-- ===== OT 0384 (hoja original: 384-lista) =====
INSERT INTO cliente (nombre, empresa, cedula, correo, telefono, direccion) VALUES ('santiago hernandez', NULL, '1033097087', 'danielshc08@gmail.com', '3157195100 - 3125181512', NULL);
SET @cliente_id = LAST_INSERT_ID();
INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (@cliente_id, 'SIN CLASIFICAR', 'MAKITA', '9557HPG', '831741K');
SET @articulo_id = LAST_INSERT_ID();
INSERT INTO orden_servicio (codigo_seguimiento, articulo_id, estado_actual, observaciones, fecha_ingreso) VALUES ('0384', @articulo_id, 'lista', 'GUARDA, BRIDA Y TUERCA', '2025-09-08 00:00:00');
SET @orden_id = LAST_INSERT_ID();
INSERT INTO cotizacion (orden_id, dictamen, monto, subtotal, iva) VALUES (@orden_id, 'MAQUINA NO ENCIENDE, CABLE CON CIRCUITO ABIERTO A MITAD DE LONGITUD,', 62000.0, 62000.0, 0);
SET @cotizacion_id = LAST_INSERT_ID();
INSERT INTO cotizacion_detalle (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total) VALUES
  (@cotizacion_id, 1, NULL, 1, 'RODAMIENTO 607', NULL, 12000.0),
  (@cotizacion_id, 2, NULL, 1, 'CABLE DE PODER ORIGINAL MAKITA', NULL, 50000.0);
