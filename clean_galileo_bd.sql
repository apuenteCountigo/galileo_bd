-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Servidor: bd
-- Tiempo de generación: 22-09-2022 a las 08:42:58
-- Versión del servidor: 8.0.29
-- Versión de PHP: 8.0.19

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `galileo_bd`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`%` PROCEDURE `borrarTablaPos` (IN `tableName` VARCHAR(50))   BEGIN
        SET @spaceLess = REPLACE(`tableName`, ' ', '');
        SET @tableName = CONCAT(
            'pos', @spaceLess);
        SET @q = CONCAT(
            'DROP TABLE IF EXISTS `', @tableName, '`;');
        PREPARE stmt FROM @q;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

    END$$

CREATE DEFINER=`root`@`%` PROCEDURE `crearTablaPos` (IN `tableName` VARCHAR(50))   BEGIN
        SET @spaceLess = REPLACE(`tableName`, ' ', '');
        SET @tableName = CONCAT(
            'pos', @spaceLess);
        SET @q = CONCAT(
            'CREATE TABLE `', @tableName, '` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idBalizas` int NOT NULL,
  `clave` varchar(7) DEFAULT NULL,
  `alias` varchar(100) DEFAULT NULL,
  `idPosicion` int(11) DEFAULT NULL, 
  `fechaCaptacion` datetime DEFAULT NULL,
  `timestampServidor` datetime DEFAULT NULL,
  `latitud` float(30) DEFAULT NULL,
  `longitud` float(30) DEFAULT NULL,
  `rumbo` float(10) DEFAULT NULL,
  `velocidad` int(3) DEFAULT NULL,
  `estadoBateria` float(4) DEFAULT NULL,
  `evento` varchar(100) DEFAULT NULL,
  `satelites` int(20) DEFAULT NULL,
  `precision` varchar(20) DEFAULT NULL,
  `senalGps` int(5) DEFAULT NULL,
  `senalGsm` int(5) DEFAULT NULL,
  `mmcBts` int(4) DEFAULT NULL,
  `mncBts` int(4) DEFAULT NULL,
  `lacBts` varchar(20) DEFAULT NULL,
  `toponimia` varchar(255) DEFAULT NULL,
  `notas` longtext,
  PRIMARY KEY (`id`))');
        PREPARE stmt FROM @q;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET @permisos = CONCAT('GRANT ALL PRIVILEGES ON `galileo_bd`.`', @tableName,'` TO `galileo_bd`@`%`;');
        PREPARE stmt1 FROM @permisos;
        EXECUTE stmt1;
        DEALLOCATE PREPARE stmt1;

        SET @flush = 'FLUSH PRIVILEGES';
        PREPARE stmt2 FROM @flush;
        EXECUTE stmt2;
        DEALLOCATE PREPARE stmt2;
        -- Devolver mensaje de confirmación
        SELECT ' created successfully.' AS message;
    END$$

CREATE DEFINER=`root`@`%` PROCEDURE `posUnidad` (IN `tableName` VARCHAR(50), IN `balizasid` VARCHAR(255), IN `fechaInicio` TIMESTAMP, IN `fechaFin` TIMESTAMP)   BEGIN
        SET @spaceLess = REPLACE(`tableName`, '', '');
        SET @tableName = CONCAT(
            'pos', @spaceLess);
        SET @q = CONCAT(
            'SELECT * FROM ', @tableName, ' WHERE idBalizas IN ', `balizasid`, ' AND timestampServidor BETWEEN \'', `fechaInicio`, '\' AND \'', `fechaFin`, '\';');
        PREPARE stmt FROM @q;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END$$

CREATE DEFINER=`root`@`%` PROCEDURE `getPosiciones`(IN `tableName` VARCHAR(50), IN `objetivo` VARCHAR(50), IN `fechaInicio` TIMESTAMP, IN `fechaFin` TIMESTAMP, IN `precision` VARCHAR(50), IN `signo` VARCHAR(4))
BEGIN
        SET @spaceLess = REPLACE(`tableName`, '', '');
        SET @tableName = CONCAT(
            'pos', @spaceLess);
        SET @q = CONCAT(
            'SELECT * FROM ', @tableName, ' WHERE alias= \'', `objetivo`, '\' AND timestampServidor BETWEEN \'', `fechaInicio`, '\' AND \'', `fechaFin`, '\' AND `precision`',`signo`,'\'', `precision`, '\'  ORDER BY clave,timestampServidor ASC;');
        PREPARE stmt FROM @q;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `accionEntidad`
--

