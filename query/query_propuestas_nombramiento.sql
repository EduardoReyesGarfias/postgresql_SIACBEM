-- POR GRUPO

SELECT 
--*
b.filiacion,b.paterno||' '||b.materno||' '||b.nombre as nombre_completo, b.genero, b.fecha_nacimiento
, b.nacionalidad,b.estado_civil, b.lugar_nacimiento
,b.calle,b.no_ext,b.no_int,i.d_codigo,i.d_asenta,i.d_mnpio,i.d_estado,i.d_ciudad
,(
	SELECT STRING_AGG(vega.grado_academico, ',' ORDER BY vega.nivel_grado_academico DESC )
	FROM view_empleado_grados_academicos vega
	WHERE vega.id_empleado = b.id_empleado
)as grado_academico
,(
	SELECT STRING_AGG(vega.profesion, ',' ORDER BY vega.nivel_grado_academico DESC )
	FROM view_empleado_grados_academicos vega
	WHERE vega.id_empleado = b.id_empleado
)as profesion
,b.fecha_ingreso, b.fecha_ingreso_sispagos_impresion
,c.categoria_padre, c.descripcion_cat_padre, a.horas_grupo
,e.materia, a.qna_desde, a.qna_hasta
,f.codigo, f.descripcion, g.nombre_subprograma, h.clave_sep
,(
	SELECT 
	emp.rfc||'|'||
	(emp.paterno||' '||emp.materno||' '||emp.nombre)||'|'||
	convierte_de_fecha_a_qna(fecha_desde)||'|'||
	convierte_de_fecha_a_qna(fecha_hasta)||'|'||
	ctmp.codigo
	FROM tramites_licencias_asignaciones tla
	INNER JOIN tramites_licencias tl ON tl.id_tramite_licencia = tla.id_tramite_licencia
	INNER JOIN profesores_profesor_asignado_base ppa ON ppa.id_profesores_profesor_asignado_base = tla.id_asignacion
	INNER JOIN plantilla_base_docente_rh pbdr ON pbdr.id_plantilla_base_docente_rh = ppa.id_plantilla_base_docente_rh
	INNER JOIN empleados emp ON emp.id_empleado = pbdr.id_empleado 
	INNER JOIN cat_tipo_movimiento_personal ctmp ON ctmp.id_tipo_movimiento_personal = tl.id_movimiento_titular
	WHERE tla.id_tramite_licencia_asignacion = a.id_tramites_licencias_asignaciones
	AND tl.id_cat_tramite_status = 3
)as sustituye
FROM asignacion_tiempo_fijo_basico a
INNER JOIN empleados b ON a.id_empleado = b.id_empleado
INNER JOIN cat_categorias_padre c ON c.id_cat_categoria_padre = a.id_cat_categoria_padre
INNER JOIN detalle_materias d ON d.id_detalle_materia = a.id_detalle_materia
INNER JOIN cat_materias e ON e.id_materia = d.id_materia
INNER JOIN cat_tipo_movimiento_personal f ON f.id_tipo_movimiento_personal = a.id_tipo_movimiento_personal
INNER JOIN subprogramas g ON g.id_subprograma = a.id_subprograma
INNER JOIN claves_sep h ON h.id_sep = g.id_sep
INNER JOIN codigos_postales i ON i.id_cp = b.id_cp
WHERE id_asignacion_tiempo_fijo_basico = 3405




--SELECT split_part('EOHH610704T23|ESCOBAR HERRERA HECTOR','|', 2)


-- POR MATERIA

