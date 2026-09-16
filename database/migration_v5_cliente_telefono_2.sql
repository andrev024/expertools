-- Ejecutar una sola vez en la base de datos existente.
ALTER TABLE cliente ADD COLUMN telefono_2 VARCHAR(30) NULL AFTER telefono;
