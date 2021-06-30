SELECT s.nombre_subprograma ,e.rfc,e.nombre,e.paterno,e.materno,o.periodo,cm.materia,a.horas_grupo,
	d.categoria_padre,m.codigo,m.descripcion,a.qna_desde,a.qna_hasta,
	f.prefijo_director,f.nombre_director,f.puesto_director,f.prefijo_coordinador,
	f.nombre_coordinador,f.puesto_coordinador,a.id_grupo_optativa,
	string_agg(dp.profesion,','  ORDER BY dp.id_profesion DESC) as profesion,
	string_agg(b.grado_academico,','  ORDER BY dp.id_profesion DESC) as grado_academico,
	a.observacion_comision_mixta, a.observacion_plantel,
	string_agg(
	(CASE WHEN g.valida_archivo = true THEN
	'SI'
	WHEN g.valida_archivo = false THEN
	'NO'
	WHEN g.valida_archivo is null THEN
	'PEN'
	END),','  ORDER BY dp.id_profesion DESC) as valida_archivo
	
	
	
	,(
		SELECT nombre_grupo_optativas||' - '||(
			SELECT COALESCE(prefijo,'')
			FROM view_empleado_grados_academicos
			WHERE id_empleado = emp.id_empleado
			ORDER BY nivel_grado_academico DESC
			LIMIT 1
		)||' '||emp.paterno||' '||emp.materno||' '||emp.nombre 
		FROM tramites_licencias_asignaciones tla
		INNER JOIN tramites_licencias tl ON tl.id_tramite_licencia = tla.id_tramite_licencia
		INNER JOIN profesores_profesor_asignado_optativas ppa ON ppa.id_profesores_profesor_asignado_optativas = tla.id_asignacion
		INNER JOIN plantilla_base_docente_rh pbdr ON pbdr.id_plantilla_base_docente_rh = ppa.id_plantilla_base_docente_rh
		INNER JOIN empleados emp ON emp.id_empleado = pbdr.id_empleado 
		INNER JOIN profesor_asignado_optativas USING (id_profesor_asignado_optativa)
		INNER JOIN grupos_optativas USING(id_grupo_optativa)
		WHERE tla.id_tramite_licencia_asignacion = a.id_tramites_licencias_asignaciones
		AND tl.id_cat_tramite_status = 3
	)as sustituye

	FROM asignacion_tiempo_fijo_optativas a

	INNER JOIN empleados e ON e.id_empleado = a.id_empleado
	INNER JOIN subprogramas s ON s.id_subprograma = a.id_subprograma
	INNER JOIN cat_estructuras_ocupacionales o ON o.id_estructura_ocupacional = a.id_estructura_ocupacional
	INNER JOIN detalle_materias ma ON ma.id_detalle_materia = a.id_detalle_materia
	INNER JOIN cat_materias cm ON cm.id_materia = ma.id_materia
	INNER JOIN cat_categorias_padre d ON d.id_cat_categoria_padre = a.id_cat_categoria_padre
	INNER JOIN cat_tipo_movimiento_personal m ON m.id_tipo_movimiento_personal = a.id_tipo_movimiento_personal

	INNER JOIN empleado_grados_academicos g ON g.id_empleado = a.id_empleado
	INNER JOIN cat_grados_academicos b ON b.id_grado_academico = g.id_grado_academico
	LEFT JOIN curricula_estudios_empleados c ON c.id_empleado_grado_academico = g.id_empleado_grado_academico
	LEFT JOIN cat_profesiones dp ON dp.id_profesion = c.id_profesion
	LEFT JOIN cat_instituciones_educativas ed ON ed.id_institucion_educativa = c.id_institucion_educativa
	LEFT JOIN cat_documento_de_acreditacion fa ON fa.id_documento_acreditacion = g.id_documento_acreditacion

	LEFT JOIN planteles_firmantes(148,28) f ON 148=s.id_subprograma

	WHERE a.id_subprograma = 148

	AND id_asignacion_tiempo_fijo_optativa in(1519,2206,2205,2249,2250,2207)

	GROUP BY
	s.nombre_subprograma ,e.rfc,e.nombre,e.paterno,e.materno,o.periodo,cm.materia,a.horas_grupo,
	d.categoria_padre,m.codigo,m.descripcion,a.qna_desde,a.qna_hasta,
	f.prefijo_director,f.nombre_director,f.puesto_director,f.prefijo_coordinador,
	f.nombre_coordinador,f.puesto_coordinador,a.id_grupo_optativa,
	a.observacion_comision_mixta, a.observacion_plantel, a.id_tramites_licencias_asignaciones
	
	
	
	
	
	
	-- Basico
