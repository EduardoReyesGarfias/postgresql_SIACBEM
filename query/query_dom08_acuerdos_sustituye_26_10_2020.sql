SELECT 
STRING_AGG(ff.nombre_grupo||' - '||(
	SELECT COALESCE(prefijo,'')
	FROM view_empleado_grados_academicos
	WHERE id_empleado = ee.id_empleado
	ORDER BY nivel_grado_academico DESC
	LIMIT 1
)||' '||ee.paterno||' '||ee.materno||' '||ee.nombre||' (', ',' )
FROM asignacion_tiempo_fijo_basico aa
INNER JOIN tramites_licencias_asignaciones bb ON aa.id_tramites_licencias_asignaciones = bb.id_tramite_licencia_asignacion
INNER JOIN profesores_profesor_asignado_base cc ON cc.id_profesores_profesor_asignado_base = bb.id_asignacion
INNER JOIN plantilla_base_docente_rh dd ON dd.id_plantilla_base_docente_rh = cc.id_plantilla_base_docente_rh
INNER JOIN empleados ee ON ee.id_empleado = dd.id_empleado
INNER JOIN grupos_estructura_base ff USING(id_grupo_estructura_base)
WHERE aa.id_asignacion_tiempo_fijo_basico in(5988,5976,5977,5978,5979,6231)
AND aa.id_empleado = 10323
AND aa.id_detalle_materia = 757



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
		case WHEN  a.id_tramites_licencias_asignaciones IS NOT NULL THEN
			(
				
				SELECT 
				STRING_AGG(ff.nombre_grupo||' - '||(
					SELECT COALESCE(prefijo,'')
					FROM view_empleado_grados_academicos
					WHERE id_empleado = ee.id_empleado
					ORDER BY nivel_grado_academico DESC
					LIMIT 1
				)||' '||ee.paterno||' '||ee.materno||' '||ee.nombre||' ('||a.horas_grupo||' hrs)', ',' )
				FROM asignacion_tiempo_fijo_basico aa
				INNER JOIN tramites_licencias_asignaciones bb ON aa.id_tramites_licencias_asignaciones = bb.id_tramite_licencia_asignacion
				INNER JOIN profesores_profesor_asignado_base cc ON cc.id_profesores_profesor_asignado_base = bb.id_asignacion
				INNER JOIN plantilla_base_docente_rh dd ON dd.id_plantilla_base_docente_rh = cc.id_plantilla_base_docente_rh
				INNER JOIN empleados ee ON ee.id_empleado = dd.id_empleado
				INNER JOIN grupos_estructura_base ff USING(id_grupo_estructura_base)
				WHERE aa.id_asignacion_tiempo_fijo_basico in(5988,5976,5977,5978,5979,6231)
				AND aa.id_empleado = a.id_empleado
				AND aa.id_detalle_materia = ma.id_detalle_materia

				
				
			 )
		END
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

	LEFT JOIN planteles_firmantes(14,28) f ON 14=s.id_subprograma

	WHERE a.id_subprograma = 14

	AND id_asignacion_tiempo_fijo_basico in(5988,5976,5977,5978,5979,6231)

	GROUP BY
	s.nombre_subprograma ,e.rfc,e.nombre,e.paterno,e.materno,o.periodo,cm.materia,a.horas_grupo,
	d.categoria_padre,m.codigo,m.descripcion,a.qna_desde,a.qna_hasta,
	f.prefijo_director,f.nombre_director,f.puesto_director,f.prefijo_coordinador,
	f.nombre_coordinador,f.puesto_coordinador,a.id_grupo_estructura_base,
	a.observacion_comision_mixta, a.observacion_plantel,a.id_tramites_licencias_asignaciones, ma.id_detalle_materia, a.id_empleado