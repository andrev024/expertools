-- Ejecutar una sola vez tras realizar y verificar un respaldo de la base.
-- Los registros actuales se asignan a la cuenta inicial Expertools.

CREATE TABLE ferreteria (
    id INT NOT NULL AUTO_INCREMENT,
    slug VARCHAR(80) NOT NULL,
    nombre_comercial VARCHAR(150) NOT NULL,
    telefono VARCHAR(60) DEFAULT NULL,
    direccion VARCHAR(255) DEFAULT NULL,
    logo_key VARCHAR(512) DEFAULT NULL,
    codigo_prefijo VARCHAR(20) NOT NULL DEFAULT 'OT-A-',
    siguiente_consecutivo INT NOT NULL DEFAULT 600,
    creado_en TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_ferreteria_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO ferreteria (id, slug, nombre_comercial, codigo_prefijo)
VALUES (1, 'expertools', 'Expertools', 'OT-A-');

ALTER TABLE usuario
    ADD COLUMN ferreteria_id INT NULL AFTER id;

ALTER TABLE cliente
    ADD COLUMN ferreteria_id INT NULL AFTER id;

UPDATE usuario SET ferreteria_id = 1 WHERE ferreteria_id IS NULL;
UPDATE cliente SET ferreteria_id = 1 WHERE ferreteria_id IS NULL;

ALTER TABLE usuario
    MODIFY COLUMN ferreteria_id INT NOT NULL,
    ADD KEY idx_usuario_ferreteria (ferreteria_id),
    ADD CONSTRAINT fk_usuario_ferreteria
        FOREIGN KEY (ferreteria_id) REFERENCES ferreteria (id);

ALTER TABLE cliente
    MODIFY COLUMN ferreteria_id INT NOT NULL,
    ADD KEY idx_cliente_ferreteria (ferreteria_id),
    ADD CONSTRAINT fk_cliente_ferreteria
        FOREIGN KEY (ferreteria_id) REFERENCES ferreteria (id);

ALTER TABLE orden_servicio
    ADD COLUMN ferreteria_id INT NULL AFTER id;

UPDATE orden_servicio os
JOIN articulo a ON a.id = os.articulo_id
JOIN cliente c ON c.id = a.cliente_id
SET os.ferreteria_id = c.ferreteria_id;

ALTER TABLE orden_servicio
    MODIFY COLUMN ferreteria_id INT NOT NULL,
    DROP INDEX codigo_seguimiento,
    DROP INDEX idx_codigo_seguimiento,
    ADD KEY idx_orden_ferreteria (ferreteria_id),
    ADD UNIQUE KEY uq_orden_ferreteria_codigo (ferreteria_id, codigo_seguimiento),
    ADD CONSTRAINT fk_orden_ferreteria
        FOREIGN KEY (ferreteria_id) REFERENCES ferreteria (id);

UPDATE ferreteria f
SET f.siguiente_consecutivo = COALESCE(
    (
        SELECT MAX(CAST(SUBSTRING_INDEX(os.codigo_seguimiento, '-', -1) AS UNSIGNED)) + 1
        FROM orden_servicio os
        WHERE os.ferreteria_id = f.id
          AND os.codigo_seguimiento LIKE CONCAT(f.codigo_prefijo, '%')
    ),
    600
);