SELECT s.nombre_subprograma ,e.rfc,e.nombre,e.paterno,e.materno,o.periodo,cm.materia,a.horas_grupo,
	d.categoria_padre,m.codigo,m.descripcion,a.qna_desde,a.qna_hasta,
	f.prefijo_director,f.nombre_director,f.puesto_director,f.prefijo_coordinador,
	f.nombre_coordinador,f.puesto_coordinador,a.id_grupo_estructura_base,
	string_agg(dp.profesion,','  ORDER BY dp.id_profesion DESC) as profesion,
	string_agg(b.grado_academico,','  ORDER BY dp.id_profesion DESC) as grado_academico,
	a.observacion_comision_mixta, a.observacion_plantel,	
	string_agg(
	(CASE WHEN g.valida_archivo = true THEN
	'SI'
	WHEN g.valida_archivo = false THEN
	'NO'
	WHEN g.valida_archivo is null THEN
	'PEN'
	END),','  ORDER BY dp.id_profesion DESC) as valida_archivo

	,(
		SELECT nombre_grupo||' - '||(
			SELECT COALESCE(prefijo,'')
			FROM view_empleado_grados_academicos
			WHERE id_empleado = emp.id_empleado
			ORDER BY nivel_grado_academico DESC
			LIMIT 1
		)||' '||emp.paterno||' '||emp.materno||' '||emp.nombre 
		FROM tramites_licencias_asignaciones tla
		INNER JOIN tramites_licencias tl ON tl.id_tramite_licencia = tla.id_tramite_licencia
		INNER JOIN profesores_profesor_asignado_base ppa ON ppa.id_profesores_profesor_asignado_base = tla.id_asignacion
		INNER JOIN plantilla_base_docente_rh pbdr ON pbdr.id_plantilla_base_docente_rh = ppa.id_plantilla_base_docente_rh
		INNER JOIN empleados emp ON emp.id_empleado = pbdr.id_empleado 
		INNER JOIN profesor_asignado_base USING (id_profesor_asignado_base)
		INNER JOIN grupos_estructura_base USING(id_grupo_estructura_base)
		WHERE tla.id_tramite_licencia_asignacion = a.id_tramites_licencias_asignaciones
		AND tl.id_cat_tramite_status = 3
	)as sustituye

	FROM asignacion_tiempo_fijo_basico a

	INNER JOIN empleados e ON e.id_empleado = a.id_empleado
	INNER JOIN subprogramas s ON s.id_subprograma = a.id_subprograma
	INNER JOIN cat_estructuras_ocupacionales o ON o.id_estructura_ocupacional = a.id_estructura_ocupacional
	INNER JOIN detalle_materias ma ON ma.id_detalle_materia = a.id_detalle_materia
	INNER JOIN cat_materias cm ON cm.id_materia = ma.id_materia
	INNER JOIN cat_categorias_padre d ON d.id_cat_categoria_padre = a.id_cat_categoria_padre
	INNER JOIN cat_tipo_movimiento_personal m ON m.id_tipo_movimiento_personal = a.id_tipo_movimiento_personal

	INNER JOIN empleado_grados_academicos g ON g.id_empleado = a.id_empleado
	INNER JOIN cat_grados_academicos b ON b.id_grado_academico = g.id_grado_academico
	LEFT JOIN curricula_estudios_empleados c ON c.id_empleado_grado_academico = g.id_empleado_grado_academico
	LEFT JOIN cat_profesiones dp ON dp.id_profesion = c.id_profesion
	LEFT JOIN cat_instituciones_educativas ed ON ed.id_institucion_educativa = c.id_institucion_educativa
	LEFT JOIN cat_documento_de_acreditacion fa ON fa.id_documento_acreditacion = g.id_documento_acreditacion

	LEFT JOIN planteles_firmantes(49,28) f ON 49=s.id_subprograma

	WHERE a.id_subprograma = 49

	AND id_asignacion_tiempo_fijo_basico in(3036,3037,3039)

	GROUP BY
	s.nombre_subprograma ,e.rfc,e.nombre,e.paterno,e.materno,o.periodo,cm.materia,a.horas_grupo,
	d.categoria_padre,m.codigo,m.descripcion,a.qna_desde,a.qna_hasta,
	f.prefijo_director,f.nombre_director,f.puesto_director,f.prefijo_coordinador,
	f.nombre_coordinador,f.puesto_coordinador,a.id_grupo_estructura_base,
	a.observacion_comision_mixta, a.observacion_plantel,a.id_tramites_licencias_asignaciones	



