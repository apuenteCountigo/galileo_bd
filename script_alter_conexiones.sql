DELIMITER //

CREATE PROCEDURE AddColumnIfNotExists()
BEGIN
    -- Declara una variable para almacenar el resultado de la verificación
    DECLARE columnExists INT DEFAULT 0;

    -- Verifica si la columna 'ruta' ya existe en la tabla 'conexiones'
    SELECT COUNT(*)
    INTO columnExists
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'conexiones'
      AND COLUMN_NAME = 'ruta';

    -- Si la columna no existe, la agrega
    IF columnExists = 0 THEN
        ALTER TABLE `conexiones` ADD `ruta` VARCHAR(255) NULL DEFAULT NULL AFTER `viewIDs`;
    END IF;
END //

DELIMITER ;

-- Ejecuta el procedimiento
CALL AddColumnIfNotExists();

-- (Opcional) Borra el procedimiento si ya no es necesario
DROP PROCEDURE IF EXISTS AddColumnIfNotExists;
