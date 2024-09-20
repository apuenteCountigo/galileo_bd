DELIMITER //

CREATE PROCEDURE TempProcedure()
BEGIN
    -- 1. Crear una tabla temporal y almacenar modelos únicos de la tabla "balizas"
    CREATE TEMPORARY TABLE TempModelos (
        modelo VARCHAR(255) PRIMARY KEY
    );

    INSERT INTO TempModelos (modelo)
    SELECT DISTINCT modelo FROM balizas;

    -- 2. Insertar en la tabla "modelosBalizas" solo los modelos que no existan como descripción en la tabla "modelosBalizas"
    INSERT INTO modelosBalizas (descripcion)
    SELECT t.modelo 
    FROM TempModelos t
    LEFT JOIN modelosBalizas mb ON t.modelo = mb.descripcion
    WHERE mb.descripcion IS NULL;

    -- 3. Crear una nueva columna en "balizas" llamada "modelosOld"
    ALTER TABLE balizas ADD COLUMN modelosOld VARCHAR(255);

    -- 4. Actualizar la columna "modelosOld" con los valores actuales de la columna "modelo"
    UPDATE balizas SET modelosOld = modelo;

    -- 5. Eliminar la columna "modelo"
    ALTER TABLE balizas DROP COLUMN modelo;

    -- 6. Crear nuevamente la columna "modelo" como tipo int
    ALTER TABLE balizas ADD COLUMN modelo INT;

    -- 7. Llenar la columna "modelo" en "balizas" con los id de la tabla "modelosBalizas"
    UPDATE balizas b
    JOIN modelosBalizas mb ON b.modelosOld = mb.descripcion
    SET b.modelo = mb.id;

    -- 8. Crear la relación de uno a muchos entre "modelosBalizas" y "balizas"
    ALTER TABLE balizas 
    ADD CONSTRAINT fk_modelosBalizas
    FOREIGN KEY (modelo) REFERENCES modelosBalizas(id);

    -- Limpiar la tabla temporal
    DROP TEMPORARY TABLE IF EXISTS TempModelos;
END //

DELIMITER ;

-- Llamar al procedimiento almacenado temporal
CALL TempProcedure();

-- Eliminar el procedimiento almacenado una vez finalizado
DROP PROCEDURE IF EXISTS TempProcedure;
