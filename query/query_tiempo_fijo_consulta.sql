/* basico */
SELECT 
a.id_asignacion_tiempo_fijo_basico,b.usuario, c.nombre_subprograma, d.nombre,d.paterno,d.materno
,e.nombre,e.paterno,e.materno, f.nombre_grupo
FROM asignacion_tiempo_fijo_basico a
INNER JOIN usuarios b ON a.id_usuario = b.id_usuario
INNER JOIN subprogramas c ON c.id_subprograma = a.id_subprograma
INNER JOIN empleados d ON d.id_empleado = b.id_empleado
INNER JOIN empleados e ON e.id_empleado = a.id_empleado
INNER JOIN grupos_estructura_base f ON f.id_grupo_estructura_base = a.id_grupo_estructura_base

BEGIN;
DELETE FROM asignacion_tiempo_fijo_basico
WHERE id_asignacion_tiempo_fijo_basico in(10,12)

rollback;
commit;

/* capacitacion */
SELECT 
a.id_asignacion_tiempo_fijo_capacitacion,
b.usuario, c.nombre_subprograma, d.nombre,d.paterno,d.materno
,e.nombre,e.paterno,e.materno, f.nombre_grupo_capacitacion
FROM asignacion_tiempo_fijo_capacitacion a
INNER JOIN usuarios b ON a.id_usuario = b.id_usuario
INNER JOIN subprogramas c ON c.id_subprograma = a.id_subprograma
INNER JOIN empleados d ON d.id_empleado = b.id_empleado
INNER JOIN empleados e ON e.id_empleado = a.id_empleado
INNER JOIN grupos_capacitacion f ON f.id_grupo_capacitacion = a.id_grupo_capacitacion

BEGIN;
DELETE FROM asignacion_tiempo_fijo_capacitacion
WHERE id_asignacion_tiempo_fijo_capacitacion in()

rollback;
commit;



/* formacion */
SELECT a.id_asignacion_tiempo_fijo_optativa,
b.usuario, c.nombre_subprograma, d.nombre,d.paterno,d.materno
,e.nombre,e.paterno,e.materno, f.nombre_grupo_optativas
FROM asignacion_tiempo_fijo_optativas a
INNER JOIN usuarios b ON a.id_usuario = b.id_usuario
INNER JOIN subprogramas c ON c.id_subprograma = a.id_subprograma
INNER JOIN empleados d ON d.id_empleado = b.id_empleado
INNER JOIN empleados e ON e.id_empleado = a.id_empleado
INNER JOIN grupos_optativas f ON f.id_grupo_optativa = a.id_grupo_optativa

BEGIN;

DELETE FROM asignacion_tiempo_fijo_optativa
WHERE a.id_asignacion_tiempo_fijo_optativa in()

rollback;
commit;
