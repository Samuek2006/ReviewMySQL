## Base de datos `sistema_clinico`

## Descripción general

`sistema_clinico` es una base de datos MySQL para la gestión de una clínica/hospital, centrada en pacientes, médicos, facultades, sedes, citas y medicamentos. Incluye procedimientos almacenados, triggers, eventos y vistas para soportar operaciones CRUD, reportes y controles de integridad.

## Esquema y tablas principales

- `registro_pacientes`: información básica de pacientes (ID, nombre, teléfono).
- `registro_medicos`: médicos y su especialidad.
- `catalogo_facultades`: facultades médicas y su decano.
- `catalogo_sedes`: sedes o centros de atención.
- `registro_citas`: citas médicas, vinculadas a paciente, médico y sede.
- `registro_medicamentos`: medicamentos recetados por cita (clave compuesta).
- `facultad_medicos_rel`: relación muchos-a-muchos entre médicos y facultades.
- `bitacora_errores`: registro centralizado de errores y eventos de negocio.
- `informe_citas_diario`: tabla de salida para informes diarios de citas por sede y médico.

Cada tabla usa claves primarias claras y claves foráneas para mantener la integridad referencial.

## Procedimientos almacenados

Hay dos grupos de procedimientos: CRUD “normales” y CRUD dinámicos (con `PREPARE/EXECUTE`).

- CRUD básicos por entidad (insert, select, update, delete):
  - Pacientes: `sp_registro_pacientes_*` (alta, consulta, actualiza, baja).
  - Médicos: `sp_registro_medicos_*`.
  - Facultades: `sp_catalogo_facultades_*`.
  - Sedes: `sp_catalogo_sedes_*`.
  - Citas: `sp_registro_citas_*`.
  - Medicamentos: `sp_registro_medicamentos_*`.
  - Relación facultad–médicos: `sp_facultad_medicos_rel_*`.
- CRUD dinámicos (seguridad + SQL dinámico):
  - Pacientes: `sp_registro_pacientes_*_dyn`.
  - Médicos, sedes, facultades, citas, medicamentos, relación: `*_alta_dyn`, `*_consulta_dyn`, `*_actualiza_dyn`, `*_baja_dyn`.
- Reportes:
  - `sp_resumen_medicos_por_especialidad`: cuenta médicos por especialidad.
  - `sp_resumen_pacientes_por_medico`: pacientes distintos por médico.
  - `sp_resumen_pacientes_por_sede`: pacientes distintos por sede.
  - `sp_generar_informe_citas_diario(fecha)`: inserta un resumen de citas por sede y médico en `informe_citas_diario`.
- Manejo de errores:
  - `sp_bitacora_registro_error(origen, codigo, detalle)`: inserta en `bitacora_errores` y es reutilizado por casi todos los procedimientos ante `SQLEXCEPTION`.

## Triggers, vistas y eventos

- Triggers:
  - `trg_registro_pacientes_ins_valida` y `trg_registro_pacientes_upd_valida`: validan nombre y teléfono de pacientes en inserción/actualización, lanzando `SIGNAL '45000'` para datos inválidos.
  - `trg_registro_citas_ins_valida`: valida la fecha de la cita (no nula, no demasiado antigua).
- Vistas:
  - `vw_medicos_por_facultad`: lista médicos con su facultad y decano.
  - `vw_pacientes_por_medicamento`: relaciona medicamentos con pacientes y citas.
- Evento programado:
  - `ev_informe_citas_diario`: se ejecuta diariamente (requiere `event_scheduler=ON`) y llama a `sp_generar_informe_citas_diario` para el día anterior.

## Roles y permisos

Se definen roles lógicos para controlar el acceso:

- `rol_supervisor`: privilegios completos sobre `sistema_clinico.*`.
- `rol_medico_clinico`: lectura sobre pacientes y medicamentos, lectura/escritura sobre citas.
- `rol_recepcion`: lectura e inserción de pacientes, lectura de citas.
- `rol_auditoria`: solo lectura sobre toda la base de datos.

## Cómo usar el script

1. Ejecutar el script completo en un servidor MySQL 8.x con `event_scheduler` habilitado.
2. Revisar y ajustar, si es necesario, los nombres de host/usuarios a los que se asignarán los roles.
3. Probar los procedimientos clave (por ejemplo, alta/consulta de pacientes y citas, generación de informe diario) con datos de ejemplo ya incluidos.
