-- Datos de prueba (seed): usuarios y datos base para poder probar el sistema
-- recien levantado, sin tener que crearlos a mano cada vez.
--
-- Password para AMBOS usuarios de prueba: 123456
-- (el hash de abajo corresponde a esa contraseña, ya verificado)
USE taller_tracker;

INSERT INTO usuario (nombre, email, password_hash, rol) VALUES
('Admin Prueba', 'admin@test.com', '$2y$10$Vnuxoi/43pcVsoHLoICCzuMVZ.83A4FrbXZWNc9K10S/9/Oc8UfHG', 'recepcion'),
('Carlos Tecnico', 'tecnico@test.com', '$2y$10$Vnuxoi/43pcVsoHLoICCzuMVZ.83A4FrbXZWNc9K10S/9/Oc8UfHG', 'tecnico');

INSERT INTO cliente (nombre, telefono) VALUES
('Juan Perez', '3001234567');

INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES
(1, 'Taladro', 'DeWalt', 'DW505', 'SN12345');
