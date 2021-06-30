

CREATE OR REPLACE VIEW view_plantilla_subprograma AS
(SELECT admon.id_estructura_ocupacional,admon.id_subprograma,emp.id_empleado,emp.nombre,emp.paterno,emp.materno, 'Administrativo' as tipo_plantilla
FROM plantilla_base_administrativo_plantel admon
INNER JOIN empleados emp ON emp.id_empleado = admon.id_empleado
GROUP BY admon.id_estructura_ocupacional,admon.id_subprograma,emp.id_empleado,emp.nombre,emp.paterno,emp.materno 
ORDER BY admon.id_estructura_ocupacional,admon.id_subprograma,emp.nombre)
UNION ALL
(SELECT docente.id_estructura_ocupacional,docente.id_subprograma,emp.id_empleado,emp.nombre,emp.paterno,emp.materno, 'Docente' as tipo_plantilla 
FROM plantilla_base_docente_rh  docente 
INNER JOIN empleados emp ON emp.id_empleado = docente.id_empleado
WHERE docente.revision_rh = true
GROUP BY docente.id_estructura_ocupacional,docente.id_subprograma,emp.id_empleado,emp.nombre,emp.paterno,emp.materno 
ORDER BY emp.nombre)

SELECT id_empleado, nombre, paterno, materno
FROM view_plantilla_subprograma
where id_subprograma = 87
AND id_estructura_ocupacional = 27
GROUP BY id_empleado, nombre,paterno,materno
ORDER BY nombre,paterno,materno


