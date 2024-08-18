-- Paso 1: Verificar si la tabla 'modelosBalizas' ya existe
SET @table_name = 'modelosBalizas';
SET @table_exists = (
    SELECT COUNT(*)
    FROM information_schema.tables
    WHERE table_name = @table_name
    AND table_schema = DATABASE()
);

-- Paso 2: Crear la tabla solo si no existe
IF @table_exists = 0 THEN
    CREATE TABLE modelosBalizas (
        id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
        descripcion VARCHAR(50) UNIQUE
    );
END IF;

-- Paso 1: Verificar si la columna 'idModeloBaliza' ya existe
SET @column_name = 'idModeloBaliza';
SET @column_exists = (
    SELECT COUNT(*)
    FROM information_schema.columns
    WHERE table_name = 'Balizas'
    AND column_name = @column_name
    AND table_schema = DATABASE()
);

-- Paso 2: Agregar la columna 'idModeloBaliza' solo si no existe
IF @column_exists = 0 THEN
    ALTER TABLE Balizas
    ADD COLUMN idModeloBaliza INT NULL;
END IF;

-- Paso 3: Crear la relación de clave foránea
ALTER TABLE Balizas
ADD CONSTRAINT fk_modeloBaliza
FOREIGN KEY (idModeloBaliza) REFERENCES modelosBalizas(id)
ON DELETE SET NULL
ON UPDATE CASCADE;
