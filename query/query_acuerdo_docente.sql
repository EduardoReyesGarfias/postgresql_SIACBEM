SELECT 
	emp_asign.paterno||' '||emp_asign.materno||' '||emp_asign.nombre AS nombre_completo,
	emp_asign.rfc,
	(
		SELECT STRING_AGG(UPPER(vega.grado_academico), ',' ORDER BY vega.nivel_grado_academico DESC )
		FROM view_empleado_grados_academicos vega
		WHERE vega.id_empleado = emp_asign.id_empleado
	)as grado_academico,
	(
		SELECT STRING_AGG(UPPER(vega.profesion), ',' ORDER BY vega.nivel_grado_academico DESC )
		FROM view_empleado_grados_academicos vega
		WHERE vega.id_empleado = emp_asign.id_empleado
	)as profesion,
	(
		SELECT STRING_AGG(UPPER(vega.valida_archivo), ',' ORDER BY vega.nivel_grado_academico DESC )
		FROM view_empleado_grados_academicos vega
		WHERE vega.id_empleado = emp_asign.id_empleado
	)as profesion,
	STRING_AGG((
		mat.materia||' ('||
		atf.horas_grupo||' hrs - '||
		gpos.nombre_grupo||' )'
	),',') as materia, 
	SUM(atf.horas_grupo) AS horas_grupo,
	catego.categoria_padre,
	mov.codigo, 
	atf.qna_desde,
	atf.qna_hasta,
	STRING_AGG(gpos.nombre_grupo, ',' ORDER BY gpos.nombre_grupo ASC) as nombre_grupo,
	(
		COALESCE((
			SELECT prefijo
			FROM view_empleado_grados_academicos
			WHERE id_empleado = emp_sust.id_empleado
			ORDER BY nivel_grado_academico DESC
			LIMIT 1
		),'')||' '||
		COALESCE(emp_sust.paterno,'')||' '||COALESCE(emp_sust.materno,'')||' '||COALESCE(emp_sust.nombre,'')
	)||''||
	(
		COALESCE((
			SELECT prefijo
			FROM view_empleado_grados_academicos
			WHERE id_empleado = emp_sust_tf.id_empleado
			ORDER BY nivel_grado_academico DESC
			LIMIT 1
		),'')||' '||
		COALESCE(emp_sust_tf.paterno,'')||' '||COALESCE(emp_sust_tf.materno,'')||' '||COALESCE(emp_sust_tf.nombre,'')
	) AS sustituye,
	atf.observacion_comision_mixta
FROM asignacion_tiempo_fijo_basico atf
INNER JOIN empleados emp_asign ON emp_asign.id_empleado = atf.id_empleado
INNER JOIN cat_categorias_padre catego ON catego.id_cat_categoria_padre = atf.id_cat_categoria_padre
INNER JOIN detalle_materias detalle_mat ON detalle_mat.id_detalle_materia = atf.id_detalle_materia
INNER JOIN cat_materias mat ON mat.id_materia = detalle_mat.id_materia
INNER JOIN cat_tipo_movimiento_personal mov ON mov.id_tipo_movimiento_personal = atf.id_tipo_movimiento_personal
INNER JOIN subprogramas subp ON subp.id_subprograma = atf.id_subprograma
INNER JOIN claves_sep sep ON sep.id_sep = subp.id_sep
INNER JOIN grupos_estructura_base gpos ON atf.id_grupo_estructura_base = gpos.id_grupo_estructura_base
LEFT JOIN tramites_licencias_asignaciones licencia_asign1 ON licencia_asign1.id_tramite_licencia_asignacion = atf.id_tramites_licencias_asignaciones AND licencia_asign1.id_componente = 1
LEFT JOIN tramites_licencias licencia1 ON licencia1.id_tramite_licencia = licencia_asign1.id_tramite_licencia
LEFT JOIN empleados emp_sust ON emp_sust.id_empleado = licencia1.id_empleado
LEFT JOIN tramites_licencias_asignaciones_tf licencia_asign2 ON licencia_asign2.id_tramite_licencia_asignacion_tf = atf.id_tramites_licencias_asignaciones_tf AND licencia_asign2.id_componente = 1
LEFT JOIN tramites_licencias licencia2 ON licencia2.id_tramite_licencia = licencia_asign2.id_tramite_licencia
LEFT JOIN empleados emp_sust_tf ON emp_sust_tf.id_empleado = licencia2.id_empleado
WHERE atf.id_asignacion_tiempo_fijo_basico in (12993,12994, 13268, 13001, 13005)
GROUP BY 
	emp_asign.rfc,
	emp_asign.paterno,
	emp_asign.materno,
	emp_asign.nombre,
	emp_asign.id_empleado,
	catego.categoria_padre, 
	mat.materia, 
	atf.qna_desde,
	atf.qna_hasta,
	mov.codigo,
	emp_sust.paterno,
	emp_sust.materno,
	emp_sust.nombre,
	emp_sust.id_empleado,
	emp_sust_tf.paterno,
	emp_sust_tf.materno,
	emp_sust_tf.nombre,
	emp_sust_tf.id_empleado,
	atf.observacion_comision_mixta
ORDER BY
	emp_asign.rfc,
	mat.materia,
	nombre_grupo
	
/*	
SELECT *
FROM asignacion_tiempo_fijo_basico
LIMIT 1
*/