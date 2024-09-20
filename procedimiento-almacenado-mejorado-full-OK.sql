-- Desactivar la verificación de claves foráneas temporalmente
SET FOREIGN_KEY_CHECKS = 0;

DELIMITER //

-- Eliminar el procedimiento si ya existe
DROP PROCEDURE IF EXISTS TempProcedure //

-- Crear el procedimiento almacenado
CREATE PROCEDURE TempProcedure()
BEGIN
    -- Operaciones en la tabla "balizas"
    -- 1. Crear una tabla temporal y almacenar modelos únicos de la tabla "balizas"
    CREATE TEMPORARY TABLE IF NOT EXISTS TempModelos (
        modelo VARCHAR(255) PRIMARY KEY
    );

    INSERT IGNORE INTO TempModelos (modelo)
    SELECT DISTINCT modelo FROM balizas;

    -- 2. Insertar en la tabla "modelosBalizas" solo los modelos que no existan como descripción
    INSERT IGNORE INTO modelosBalizas (descripcion)
    SELECT t.modelo 
    FROM TempModelos t
    LEFT JOIN modelosBalizas mb ON t.modelo = mb.descripcion
    WHERE mb.descripcion IS NULL;

    -- 3. Crear una nueva columna en "balizas" llamada "modelosOld" si no existe
    IF NOT EXISTS (
        SELECT * FROM information_schema.columns
        WHERE table_name = 'balizas' AND column_name = 'modelosOld'
    ) THEN
        ALTER TABLE balizas ADD COLUMN modelosOld VARCHAR(255);
    END IF;

    -- 4. Actualizar la columna "modelosOld" con los valores actuales de la columna "modelo"
    UPDATE balizas SET modelosOld = modelo WHERE modelosOld IS NULL;

    -- 5. Eliminar la columna "modelo" si existe
    IF EXISTS (
        SELECT * FROM information_schema.columns
        WHERE table_name = 'balizas' AND column_name = 'modelo'
    ) THEN
        ALTER TABLE balizas DROP COLUMN modelo;
    END IF;

    -- 6. Crear nuevamente la columna "modelo" como tipo int
    ALTER TABLE balizas ADD COLUMN modelo INT;

    -- 7. Llenar la columna "modelo" en "balizas" con los id de la tabla "modelosBalizas"
    UPDATE balizas b
    JOIN modelosBalizas mb ON b.modelosOld = mb.descripcion
    SET b.modelo = mb.id
    WHERE b.modelo IS NULL;

    -- 8. Crear la relación de uno a muchos entre "modelosBalizas" y "balizas"
    IF NOT EXISTS (
        SELECT * FROM information_schema.table_constraints
        WHERE constraint_name = 'fk_modelosBalizas'
    ) THEN
        ALTER TABLE balizas 
        ADD CONSTRAINT fk_modelosBalizas
        FOREIGN KEY (modelo) REFERENCES modelosBalizas(id);
    END IF;

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

    -- 11. Modificar los campos idDataminer, idElement y idGrupo para que no permitan NULL
    ALTER TABLE operaciones 
    MODIFY COLUMN idDataminer INT NOT NULL,
    MODIFY COLUMN idElement INT NOT NULL,
    MODIFY COLUMN idGrupo INT NOT NULL;

    -- Operaciones en la tabla "objetivos"
    -- 12. Eliminar la restricción UNIQUE del campo "descripcion" si existe
    IF EXISTS (
        SELECT * FROM information_schema.table_constraints
        WHERE table_name = 'objetivos' 
        AND constraint_type = 'UNIQUE' 
        AND constraint_name LIKE '%descripcion%'
    ) THEN
        ALTER TABLE objetivos DROP INDEX descripcion;
    END IF;

    -- 13. Crear una llave combinada con los campos "descripcion" e "idOperacion"
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
END //

DELIMITER ;

-- Llamar al procedimiento almacenado
CALL TempProcedure();

-- Eliminar el procedimiento almacenado una vez finalizado
DROP PROCEDURE IF EXISTS TempProcedure;

-- Reactivar la verificación de claves foráneas
SET FOREIGN_KEY_CHECKS = 1;
