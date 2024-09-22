CREATE TABLE `modelosBalizas` (
    `id` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `descripcion` VARCHAR(50) UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


ALTER TABLE operaciones 
    MODIFY COLUMN nombre VARCHAR(255) NOT NULL;

ALTER TABLE objetivos 
    MODIFY COLUMN descripcion VARCHAR(255) NOT NULL;

UPDATE operaciones SET idDataminer = 0 WHERE idDataminer IS NULL;
UPDATE operaciones SET idElement = 0 WHERE idElement IS NULL;
UPDATE operaciones SET idGrupo = 0 WHERE idGrupo IS NULL;

UPDATE objetivos SET traccarID = 0 WHERE traccarID IS NULL;