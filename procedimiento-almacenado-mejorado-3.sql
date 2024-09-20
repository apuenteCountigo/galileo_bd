DELIMITER //

DROP PROCEDURE IF EXISTS TempProcedure //

CREATE PROCEDURE TempProcedure()
BEGIN
    DECLARE procedure_exists INT;

    -- Verificar si el procedimiento ya existe
    SELECT COUNT(*) INTO procedure_exists
    FROM information_schema.routines
    WHERE routine_schema = DATABASE()
    AND routine_name = 'TempProcedure';

    IF procedure_exists = 0 THEN
        -- El procedimiento no existe, así que lo creamos
        
        -- Operaciones en la tabla "balizas"
        -- (Se mantienen las operaciones anteriores para la tabla "balizas")
        -- ...

        -- Operaciones en la tabla "operaciones"
        -- 9. Eliminar la restricción UNIQUE del campo "nombre" si existe
        IF EXISTS (
            SELECT * FROM information_schema.table_constraints
            WHERE table_name = 'operaciones' 
            AND constraint_type = 'UNIQUE' 
            AND constraint_name LIKE '%nombre%'
        ) THEN
            ALTER TABLE operaciones DROP INDEX nombre;
        END IF;

        -- 10. Crear una llave combinada con los campos "nombre" e "idUnidad"
        IF NOT EXISTS (
            SELECT * FROM information_schema.statistics
            WHERE table_name = 'operaciones' 
            AND index_name = 'uk_nombre_idUnidad'
        ) THEN
            ALTER TABLE operaciones 
            ADD CONSTRAINT uk_nombre_idUnidad UNIQUE (nombre, idUnidad);
        END IF;

        -- Nuevas operaciones en la tabla "objetivos"
        -- 11. Eliminar la restricción UNIQUE del campo "descripcion" si existe
        IF EXISTS (
            SELECT * FROM information_schema.table_constraints
            WHERE table_name = 'objetivos' 
            AND constraint_type = 'UNIQUE' 
            AND constraint_name LIKE '%descripcion%'
        ) THEN
            ALTER TABLE objetivos DROP INDEX descripcion;
        END IF;

        -- 12. Crear una llave combinada con los campos "descripcion" e "idOperacion"
        IF NOT EXISTS (
            SELECT * FROM information_schema.statistics
            WHERE table_name = 'objetivos' 
            AND index_name = 'uk_descripcion_idOperacion'
        ) THEN
            ALTER TABLE objetivos 
            ADD CONSTRAINT uk_descripcion_idOperacion UNIQUE (descripcion, idOperacion);
        END IF;

        -- Limpiar la tabla temporal
        DROP TEMPORARY TABLE IF EXISTS TempModelos;
        
        SELECT 'Procedimiento ejecutado con éxito.' AS Mensaje;
    ELSE
        SELECT 'El procedimiento ya existe y no se ha ejecutado.' AS Mensaje;
    END IF;
END //

DELIMITER ;

-- Llamar al procedimiento almacenado
CALL TempProcedure();

-- Eliminar el procedimiento almacenado una vez finalizado
DROP PROCEDURE IF EXISTS TempProcedure;
