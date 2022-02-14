CREATE VIEW view_horas_asignadas_empleado_tf_2 AS
(
SELECT
	asig.id_asignacion_tiempo_fijo_basico AS id_asignacion,
	asig.id_empleado,
	asig.id_estructura_ocupacional,
	subp.id_subprograma,
	subp.nombre_subprograma,
	asig.horas_grupo,
	materia.materia,
	'Básico' as componente,
	gpos.nombre_grupo,
	mov.descripcion,
	mov.codigo,
	catego.categoria_padre,
	asig.qna_desde,
	asig.qna_hasta,
	/*CASE WHEN (tl.id_tramite_licencia is not null) THEN 1 ELSE 0 END AS licencia_tf,
	CASE WHEN (tb.id_tramite_baja is not null) THEN 1 ELSE 0 END AS baja_tf*/
	COALESCE((
		SELECT
			CASE WHEN (tl.id_tramite_licencia is not null) THEN 1 ELSE 0 END
		FROM tramites_licencias_asignaciones_tf tla
		LEFT JOIN tramites_licencias tl ON tl.id_tramite_licencia = tla.id_tramite_licencia AND tl.id_cat_tramite_status = 3
		WHERE 
			tla.id_asignacion = asig.id_asignacion_tiempo_fijo_basico 
			AND tla.id_componente = 1
		LIMIT 1
	), 0) AS licencia_tf,
	COALESCE((	
		SELECT
			CASE WHEN (tb.id_tramite_baja is not null) THEN 1 ELSE 0 END
		FROM tramites_bajas_tiempo_fijo tbtf
		INNER JOIN tramites_bajas tb ON tb.id_tramite_baja = tbtf.id_tramite_baja AND tb.id_cat_tramite_status = 3
		WHERE
			tbtf.id_asignacion = asig.id_asignacion_tiempo_fijo_basico 
			AND tbtf.id_componente = 1
		LIMIT 1
	),0) AS baja_tf,
	asig.id_plantilla_base_docente_rh
FROM asignacion_tiempo_fijo_basico asig
INNER JOIN grupos_estructura_base gpos ON asig.id_grupo_estructura_base = gpos.id_grupo_estructura_base
INNER JOIN detalle_materias detalle ON detalle.id_detalle_materia = asig.id_detalle_materia
INNER JOIN cat_materias materia ON materia.id_materia = detalle.id_materia
INNER JOIN cat_tipo_movimiento_personal mov ON mov.id_tipo_movimiento_personal = asig.id_tipo_movimiento_personal
INNER JOIN cat_categorias_padre catego ON catego.id_cat_categoria_padre = asig.id_cat_categoria_padre
INNER JOIN subprogramas subp ON subp.id_subprograma = asig.id_subprograma
/*LEFT JOIN tramites_licencias_asignaciones_tf tla ON tla.id_asignacion = asig.id_asignacion_tiempo_fijo_basico AND tla.id_componente = 1
LEFT JOIN tramites_licencias tl ON tl.id_tramite_licencia = tla.id_tramite_licencia AND tl.id_cat_tramite_status = 3
LEFT JOIN tramites_bajas_tiempo_fijo tbtf ON tbtf.id_asignacion = asig.id_asignacion_tiempo_fijo_basico AND tbtf.id_componente = 1
LEFT JOIN tramites_bajas tb ON tb.id_tramite_baja = tbtf.id_tramite_baja AND tb.id_cat_tramite_status = 3*/
ORDER BY 
	subp.nombre_subprograma,
	materia.materia,
	asig.horas_grupo
)
UNION ALL
(
SELECT
	asig.id_asignacion_tiempo_fijo_capacitacion AS id_asignacion,
	asig.id_empleado,
	asig.id_estructura_ocupacional,
	subp.id_subprograma,
	subp.nombre_subprograma,
	asig.horas_grupo,
	materia.materia,
	'Capacitación' as componente,
	gpos.nombre_grupo_capacitacion as nombre_grupo,
	mov.descripcion,
	mov.codigo,
	catego.categoria_padre,
	asig.qna_desde,
	asig.qna_hasta,
	/*CASE WHEN (tl.id_tramite_licencia is not null) THEN 1 ELSE 0 END AS licencia_tf,
	CASE WHEN (tb.id_tramite_baja is not null) THEN 1 ELSE 0 END AS baja_tf*/
	COALESCE((
		SELECT
			CASE WHEN (tl.id_tramite_licencia is not null) THEN 1 ELSE 0 END
		FROM tramites_licencias_asignaciones_tf tla
		LEFT JOIN tramites_licencias tl ON tl.id_tramite_licencia = tla.id_tramite_licencia AND tl.id_cat_tramite_status = 3
		WHERE 
			tla.id_asignacion = asig.id_asignacion_tiempo_fijo_capacitacion 
			AND tla.id_componente = 3
		LIMIT 1
	), 0) AS licencia_tf,
	COALESCE((	
		SELECT
		CASE WHEN (tb.id_tramite_baja is not null) THEN 1 ELSE 0 END
		FROM tramites_bajas_tiempo_fijo tbtf
		INNER JOIN tramites_bajas tb ON tb.id_tramite_baja = tbtf.id_tramite_baja AND tb.id_cat_tramite_status = 3
		WHERE
			tbtf.id_asignacion = asig.id_asignacion_tiempo_fijo_capacitacion 
			AND tbtf.id_componente = 3
		LIMIT 1
	),0) AS baja_tf,
	asig.id_plantilla_base_docente_rh
FROM asignacion_tiempo_fijo_capacitacion asig
INNER JOIN grupos_capacitacion gpos ON asig.id_grupo_capacitacion = gpos.id_grupo_capacitacion
INNER JOIN detalle_materias detalle ON detalle.id_detalle_materia = asig.id_detalle_materia
INNER JOIN cat_materias materia ON materia.id_materia = detalle.id_materia
INNER JOIN cat_tipo_movimiento_personal mov ON mov.id_tipo_movimiento_personal = asig.id_tipo_movimiento_personal
INNER JOIN cat_categorias_padre catego ON catego.id_cat_categoria_padre = asig.id_cat_categoria_padre
INNER JOIN subprogramas subp ON subp.id_subprograma = asig.id_subprograma
/*LEFT JOIN tramites_licencias_asignaciones_tf tla ON tla.id_asignacion = asig.id_asignacion_tiempo_fijo_capacitacion AND tla.id_componente = 3
LEFT JOIN tramites_licencias tl ON tl.id_tramite_licencia = tla.id_tramite_licencia AND tl.id_cat_tramite_status = 3
LEFT JOIN tramites_bajas_tiempo_fijo tbtf ON tbtf.id_asignacion = asig.id_asignacion_tiempo_fijo_capacitacion AND tbtf.id_componente = 3
LEFT JOIN tramites_bajas tb ON tb.id_tramite_baja = tbtf.id_tramite_baja AND tb.id_cat_tramite_status = 3*/
ORDER BY 
	subp.nombre_subprograma,
	materia.materia,
	asig.horas_grupo
)

