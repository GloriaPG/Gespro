CREATE TABLE `gespro`.`usuarios_monitor` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(50) NULL,
  `apellido_paterno` VARCHAR(50) NULL,
  `apellido_materno` VARCHAR(50) NULL,
  `email` VARCHAR(50) NOT NULL,
  `password` VARCHAR(250) NOT NULL,
  `activo` BIT NULL,
  PRIMARY KEY (`id`));
  
  CREATE TABLE `gespro`.`moneda` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(45) NOT NULL,
  `codigo` VARCHAR(45) NULL,
  `simbolo` VARCHAR(1) NOT NULL,
  `activo` BIT NULL,
  PRIMARY KEY (`id`));


ALTER TABLE `gespro`.`datos_usuario` 
ADD COLUMN `CIUDAD` VARCHAR(60) NULL AFTER `NUM_EMPLEADO`;