-- capacitacion
SELECT s.nombre_subprograma ,e.rfc,e.nombre,e.paterno,e.materno,o.periodo,cm.materia,a.horas_grupo,
d.categoria_padre,m.codigo,m.descripcion,a.qna_desde,a.qna_hasta,
f.prefijo_director,f.nombre_director,f.puesto_director,f.prefijo_coordinador,
f.nombre_coordinador,f.puesto_coordinador,a.id_grupo_capacitacion,
string_agg(dp.profesion,','  ORDER BY dp.id_profesion DESC) as profesion,
string_agg(b.grado_academico,','  ORDER BY dp.id_profesion DESC) as grado_academico,
a.observacion_comision_mixta, a.observacion_plantel,
string_agg(
(CASE WHEN g.valida_archivo = true THEN
'SI'
WHEN g.valida_archivo = false THEN
'NO'
WHEN g.valida_archivo is null THEN
'PEN'
END),','  ORDER BY dp.id_profesion DESC) as valida_archivo

,(
	SELECT nombre_grupo_capacitacion||' - '||(
		SELECT COALESCE(prefijo,'')
		FROM view_empleado_grados_academicos
		WHERE id_empleado = emp.id_empleado
		ORDER BY nivel_grado_academico DESC
		LIMIT 1
	)||' '||emp.paterno||' '||emp.materno||' '||emp.nombre 
	FROM tramites_licencias_asignaciones tla
	INNER JOIN tramites_licencias tl ON tl.id_tramite_licencia = tla.id_tramite_licencia
	INNER JOIN profesores_profesor_asignado_capacitacion ppa ON ppa.id_profesores_profesor_asignado_capacitacion = tla.id_asignacion
	INNER JOIN plantilla_base_docente_rh pbdr ON pbdr.id_plantilla_base_docente_rh = ppa.id_plantilla_base_docente_rh
	INNER JOIN empleados emp ON emp.id_empleado = pbdr.id_empleado 
	INNER JOIN profesor_asignado_capacitacion USING (id_profesor_asignado_capacitacion)
	INNER JOIN grupos_capacitacion USING(id_grupo_capacitacion)
	WHERE tla.id_tramite_licencia_asignacion = a.id_tramites_licencias_asignaciones
	AND tl.id_cat_tramite_status = 3
)as sustituye

FROM asignacion_tiempo_fijo_capacitacion a

INNER JOIN empleados e ON e.id_empleado = a.id_empleado
INNER JOIN subprogramas s ON s.id_subprograma = a.id_subprograma
INNER JOIN cat_estructuras_ocupacionales o ON o.id_estructura_ocupacional = a.id_estructura_ocupacional
INNER JOIN detalle_materias ma ON ma.id_detalle_materia = a.id_detalle_materia
INNER JOIN cat_materias cm ON cm.id_materia = ma.id_materia
INNER JOIN cat_categorias_padre d ON d.id_cat_categoria_padre = a.id_cat_categoria_padre
INNER JOIN cat_tipo_movimiento_personal m ON m.id_tipo_movimiento_personal = a.id_tipo_movimiento_personal

INNER JOIN empleado_grados_academicos g ON g.id_empleado = a.id_empleado
INNER JOIN cat_grados_academicos b ON b.id_grado_academico = g.id_grado_academico
LEFT JOIN curricula_estudios_empleados c ON c.id_empleado_grado_academico = g.id_empleado_grado_academico
LEFT JOIN cat_profesiones dp ON dp.id_profesion = c.id_profesion
LEFT JOIN cat_instituciones_educativas ed ON ed.id_institucion_educativa = c.id_institucion_educativa
LEFT JOIN cat_documento_de_acreditacion fa ON fa.id_documento_acreditacion = g.id_documento_acreditacion

LEFT JOIN planteles_firmantes(49,28) f ON 49=s.id_subprograma

WHERE a.id_subprograma = 49

AND id_asignacion_tiempo_fijo_capacitacion in(1618,1619)

GROUP BY
s.nombre_subprograma ,e.rfc,e.nombre,e.paterno,e.materno,o.periodo,cm.materia,a.horas_grupo,
d.categoria_padre,m.codigo,m.descripcion,a.qna_desde,a.qna_hasta,
f.prefijo_director,f.nombre_director,f.puesto_director,f.prefijo_coordinador,
f.nombre_coordinador,f.puesto_coordinador,a.id_grupo_capacitacion,
a.observacion_comision_mixta, a.observacion_plantel,a.id_tramites_licencias_asignaciones





