CREATE OR REPLACE VIEW view_profesores_idoneos_asignados AS
(
SELECT
'Básico' as componente, f.nombre_subprograma, e.paterno, e.materno, e.nombre, d.materia, g.categoria_padre, a.horas_grupo, h.codigo, a.fecha_sistema 
FROM asignacion_tiempo_fijo_basico a
INNER JOIN profesores_idoneos b USING(id_empleado)
INNER JOIN detalle_materias c USING(id_detalle_materia)
INNER JOIN cat_materias d USING(id_materia)
INNER JOIN empleados e USING(id_empleado)
INNER JOIN subprogramas f USING(id_subprograma)
INNER JOIN cat_categorias_padre g USING(id_cat_categoria_padre)
INNER JOIN cat_tipo_movimiento_personal h USING(id_tipo_movimiento_personal)
WHERE h.codigo = 19
ORDER BY f.nombre_subprograma, e.paterno, e.materno, e.nombre, d.materia, g.categoria_padre
)	
UNION ALL
(
SELECT
'Cápacitación' as componente, f.nombre_subprograma, e.paterno, e.materno, e.nombre, d.materia, g.categoria_padre, a.horas_grupo, h.codigo, a.fecha_sistema 
FROM asignacion_tiempo_fijo_capacitacion a
INNER JOIN profesores_idoneos b USING(id_empleado)
INNER JOIN detalle_materias c USING(id_detalle_materia)
INNER JOIN cat_materias d USING(id_materia)
INNER JOIN empleados e USING(id_empleado)
INNER JOIN subprogramas f USING(id_subprograma)
INNER JOIN cat_categorias_padre g USING(id_cat_categoria_padre)
INNER JOIN cat_tipo_movimiento_personal h USING(id_tipo_movimiento_personal)
WHERE h.codigo = 19
ORDER BY f.nombre_subprograma, e.paterno, e.materno, e.nombre, d.materia, g.categoria_padre
)
UNION ALL
(
SELECT
'Optativas' as componente, f.nombre_subprograma, e.paterno, e.materno, e.nombre, d.materia, g.categoria_padre, a.horas_grupo, h.codigo, a.fecha_sistema 
FROM asignacion_tiempo_fijo_optativas a
INNER JOIN profesores_idoneos b USING(id_empleado)
INNER JOIN detalle_materias c USING(id_detalle_materia)
INNER JOIN cat_materias d USING(id_materia)
INNER JOIN empleados e USING(id_empleado)
INNER JOIN subprogramas f USING(id_subprograma)
INNER JOIN cat_categorias_padre g USING(id_cat_categoria_padre)
INNER JOIN cat_tipo_movimiento_personal h USING(id_tipo_movimiento_personal)
WHERE h.codigo = 19
ORDER BY f.nombre_subprograma, e.paterno, e.materno, e.nombre, d.materia, g.categoria_padre
)
UNION ALL
(
SELECT
'Paraescolares' as componente, f.nombre_subprograma, e.paterno, e.materno, e.nombre, d.nombre as materia, g.categoria_padre, a.horas_grupo, h.codigo, a.fecha_sistema 
FROM asignacion_tiempo_fijo_paraescolares a
INNER JOIN profesores_idoneos b USING(id_empleado)
INNER JOIN cat_materias_paraescolares d ON d.id_paraescolar = a.id_cat_materias_paraescolares
INNER JOIN empleados e USING(id_empleado)
INNER JOIN subprogramas f USING(id_subprograma)
INNER JOIN cat_categorias_padre g USING(id_cat_categoria_padre)
INNER JOIN cat_tipo_movimiento_personal h USING(id_tipo_movimiento_personal)
WHERE h.codigo = 19
ORDER BY f.nombre_subprograma, e.paterno, e.materno, e.nombre, d.nombre, g.categoria_padre
)


SELECT *
FROM view_profesores_idoneos_asignados