UNION ALL
(
SELECT
	asig.id_asignacion_tiempo_fijo_optativa AS id_asignacion,
	asig.id_empleado,
	asig.id_estructura_ocupacional,
	subp.id_subprograma,
	subp.nombre_subprograma,
	asig.horas_grupo,
	materia.materia,
	'Optativas' as componente,
	gpos.nombre_grupo_optativas as nombre_grupo,
	mov.descripcion,
	mov.codigo,
	catego.categoria_padre,
	asig.qna_desde,
	asig.qna_hasta,
	/*CASE WHEN (tl.id_tramite_licencia is not null) THEN 1 ELSE 0 END AS licencia_tf,
	CASE WHEN (tb.id_tramite_baja is not null) THEN 1 ELSE 0 END AS baja_tf*/
	COALESCE((
		SELECT
			CASE WHEN (tl.id_tramite_licencia is not null) THEN 1 ELSE 0 END
		FROM tramites_licencias_asignaciones_tf tla
		LEFT JOIN tramites_licencias tl ON tl.id_tramite_licencia = tla.id_tramite_licencia AND tl.id_cat_tramite_status = 3
		WHERE 
			tla.id_asignacion = asig.id_asignacion_tiempo_fijo_optativa 
			AND tla.id_componente = 2
		LIMIT 1
	), 0) AS licencia_tf,
	COALESCE((	
		SELECT
		CASE WHEN (tb.id_tramite_baja is not null) THEN 1 ELSE 0 END
		FROM tramites_bajas_tiempo_fijo tbtf
		INNER JOIN tramites_bajas tb ON tb.id_tramite_baja = tbtf.id_tramite_baja AND tb.id_cat_tramite_status = 3
		WHERE
			tbtf.id_asignacion = asig.id_asignacion_tiempo_fijo_optativa 
			AND tbtf.id_componente = 2
		LIMIT 1
	),0) AS baja_tf,
	asig.id_plantilla_base_docente_rh
FROM asignacion_tiempo_fijo_optativas asig
INNER JOIN grupos_optativas gpos ON asig.id_grupo_optativa = gpos.id_grupo_optativa
INNER JOIN detalle_materias detalle ON detalle.id_detalle_materia = asig.id_detalle_materia
INNER JOIN cat_materias materia ON materia.id_materia = detalle.id_materia
INNER JOIN cat_tipo_movimiento_personal mov ON mov.id_tipo_movimiento_personal = asig.id_tipo_movimiento_personal
INNER JOIN cat_categorias_padre catego ON catego.id_cat_categoria_padre = asig.id_cat_categoria_padre
INNER JOIN subprogramas subp ON subp.id_subprograma = asig.id_subprograma
/*LEFT JOIN tramites_licencias_asignaciones_tf tla ON tla.id_asignacion = asig.id_asignacion_tiempo_fijo_optativa AND tla.id_componente = 2
LEFT JOIN tramites_licencias tl ON tl.id_tramite_licencia = tla.id_tramite_licencia AND tl.id_cat_tramite_status = 3
LEFT JOIN tramites_bajas_tiempo_fijo tbtf ON tbtf.id_asignacion = asig.id_asignacion_tiempo_fijo_optativa AND tbtf.id_componente = 2
LEFT JOIN tramites_bajas tb ON tb.id_tramite_baja = tbtf.id_tramite_baja AND tb.id_cat_tramite_status = 3*/
ORDER BY 
	subp.nombre_subprograma,
	materia.materia,
	asig.horas_grupo
)
UNION ALL
(
SELECT
	asig.id_asignacion_tiempo_fijo_paraescolares AS id_asignacion,
	asig.id_empleado,
	asig.id_estructura_ocupacional,
	subp.id_subprograma,
	subp.nombre_subprograma,
	asig.horas_grupo,
	materia.nombre as materia,
	'Paraescolares' as componente,
	gpos.nombre as nombre_grupo,
	mov.descripcion,
	mov.codigo,
	catego.categoria_padre,
	asig.qna_desde,
	asig.qna_hasta,
	/*CASE WHEN (tl.id_tramite_licencia is not null) THEN 1 ELSE 0 END AS licencia_tf,
	CASE WHEN (tb.id_tramite_baja is not null) THEN 1 ELSE 0 END AS baja_tf*/
	COALESCE((
		SELECT
			CASE WHEN (tl.id_tramite_licencia is not null) THEN 1 ELSE 0 END
		FROM tramites_licencias_asignaciones_tf tla
		LEFT JOIN tramites_licencias tl ON tl.id_tramite_licencia = tla.id_tramite_licencia AND tl.id_cat_tramite_status = 3
		WHERE 
			tla.id_asignacion = asig.id_asignacion_tiempo_fijo_paraescolares 
			AND tla.id_componente = 4
		LIMIT 1
	), 0) AS licencia_tf,
	COALESCE((	
		SELECT
		CASE WHEN (tb.id_tramite_baja is not null) THEN 1 ELSE 0 END
		FROM tramites_bajas_tiempo_fijo tbtf
		INNER JOIN tramites_bajas tb ON tb.id_tramite_baja = tbtf.id_tramite_baja AND tb.id_cat_tramite_status = 3
		WHERE
			tbtf.id_asignacion = asig.id_asignacion_tiempo_fijo_paraescolares 
			AND tbtf.id_componente = 4
		LIMIT 1
	),0) AS baja_tf,
	asig.id_plantilla_base_docente_rh
FROM asignacion_tiempo_fijo_paraescolares asig
INNER JOIN grupos_paraescolares gpos ON asig.id_grupo_paraescolares = gpos.id_grupo_paraescolar
INNER JOIN cat_materias_paraescolares materia ON materia.id_paraescolar = asig.id_cat_materias_paraescolares
INNER JOIN cat_tipo_movimiento_personal mov ON mov.id_tipo_movimiento_personal = asig.id_tipo_movimiento_personal
INNER JOIN cat_categorias_padre catego ON catego.id_cat_categoria_padre = asig.id_cat_categoria_padre
INNER JOIN subprogramas subp ON subp.id_subprograma = asig.id_subprograma
/*LEFT JOIN tramites_licencias_asignaciones_tf tla ON tla.id_asignacion = asig.id_asignacion_tiempo_fijo_paraescolares AND tla.id_componente = 4
LEFT JOIN tramites_licencias tl ON tl.id_tramite_licencia = tla.id_tramite_licencia AND tl.id_cat_tramite_status = 3
LEFT JOIN tramites_bajas_tiempo_fijo tbtf ON tbtf.id_asignacion = asig.id_asignacion_tiempo_fijo_paraescolares AND tbtf.id_componente = 4
LEFT JOIN tramites_bajas tb ON tb.id_tramite_baja = tbtf.id_tramite_baja AND tb.id_cat_tramite_status = 3*/
ORDER BY 
	subp.nombre_subprograma,
	materia.nombre,
	asig.horas_grupo
)