CREATE TABLE `accionEntidad` (
  `id` int NOT NULL,
  `descripcion` varchar(20) DEFAULT NULL COMMENT 'Descripción de acciones que pueden realizarse en la aplicación.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Acciones en el contexto de la aplicación.';

--
-- Volcado de datos para la tabla `accionEntidad`
--

INSERT INTO `accionEntidad` (`id`, `descripcion`) VALUES
(1, 'Creación'),
(2, 'Eliminación'),
(3, 'Actualización'),
(4, 'Asignar'),
(5, 'Desasignar');

-- --------------------------------------------------------

CREATE TABLE modelosBalizas (
    id INT NOT NULL AUTO_INCREMENT,
    descripcion VARCHAR(50) UNIQUE,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Estructura de tabla para la tabla `balizas`
--

CREATE TABLE `balizas` (
  `id` int NOT NULL,
  `clave` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8_general_ci DEFAULT NULL COMMENT 'Clave de identificación de la baliza.',
  `marca` varchar(15) DEFAULT NULL,
  `modelo` varchar(15) DEFAULT NULL,
  `numSerie` varchar(50) DEFAULT NULL,
  `tipoCoordenada` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8_general_ci DEFAULT NULL COMMENT 'Tipo de coordenada que facilita (coordenadas / Proyección).',
  `imei` varchar(20) DEFAULT NULL,
  `telefono1` varchar(13) DEFAULT NULL COMMENT 'Número de abonado asociado a la SIM utilizada',
  `compania` varchar(255) DEFAULT NULL,
  `pin1` varchar(4) DEFAULT NULL,
  `pin2` varchar(4) DEFAULT NULL,
  `puk` varchar(10) DEFAULT NULL,
  `iccTarjeta` varchar(20) DEFAULT NULL,
  `fechaAlta` timestamp NULL DEFAULT NULL COMMENT 'Fecha de compra o adquisición del dispositivo.',
  `fechaAsignaUni` date DEFAULT NULL,
  `fechaAsignaOp` date DEFAULT NULL,
  `idDataminer` varchar(45) DEFAULT NULL,
  `idElement` varchar(45) DEFAULT NULL COMMENT 'Identificador de elemento devuelto por la API de Dataminer una vez confirmada la creación de la baliza como elemento.',
  `puerto` varchar(10) DEFAULT NULL,
  `idModeloBaliza` int DEFAULT NULL,
  `idTipoBaliza` int DEFAULT NULL,
  `idEstadoBaliza` int NOT NULL,
  `idUnidad` int DEFAULT NULL COMMENT 'Id de la unidad explotadora de la baliza, si es null no esta asignada.',
  `idTipoContrato` int DEFAULT NULL COMMENT 'Id del tipo de contrato establecido con la operadora.',
  `idConexion` int NOT NULL,
  `notas` longtext CHARACTER SET utf8mb3 COLLATE utf8_general_ci,
  `operacion` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8_general_ci DEFAULT NULL,
  `objetivo` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Tabla de metadatos de balizas.';

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `conexiones`
--

CREATE TABLE `conexiones` (
  `id` int NOT NULL,
  `servicio` varchar(15) DEFAULT NULL,
  `ipServicio` varchar(15) DEFAULT NULL,
  `puerto` varchar(6) CHARACTER SET utf8mb3 COLLATE utf8_general_ci DEFAULT NULL,
  `usuario` varchar(15) DEFAULT NULL,
  `password` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8_general_ci DEFAULT NULL,
  `fechaCreacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `dmaID` int DEFAULT NULL,
  `viewIDs` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Datos de conexiones necesarias para la comunicación del Backend de la página web con el resto de aplicaciones.';

--
-- Volcado de datos para la tabla `conexiones`
--

INSERT INTO `conexiones` (`id`, `servicio`, `ipServicio`, `puerto`, `usuario`, `password`, `fechaCreacion`, `dmaID`, `viewIDs`) VALUES
(1, 'TRACCAR', '192.168.0.198', '8082', 'admin', 'admin', '2022-07-02 21:02:59', NULL, NULL),
(2, 'DATAMINER', '192.168.0.200', '8084', 'countigo', 'Countigo2022!', '2022-07-02 21:02:59', 2633, 312),
(4, 'BASE DE DATOS', '192.168.7.22', '443', 'super', '12345', '2022-07-02 21:02:59', NULL, NULL),
(7, 'FTP', '192.168.0.246', NULL, 'Countigo', 'Countigo2022!', '2022-07-18 14:28:41', 1, NULL),
(9, 'OTROS', '10.10.10.6', '8080', 'admin', 'admin', '2022-07-27 01:57:02', NULL, NULL),
(10, 'BASE DE DATOS', '192.168.1.2', '8988', 'root', '12345678', '2022-09-01 18:30:43', NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `documentos`
--

CREATE TABLE `documentos` (
  `id` int NOT NULL,
  `descripcion` varchar(45) DEFAULT NULL,
  `ubicacion` varchar(255) DEFAULT NULL,
  `idBalizas` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empleos`
--

CREATE TABLE `empleos` (
  `id` int NOT NULL,
  `descripcion` varchar(20) DEFAULT NULL COMMENT 'Empleo de los usuarios de la organización. Valores: Guardia Civil, Cabo, Cabo1, Sargento, Sargento 1º, Brigada, Subteniente, Suboficial Mayor, Alférez, Teniente, Capitan, Comandante, Teniente Coronel, Coronel, General de Brigada.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Tabla de empleos de la organización.';

--
-- Volcado de datos para la tabla `empleos`
--

INSERT INTO `empleos` (`id`, `descripcion`) VALUES
(13, 'Alférez'),
(10, 'Brigada'),
(3, 'Cabo'),
(7, 'Cabo1'),
(15, 'Capitán'),
(16, 'Comandante'),
(18, 'Coronel'),
(19, 'General de Brigada'),
(4, 'Guardia Civil'),
(33, 'Prueba'),
(36, 'Prueba 2'),
(8, 'Sargento'),
(9, 'Sargento 1º'),
(12, 'Suboficial Mayor'),
(11, 'Subteniente'),
(14, 'Teniente'),
(17, 'Teniente Coronel');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estados`
--

CREATE TABLE `estados` (
  `id` int NOT NULL,
  `descripcion` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8_general_ci DEFAULT NULL COMMENT 'Descripción del estado en el contexto de la entidad de referencia. \\nBalizas (entidad): Operativa, Averiada, Perdida, Baja.\\nOperaciones: Activa, Durmiente, Finalizada.\\nUsuario: Activo, Desactivado.',
  `tipoEntidad_id` int NOT NULL COMMENT 'Id de la entidad de referencia que da contexto al estado. Balizas, operaciones, objetivos.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Nomenclador de estados de las diferentes entidades que conforman el dominio de la aplicación.';

--
-- Volcado de datos para la tabla `estados`
--

INSERT INTO `estados` (`id`, `descripcion`, `tipoEntidad_id`) VALUES
(2, 'ACTIVO', 2),
(4, 'DESACTIVADO', 2),
(6, 'PERMANENTE', 4),
(7, 'INVITADO', 4),
(8, 'Operativa', 3),
(9, 'En Reparación', 3),
(10, 'En Instalación', 3),
(11, 'Perdida', 3),
(12, 'Baja', 3),
(18, 'Disponible en Unidad', 3),
(19, 'Sin Inicializar', 3),
(20, 'A Recuperar', 3),
(21, 'Sin Asignar a Unidad', 3),
(23, 'Activa', 6),
(24, 'Durmiente', 6),
(25, 'Finalizada', 6);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `historicoObjetivosBalizas`
--

CREATE TABLE `historicoObjetivosBalizas` (
  `id` int NOT NULL,
  `idObjetivo` int NOT NULL,
  `idBaliza` int NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `idAccion` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `invitadoExterno`
--

CREATE TABLE `invitadoExterno` (
  `id` int NOT NULL,
  `compannia` varchar(45) DEFAULT NULL COMMENT 'Compañía a la que pertenece el agente externo.',
  `fechaExpiracion` date DEFAULT NULL COMMENT 'Fecha de expiración en el sistema.',
  `usuarios_id` int NOT NULL,
  `idAgente` int DEFAULT NULL COMMENT 'Agente que ha invitado al agente externo.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Tabla para registrar información de usuarios externos a la organización.';

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `juzgados`
--

CREATE TABLE `juzgados` (
  `id` int NOT NULL,
  `descripcion` varchar(45) DEFAULT NULL COMMENT 'Nombre del juzgado.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Tabla de juzgados.';

--
-- Volcado de datos para la tabla `juzgados`
--

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `listaTablasPos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `listaTablasPos` (
`idUnidad` bigint unsigned
,`tablaPos` varchar(64)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `listaUnidadesTablaPosiciones`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `listaUnidadesTablaPosiciones` (
`denominacion` varchar(50)
,`idUnidad` bigint unsigned
,`tablaPos` varchar(64)
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `objetivos`
--

CREATE TABLE `objetivos` (
  `id` int NOT NULL,
  `descripcion` text COMMENT 'Nombre o breve descripción del objetivo.',
  `urgencia` enum('Sí','No') DEFAULT NULL COMMENT 'Si concurren o no razones de urgencia en la instalación.',
  `finalAuto` date DEFAULT NULL COMMENT 'Fecha de finalización de la autorización judicial.',
  `emailIncidenciaJud` text COMMENT 'Correo electrónico donde se comunicarán las incidencias de cese de la medida judicial (fecha de terminación de la medida, etc.).',
  `observaciones` longtext,
  `idBaliza` int DEFAULT NULL COMMENT 'Medio de la tabla de dispositivos balizas disponibles.',
  `idOperacion` int NOT NULL COMMENT 'Id de la operación o tipo de trabajo solicitado.',
  `fechaCreacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `traccarID` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Tabla de objetivos.';

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `operaciones`
--

CREATE TABLE `operaciones` (
  `id` int NOT NULL COMMENT 'Id de las operaciones.',
  `nombre` varchar(30) NOT NULL COMMENT 'Nombre de la operación.',
  `fechaInicio` date NOT NULL COMMENT 'Fecha de inicio de la operación.',
  `fechaFin` date DEFAULT NULL COMMENT 'Fecha de finalización de la operación.',
  `idDataminer` int DEFAULT NULL COMMENT 'Id asignado a la operación por la API de Dataminer una vez confirmada su creación en la plataforma.',
  `idElement` int DEFAULT NULL,
  `observaciones` longtext,
  `idUnidad` int NOT NULL COMMENT 'Id de la unidad donde se creó la operación.',
  `idJuzgado` int DEFAULT NULL,
  `diligencias` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8_general_ci DEFAULT NULL,
  `idEstado` int NOT NULL COMMENT 'Id de estado de la operación.',
  `fechaCreacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `idGrupo` int DEFAULT NULL COMMENT 'Id generado en Traccar al crear la operación.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Tabla para el registro de los datos de las operaciones.';

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `perfiles`
--

CREATE TABLE `perfiles` (
  `id` int NOT NULL,
  `descripcion` varchar(50) NOT NULL COMMENT 'Roles de usuario en la aplicación web. Valores: Super administrador, Administrador de unidad, Usuario final, Usuario invitado externo.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Tabla de roles de usuario en la aplicación web.';

--
-- Volcado de datos para la tabla `perfiles`
--

INSERT INTO `perfiles` (`id`, `descripcion`) VALUES
(2, 'Administrador de Unidad'),
(4, 'Invitado Externo'),
(1, 'Super Administrador'),
(3, 'Usuario Final');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `permisos`
--

CREATE TABLE `permisos` (
  `id` int NOT NULL,
  `idTipoEntidad` int NOT NULL,
  `idEntidad` int NOT NULL,
  `idUsuario` int NOT NULL,
  `permisos` varchar(10) NOT NULL,
  `fechaCreacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------


--
-- Estructura de tabla para la tabla `posiciones`
--

CREATE TABLE `posiciones` (
  `id` int NOT NULL,
  `idBalizas` int NOT NULL,
  `clave` varchar(7) DEFAULT NULL,
  `alias` varchar(100) DEFAULT NULL,
  `idPosicion` int DEFAULT NULL,
  `fechaCaptacion` datetime DEFAULT NULL,
  `timestampServidor` datetime DEFAULT NULL,
  `latitud` double DEFAULT NULL,
  `longitud` double DEFAULT NULL,
  `rumbo` float DEFAULT NULL,
  `velocidad` int DEFAULT NULL,
  `estadoBateria` float DEFAULT NULL,
  `evento` varchar(100) DEFAULT NULL,
  `satelites` int DEFAULT NULL,
  `precision` varchar(20) DEFAULT NULL,
  `senalGps` int DEFAULT NULL,
  `senalGsm` int DEFAULT NULL,
  `mmcBts` int DEFAULT NULL,
  `mncBts` int DEFAULT NULL,
  `lacBts` varchar(20) DEFAULT NULL,
  `toponimia` varchar(255) DEFAULT NULL,
  `notas` longtext
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `progresos`
--

CREATE TABLE `progresos` (
  `id` int NOT NULL,
  `idUsuario` int NOT NULL,
  `valor` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `provincias`
--

CREATE TABLE `provincias` (
  `id` int NOT NULL,
  `descripcion` varchar(45) NOT NULL COMMENT 'Lugar donde se realiza la instalación o posibilidad de añadir ubicaciones. Valores: Sin determinar, La Coruña, Alava, Albacete, Alicante, Algeciras, Almeria, Oviedo, Gijón, Ávila, Badajoz, Baleares, Barcelona, Burgos, Cáceres, Cadiz, Cantabria, Castellón, Ceuta, Ciudad Real, Córdoba, Cuenca, Gerona, Granada, Guadalajara, Guipuzcoa, Huelva, Huesca, Jaen, La Rioja, Las Palmas, León, Lérida, Lugo, Madrid, Málaga, Melilla, Murcia, Navarra, Orense, Palencia, Pontevedra, Salamanca, Santa Cruz de Tenerife, Segovia, Sevilla, Soria, Tarragona, Teruel, Toledo, Valencia, Valladolid, Vizcaya, Zamora, Zaragoza, Otro lugar.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Tabla de provincias.';

--
-- Volcado de datos para la tabla `provincias`
--

INSERT INTO `provincias` (`id`, `descripcion`) VALUES
(55, ' Las Palmas'),
(5, 'Alava'),
(4, 'Albacete'),
(10, 'Algeciras'),
(9, 'Alicante'),
(11, 'Almeria'),
(14, 'Ávila'),
(20, 'Badajoz'),
(26, 'Baleares'),
(22, 'Barcelona'),
(28, 'Burgos'),
(29, 'Cáceres'),
(30, 'Cadiz'),
(31, 'Cantabria'),
(32, 'Castellón'),
(38, 'Ceuta'),
(34, 'Ciudad Real'),
(35, 'Córdoba'),
(46, 'Cuenca'),
(42, 'Gerona'),
(18, 'Gijón'),
(43, 'Granada'),
(44, 'Guadalajara'),
(50, 'Guipuzcoa'),
(56, 'Huelva'),
(57, 'Huesca'),
(58, 'Jaen'),
(2, 'La Coruña'),
(54, 'La Rioja'),
(66, 'León'),
(67, 'Lérida'),
(63, 'Lugo'),
(64, 'Madrid'),
(65, 'Málaga'),
(71, 'Melilla'),
(72, 'Murcia'),
(79, 'Orense'),
(110, 'Otro lugar'),
(12, 'Oviedo'),
(80, 'Palencia'),
(81, 'Pontevedra'),
(82, 'Salamanca'),
(83, 'Santa Cruz de Tenerife'),
(84, 'Segovia'),
(85, 'Sevilla'),
(1, 'Sin determinar'),
(91, 'Soria'),
(97, 'Tarragona'),
(93, 'Teruel'),
(94, 'Toledo'),
(100, 'Valencia'),
(101, 'Valladolid'),
(102, 'Vizcaya'),
(103, 'Zamora'),
(104, 'Zaragoza');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipoBaliza`
--

CREATE TABLE `tipoBaliza` (
  `id` int NOT NULL,
  `descripcion` varchar(20) DEFAULT NULL COMMENT 'Modo de funcionamiento de baliza. Ej.: GPS-GSM, GPS-GPRS, GPSDATOS, ARGOS, GPSARGOS, GPS-GPRS-IRIDIUM, GPS-IRIDIUM.',
  `icono` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Nomenclador de tipos de baliza según su funcionamiento.';

--
-- Volcado de datos para la tabla `tipoBaliza`
--

INSERT INTO `tipoBaliza` (`id`, `descripcion`, `icono`) VALUES
(1, 'GPS-GSM', NULL),
(2, 'GPS-GPRS', NULL),
(3, 'GPSDATOS', NULL),
(4, 'ARGOS', NULL),
(5, 'GPSARGOS', NULL),
(6, 'GPS-GPRS-IRIDIUM', NULL),
(7, 'GPS-IRIDIUM', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipoContrato`
--

CREATE TABLE `tipoContrato` (
  `id` int NOT NULL,
  `descripcion` varchar(20) DEFAULT NULL COMMENT 'Tipo de contrato establecido con la operadora. Valores: Contrato GC, Otros contratos, Prepago, Recarga automática.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Nomenclador de tipos de contratos.';

--
-- Volcado de datos para la tabla `tipoContrato`
--

INSERT INTO `tipoContrato` (`id`, `descripcion`) VALUES
(1, 'Contrato GC'),
(2, 'Otros contratos'),
(3, 'Prepago'),
(4, 'Recarga automática');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipoEntidad`
--

CREATE TABLE `tipoEntidad` (
  `id` int NOT NULL,
  `descripcion` varchar(20) NOT NULL COMMENT 'Descripción de los tipos de entidades correspondientes al dominio de la aplicación. Ej: balizas, operaciones, etc.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Tabla de los tipos de entidades del dominio de aplicación. Ej.: balizas, operaciones, etc.';

--
-- Volcado de datos para la tabla `tipoEntidad`
--

INSERT INTO `tipoEntidad` (`id`, `descripcion`) VALUES
(3, 'balizas'),
(8, 'objetivos'),
(6, 'operaciones'),
(10, 'Permisos'),
(5, 'unidades'),
(4, 'unidadesUsuarios'),
(2, 'usuarios');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `trazas`
--

CREATE TABLE `trazas` (
  `id` int NOT NULL,
  `idEntidad` int DEFAULT NULL,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Momento de ocurrida la acción en el sistema.',
  `idTipoEntidad` int NOT NULL COMMENT 'Tipo de entidad donde ocurrió la acción.',
  `idAccionEntidad` int NOT NULL COMMENT 'Acción ocurrida en el sistema.',
  `idusuario` int NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Registro de trazas de actividad en el sistema.	';

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `unidades`
--

CREATE TABLE `unidades` (
  `id` int NOT NULL COMMENT 'Id de la Unidad',
  `denominacion` varchar(50) NOT NULL COMMENT 'Denominación de la unidad o Grupo',
  `responsable` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8_general_ci DEFAULT NULL,
  `telefono` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8_general_ci DEFAULT NULL COMMENT 'Telefono de contacto de la unidad.',
  `groupWise` varchar(25) CHARACTER SET utf8mb3 COLLATE utf8_general_ci DEFAULT NULL COMMENT 'Group wise de la Unidad',
  `direccion` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8_general_ci DEFAULT NULL COMMENT 'Dirección, calle y número',
  `codigoPostal` varchar(5) CHARACTER SET utf8mb3 COLLATE utf8_general_ci DEFAULT NULL COMMENT 'Código Postal',
  `localidad` varchar(45) DEFAULT NULL,
  `idprovincia` int DEFAULT NULL COMMENT 'Id de la localidad de la ubicación de la Unidad.',
  `fechaCreacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `email` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8_general_ci DEFAULT NULL,
  `notas` longtext CHARACTER SET utf8mb3 COLLATE utf8_general_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Tabla de unidades.';

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `unidadesUsuarios`
--

CREATE TABLE `unidadesUsuarios` (
  `id` int NOT NULL,
  `idunidad` int NOT NULL,
  `idusuario` int NOT NULL,
  `expira` timestamp NULL DEFAULT NULL,
  `estado` int NOT NULL,
  `fechaCreacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id` int NOT NULL,
  `tip` varchar(7) NOT NULL COMMENT 'Tarjeta de identidad profesional del cliente',
  `nombre` varchar(20) NOT NULL COMMENT 'Nombre del agente',
  `apellidos` varchar(50) NOT NULL COMMENT 'Apellidos del agente',
  `contacto` varchar(11) DEFAULT NULL COMMENT 'Teléfono de contacto del agente para notificaciones de la plataforma',
  `email` varchar(30) DEFAULT NULL COMMENT 'Email de contacto del agente para notificaciones de la plataforma.',
  `password` varchar(255) NOT NULL COMMENT 'Password de acceso a la plataforma',
  `certificado` text NOT NULL COMMENT 'Certificado para acceso a VPN',
  `observaciones` longtext,
  `traccar` varchar(255) DEFAULT NULL COMMENT 'Token Traccar',
  `traccarID` int DEFAULT NULL COMMENT 'Id de Traccar',
  `idPerfil` int NOT NULL COMMENT 'Id del nivel de usuario.',
  `idEmpleo` int NOT NULL COMMENT 'Id del empleo del usuario.',
  `estado` int NOT NULL COMMENT 'Id de estado del usuario. Valores: Activo, Desactivado.',
  `fechaCreacion` datetime DEFAULT CURRENT_TIMESTAMP,
  `idUnidad` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id`, `tip`, `nombre`, `apellidos`, `contacto`, `email`, `password`, `certificado`, `observaciones`, `traccar`, `traccarID`, `idPerfil`, `idEmpleo`, `estado`, `fechaCreacion`, `idUnidad`) VALUES
(173, 'XZ100', 'Leo', 'Alvarez', '21323232', 'leo@gmail.com', '$2a$10$Za9bh0lVURAVGelJYIurROdfAvXveLa6KcYUx9qwyC5KZU29w8Z/e', 'acf', '', '12c7dd95-5b1e-455f-8598-4c62da28c545', 253, 1, 18, 2, '2022-03-07 16:52:05', NULL);

-- --------------------------------------------------------

--
-- Estructura para la vista `listaTablasPos`
--
DROP TABLE IF EXISTS `listaTablasPos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `listaTablasPos`  AS SELECT cast(substr(`information_schema`.`tables`.`TABLE_NAME`,4) as unsigned) AS `idUnidad`, `information_schema`.`tables`.`TABLE_NAME` AS `tablaPos` FROM `information_schema`.`TABLES` AS `tables` WHERE ((`information_schema`.`tables`.`TABLE_SCHEMA` = 'galileo_bd') AND (substr(`information_schema`.`tables`.`TABLE_NAME`,1,3) = 'pos'))  ;

-- --------------------------------------------------------

--
-- Estructura para la vista `listaUnidadesTablaPosiciones`
--
DROP TABLE IF EXISTS `listaUnidadesTablaPosiciones`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `listaUnidadesTablaPosiciones`  AS SELECT `listaTablasPos`.`idUnidad` AS `idUnidad`, `unidades`.`denominacion` AS `denominacion`, `listaTablasPos`.`tablaPos` AS `tablaPos` FROM (`listaTablasPos` join `unidades` on((`unidades`.`id` = `listaTablasPos`.`idUnidad`)))  ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `accionEntidad`
--
ALTER TABLE `accionEntidad`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `balizas`
--
ALTER TABLE `balizas`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `clave` (`clave`),
  ADD UNIQUE KEY `clave_2` (`clave`),
  ADD KEY `fk_t_balizas_t_tipo_baliza1_idx` (`idTipoBaliza`),
  ADD KEY `fk_t_balizas_t_estado_baliza1_idx` (`idEstadoBaliza`),
  ADD KEY `fk_t_balizas_t_unidades1_idx` (`idUnidad`),
  ADD KEY `fk_t_balizas_t_tipo_contrato1_idx` (`idTipoContrato`),
  ADD KEY `fk_t_balizas_t_modeloBaliza1_idx` (`idModeloBaliza`),
  ADD KEY `idConexion` (`idConexion`);

--
-- Indices de la tabla `conexiones`
--
ALTER TABLE `conexiones`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `documentos`
--
ALTER TABLE `documentos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_documentos_balizas1_idx` (`idBalizas`);

--
-- Indices de la tabla `empleos`
--
ALTER TABLE `empleos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `descripcion` (`descripcion`);

--
-- Indices de la tabla `estados`
--
ALTER TABLE `estados`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_estados_tipoEntidad1_idx` (`tipoEntidad_id`);

--
-- Indices de la tabla `historicoObjetivosBalizas`
--
ALTER TABLE `historicoObjetivosBalizas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idBaliza` (`idBaliza`),
  ADD KEY `idObjetivo` (`idObjetivo`),
  ADD KEY `idAccion` (`idAccion`);

--
-- Indices de la tabla `invitadoExterno`
--
ALTER TABLE `invitadoExterno`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_invitadoExterno_usuarios1_idx` (`usuarios_id`);

--
-- Indices de la tabla `juzgados`
--
ALTER TABLE `juzgados`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `objetivos`
--
ALTER TABLE `objetivos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_t_objetivos_t_balizas1_idx` (`idBaliza`),
  ADD KEY `fk_t_objetivos_t_operaciones1_idx` (`idOperacion`);

--
-- Indices de la tabla `operaciones`
--
ALTER TABLE `operaciones`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nombre_UNIQUE` (`nombre`),
  ADD UNIQUE KEY `nombre` (`nombre`),
  ADD KEY `fk_t_operaciones_t_unidades1_idx` (`idUnidad`),
  ADD KEY `fk_t_operaciones_estados1_idx` (`idEstado`),
  ADD KEY `idJuzgado` (`idJuzgado`);

--
-- Indices de la tabla `perfiles`
--
ALTER TABLE `perfiles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `descripcion` (`descripcion`);

--
-- Indices de la tabla `permisos`
--
ALTER TABLE `permisos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idTipoEntidad` (`idTipoEntidad`),
  ADD KEY `idUsuario` (`idUsuario`);

--

--
-- Indices de la tabla `posiciones`
--
ALTER TABLE `posiciones`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `progresos`
--
ALTER TABLE `progresos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idUsuario` (`idUsuario`);

--
-- Indices de la tabla `provincias`
--
ALTER TABLE `provincias`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `descripcion` (`descripcion`);

--
-- Indices de la tabla `tipoBaliza`
--
ALTER TABLE `tipoBaliza`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `descripcion` (`descripcion`);

--
-- Indices de la tabla `tipoContrato`
--
ALTER TABLE `tipoContrato`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `descripcion` (`descripcion`);

--
-- Indices de la tabla `tipoEntidad`
--
ALTER TABLE `tipoEntidad`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `descripcion` (`descripcion`);

--
-- Indices de la tabla `trazas`
--
ALTER TABLE `trazas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_trazas_tipoEntidad1_idx` (`idTipoEntidad`),
  ADD KEY `fk_trazas_accionEntidad1_idx` (`idAccionEntidad`),
  ADD KEY `idusuario` (`idusuario`);

--
-- Indices de la tabla `unidades`
--
ALTER TABLE `unidades`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `denominacion` (`denominacion`) USING BTREE,
  ADD KEY `fk_t_unidades_t_localidad1_idx` (`idprovincia`);

--
-- Indices de la tabla `unidadesUsuarios`
--
ALTER TABLE `unidadesUsuarios`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idunidad` (`idunidad`),
  ADD KEY `idusuario` (`idusuario`),
  ADD KEY `estado` (`estado`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `TIP_UNIQUE` (`tip`),
  ADD KEY `fk_t_usuarios_t_rol_idx` (`idPerfil`),
  ADD KEY `fk_t_usuarios_t_empleo1_idx` (`idEmpleo`),
  ADD KEY `fk_usuarios_estados1_idx` (`estado`),
  ADD KEY `idUnidad` (`idUnidad`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `accionEntidad`
--
ALTER TABLE `accionEntidad`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `balizas`
--
ALTER TABLE `balizas`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=143;

--
-- AUTO_INCREMENT de la tabla `conexiones`
--
ALTER TABLE `conexiones`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de la tabla `empleos`
--
ALTER TABLE `empleos`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT de la tabla `estados`
--
ALTER TABLE `estados`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT de la tabla `historicoObjetivosBalizas`
--
ALTER TABLE `historicoObjetivosBalizas`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=136;

--
-- AUTO_INCREMENT de la tabla `invitadoExterno`
--
ALTER TABLE `invitadoExterno`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `juzgados`
--
ALTER TABLE `juzgados`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT de la tabla `objetivos`
--
ALTER TABLE `objetivos`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=147;

--
-- AUTO_INCREMENT de la tabla `operaciones`
--
ALTER TABLE `operaciones`
  MODIFY `id` int NOT NULL AUTO_INCREMENT COMMENT 'Id de las operaciones.', AUTO_INCREMENT=256;

--
-- AUTO_INCREMENT de la tabla `perfiles`
--
ALTER TABLE `perfiles`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `permisos`
--
ALTER TABLE `permisos`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=138;

--

--
-- AUTO_INCREMENT de la tabla `posiciones`
--
ALTER TABLE `posiciones`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `progresos`
--
ALTER TABLE `progresos`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT de la tabla `provincias`
--
ALTER TABLE `provincias`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=111;

--
-- AUTO_INCREMENT de la tabla `tipoBaliza`
--
ALTER TABLE `tipoBaliza`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `tipoContrato`
--
ALTER TABLE `tipoContrato`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `tipoEntidad`
--
ALTER TABLE `tipoEntidad`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `trazas`
--
ALTER TABLE `trazas`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1799;

--
-- AUTO_INCREMENT de la tabla `unidades`
--
ALTER TABLE `unidades`
  MODIFY `id` int NOT NULL AUTO_INCREMENT COMMENT 'Id de la Unidad', AUTO_INCREMENT=975;

--
-- AUTO_INCREMENT de la tabla `unidadesUsuarios`
--
ALTER TABLE `unidadesUsuarios`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=387;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=347;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `balizas`
--
ALTER TABLE `balizas`
  ADD CONSTRAINT `balizas_ibfk_1` FOREIGN KEY (`idConexion`) REFERENCES `conexiones` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `fk_t_balizas_t_estado_baliza1` FOREIGN KEY (`idEstadoBaliza`) REFERENCES `estados` (`id`),
  ADD CONSTRAINT `fk_t_balizas_t_tipo_baliza1` FOREIGN KEY (`idTipoBaliza`) REFERENCES `tipoBaliza` (`id`),
  ADD CONSTRAINT `fk_t_balizas_t_tipo_contrato1` FOREIGN KEY (`idTipoContrato`) REFERENCES `tipoContrato` (`id`),
  ADD CONSTRAINT `fk_modeloBaliza` FOREIGN KEY (`idModeloBaliza`) REFERENCES `modelosBalizas` (`id`),
  ADD CONSTRAINT `fk_t_balizas_t_unidades1` FOREIGN KEY (`idUnidad`) REFERENCES `unidades` (`id`);

--
-- Filtros para la tabla `documentos`
--
ALTER TABLE `documentos`
  ADD CONSTRAINT `fk_documentos_balizas1` FOREIGN KEY (`idBalizas`) REFERENCES `balizas` (`id`);

--
-- Filtros para la tabla `estados`
--
ALTER TABLE `estados`
  ADD CONSTRAINT `fk_estados_tipoEntidad1` FOREIGN KEY (`tipoEntidad_id`) REFERENCES `tipoEntidad` (`id`);

--
-- Filtros para la tabla `historicoObjetivosBalizas`
--
ALTER TABLE `historicoObjetivosBalizas`
  ADD CONSTRAINT `historicoObjetivosBalizas_ibfk_1` FOREIGN KEY (`idAccion`) REFERENCES `accionEntidad` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `historicoObjetivosBalizas_ibfk_2` FOREIGN KEY (`idBaliza`) REFERENCES `balizas` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `historicoObjetivosBalizas_ibfk_3` FOREIGN KEY (`idObjetivo`) REFERENCES `objetivos` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `invitadoExterno`
--
ALTER TABLE `invitadoExterno`
  ADD CONSTRAINT `fk_invitadoExterno_usuarios1` FOREIGN KEY (`usuarios_id`) REFERENCES `usuarios` (`id`);

--
-- Filtros para la tabla `objetivos`
--
ALTER TABLE `objetivos`
  ADD CONSTRAINT `fk_t_objetivos_t_balizas1` FOREIGN KEY (`idBaliza`) REFERENCES `balizas` (`id`),
  ADD CONSTRAINT `fk_t_objetivos_t_operaciones1` FOREIGN KEY (`idOperacion`) REFERENCES `operaciones` (`id`);

--
-- Filtros para la tabla `operaciones`
--
ALTER TABLE `operaciones`
  ADD CONSTRAINT `fk_t_operaciones_estados1` FOREIGN KEY (`idEstado`) REFERENCES `estados` (`id`),
  ADD CONSTRAINT `fk_t_operaciones_t_unidades1` FOREIGN KEY (`idUnidad`) REFERENCES `unidades` (`id`),
  ADD CONSTRAINT `operaciones_ibfk_1` FOREIGN KEY (`idJuzgado`) REFERENCES `juzgados` (`id`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `permisos`
--
ALTER TABLE `permisos`
  ADD CONSTRAINT `permisos_ibfk_1` FOREIGN KEY (`idTipoEntidad`) REFERENCES `tipoEntidad` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `permisos_ibfk_2` FOREIGN KEY (`idUsuario`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `progresos`
--
ALTER TABLE `progresos`
  ADD CONSTRAINT `progresos_ibfk_1` FOREIGN KEY (`idUsuario`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `trazas`
--
ALTER TABLE `trazas`
  ADD CONSTRAINT `fk_trazas_accionEntidad1` FOREIGN KEY (`idAccionEntidad`) REFERENCES `accionEntidad` (`id`),
  ADD CONSTRAINT `fk_trazas_tipoEntidad1` FOREIGN KEY (`idTipoEntidad`) REFERENCES `tipoEntidad` (`id`),
  ADD CONSTRAINT `trazas_ibfk_1` FOREIGN KEY (`idusuario`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `unidades`
--
ALTER TABLE `unidades`
  ADD CONSTRAINT `fk_t_unidades_t_localidad1` FOREIGN KEY (`idprovincia`) REFERENCES `provincias` (`id`);

--
-- Filtros para la tabla `unidadesUsuarios`
--
ALTER TABLE `unidadesUsuarios`
  ADD CONSTRAINT `unidadesUsuarios_ibfk_1` FOREIGN KEY (`idunidad`) REFERENCES `unidades` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `unidadesUsuarios_ibfk_2` FOREIGN KEY (`idusuario`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `unidadesUsuarios_ibfk_3` FOREIGN KEY (`estado`) REFERENCES `estados` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD CONSTRAINT `fk_t_usuarios_t_empleo1` FOREIGN KEY (`idEmpleo`) REFERENCES `empleos` (`id`),
  ADD CONSTRAINT `fk_t_usuarios_t_rol` FOREIGN KEY (`idPerfil`) REFERENCES `perfiles` (`id`),
  ADD CONSTRAINT `fk_usuarios_estados1` FOREIGN KEY (`estado`) REFERENCES `estados` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