-- paraescolares

SELECT s.nombre_subprograma ,e.rfc,e.nombre,e.paterno,e.materno,o.periodo,cm.nombre as materia,a.horas_grupo,
d.categoria_padre,m.codigo,m.descripcion,a.qna_desde,a.qna_hasta,
f.prefijo_director,f.nombre_director,f.puesto_director,f.prefijo_coordinador,
f.nombre_coordinador,f.puesto_coordinador,a.id_grupo_paraescolares,
string_agg(dp.profesion,',' ORDER BY dp.id_profesion DESC) as profesion,
string_agg(b.grado_academico,',' ORDER BY dp.id_profesion DESC) as grado_academico,
a.observacion_comision_mixta, a.observacion_plantel,
string_agg(
(CASE WHEN g.valida_archivo = true THEN
'SI'
WHEN g.valida_archivo = false THEN
'NO'
WHEN g.valida_archivo is null THEN
'PEN'
END),',' ORDER BY dp.id_profesion DESC) as valida_archivo

,(
	SELECT grupos_paraescolares.nombre||' - '||(
		SELECT COALESCE(prefijo,'')
		FROM view_empleado_grados_academicos
		WHERE id_empleado = emp.id_empleado
		ORDER BY nivel_grado_academico DESC
		LIMIT 1
	)||' '||emp.paterno||' '||emp.materno||' '||emp.nombre 
	FROM tramites_licencias_asignaciones tla
	INNER JOIN tramites_licencias tl ON tl.id_tramite_licencia = tla.id_tramite_licencia
	INNER JOIN profesores_profesor_asignado_paraescolares ppa ON ppa.id_profesores_profesor_asignado_paraescolares = tla.id_asignacion
	INNER JOIN plantilla_base_docente_rh pbdr ON pbdr.id_plantilla_base_docente_rh = ppa.id_plantilla_base_docente_rh
	INNER JOIN empleados emp ON emp.id_empleado = pbdr.id_empleado 
	INNER JOIN profesor_asignado_paraescolares USING (id_profesor_asignado_paraescolares)
	INNER JOIN grupos_paraescolares ON grupos_paraescolares.id_grupo_paraescolar = profesor_asignado_paraescolares.id_grupo_paraescolares
	WHERE tla.id_tramite_licencia_asignacion = a.id_tramites_licencias_asignaciones
	AND tl.id_cat_tramite_status = 3
)as sustituye

FROM asignacion_tiempo_fijo_paraescolares a

INNER JOIN empleados e ON e.id_empleado = a.id_empleado
INNER JOIN subprogramas s ON s.id_subprograma = a.id_subprograma
INNER JOIN cat_estructuras_ocupacionales o ON o.id_estructura_ocupacional = a.id_estructura_ocupacional
INNER JOIN cat_materias_paraescolares cm ON cm.id_paraescolar = a.id_cat_materias_paraescolares
INNER JOIN cat_categorias_padre d ON d.id_cat_categoria_padre = a.id_cat_categoria_padre
INNER JOIN cat_tipo_movimiento_personal m ON m.id_tipo_movimiento_personal = a.id_tipo_movimiento_personal

INNER JOIN empleado_grados_academicos g ON g.id_empleado = a.id_empleado
INNER JOIN cat_grados_academicos b ON b.id_grado_academico = g.id_grado_academico
LEFT JOIN curricula_estudios_empleados c ON c.id_empleado_grado_academico = g.id_empleado_grado_academico
LEFT JOIN cat_profesiones dp ON dp.id_profesion = c.id_profesion
LEFT JOIN cat_instituciones_educativas ed ON ed.id_institucion_educativa = c.id_institucion_educativa
LEFT JOIN cat_documento_de_acreditacion fa ON fa.id_documento_acreditacion = g.id_documento_acreditacion

LEFT JOIN planteles_firmantes(49,28) f ON 49=s.id_subprograma

WHERE a.id_subprograma = 49

AND id_asignacion_tiempo_fijo_paraescolares in(1259,927)

GROUP BY
s.nombre_subprograma ,e.rfc,e.nombre,e.paterno,e.materno,o.periodo,cm.nombre,a.horas_grupo,
d.categoria_padre,m.codigo,m.descripcion,a.qna_desde,a.qna_hasta,
f.prefijo_director,f.nombre_director,f.puesto_director,f.prefijo_coordinador,
f.nombre_coordinador,f.puesto_coordinador,a.id_grupo_paraescolares,
a.observacion_comision_mixta, a.observacion_plantel,a.id_tramites_licencias_asignaciones	


