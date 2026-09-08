ALTER TABLE orden_servicio MODIFY tipo ENUM('mantenimiento', 'reparacion', 'garantia') NOT NULL DEFAULT 'reparacion';
UPDATE orden_servicio SET tipo = 'reparacion' WHERE tipo = 'mantenimiento';
ALTER TABLE orden_servicio MODIFY tipo ENUM('reparacion', 'garantia') NOT NULL DEFAULT 'reparacion';
SET @sql = (
    SELECT IF(
        COUNT(*) = 0,
        'ALTER TABLE cotizacion ADD COLUMN abono DECIMAL(10,2) NOT NULL DEFAULT 0',
        'SELECT 1'
    )
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'cotizacion'
      AND COLUMN_NAME = 'abono'
);
PREPARE agregar_abono FROM @sql;
EXECUTE agregar_abono;
DEALLOCATE PREPARE agregar_abono;

ALTER TABLE historial_estado MODIFY usuario_id INT NULL;
CREATE TABLE IF NOT EXISTS accesorio (
    id INT AUTO_INCREMENT PRIMARY KEY,
    articulo_id INT NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion VARCHAR(255) NULL,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (articulo_id) REFERENCES articulo(id) ON DELETE CASCADE
);