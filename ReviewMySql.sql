DROP DATABASE IF EXISTS sistema_clinico;
CREATE DATABASE sistema_clinico;
USE sistema_clinico;

-- PACIENTES
CREATE TABLE registro_pacientes (
    Id_Paciente VARCHAR(10) PRIMARY KEY,
    Nombre_Paciente VARCHAR(50) NOT NULL,
    Telefono_Paciente VARCHAR(20)
);

INSERT INTO registro_pacientes (Id_Paciente, Nombre_Paciente, Telefono_Paciente) VALUES
('P-501', 'Juan Rivas', '600-111'),
('P-502', 'Ana Soto', '600-222'),
('P-503', 'Luis Paz', '600-333');

-- FACULTADES
CREATE TABLE catalogo_facultades (
    Id_Facultad VARCHAR(10) PRIMARY KEY,
    Nombre_Facultad VARCHAR(50) NOT NULL,
    Nombre_Decano VARCHAR(50)
);

INSERT INTO catalogo_facultades (Id_Facultad, Nombre_Facultad, Nombre_Decano) VALUES
('F01', 'Medicina', 'Dr. Wilson'),
('F02', 'Ciencias', 'Dr. Palmer');

-- MEDICOS
CREATE TABLE registro_medicos (
    Id_Medico VARCHAR(10) PRIMARY KEY,
    Nombre_Medico VARCHAR(50) NOT NULL,
    Especialidad_Medico VARCHAR(50)
);

INSERT INTO registro_medicos (Id_Medico, Nombre_Medico, Especialidad_Medico) VALUES
('M-10', 'Dr. House', 'Infectología'),
('M-22', 'Dra. Grey', 'Cardiología'),
('M-30', 'Dr. Strange', 'Neurocirugía');

-- SEDES
CREATE TABLE catalogo_sedes (
    Id_Sede VARCHAR(10) PRIMARY KEY,
    Nombre_Sede VARCHAR(50) NOT NULL,
    Direccion_Sede VARCHAR(100)
);

INSERT INTO catalogo_sedes (Id_Sede, Nombre_Sede, Direccion_Sede) VALUES
('S01', 'Centro Médico', 'Calle 5 #10'),
('S02', 'Clínica Norte', 'Av. Libertador');

-- CITAS
CREATE TABLE registro_citas (
    Id_Cita VARCHAR(10) PRIMARY KEY,
    Fecha_Cita DATE NOT NULL,
    Diagnostico_Cita VARCHAR(100),

    Paciente_Ref VARCHAR(10),
    Medico_Ref VARCHAR(10),
    Sede_Ref VARCHAR(10),

    CONSTRAINT fk_cita_paciente_ref
        FOREIGN KEY (Paciente_Ref)
        REFERENCES registro_pacientes(Id_Paciente),

    CONSTRAINT fk_cita_medico_ref
        FOREIGN KEY (Medico_Ref)
        REFERENCES registro_medicos(Id_Medico),

    CONSTRAINT fk_cita_sede_ref
        FOREIGN KEY (Sede_Ref)
        REFERENCES catalogo_sedes(Id_Sede)
);

INSERT INTO registro_citas (Id_Cita, Fecha_Cita, Diagnostico_Cita, Paciente_Ref, Medico_Ref, Sede_Ref) VALUES
('C-001', '2024-05-10', 'Gripe Fuerte', 'P-501', 'M-10', 'S01'),
('C-002', '2024-05-11', 'Infección', 'P-502', 'M-10', 'S01'),
('C-003', '2024-05-12', 'Arritmia', 'P-501', 'M-22', 'S02'),
('C-004', '2024-05-15', 'Migraña', 'P-503', 'M-30', 'S02');

-- MEDICAMENTOS
CREATE TABLE registro_medicamentos (
    Cita_Ref VARCHAR(10),
    Nombre_Medicamento VARCHAR(50),
    Dosis_Medicamento VARCHAR(20),

    PRIMARY KEY (Cita_Ref, Nombre_Medicamento),

    CONSTRAINT fk_medicamento_cita_ref
        FOREIGN KEY (Cita_Ref)
        REFERENCES registro_citas(Id_Cita)
        ON DELETE CASCADE
);

INSERT INTO registro_medicamentos (Cita_Ref, Nombre_Medicamento, Dosis_Medicamento) VALUES
('C-001', 'Paracetamol', '500mg'),
('C-001', 'Ibuprofeno', '400mg'),
('C-002', 'Amoxicilina', '875mg'),
('C-003', 'Aspirina', '100mg'),
('C-004', 'Ergotamina', '1mg');

-- RELACION FACULTAD - MEDICOS
CREATE TABLE facultad_medicos_rel (
    Medico_Ref VARCHAR(10),
    Facultad_Ref VARCHAR(10),

    PRIMARY KEY (Medico_Ref, Facultad_Ref),

    CONSTRAINT fk_rel_medico_ref
        FOREIGN KEY (Medico_Ref)
        REFERENCES registro_medicos(Id_Medico),

    CONSTRAINT fk_rel_facultad_ref
        FOREIGN KEY (Facultad_Ref)
        REFERENCES catalogo_facultades(Id_Facultad)
);

INSERT INTO facultad_medicos_rel (Medico_Ref, Facultad_Ref) VALUES
('M-10', 'F01'),
('M-22', 'F01'),
('M-30', 'F02');

-- BITÁCORA DE ERRORES
CREATE TABLE bitacora_errores (
    Id_Error INT AUTO_INCREMENT PRIMARY KEY,
    nombre_origen VARCHAR(50),
    codigo_evento INT,
    descripcion_evento VARCHAR(200),
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
);

