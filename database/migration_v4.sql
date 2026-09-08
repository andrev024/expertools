SET @sql = (
    SELECT IF(
        COUNT(*) = 0,
        'ALTER TABLE orden_servicio ADD COLUMN ubicacion_actual VARCHAR(150) NULL AFTER estado_actual',
        'SELECT 1'
    )
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'orden_servicio'
      AND COLUMN_NAME = 'ubicacion_actual'
);
PREPARE agregar_ubicacion FROM @sql;
EXECUTE agregar_ubicacion;
DEALLOCATE PREPARE agregar_ubicacion;

UPDATE orden_servicio os
JOIN (
    SELECT h.orden_id, SUBSTRING_INDEX(h.comentario, 'Ubicacion: ', -1) AS ubicacion
    FROM historial_estado h
    WHERE h.comentario LIKE '%Ubicacion:%'
      AND h.id = (
          SELECT MAX(h2.id)
          FROM historial_estado h2
          WHERE h2.orden_id = h.orden_id AND h2.comentario LIKE '%Ubicacion:%'
      )
) ubicaciones ON ubicaciones.orden_id = os.id
SET os.ubicacion_actual = ubicaciones.ubicacion;