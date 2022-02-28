CREATE OR REPLACE VIEW view_empleado_grados_academicos_actual AS
SELECT 
	
	grados.id_empleado_grado_academico,
	emp.id_empleado,
	emp.paterno||' '||emp.materno||' '||emp.nombre as nombre_completo, 
	emp.rfc, 
	emp.filiacion, 
	cat.grado_academico, 
	profesion.profesion, 
	(
		CASE WHEN emp.genero = 'M' THEN
			profesion.prefijo
		ELSE
			profesion.prefijo_fem
		END
	) as prefijo,
	array_to_json(ARRAY_AGG(
		CASE WHEN archivos.valida_archivo is null THEN
			'PEN'
		WHEN archivos.valida_archivo = true THEN
			'SI'
		WHEN archivos.valida_archivo = false THEN
			'NO'
		END
	)) as valida_archivo,
	array_to_json(ARRAY_AGG(archivos.ruta_archivo)) AS ruta_archivo,
	array_to_json(ARRAY_AGG(archivos.observacion_archivo)) AS observacion_archivo,
	array_to_json(ARRAY_AGG(archivos.id_empleado_grado_academico_archivo)) AS id_empleado_grado_academico_archivo,
	profesion.tipo_perfil,
	cat.nivel_grado_academico,
	profesion.id_profesion,
	ingles.fecha_expedicion,
	ingles.fecha_vigencia,
	ARRAY_AGG(archivos.ruta_archivo) AS ruta_archivo_array
FROM empleados emp
LEFT JOIN empleado_grados_academicos grados ON emp.id_empleado = grados.id_empleado
LEFT JOIN cat_grados_academicos cat ON cat.id_grado_academico = grados.id_grado_academico
LEFT JOIN curricula_estudios_empleados curricula ON curricula.id_empleado_grado_academico = grados.id_empleado_grado_academico
LEFT JOIN cat_profesiones profesion ON profesion.id_profesion = curricula.id_profesion
LEFT JOIN empleado_grados_academicos_archivos archivos ON archivos.id_empleado_grado_academico = grados.id_empleado_grado_academico
LEFT JOIN empleado_grado_academico_ingles_vigencia ingles ON ingles.id_empleado_grado_academico = grados.id_empleado_grado_academico
GROUP BY 
	grados.id_empleado_grado_academico,
	emp.id_empleado,
	emp.paterno,
	emp.materno,
	emp.nombre, 
	emp.rfc, 
	emp.filiacion, 
	cat.grado_academico, 
	profesion.profesion,
	profesion.tipo_perfil,
	cat.nivel_grado_academico,
	profesion.id_profesion,
	ingles.fecha_expedicion,
	ingles.fecha_vigencia
ORDER BY 
	emp.id_empleado,
	cat.nivel_grado_academico ASC, 
	profesion.id_profesion;
	