--------------------------------------------------------------------
-- CRUD PACIENTES
--------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_registro_pacientes_alta;
DELIMITER $$
CREATE PROCEDURE sp_registro_pacientes_alta(
    IN v_id VARCHAR(10),
    IN v_nombre VARCHAR(50),
    IN v_telefono VARCHAR(20)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO bitacora_errores(nombre_origen,codigo_evento,descripcion_evento)
        VALUES('registro_pacientes',1,'Error al registrar datos de paciente');
        ROLLBACK;
    END;

    START TRANSACTION;
    INSERT INTO registro_pacientes VALUES(v_id,v_nombre,v_telefono);
    COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_registro_pacientes_consulta;
DELIMITER $$
CREATE PROCEDURE sp_registro_pacientes_consulta(IN v_id VARCHAR(10))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO bitacora_errores(nombre_origen,codigo_evento,descripcion_evento)
        VALUES('registro_pacientes',2,'Error al obtener información de paciente');
    END;

    SELECT * FROM registro_pacientes WHERE Id_Paciente = v_id;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_registro_pacientes_actualiza;
DELIMITER $$
CREATE PROCEDURE sp_registro_pacientes_actualiza(
    IN v_id VARCHAR(10),
    IN v_nombre VARCHAR(50),
    IN v_telefono VARCHAR(20)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO bitacora_errores(nombre_origen,codigo_evento,descripcion_evento)
        VALUES('registro_pacientes',3,'Error al actualizar datos de paciente');
        ROLLBACK;
    END;

    START TRANSACTION;
    UPDATE registro_pacientes
       SET Nombre_Paciente = v_nombre,
           Telefono_Paciente = v_telefono
     WHERE Id_Paciente = v_id;
    COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_registro_pacientes_baja;
DELIMITER $$
CREATE PROCEDURE sp_registro_pacientes_baja(IN v_id VARCHAR(10))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO bitacora_errores(nombre_origen,codigo_evento,descripcion_evento)
        VALUES('registro_pacientes',4,'Error al eliminar registro de paciente');
        ROLLBACK;
    END;

    START TRANSACTION;
    DELETE FROM registro_pacientes WHERE Id_Paciente = v_id;
    COMMIT;
END$$
DELIMITER ;

--------------------------------------------------------------------
-- CRUD FACULTADES
--------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_catalogo_facultades_alta;
DELIMITER $$
CREATE PROCEDURE sp_catalogo_facultades_alta(
    IN v_id VARCHAR(10),
    IN v_nombre VARCHAR(50),
    IN v_decano VARCHAR(50)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO bitacora_errores(nombre_origen,codigo_evento,descripcion_evento)
        VALUES('catalogo_facultades',13,'Error al registrar facultad');
        ROLLBACK;
    END;

    START TRANSACTION;
    INSERT INTO catalogo_facultades VALUES(v_id,v_nombre,v_decano);
    COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_catalogo_facultades_consulta;
DELIMITER $$
CREATE PROCEDURE sp_catalogo_facultades_consulta(IN v_id VARCHAR(10))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO bitacora_errores(nombre_origen,codigo_evento,descripcion_evento)
        VALUES('catalogo_facultades',14,'Error al consultar facultad');
    END;

    SELECT * FROM catalogo_facultades WHERE Id_Facultad = v_id;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_catalogo_facultades_actualiza;
DELIMITER $$
CREATE PROCEDURE sp_catalogo_facultades_actualiza(
    IN v_id VARCHAR(10),
    IN v_nombre VARCHAR(50),
    IN v_decano VARCHAR(50)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO bitacora_errores(nombre_origen,codigo_evento,descripcion_evento)
        VALUES('catalogo_facultades',15,'Error al actualizar facultad');
        ROLLBACK;
    END;

    START TRANSACTION;
    UPDATE catalogo_facultades
       SET Nombre_Facultad = v_nombre,
           Nombre_Decano = v_decano
     WHERE Id_Facultad = v_id;
    COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_catalogo_facultades_baja;
DELIMITER $$
CREATE PROCEDURE sp_catalogo_facultades_baja(IN v_id VARCHAR(10))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO bitacora_errores(nombre_origen,codigo_evento,descripcion_evento)
        VALUES('catalogo_facultades',16,'Error al remover facultad');
        ROLLBACK;
    END;

    START TRANSACTION;
    DELETE FROM catalogo_facultades WHERE Id_Facultad = v_id;
    COMMIT;
END$$
DELIMITER ;

--------------------------------------------------------------------
-- CRUD MEDICOS
--------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_registro_medicos_alta;
DELIMITER $$
CREATE PROCEDURE sp_registro_medicos_alta(
    IN v_id VARCHAR(10),
    IN v_nombre VARCHAR(50),
    IN v_especialidad VARCHAR(50)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO bitacora_errores(nombre_origen,codigo_evento,descripcion_evento)
        VALUES('registro_medicos',5,'Error al registrar médico');
        ROLLBACK;
    END;

    START TRANSACTION;
    INSERT INTO registro_medicos VALUES(v_id,v_nombre,v_especialidad);
    COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_registro_medicos_consulta;
DELIMITER $$
CREATE PROCEDURE sp_registro_medicos_consulta(IN v_id VARCHAR(10))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO bitacora_errores(nombre_origen,codigo_evento,descripcion_evento)
        VALUES('registro_medicos',6,'Error al consultar médico');
    END;

    SELECT * FROM registro_medicos WHERE Id_Medico = v_id;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_registro_medicos_actualiza;
DELIMITER $$
CREATE PROCEDURE sp_registro_medicos_actualiza(
    IN v_id VARCHAR(10),
    IN v_nombre VARCHAR(50),
    IN v_especialidad VARCHAR(50)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO bitacora_errores(nombre_origen,codigo_evento,descripcion_evento)
        VALUES('registro_medicos',7,'Error al actualizar médico');
        ROLLBACK;
    END;

    START TRANSACTION;
    UPDATE registro_medicos
       SET Nombre_Medico = v_nombre,
           Especialidad_Medico = v_especialidad
     WHERE Id_Medico = v_id;
    COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_registro_medicos_baja;
DELIMITER $$
CREATE PROCEDURE sp_registro_medicos_baja(IN v_id VARCHAR(10))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO bitacora_errores(nombre_origen,codigo_evento,descripcion_evento)
        VALUES('registro_medicos',8,'Error al eliminar médico');
        ROLLBACK;
    END;

    START TRANSACTION;
    DELETE FROM registro_medicos WHERE Id_Medico = v_id;
    COMMIT;
END$$
DELIMITER ;

--------------------------------------------------------------------
-- CRUD SEDES
--------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_catalogo_sedes_alta;
DELIMITER $$
CREATE PROCEDURE sp_catalogo_sedes_alta(
    IN v_id VARCHAR(10),
    IN v_nombre VARCHAR(50),
    IN v_direccion VARCHAR(100)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO bitacora_errores(nombre_origen,codigo_evento,descripcion_evento)
        VALUES('catalogo_sedes',9,'Error al registrar sede');
        ROLLBACK;
    END;

    START TRANSACTION;
    INSERT INTO catalogo_sedes VALUES(v_id,v_nombre,v_direccion);
    COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_catalogo_sedes_consulta;
DELIMITER $$
CREATE PROCEDURE sp_catalogo_sedes_consulta(IN v_id VARCHAR(10))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO bitacora_errores(nombre_origen,codigo_evento,descripcion_evento)
        VALUES('catalogo_sedes',10,'Error al consultar sede');
    END;

    SELECT * FROM catalogo_sedes WHERE Id_Sede = v_id;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_catalogo_sedes_actualiza;
DELIMITER $$
CREATE PROCEDURE sp_catalogo_sedes_actualiza(
    IN v_id VARCHAR(10),
    IN v_nombre VARCHAR(50),
    IN v_direccion VARCHAR(100)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO bitacora_errores(nombre_origen,codigo_evento,descripcion_evento)
        VALUES('catalogo_sedes',11,'Error al actualizar sede');
        ROLLBACK;
    END;

    START TRANSACTION;
    UPDATE catalogo_sedes
       SET Nombre_Sede = v_nombre,
           Direccion_Sede = v_direccion
     WHERE Id_Sede = v_id;
    COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_catalogo_sedes_baja;
DELIMITER $$
CREATE PROCEDURE sp_catalogo_sedes_baja(IN v_id VARCHAR(10))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO bitacora_errores(nombre_origen,codigo_evento,descripcion_evento)
        VALUES('catalogo_sedes',12,'Error al eliminar sede');
        ROLLBACK;
    END;

    START TRANSACTION;
    DELETE FROM catalogo_sedes WHERE Id_Sede = v_id;
    COMMIT;
END$$
DELIMITER ;

--------------------------------------------------------------------
-- CRUD CITAS
--------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_registro_citas_alta;
DELIMITER $$
CREATE PROCEDURE sp_registro_citas_alta(
    IN v_cod VARCHAR(10),
    IN v_fecha DATE,
    IN v_diag VARCHAR(100),
    IN v_paciente VARCHAR(10),
    IN v_medico VARCHAR(10),
    IN v_sede VARCHAR(10)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO bitacora_errores(nombre_origen,codigo_evento,descripcion_evento)
        VALUES('registro_citas',17,'Error al registrar cita');
        ROLLBACK;
    END;

    START TRANSACTION;
    INSERT INTO registro_citas VALUES(v_cod,v_fecha,v_diag,v_paciente,v_medico,v_sede);
    COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_registro_citas_consulta;
DELIMITER $$
CREATE PROCEDURE sp_registro_citas_consulta(IN v_cod VARCHAR(10))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO bitacora_errores(nombre_origen,codigo_evento,descripcion_evento)
        VALUES('registro_citas',18,'Error al consultar cita');
    END;

    SELECT * FROM registro_citas WHERE Id_Cita = v_cod;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_registro_citas_actualiza;
DELIMITER $$
CREATE PROCEDURE sp_registro_citas_actualiza(
    IN v_cod VARCHAR(10),
    IN v_fecha DATE,
    IN v_diag VARCHAR(100),
    IN v_paciente VARCHAR(10),
    IN v_medico VARCHAR(10),
    IN v_sede VARCHAR(10)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO bitacora_errores(nombre_origen,codigo_evento,descripcion_evento)
        VALUES('registro_citas',19,'Error al actualizar cita');
        ROLLBACK;
    END;

    START TRANSACTION;
    UPDATE registro_citas
       SET Fecha_Cita = v_fecha,
           Diagnostico_Cita = v_diag,
           Paciente_Ref = v_paciente,
           Medico_Ref = v_medico,
           Sede_Ref = v_sede
     WHERE Id_Cita = v_cod;
    COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_registro_citas_baja;
DELIMITER $$
CREATE PROCEDURE sp_registro_citas_baja(IN v_cod VARCHAR(10))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO bitacora_errores(nombre_origen,codigo_evento,descripcion_evento)
        VALUES('registro_citas',20,'Error al eliminar cita');
        ROLLBACK;
    END;

    START TRANSACTION;
    DELETE FROM registro_citas WHERE Id_Cita = v_cod;
    COMMIT;
END$$
DELIMITER ;

--------------------------------------------------------------------
-- CRUD MEDICAMENTOS
--------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_registro_medicamentos_alta;
DELIMITER $$
CREATE PROCEDURE sp_registro_medicamentos_alta(
    IN v_cod VARCHAR(10),
    IN v_medicamento VARCHAR(50),
    IN v_dosis VARCHAR(20)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO bitacora_errores(nombre_origen,codigo_evento,descripcion_evento)
        VALUES('registro_medicamentos',21,'Error al registrar medicamento');
        ROLLBACK;
    END;

    START TRANSACTION;
    INSERT INTO registro_medicamentos VALUES(v_cod,v_medicamento,v_dosis);
    COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_registro_medicamentos_consulta;
DELIMITER $$
CREATE PROCEDURE sp_registro_medicamentos_consulta(IN v_cod VARCHAR(10))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO bitacora_errores(nombre_origen,codigo_evento,descripcion_evento)
        VALUES('registro_medicamentos',22,'Error al consultar medicamentos');
    END;

    SELECT * FROM registro_medicamentos WHERE Cita_Ref = v_cod;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_registro_medicamentos_actualiza;
DELIMITER $$
CREATE PROCEDURE sp_registro_medicamentos_actualiza(
    IN v_cod VARCHAR(10),
    IN v_medicamento VARCHAR(50),
    IN v_dosis VARCHAR(20)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO bitacora_errores(nombre_origen,codigo_evento,descripcion_evento)
        VALUES('registro_medicamentos',23,'Error al actualizar medicamento');
        ROLLBACK;
    END;

    START TRANSACTION;
    UPDATE registro_medicamentos
       SET Dosis_Medicamento = v_dosis
     WHERE Cita_Ref = v_cod
       AND Nombre_Medicamento = v_medicamento;
    COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_registro_medicamentos_baja;
DELIMITER $$
CREATE PROCEDURE sp_registro_medicamentos_baja(
    IN v_cod VARCHAR(10),
    IN v_medicamento VARCHAR(50)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO bitacora_errores(nombre_origen,codigo_evento,descripcion_evento)
        VALUES('registro_medicamentos',24,'Error al eliminar medicamento');
        ROLLBACK;
    END;

    START TRANSACTION;
    DELETE FROM registro_medicamentos
     WHERE Cita_Ref = v_cod
       AND Nombre_Medicamento = v_medicamento;
    COMMIT;
END$$
DELIMITER ;

--------------------------------------------------------------------
-- CRUD RELACIÓN FACULTAD - MÉDICOS
--------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_facultad_medicos_rel_alta;
DELIMITER $$
CREATE PROCEDURE sp_facultad_medicos_rel_alta(
    IN v_medico VARCHAR(10),
    IN v_facultad VARCHAR(10)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO bitacora_errores(nombre_origen,codigo_evento,descripcion_evento)
        VALUES('facultad_medicos_rel',25,'Error al registrar relación facultad-médico');
        ROLLBACK;
    END;

    START TRANSACTION;
    INSERT INTO facultad_medicos_rel VALUES(v_medico,v_facultad);
    COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_facultad_medicos_rel_consulta;
DELIMITER $$
CREATE PROCEDURE sp_facultad_medicos_rel_consulta(IN v_medico VARCHAR(10))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO bitacora_errores(nombre_origen,codigo_evento,descripcion_evento)
        VALUES('facultad_medicos_rel',26,'Error al consultar relación facultad-médico');
    END;

    SELECT * FROM facultad_medicos_rel WHERE Medico_Ref = v_medico;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_facultad_medicos_rel_actualiza;
DELIMITER $$
CREATE PROCEDURE sp_facultad_medicos_rel_actualiza(
    IN v_medico_old VARCHAR(10),
    IN v_facultad_old VARCHAR(10),
    IN v_medico_new VARCHAR(10),
    IN v_facultad_new VARCHAR(10)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO bitacora_errores(nombre_origen,codigo_evento,descripcion_evento)
        VALUES('facultad_medicos_rel',27,'Error al actualizar relación facultad-médico');
        ROLLBACK;
    END;

    START TRANSACTION;
    UPDATE facultad_medicos_rel
       SET Medico_Ref = v_medico_new,
           Facultad_Ref = v_facultad_new
     WHERE Medico_Ref = v_medico_old
       AND Facultad_Ref = v_facultad_old;
    COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_facultad_medicos_rel_baja;
DELIMITER $$
CREATE PROCEDURE sp_facultad_medicos_rel_baja(
    IN v_medico VARCHAR(10),
    IN v_facultad VARCHAR(10)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO bitacora_errores(nombre_origen,codigo_evento,descripcion_evento)
        VALUES('facultad_medicos_rel',28,'Error al eliminar relación facultad-médico');
        ROLLBACK;
    END;

    START TRANSACTION;
    DELETE FROM facultad_medicos_rel
     WHERE Medico_Ref = v_medico
       AND Facultad_Ref = v_facultad;
    COMMIT;
END$$
DELIMITER ;

--------------------------------------------------------------------
-- PROCEDIMIENTO GENERAL ERRORES Y REPORTES
--------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_bitacora_registro_error;
DELIMITER $$
CREATE PROCEDURE sp_bitacora_registro_error(
    IN v_origen VARCHAR(50),
    IN v_codigo INT,
    IN v_detalle VARCHAR(200)
)
BEGIN
    INSERT INTO bitacora_errores(nombre_origen, codigo_evento, descripcion_evento, fecha_registro)
    VALUES(v_origen, v_codigo, v_detalle, NOW());
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_resumen_medicos_por_especialidad;
DELIMITER $$
CREATE PROCEDURE sp_resumen_medicos_por_especialidad(
    IN v_especialidad VARCHAR(50)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_bitacora_registro_error(
            'registro_medicos',
            201,
            'Error al obtener total de médicos por especialidad'
        );
    END;

    SELECT COUNT(*) AS Total_Medicos
    FROM registro_medicos
    WHERE Especialidad_Medico = v_especialidad;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_resumen_pacientes_por_medico;
DELIMITER $$
CREATE PROCEDURE sp_resumen_pacientes_por_medico(
    IN v_medico VARCHAR(10)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_bitacora_registro_error(
            'registro_citas',
            202,
            'Error al obtener cantidad de pacientes por médico'
        );
    END;

    SELECT COUNT(DISTINCT Paciente_Ref) AS Total_Pacientes
    FROM registro_citas
    WHERE Medico_Ref = v_medico;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_resumen_pacientes_por_sede;
DELIMITER $$
CREATE PROCEDURE sp_resumen_pacientes_por_sede(
    IN v_sede VARCHAR(10)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_bitacora_registro_error(
            'registro_citas',
            203,
            'Error al obtener cantidad de pacientes por sede'
        );
    END;

    SELECT COUNT(DISTINCT Paciente_Ref) AS Total_Pacientes
    FROM registro_citas
    WHERE Sede_Ref = v_sede;
END$$
DELIMITER ;

--------------------------------------------------------------------
-- ROLES Y PERMISOS
--------------------------------------------------------------------

CREATE ROLE rol_supervisor;
CREATE ROLE rol_medico_clinico;
CREATE ROLE rol_recepcion;
CREATE ROLE rol_auditoria;

GRANT ALL PRIVILEGES
ON sistema_clinico.*
TO rol_supervisor;

GRANT SELECT ON sistema_clinico.registro_pacientes TO rol_medico_clinico;
GRANT SELECT, INSERT, UPDATE ON sistema_clinico.registro_citas TO rol_medico_clinico;
GRANT SELECT ON sistema_clinico.registro_medicamentos TO rol_medico_clinico;

GRANT SELECT, INSERT ON sistema_clinico.registro_pacientes TO rol_recepcion;
GRANT SELECT ON sistema_clinico.registro_citas TO rol_recepcion;

GRANT SELECT ON sistema_clinico.* TO rol_auditoria;

--------------------------------------------------------------------
-- PACIENTES – PREPARE/EXECUTE
--------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_registro_pacientes_alta_dyn;
DELIMITER $$
CREATE PROCEDURE sp_registro_pacientes_alta_dyn(
    IN v_id VARCHAR(10),
    IN v_nombre VARCHAR(50),
    IN v_telefono VARCHAR(20)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_bitacora_registro_error('registro_pacientes',501,'Error al insertar paciente (dyn)');
        ROLLBACK;
    END;

    START TRANSACTION;

    SET @p_id  = v_id;
    SET @p_nom = v_nombre;
    SET @p_tel = v_telefono;

    SET @sql_cmd = 'INSERT INTO registro_pacientes (Id_Paciente,Nombre_Paciente,Telefono_Paciente) VALUES (?,?,?)';
    PREPARE stmt_pac_ins FROM @sql_cmd;
    EXECUTE stmt_pac_ins USING @p_id,@p_nom,@p_tel;
    DEALLOCATE PREPARE stmt_pac_ins;

    COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_registro_pacientes_consulta_dyn;
DELIMITER $$
CREATE PROCEDURE sp_registro_pacientes_consulta_dyn(
    IN v_id VARCHAR(10)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_bitacora_registro_error('registro_pacientes',502,'Error al consultar paciente (dyn)');
    END;

    SET @p_id = v_id;

    SET @sql_cmd = 'SELECT * FROM registro_pacientes WHERE Id_Paciente = ?';
    PREPARE stmt_pac_sel FROM @sql_cmd;
    EXECUTE stmt_pac_sel USING @p_id;
    DEALLOCATE PREPARE stmt_pac_sel;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_registro_pacientes_actualiza_dyn;
DELIMITER $$
CREATE PROCEDURE sp_registro_pacientes_actualiza_dyn(
    IN v_id VARCHAR(10),
    IN v_nombre VARCHAR(50),
    IN v_telefono VARCHAR(20)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_bitacora_registro_error('registro_pacientes',503,'Error al actualizar paciente (dyn)');
        ROLLBACK;
    END;

    START TRANSACTION;

    SET @p_id  = v_id;
    SET @p_nom = v_nombre;
    SET @p_tel = v_telefono;

    SET @sql_cmd = 'UPDATE registro_pacientes
                    SET Nombre_Paciente = ?, Telefono_Paciente = ?
                    WHERE Id_Paciente = ?';
    PREPARE stmt_pac_upd FROM @sql_cmd;
    EXECUTE stmt_pac_upd USING @p_nom,@p_tel,@p_id;
    DEALLOCATE PREPARE stmt_pac_upd;

    COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_registro_pacientes_baja_dyn;
DELIMITER $$
CREATE PROCEDURE sp_registro_pacientes_baja_dyn(
    IN v_id VARCHAR(10)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_bitacora_registro_error('registro_pacientes',504,'Error al eliminar paciente (dyn)');
        ROLLBACK;
    END;

    START TRANSACTION;

    SET @p_id = v_id;

    SET @sql_cmd = 'DELETE FROM registro_pacientes WHERE Id_Paciente = ?';
    PREPARE stmt_pac_del FROM @sql_cmd;
    EXECUTE stmt_pac_del USING @p_id;
    DEALLOCATE PREPARE stmt_pac_del;

    COMMIT;
END$$
DELIMITER ;

--------------------------------------------------------------------
-- MEDICOS – PREPARE/EXECUTE
--------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_registro_medicos_alta_dyn;
DELIMITER $$
CREATE PROCEDURE sp_registro_medicos_alta_dyn(
    IN v_id VARCHAR(10),
    IN v_nombre VARCHAR(50),
    IN v_especialidad VARCHAR(50)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_bitacora_registro_error('registro_medicos',601,'Error al insertar médico (dyn)');
        ROLLBACK;
    END;

    START TRANSACTION;

    SET @m_id   = v_id;
    SET @m_nom  = v_nombre;
    SET @m_esp  = v_especialidad;

    SET @sql_cmd = 'INSERT INTO registro_medicos (Id_Medico,Nombre_Medico,Especialidad_Medico)
                    VALUES (?,?,?)';
    PREPARE stmt_med_ins FROM @sql_cmd;
    EXECUTE stmt_med_ins USING @m_id,@m_nom,@m_esp;
    DEALLOCATE PREPARE stmt_med_ins;

    COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_registro_medicos_consulta_dyn;
DELIMITER $$
CREATE PROCEDURE sp_registro_medicos_consulta_dyn(
    IN v_id VARCHAR(10)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_bitacora_registro_error('registro_medicos',602,'Error al consultar médico (dyn)');
    END;

    SET @m_id = v_id;

    SET @sql_cmd = 'SELECT * FROM registro_medicos WHERE Id_Medico = ?';
    PREPARE stmt_med_sel FROM @sql_cmd;
    EXECUTE stmt_med_sel USING @m_id;
    DEALLOCATE PREPARE stmt_med_sel;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_registro_medicos_actualiza_dyn;
DELIMITER $$
CREATE PROCEDURE sp_registro_medicos_actualiza_dyn(
    IN v_id VARCHAR(10),
    IN v_nombre VARCHAR(50),
    IN v_especialidad VARCHAR(50)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_bitacora_registro_error('registro_medicos',603,'Error al actualizar médico (dyn)');
        ROLLBACK;
    END;

    START TRANSACTION;

    SET @m_id   = v_id;
    SET @m_nom  = v_nombre;
    SET @m_esp  = v_especialidad;

    SET @sql_cmd = 'UPDATE registro_medicos
                    SET Nombre_Medico = ?, Especialidad_Medico = ?
                    WHERE Id_Medico = ?';
    PREPARE stmt_med_upd FROM @sql_cmd;
    EXECUTE stmt_med_upd USING @m_nom,@m_esp,@m_id;
    DEALLOCATE PREPARE stmt_med_upd;

    COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_registro_medicos_baja_dyn;
DELIMITER $$
CREATE PROCEDURE sp_registro_medicos_baja_dyn(
    IN v_id VARCHAR(10)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_bitacora_registro_error('registro_medicos',604,'Error al eliminar médico (dyn)');
        ROLLBACK;
    END;

    START TRANSACTION;

    SET @m_id = v_id;

    SET @sql_cmd = 'DELETE FROM registro_medicos WHERE Id_Medico = ?';
    PREPARE stmt_med_del FROM @sql_cmd;
    EXECUTE stmt_med_del USING @m_id;
    DEALLOCATE PREPARE stmt_med_del;

    COMMIT;
END$$
DELIMITER ;

--------------------------------------------------------------------
-- SEDES – PREPARE/EXECUTE
--------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_catalogo_sedes_alta_dyn;
DELIMITER $$
CREATE PROCEDURE sp_catalogo_sedes_alta_dyn(
    IN v_id VARCHAR(10),
    IN v_nombre VARCHAR(50),
    IN v_direccion VARCHAR(100)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_bitacora_registro_error('catalogo_sedes',701,'Error al insertar sede (dyn)');
        ROLLBACK;
    END;

    START TRANSACTION;

    SET @s_id  = v_id;
    SET @s_nom = v_nombre;
    SET @s_dir = v_direccion;

    SET @sql_cmd = 'INSERT INTO catalogo_sedes (Id_Sede,Nombre_Sede,Direccion_Sede)
                    VALUES (?,?,?)';
    PREPARE stmt_sed_ins FROM @sql_cmd;
    EXECUTE stmt_sed_ins USING @s_id,@s_nom,@s_dir;
    DEALLOCATE PREPARE stmt_sed_ins;

    COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_catalogo_sedes_consulta_dyn;
DELIMITER $$
CREATE PROCEDURE sp_catalogo_sedes_consulta_dyn(
    IN v_id VARCHAR(10)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_bitacora_registro_error('catalogo_sedes',702,'Error al consultar sede (dyn)');
    END;

    SET @s_id = v_id;

    SET @sql_cmd = 'SELECT * FROM catalogo_sedes WHERE Id_Sede = ?';
    PREPARE stmt_sed_sel FROM @sql_cmd;
    EXECUTE stmt_sed_sel USING @s_id;
    DEALLOCATE PREPARE stmt_sed_sel;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_catalogo_sedes_actualiza_dyn;
DELIMITER $$
CREATE PROCEDURE sp_catalogo_sedes_actualiza_dyn(
    IN v_id VARCHAR(10),
    IN v_nombre VARCHAR(50),
    IN v_direccion VARCHAR(100)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_bitacora_registro_error('catalogo_sedes',703,'Error al actualizar sede (dyn)');
        ROLLBACK;
    END;

    START TRANSACTION;

    SET @s_id  = v_id;
    SET @s_nom = v_nombre;
    SET @s_dir = v_direccion;

    SET @sql_cmd = 'UPDATE catalogo_sedes
                    SET Nombre_Sede = ?, Direccion_Sede = ?
                    WHERE Id_Sede = ?';
    PREPARE stmt_sed_upd FROM @sql_cmd;
    EXECUTE stmt_sed_upd USING @s_nom,@s_dir,@s_id;
    DEALLOCATE PREPARE stmt_sed_upd;

    COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_catalogo_sedes_baja_dyn;
DELIMITER $$
CREATE PROCEDURE sp_catalogo_sedes_baja_dyn(
    IN v_id VARCHAR(10)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_bitacora_registro_error('catalogo_sedes',704,'Error al eliminar sede (dyn)');
        ROLLBACK;
    END;

    START TRANSACTION;

    SET @s_id = v_id;

    SET @sql_cmd = 'DELETE FROM catalogo_sedes WHERE Id_Sede = ?';
    PREPARE stmt_sed_del FROM @sql_cmd;
    EXECUTE stmt_sed_del USING @s_id;
    DEALLOCATE PREPARE stmt_sed_del;

    COMMIT;
END$$
DELIMITER ;

--------------------------------------------------------------------
-- FACULTADES – PREPARE/EXECUTE
--------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_catalogo_facultades_alta_dyn;
DELIMITER $$
CREATE PROCEDURE sp_catalogo_facultades_alta_dyn(
    IN v_id VARCHAR(10),
    IN v_nombre VARCHAR(50),
    IN v_decano VARCHAR(50)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_bitacora_registro_error('catalogo_facultades',801,'Error al insertar facultad (dyn)');
        ROLLBACK;
    END;

    START TRANSACTION;

    SET @f_id  = v_id;
    SET @f_nom = v_nombre;
    SET @f_dec = v_decano;

    SET @sql_cmd = 'INSERT INTO catalogo_facultades (Id_Facultad,Nombre_Facultad,Nombre_Decano)
                    VALUES (?,?,?)';
    PREPARE stmt_fac_ins FROM @sql_cmd;
    EXECUTE stmt_fac_ins USING @f_id,@f_nom,@f_dec;
    DEALLOCATE PREPARE stmt_fac_ins;

    COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_catalogo_facultades_consulta_dyn;
DELIMITER $$
CREATE PROCEDURE sp_catalogo_facultades_consulta_dyn(
    IN v_id VARCHAR(10)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_bitacora_registro_error('catalogo_facultades',802,'Error al consultar facultad (dyn)');
    END;

    SET @f_id = v_id;

    SET @sql_cmd = 'SELECT * FROM catalogo_facultades WHERE Id_Facultad = ?';
    PREPARE stmt_fac_sel FROM @sql_cmd;
    EXECUTE stmt_fac_sel USING @f_id;
    DEALLOCATE PREPARE stmt_fac_sel;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_catalogo_facultades_actualiza_dyn;
DELIMITER $$
CREATE PROCEDURE sp_catalogo_facultades_actualiza_dyn(
    IN v_id VARCHAR(10),
    IN v_nombre VARCHAR(50),
    IN v_decano VARCHAR(50)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_bitacora_registro_error('catalogo_facultades',803,'Error al actualizar facultad (dyn)');
        ROLLBACK;
    END;

    START TRANSACTION;

    SET @f_id  = v_id;
    SET @f_nom = v_nombre;
    SET @f_dec = v_decano;

    SET @sql_cmd = 'UPDATE catalogo_facultades
                    SET Nombre_Facultad = ?, Nombre_Decano = ?
                    WHERE Id_Facultad = ?';
    PREPARE stmt_fac_upd FROM @sql_cmd;
    EXECUTE stmt_fac_upd USING @f_nom,@f_dec,@f_id;
    DEALLOCATE PREPARE stmt_fac_upd;

    COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_catalogo_facultades_baja_dyn;
DELIMITER $$
CREATE PROCEDURE sp_catalogo_facultades_baja_dyn(
    IN v_id VARCHAR(10)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_bitacora_registro_error('catalogo_facultades',804,'Error al eliminar facultad (dyn)');
        ROLLBACK;
    END;

    START TRANSACTION;

    SET @f_id = v_id;

    SET @sql_cmd = 'DELETE FROM catalogo_facultades WHERE Id_Facultad = ?';
    PREPARE stmt_fac_del FROM @sql_cmd;
    EXECUTE stmt_fac_del USING @f_id;
    DEALLOCATE PREPARE stmt_fac_del;

    COMMIT;
END$$
DELIMITER ;

--------------------------------------------------------------------
-- CITAS – PREPARE/EXECUTE
--------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_registro_citas_alta_dyn;
DELIMITER $$
CREATE PROCEDURE sp_registro_citas_alta_dyn(
    IN v_cod VARCHAR(10),
    IN v_fecha DATE,
    IN v_diag VARCHAR(100),
    IN v_paciente VARCHAR(10),
    IN v_medico VARCHAR(10),
    IN v_sede VARCHAR(10)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_bitacora_registro_error('registro_citas',901,'Error al insertar cita (dyn)');
        ROLLBACK;
    END;

    START TRANSACTION;

    SET @c_cod = v_cod;
    SET @c_fec = v_fecha;
    SET @c_diag = v_diag;
    SET @c_pac = v_paciente;
    SET @c_med = v_medico;
    SET @c_sed = v_sede;

    SET @sql_cmd = 'INSERT INTO registro_citas
                    (Id_Cita,Fecha_Cita,Diagnostico_Cita,Paciente_Ref,Medico_Ref,Sede_Ref)
                    VALUES (?,?,?,?,?,?)';
    PREPARE stmt_cit_ins FROM @sql_cmd;
    EXECUTE stmt_cit_ins USING @c_cod,@c_fec,@c_diag,@c_pac,@c_med,@c_sed;
    DEALLOCATE PREPARE stmt_cit_ins;

    COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_registro_citas_consulta_dyn;
DELIMITER $$
CREATE PROCEDURE sp_registro_citas_consulta_dyn(
    IN v_cod VARCHAR(10)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_bitacora_registro_error('registro_citas',902,'Error al consultar cita (dyn)');
    END;

    SET @c_cod = v_cod;

    SET @sql_cmd = 'SELECT * FROM registro_citas WHERE Id_Cita = ?';
    PREPARE stmt_cit_sel FROM @sql_cmd;
    EXECUTE stmt_cit_sel USING @c_cod;
    DEALLOCATE PREPARE stmt_cit_sel;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_registro_citas_actualiza_dyn;
DELIMITER $$
CREATE PROCEDURE sp_registro_citas_actualiza_dyn(
    IN v_cod VARCHAR(10),
    IN v_fecha DATE,
    IN v_diag VARCHAR(100),
    IN v_paciente VARCHAR(10),
    IN v_medico VARCHAR(10),
    IN v_sede VARCHAR(10)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_bitacora_registro_error('registro_citas',903,'Error al actualizar cita (dyn)');
        ROLLBACK;
    END;

    START TRANSACTION;

    SET @c_cod = v_cod;
    SET @c_fec = v_fecha;
    SET @c_diag = v_diag;
    SET @c_pac = v_paciente;
    SET @c_med = v_medico;
    SET @c_sed = v_sede;

    SET @sql_cmd = 'UPDATE registro_citas
                    SET Fecha_Cita = ?, Diagnostico_Cita = ?, Paciente_Ref = ?,
                        Medico_Ref = ?, Sede_Ref = ?
                    WHERE Id_Cita = ?';
    PREPARE stmt_cit_upd FROM @sql_cmd;
    EXECUTE stmt_cit_upd USING @c_fec,@c_diag,@c_pac,@c_med,@c_sed,@c_cod;
    DEALLOCATE PREPARE stmt_cit_upd;

    COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_registro_citas_baja_dyn;
DELIMITER $$
CREATE PROCEDURE sp_registro_citas_baja_dyn(
    IN v_cod VARCHAR(10)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_bitacora_registro_error('registro_citas',904,'Error al eliminar cita (dyn)');
        ROLLBACK;
    END;

    START TRANSACTION;

    SET @c_cod = v_cod;

    SET @sql_cmd = 'DELETE FROM registro_citas WHERE Id_Cita = ?';
    PREPARE stmt_cit_del FROM @sql_cmd;
    EXECUTE stmt_cit_del USING @c_cod;
    DEALLOCATE PREPARE stmt_cit_del;

    COMMIT;
END$$
DELIMITER ;

--------------------------------------------------------------------
-- MEDICAMENTOS – PREPARE/EXECUTE
--------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_registro_medicamentos_alta_dyn;
DELIMITER $$
CREATE PROCEDURE sp_registro_medicamentos_alta_dyn(
    IN v_cod VARCHAR(10),
    IN v_medicamento VARCHAR(50),
    IN v_dosis VARCHAR(20)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_bitacora_registro_error('registro_medicamentos',1001,'Error al insertar medicamento (dyn)');
        ROLLBACK;
    END;

    START TRANSACTION;

    SET @m_cod = v_cod;
    SET @m_nom = v_medicamento;
    SET @m_dos = v_dosis;

    SET @sql_cmd = 'INSERT INTO registro_medicamentos (Cita_Ref,Nombre_Medicamento,Dosis_Medicamento)
                    VALUES (?,?,?)';
    PREPARE stmt_medreg_ins FROM @sql_cmd;
    EXECUTE stmt_medreg_ins USING @m_cod,@m_nom,@m_dos;
    DEALLOCATE PREPARE stmt_medreg_ins;

    COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_registro_medicamentos_consulta_dyn;
DELIMITER $$
CREATE PROCEDURE sp_registro_medicamentos_consulta_dyn(
    IN v_cod VARCHAR(10)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_bitacora_registro_error('registro_medicamentos',1002,'Error al consultar medicamentos (dyn)');
    END;

    SET @m_cod = v_cod;

    SET @sql_cmd = 'SELECT * FROM registro_medicamentos WHERE Cita_Ref = ?';
    PREPARE stmt_medreg_sel FROM @sql_cmd;
    EXECUTE stmt_medreg_sel USING @m_cod;
    DEALLOCATE PREPARE stmt_medreg_sel;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_registro_medicamentos_actualiza_dyn;
DELIMITER $$
CREATE PROCEDURE sp_registro_medicamentos_actualiza_dyn(
    IN v_cod VARCHAR(10),
    IN v_medicamento VARCHAR(50),
    IN v_dosis VARCHAR(20)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_bitacora_registro_error('registro_medicamentos',1003,'Error al actualizar medicamento (dyn)');
        ROLLBACK;
    END;

    START TRANSACTION;

    SET @m_cod = v_cod;
    SET @m_nom = v_medicamento;
    SET @m_dos = v_dosis;

    SET @sql_cmd = 'UPDATE registro_medicamentos
                    SET Dosis_Medicamento = ?
                    WHERE Cita_Ref = ? AND Nombre_Medicamento = ?';
    PREPARE stmt_medreg_upd FROM @sql_cmd;
    EXECUTE stmt_medreg_upd USING @m_dos,@m_cod,@m_nom;
    DEALLOCATE PREPARE stmt_medreg_upd;

    COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_registro_medicamentos_baja_dyn;
DELIMITER $$
CREATE PROCEDURE sp_registro_medicamentos_baja_dyn(
    IN v_cod VARCHAR(10),
    IN v_medicamento VARCHAR(50)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_bitacora_registro_error('registro_medicamentos',1004,'Error al eliminar medicamento (dyn)');
        ROLLBACK;
    END;

    START TRANSACTION;

    SET @m_cod = v_cod;
    SET @m_nom = v_medicamento;

    SET @sql_cmd = 'DELETE FROM registro_medicamentos
                    WHERE Cita_Ref = ? AND Nombre_Medicamento = ?';
    PREPARE stmt_medreg_del FROM @sql_cmd;
    EXECUTE stmt_medreg_del USING @m_cod,@m_nom;
    DEALLOCATE PREPARE stmt_medreg_del;

    COMMIT;
END$$
DELIMITER ;

--------------------------------------------------------------------
-- RELACIÓN FACULTAD-MÉDICOS – PREPARE/EXECUTE
--------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_facultad_medicos_rel_alta_dyn;
DELIMITER $$
CREATE PROCEDURE sp_facultad_medicos_rel_alta_dyn(
    IN v_medico VARCHAR(10),
    IN v_facultad VARCHAR(10)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_bitacora_registro_error('facultad_medicos_rel',1101,'Error al insertar relación (dyn)');
        ROLLBACK;
    END;

    START TRANSACTION;

    SET @fm_med = v_medico;
    SET @fm_fac = v_facultad;

    SET @sql_cmd = 'INSERT INTO facultad_medicos_rel (Medico_Ref,Facultad_Ref)
                    VALUES (?,?)';
    PREPARE stmt_fm_ins FROM @sql_cmd;
    EXECUTE stmt_fm_ins USING @fm_med,@fm_fac;
    DEALLOCATE PREPARE stmt_fm_ins;

    COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_facultad_medicos_rel_consulta_dyn;
DELIMITER $$
CREATE PROCEDURE sp_facultad_medicos_rel_consulta_dyn(
    IN v_medico VARCHAR(10)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_bitacora_registro_error('facultad_medicos_rel',1102,'Error al consultar relación (dyn)');
    END;

    SET @fm_med = v_medico;

    SET @sql_cmd = 'SELECT * FROM facultad_medicos_rel WHERE Medico_Ref = ?';
    PREPARE stmt_fm_sel FROM @sql_cmd;
    EXECUTE stmt_fm_sel USING @fm_med;
    DEALLOCATE PREPARE stmt_fm_sel;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_facultad_medicos_rel_actualiza_dyn;
DELIMITER $$
CREATE PROCEDURE sp_facultad_medicos_rel_actualiza_dyn(
    IN v_medico_old VARCHAR(10),
    IN v_facultad_old VARCHAR(10),
    IN v_medico_new VARCHAR(10),
    IN v_facultad_new VARCHAR(10)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_bitacora_registro_error('facultad_medicos_rel',1103,'Error al actualizar relación (dyn)');
        ROLLBACK;
    END;

    START TRANSACTION;

    SET @fm_med_old = v_medico_old;
    SET @fm_fac_old = v_facultad_old;
    SET @fm_med_new = v_medico_new;
    SET @fm_fac_new = v_facultad_new;

    SET @sql_cmd = 'UPDATE facultad_medicos_rel
                    SET Medico_Ref = ?, Facultad_Ref = ?
                    WHERE Medico_Ref = ? AND Facultad_Ref = ?';
    PREPARE stmt_fm_upd FROM @sql_cmd;
    EXECUTE stmt_fm_upd USING @fm_med_new,@fm_fac_new,@fm_med_old,@fm_fac_old;
    DEALLOCATE PREPARE stmt_fm_upd;

    COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_facultad_medicos_rel_baja_dyn;
DELIMITER $$
CREATE PROCEDURE sp_facultad_medicos_rel_baja_dyn(
    IN v_medico VARCHAR(10),
    IN v_facultad VARCHAR(10)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_bitacora_registro_error('facultad_medicos_rel',1104,'Error al eliminar relación (dyn)');
        ROLLBACK;
    END;

    START TRANSACTION;

    SET @fm_med = v_medico;
    SET @fm_fac = v_facultad;

    SET @sql_cmd = 'DELETE FROM facultad_medicos_rel
                    WHERE Medico_Ref = ? AND Facultad_Ref = ?';
    PREPARE stmt_fm_del FROM @sql_cmd;
    EXECUTE stmt_fm_del USING @fm_med,@fm_fac;
    DEALLOCATE PREPARE stmt_fm_del;

    COMMIT;
END$$
DELIMITER ;

--------------------------------------------------------------------
-- TRIGGERS DE VALIDACIÓN SOBRE PACIENTES
--------------------------------------------------------------------

-- INSERT: validar nombre y teléfono
DROP TRIGGER IF EXISTS trg_registro_pacientes_ins_valida;
DELIMITER $$
CREATE TRIGGER trg_registro_pacientes_ins_valida
BEFORE INSERT ON registro_pacientes
FOR EACH ROW
BEGIN
    -- Validar nombre no vacío y sin solo espacios
    IF NEW.Nombre_Paciente IS NULL OR TRIM(NEW.Nombre_Paciente) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Nombre de paciente inválido en inserción';
    END IF;

    -- Validar teléfono con longitud mínima
    IF NEW.Telefono_Paciente IS NOT NULL AND CHAR_LENGTH(NEW.Telefono_Paciente) < 5 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Teléfono de paciente demasiado corto en inserción';
    END IF;
END$$
DELIMITER ;

-- UPDATE: validar cambios de nombre y teléfono
DROP TRIGGER IF EXISTS trg_registro_pacientes_upd_valida;
DELIMITER $$
CREATE TRIGGER trg_registro_pacientes_upd_valida
BEFORE UPDATE ON registro_pacientes
FOR EACH ROW
BEGIN
    IF NEW.Nombre_Paciente IS NULL OR TRIM(NEW.Nombre_Paciente) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Nombre de paciente inválido en actualización';
    END IF;

    IF NEW.Telefono_Paciente IS NOT NULL AND CHAR_LENGTH(NEW.Telefono_Paciente) < 5 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Teléfono de paciente demasiado corto en actualización';
    END IF;
END$$
DELIMITER ;

--------------------------------------------------------------------
-- TRIGGER DE VALIDACIÓN SOBRE CITAS
--------------------------------------------------------------------

-- Validar fecha de la cita (no fechas muy antiguas ni nulas)
DROP TRIGGER IF EXISTS trg_registro_citas_ins_valida;
DELIMITER $$
CREATE TRIGGER trg_registro_citas_ins_valida
BEFORE INSERT ON registro_citas
FOR EACH ROW
BEGIN
    IF NEW.Fecha_Cita IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La fecha de la cita es obligatoria';
    END IF;

    -- Ejemplo de validación: no permitir fechas muy anteriores al año 2000
    IF NEW.Fecha_Cita < '2000-01-01' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Fecha de cita no permitida';
    END IF;
END$$
DELIMITER ;

--------------------------------------------------------------------
-- TABLA Y PROCEDIMIENTO DE INFORME DIARIO
--------------------------------------------------------------------

-- Tabla para almacenar informes resumen
CREATE TABLE IF NOT EXISTS informe_citas_diario (
    Id_Informe INT AUTO_INCREMENT PRIMARY KEY,
    Fecha_Informe DATE NOT NULL,
    Sede_Informe VARCHAR(50),
    Medico_Informe VARCHAR(50),
    Total_Citas INT,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Procedimiento que genera un resumen diario por sede y médico
DROP PROCEDURE IF EXISTS sp_generar_informe_citas_diario;
DELIMITER $$
CREATE PROCEDURE sp_generar_informe_citas_diario(
    IN v_fecha DATE
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_bitacora_registro_error(
            'informe_citas_diario',
            301,
            'Error al generar informe de citas diario'
        );
        ROLLBACK;
    END;

    START TRANSACTION;

    INSERT INTO informe_citas_diario (Fecha_Informe,Sede_Informe,Medico_Informe,Total_Citas)
    SELECT
        v_fecha AS Fecha_Informe,
        cs.Nombre_Sede AS Sede_Informe,
        rm.Nombre_Medico AS Medico_Informe,
        COUNT(*) AS Total_Citas
    FROM registro_citas rc
    JOIN catalogo_sedes cs   ON rc.Sede_Ref   = cs.Id_Sede
    JOIN registro_medicos rm ON rc.Medico_Ref = rm.Id_Medico
    WHERE rc.Fecha_Cita = v_fecha
    GROUP BY cs.Nombre_Sede, rm.Nombre_Medico;

    COMMIT;
END$$
DELIMITER ;

--------------------------------------------------------------------
-- VISTA(S) DE CONSULTA
--------------------------------------------------------------------

-- Vista de médicos con sus facultades
CREATE OR REPLACE VIEW vw_medicos_por_facultad AS
SELECT
    rm.Id_Medico,
    rm.Nombre_Medico,
    rm.Especialidad_Medico,
    cf.Id_Facultad,
    cf.Nombre_Facultad,
    cf.Nombre_Decano
FROM registro_medicos rm
JOIN facultad_medicos_rel fmr
    ON rm.Id_Medico = fmr.Medico_Ref
JOIN catalogo_facultades cf
    ON fmr.Facultad_Ref = cf.Id_Facultad;

-- Vista de pacientes por medicamento (a través de citas)
CREATE OR REPLACE VIEW vw_pacientes_por_medicamento AS
SELECT
    rm2.Nombre_Medicamento,
    rp.Id_Paciente,
    rp.Nombre_Paciente,
    rc.Id_Cita,
    rc.Fecha_Cita,
    rc.Diagnostico_Cita
FROM registro_medicamentos rm2
JOIN registro_citas rc
    ON rm2.Cita_Ref = rc.Id_Cita
JOIN registro_pacientes rp
    ON rc.Paciente_Ref = rp.Id_Paciente;

--------------------------------------------------------------------
-- EVENTO PROGRAMADO PARA GENERAR INFORME DIARIO
--------------------------------------------------------------------

-- Importante: requiere que el scheduler de eventos esté activado (event_scheduler=ON).
SET GLOBAL event_scheduler = ON;

DROP EVENT IF EXISTS ev_informe_citas_diario;
DELIMITER $$
CREATE EVENT ev_informe_citas_diario
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_DATE + INTERVAL 1 DAY
DO
BEGIN
    -- Genera el informe para el día anterior
    CALL sp_generar_informe_citas_diario(CURRENT_DATE - INTERVAL 1 DAY);
END$$
DELIMITER ;
