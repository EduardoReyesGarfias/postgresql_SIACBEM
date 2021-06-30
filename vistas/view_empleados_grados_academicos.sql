CREATE OR REPLACE VIEW view_empleado_grados_academicos AS SELECT 
b.id_empleado_grado_academico,a.id_empleado,a.paterno||' '||a.materno||' '||a.nombre as nombre_completo, a.rfc, a.filiacion, c.grado_academico
, e.profesion, 
(
	CASE WHEN a.genero = 'M' THEN
		e.prefijo
	ELSE
		e.prefijo_fem
	END
) as prefijo,
(
	CASE WHEN b.valida_archivo is null THEN
		'PEN'
	WHEN b.valida_archivo = true THEN
		'SI'
	WHEN b.valida_archivo = false THEN
		'NO'
	END
) as valida_archivo, e.tipo_perfil,c.nivel_grado_academico
,e.id_profesion
FROM empleados a
LEFT JOIN empleado_grados_academicos b ON a.id_empleado = b.id_empleado
LEFT JOIN cat_grados_academicos c ON c.id_grado_academico = b.id_grado_academico
LEFT JOIN curricula_estudios_empleados d ON d.id_empleado_grado_academico = b.id_empleado_grado_academico
LEFT JOIN cat_profesiones e ON e.id_profesion = d.id_profesion
ORDER BY a.id_empleado,c.nivel_grado_academico ASC, e.id_profesion;


SELECT * 
FROM view_empleado_grados_academicos
where id_empleado = 9819