SELECT 
--*
b.filiacion,b.paterno||' '||b.materno||' '||b.nombre as nombre_completo, b.genero, b.fecha_nacimiento
, b.nacionalidad,b.estado_civil, b.lugar_nacimiento
,b.calle,b.no_ext,b.no_int,i.d_codigo,i.d_asenta,i.d_mnpio,i.d_estado,i.d_ciudad
,(
	SELECT STRING_AGG(vega.grado_academico, ',' ORDER BY vega.nivel_grado_academico DESC )
	FROM view_empleado_grados_academicos vega
	WHERE vega.id_empleado = b.id_empleado
)as grado_academico
,(
	SELECT STRING_AGG(vega.profesion, ',' ORDER BY vega.nivel_grado_academico DESC )
	FROM view_empleado_grados_academicos vega
	WHERE vega.id_empleado = b.id_empleado
)as profesion
,b.fecha_ingreso, b.fecha_ingreso_sispagos_impresion
,c.categoria_padre, c.descripcion_cat_padre, SUM(a.horas_grupo) as horas_grupo
,e.materia, a.qna_desde, a.qna_hasta
,f.codigo, f.descripcion, g.nombre_subprograma, h.clave_sep
,(
	SELECT 
	string_agg(
	emp.rfc
	,',')
	FROM tramites_licencias_asignaciones tla
	INNER JOIN tramites_licencias tl ON tl.id_tramite_licencia = tla.id_tramite_licencia
	INNER JOIN profesores_profesor_asignado_base ppa ON ppa.id_profesores_profesor_asignado_base = tla.id_asignacion
	INNER JOIN plantilla_base_docente_rh pbdr ON pbdr.id_plantilla_base_docente_rh = ppa.id_plantilla_base_docente_rh
	INNER JOIN empleados emp ON emp.id_empleado = pbdr.id_empleado 
	INNER JOIN cat_tipo_movimiento_personal ctmp ON ctmp.id_tipo_movimiento_personal = tl.id_movimiento_titular
	WHERE tla.id_tramite_licencia_asignacion in(
		SELECT id_tramites_licencias_asignaciones
		FROM asignacion_tiempo_fijo_basico 
		WHERE id_empleado = 9355
		AND id_detalle_materia = 754
		AND id_subprograma = 210
		AND id_estructura_ocupacional = 28
	)
	AND tl.id_cat_tramite_status = 3
	AND tla.id_componente = 1
)as sustituye_rfc
,(
	SELECT 
	string_agg(
	emp.paterno||' '||emp.materno||' '||emp.nombre
	,',')
	FROM tramites_licencias_asignaciones tla
	INNER JOIN tramites_licencias tl ON tl.id_tramite_licencia = tla.id_tramite_licencia
	INNER JOIN profesores_profesor_asignado_base ppa ON ppa.id_profesores_profesor_asignado_base = tla.id_asignacion
	INNER JOIN plantilla_base_docente_rh pbdr ON pbdr.id_plantilla_base_docente_rh = ppa.id_plantilla_base_docente_rh
	INNER JOIN empleados emp ON emp.id_empleado = pbdr.id_empleado 
	INNER JOIN cat_tipo_movimiento_personal ctmp ON ctmp.id_tipo_movimiento_personal = tl.id_movimiento_titular
	WHERE tla.id_tramite_licencia_asignacion in(
		SELECT id_tramites_licencias_asignaciones
		FROM asignacion_tiempo_fijo_basico 
		WHERE id_empleado = 9355
		AND id_detalle_materia = 754
		AND id_subprograma = 210
		AND id_estructura_ocupacional = 28
	)
	AND tl.id_cat_tramite_status = 3
	AND tla.id_componente = 1
)as sustituye_nombre
,(
	SELECT 
	string_agg(
	convierte_de_fecha_a_qna(fecha_desde)
	,',')
	FROM tramites_licencias_asignaciones tla
	INNER JOIN tramites_licencias tl ON tl.id_tramite_licencia = tla.id_tramite_licencia
	INNER JOIN profesores_profesor_asignado_base ppa ON ppa.id_profesores_profesor_asignado_base = tla.id_asignacion
	INNER JOIN plantilla_base_docente_rh pbdr ON pbdr.id_plantilla_base_docente_rh = ppa.id_plantilla_base_docente_rh
	INNER JOIN empleados emp ON emp.id_empleado = pbdr.id_empleado 
	INNER JOIN cat_tipo_movimiento_personal ctmp ON ctmp.id_tipo_movimiento_personal = tl.id_movimiento_titular
	WHERE tla.id_tramite_licencia_asignacion in(
		SELECT id_tramites_licencias_asignaciones
		FROM asignacion_tiempo_fijo_basico 
		WHERE id_empleado = 9355
		AND id_detalle_materia = 754
		AND id_subprograma = 210
		AND id_estructura_ocupacional = 28
	)
	AND tl.id_cat_tramite_status = 3
	AND tla.id_componente = 1
)as sustituye_desde
,(
	SELECT 
	string_agg(
	convierte_de_fecha_a_qna(fecha_hasta)
	,',')
	FROM tramites_licencias_asignaciones tla
	INNER JOIN tramites_licencias tl ON tl.id_tramite_licencia = tla.id_tramite_licencia
	INNER JOIN profesores_profesor_asignado_base ppa ON ppa.id_profesores_profesor_asignado_base = tla.id_asignacion
	INNER JOIN plantilla_base_docente_rh pbdr ON pbdr.id_plantilla_base_docente_rh = ppa.id_plantilla_base_docente_rh
	INNER JOIN empleados emp ON emp.id_empleado = pbdr.id_empleado 
	INNER JOIN cat_tipo_movimiento_personal ctmp ON ctmp.id_tipo_movimiento_personal = tl.id_movimiento_titular
	WHERE tla.id_tramite_licencia_asignacion in(
		SELECT id_tramites_licencias_asignaciones
		FROM asignacion_tiempo_fijo_basico 
		WHERE id_empleado = 9355
		AND id_detalle_materia = 754
		AND id_subprograma = 210
		AND id_estructura_ocupacional = 28
	)
	AND tl.id_cat_tramite_status = 3
	AND tla.id_componente = 1
)as sustituye_hasta
,(
	SELECT 
	string_agg(
	CAST(ctmp.codigo as character(2))
	,',')
	FROM tramites_licencias_asignaciones tla
	INNER JOIN tramites_licencias tl ON tl.id_tramite_licencia = tla.id_tramite_licencia
	INNER JOIN profesores_profesor_asignado_base ppa ON ppa.id_profesores_profesor_asignado_base = tla.id_asignacion
	INNER JOIN plantilla_base_docente_rh pbdr ON pbdr.id_plantilla_base_docente_rh = ppa.id_plantilla_base_docente_rh
	INNER JOIN empleados emp ON emp.id_empleado = pbdr.id_empleado 
	INNER JOIN cat_tipo_movimiento_personal ctmp ON ctmp.id_tipo_movimiento_personal = tl.id_movimiento_titular
	WHERE tla.id_tramite_licencia_asignacion in(
		SELECT id_tramites_licencias_asignaciones
		FROM asignacion_tiempo_fijo_basico 
		WHERE id_empleado = 9355
		AND id_detalle_materia = 754
		AND id_subprograma = 210
		AND id_estructura_ocupacional = 28
	)
	AND tl.id_cat_tramite_status = 3
	AND tla.id_componente = 1
)as sustituye_motivo
FROM asignacion_tiempo_fijo_basico a
INNER JOIN empleados b ON a.id_empleado = b.id_empleado
INNER JOIN cat_categorias_padre c ON c.id_cat_categoria_padre = a.id_cat_categoria_padre
INNER JOIN detalle_materias d ON d.id_detalle_materia = a.id_detalle_materia
INNER JOIN cat_materias e ON e.id_materia = d.id_materia
INNER JOIN cat_tipo_movimiento_personal f ON f.id_tipo_movimiento_personal = a.id_tipo_movimiento_personal
INNER JOIN subprogramas g ON g.id_subprograma = a.id_subprograma
INNER JOIN claves_sep h ON h.id_sep = g.id_sep
INNER JOIN codigos_postales i ON i.id_cp = b.id_cp
WHERE b.id_empleado = 9355
AND d.id_detalle_materia = 754
AND a.id_estructura_ocupacional = 28
AND a.id_subprograma = 210
GROUP BY
b.id_empleado,b.filiacion,b.paterno,b.materno,b.nombre, b.genero, b.fecha_nacimiento
,b.nacionalidad,b.estado_civil, b.lugar_nacimiento
,b.calle,b.no_ext,b.no_int,i.d_codigo,i.d_asenta,i.d_mnpio,i.d_estado,i.d_ciudad
,b.fecha_ingreso, b.fecha_ingreso_sispagos_impresion
,c.categoria_padre, c.descripcion_cat_padre
,e.materia, a.qna_desde, a.qna_hasta
,f.codigo, f.descripcion, g.nombre_subprograma, h.clave_sep


SELECT id_tramites_licencias_asignaciones
FROM asignacion_tiempo_fijo_basico 
WHERE id_empleado = 9355
AND id_detalle_materia = 754
AND id_subprograma = 210
AND id_estructura_ocupacional = 28



