CREATE OR REPLACE FUNCTION planteles_asignaciones_tf_historial( _id_estructura int, _id_subprograma int, _id_componente int )
RETURNS TABLE(
	id_asignacion int,
	id_componente int,
	id_empleado int,
	nombre_empleado character varying,
	id_materia int,
	nombre_materia character varying,
	id_grupo int,
	nombre_grupo character varying,
	id_cat_categoria_padre int,
	categoria_padre character varying,
	horas_asignadas int,
	tipo_alta  int,
	qna_desde int,
	qna_hasta int,
	doc_acuerdo boolean,
	perfil int,
	sustituye_base text,
	sustituye_base_activo boolean,
	sustituye_tf text,
	sustituye_tf_activo boolean,
	licencia_tf boolean,
	licencia_tf_activa boolean,
	baja_tf boolean,
	activo boolean
)
AS $$
DECLARE
BEGIN
	
	-- Crear tabla temporal con la estructura deseada
	CREATE TEMP TABLE temp_planteles_asignaciones_tf(
		id_asignacion int,
		id_componente int,
		id_empleado int,
		nombre_empleado character varying,
		id_materia int,
		nombre_materia character varying,
		id_grupo int,
		nombre_grupo character varying,
		id_cat_categoria_padre int,
		categoria_padre character varying,
		horas_asignadas int,
		tipo_alta  int,
		qna_desde int,
		qna_hasta int,
		doc_acuerdo boolean,
		perfil int,
		sustituye_base text,
		sustituye_base_activo boolean,
		sustituye_tf text,
		sustituye_tf_activo boolean,
		licencia_tf boolean,
		licencia_tf_activa boolean,
		baja_tf boolean,
		activo boolean
	);

	IF _id_componente = 1 THEN

		INSERT INTO temp_planteles_asignaciones_tf(id_asignacion, id_componente, id_empleado, nombre_empleado, id_materia, nombre_materia, id_grupo, nombre_grupo, id_cat_categoria_padre, categoria_padre, horas_asignadas, tipo_alta, qna_desde, qna_hasta, doc_acuerdo, perfil, baja_tf, licencia_tf, licencia_tf_activa, sustituye_tf, sustituye_tf_activo, sustituye_base, sustituye_base_activo)
		SELECT
			a.id_asignacion_tiempo_fijo_basico, _id_componente
			,b.id_empleado, b.paterno||' '||b.materno||' '||b.nombre
			,c.id_detalle_materia, d.materia
			,e.id_grupo_estructura_base, e.nombre_grupo
			,f.id_cat_categoria_padre, f.categoria_padre
			,a.horas_grupo, g.codigo, a.qna_desde, a.qna_hasta, a.doc_acuerdo
			,planteles_valida_perfil_1(b.id_empleado, c.id_detalle_materia)
			,(
				CASE WHEN (
					SELECT ba.id_tramite_baja_tiempo_fijo
					FROM tramites_bajas_tiempo_fijo ba
					INNER JOIN tramites_bajas bb ON ba.id_tramite_baja = bb.id_tramite_baja
					WHERE 
						ba.id_asignacion = a.id_asignacion_tiempo_fijo_basico
					AND ba.id_componente = _id_componente
					AND bb.id_cat_tramite_status = 3
				) > 0 THEN true ELSE false END
			) as baja_tf
			,(
				CASE WHEN(
					SELECT ca.id_tramite_licencia_asignacion_tf
					FROM tramites_licencias_asignaciones_tf ca
					INNER JOIN tramites_licencias cb ON cb.id_tramite_licencia = ca.id_tramite_licencia
					WHERE 
						ca.id_asignacion = a.id_asignacion_tiempo_fijo_basico
						AND ca.id_componente = _id_componente 
					ORDER BY ca.id_tramite_licencia_asignacion_tf DESC
					LIMIT 1
				) > 0 THEN true ELSE false END
			) as licencia
			,(
				CASE WHEN(
					SELECT ca.id_tramite_licencia_asignacion_tf
					FROM tramites_licencias_asignaciones_tf ca
					INNER JOIN tramites_licencias cb ON cb.id_tramite_licencia = ca.id_tramite_licencia
					WHERE 
						ca.id_asignacion = a.id_asignacion_tiempo_fijo_basico
						AND ca.id_componente = _id_componente 
						AND cb.fecha_hasta >= CAST(substring(CAST(now() as text),1,10) as date)
					ORDER BY ca.id_tramite_licencia_asignacion_tf DESC
					LIMIT 1
				) > 0 THEN true ELSE false END
			) as licencia_activa
			,(		
				SELECT
				ed.paterno||' '||ed.materno||' '||ed.nombre||'--'||ec.horas_grupo||'--'||convierte_de_fecha_a_qna(eb.fecha_desde)||'--'||convierte_de_fecha_a_qna(eb.fecha_hasta)||'--'||ef.codigo
				FROM tramites_licencias_asignaciones_tf ea
				INNER JOIN tramites_licencias eb ON ea.id_tramite_licencia = eb.id_tramite_licencia
				INNER JOIN asignacion_tiempo_fijo_basico ec ON ec.id_asignacion_tiempo_fijo_basico = ea.id_asignacion
				INNER JOIN empleados ed ON ed.id_empleado = ec.id_empleado
				INNER JOIN cat_categorias_padre ee ON ee.id_cat_categoria_padre = ec.id_cat_categoria_padre
				INNER JOIN cat_tipo_movimiento_personal ef ON ef.id_tipo_movimiento_personal = ec.id_tipo_movimiento_personal
				WHERE
					ea.id_componente = _id_componente
					AND ea.id_tramite_licencia_asignacion_tf = a.id_tramites_licencias_asignaciones_tf
				ORDER BY eb.id_tramite_licencia DESC
				LIMIT 1	
			)as sustituye_tf
			,(
				CASE WHEN a.id_tramites_licencias_asignaciones_tf IS NOT NULL THEN
					CASE WHEN (
						SELECT da.id_tramite_licencia_asignacion_tf
						FROM tramites_licencias_asignaciones_tf da
						INNER JOIN tramites_licencias dc ON dc.id_tramite_licencia = da.id_tramite_licencia
						WHERE 
							da.id_tramite_licencia_asignacion_tf = a.id_tramites_licencias_asignaciones_tf
							AND dc.fecha_hasta >= CAST(substring(CAST(now() as text),1,10) as date)
							AND da.id_componente = _id_componente
					) > 0 THEN true ELSE false END
				ELSE
					false
				END
			) as sustituye_tf_activo
			,(
				SELECT
				ge.paterno||' '||ge.materno||' '||ge.nombre||'--'||gc.horas_grupo_base||'--'||convierte_de_fecha_a_qna(ga.fecha_desde)||'--'||convierte_de_fecha_a_qna(ga.fecha_hasta)
				FROM tramites_licencias ga
				INNER JOIN tramites_licencias_asignaciones gb ON gb.id_tramite_licencia = ga.id_tramite_licencia
				INNER JOIN profesores_profesor_asignado_base gc ON gb.id_asignacion = gc.id_profesores_profesor_asignado_base
				INNER JOIN plantilla_base_docente_rh gd ON gd.id_plantilla_base_docente_rh = gc.id_plantilla_base_docente_rh
				INNER JOIN empleados ge ON ge.id_empleado = gd.id_empleado
				WHERE 
					gb.id_componente = _id_componente
					AND a.id_tramites_licencias_asignaciones = gb.id_tramite_licencia_asignacion
				ORDER BY ga.id_tramite_licencia DESC
				LIMIT 1
			)as sustituye_base
			,(
				CASE WHEN a.id_tramites_licencias_asignaciones IS NOT NULL THEN
					CASE WHEN (
						SELECT ga.id_tramite_licencia
						FROM tramites_licencias ga
						INNER JOIN tramites_licencias_asignaciones gb ON gb.id_tramite_licencia = ga.id_tramite_licencia
						WHERE
							a.id_tramites_licencias_asignaciones = gb.id_tramite_licencia_asignacion
							AND gb.id_componente = _id_componente
							AND ga.fecha_hasta >= CAST(substring(CAST(now() as text),1,10) as date)
					) > 0 THEN true ELSE false END
					
				ELSE
					false
				END	
			) as sustituye_base_activo
		FROM asignacion_tiempo_fijo_basico a
		INNER JOIN empleados b ON a.id_empleado = b.id_empleado
		INNER JOIN detalle_materias c ON c.id_detalle_materia = a.id_detalle_materia
		INNER JOIN cat_materias d ON d.id_materia = c.id_materia
		INNER JOIN grupos_estructura_base e ON e.id_grupo_estructura_base = a.id_grupo_estructura_base
		INNER JOIN cat_categorias_padre f ON f.id_cat_categoria_padre = a.id_cat_categoria_padre
		INNER JOIN cat_tipo_movimiento_personal g ON g.id_tipo_movimiento_personal = a.id_tipo_movimiento_personal
		WHERE 
			a.id_subprograma = _id_subprograma
			AND a.id_estructura_ocupacional = _id_estructura
		ORDER BY 
			a.id_detalle_materia, 
			a.id_grupo_estructura_base,
			a.id_asignacion_tiempo_fijo_basico ASC;	


	ELSIF _id_componente = 2 THEN

		INSERT INTO temp_planteles_asignaciones_tf(id_asignacion, id_componente, id_empleado, nombre_empleado, id_materia, nombre_materia, id_grupo, nombre_grupo, id_cat_categoria_padre, categoria_padre, horas_asignadas, tipo_alta, qna_desde, qna_hasta, doc_acuerdo, perfil, baja_tf, licencia_tf, licencia_tf_activa, sustituye_tf, sustituye_tf_activo, sustituye_base, sustituye_base_activo)
		SELECT 
			a.id_asignacion_tiempo_fijo_optativa, 2
			,b.id_empleado, b.paterno||' '||b.materno||' '||b.nombre
			,c.id_detalle_materia, d.materia
			,e.id_grupo_optativa, e.nombre_grupo_optativas
			,f.id_cat_categoria_padre, f.categoria_padre
			,a.horas_grupo, g.codigo, a.qna_desde, a.qna_hasta, a.doc_acuerdo
			,planteles_valida_perfil_1(b.id_empleado, c.id_detalle_materia)
			,(
				CASE WHEN (
					SELECT ba.id_tramite_baja_tiempo_fijo
					FROM tramites_bajas_tiempo_fijo ba
					INNER JOIN tramites_bajas bb ON ba.id_tramite_baja = bb.id_tramite_baja
					WHERE 
						ba.id_asignacion = a.id_asignacion_tiempo_fijo_optativa
					AND ba.id_componente = _id_componente
					AND bb.id_cat_tramite_status = 3
				) > 0 THEN true ELSE false END
			) as baja_tf
			,(
				CASE WHEN(
					SELECT ca.id_tramite_licencia_asignacion_tf
					FROM tramites_licencias_asignaciones_tf ca
					INNER JOIN tramites_licencias cb ON cb.id_tramite_licencia = ca.id_tramite_licencia
					WHERE 
						ca.id_asignacion = a.id_asignacion_tiempo_fijo_optativa
						AND ca.id_componente = _id_componente 
					ORDER BY ca.id_tramite_licencia_asignacion_tf DESC
					LIMIT 1
				) > 0 THEN true ELSE false END
			) as licencia
			,(
				CASE WHEN(
					SELECT ca.id_tramite_licencia_asignacion_tf
					FROM tramites_licencias_asignaciones_tf ca
					INNER JOIN tramites_licencias cb ON cb.id_tramite_licencia = ca.id_tramite_licencia
					WHERE 
						ca.id_asignacion = a.id_asignacion_tiempo_fijo_optativa
						AND ca.id_componente = _id_componente 
						AND cb.fecha_hasta >= CAST(substring(CAST(now() as text),1,10) as date)
					ORDER BY ca.id_tramite_licencia_asignacion_tf DESC
					LIMIT 1
				) > 0 THEN true ELSE false END
			) as licencia_activa
			,(		
				SELECT
				ed.paterno||' '||ed.materno||' '||ed.nombre||'--'||ec.horas_grupo||'--'||convierte_de_fecha_a_qna(eb.fecha_desde)||'--'||convierte_de_fecha_a_qna(eb.fecha_hasta)||'--'||ef.codigo
				FROM tramites_licencias_asignaciones_tf ea
				INNER JOIN tramites_licencias eb ON ea.id_tramite_licencia = eb.id_tramite_licencia
				INNER JOIN asignacion_tiempo_fijo_optativas ec ON ec.id_asignacion_tiempo_fijo_optativa = ea.id_asignacion
				INNER JOIN empleados ed ON ed.id_empleado = ec.id_empleado
				INNER JOIN cat_categorias_padre ee ON ee.id_cat_categoria_padre = ec.id_cat_categoria_padre
				INNER JOIN cat_tipo_movimiento_personal ef ON ef.id_tipo_movimiento_personal = ec.id_tipo_movimiento_personal
				WHERE
					ea.id_componente = _id_componente
					AND ea.id_tramite_licencia_asignacion_tf = a.id_tramites_licencias_asignaciones_tf
				ORDER BY eb.id_tramite_licencia DESC
				LIMIT 1	
			)as sustituye_tf
			,(
				CASE WHEN a.id_tramites_licencias_asignaciones_tf IS NOT NULL THEN
					CASE WHEN (
						SELECT da.id_tramite_licencia_asignacion_tf
						FROM tramites_licencias_asignaciones_tf da
						INNER JOIN tramites_licencias dc ON dc.id_tramite_licencia = da.id_tramite_licencia
						WHERE 
							da.id_tramite_licencia_asignacion_tf = a.id_tramites_licencias_asignaciones_tf
							AND dc.fecha_hasta >= CAST(substring(CAST(now() as text),1,10) as date)
							AND da.id_componente = _id_componente
					) > 0 THEN true ELSE false END
				ELSE
					false
				END
			) as sustituye_tf_activo
			,(
				SELECT
				ge.paterno||' '||ge.materno||' '||ge.nombre||'--'||gc.horas_grupo_optativas||'--'||convierte_de_fecha_a_qna(ga.fecha_desde)||'--'||convierte_de_fecha_a_qna(ga.fecha_hasta)
				FROM tramites_licencias ga
				INNER JOIN tramites_licencias_asignaciones gb ON gb.id_tramite_licencia = ga.id_tramite_licencia
				INNER JOIN profesores_profesor_asignado_optativas gc ON gb.id_asignacion = gc.id_profesores_profesor_asignado_optativas
				INNER JOIN plantilla_base_docente_rh gd ON gd.id_plantilla_base_docente_rh = gc.id_plantilla_base_docente_rh
				INNER JOIN empleados ge ON ge.id_empleado = gd.id_empleado
				WHERE 
					gb.id_componente = _id_componente
					AND a.id_tramites_licencias_asignaciones = gb.id_tramite_licencia_asignacion
				ORDER BY ga.id_tramite_licencia DESC
				LIMIT 1
			)as sustituye_base
			,(
				CASE WHEN a.id_tramites_licencias_asignaciones IS NOT NULL THEN
					CASE WHEN (
						SELECT ga.id_tramite_licencia
						FROM tramites_licencias ga
						INNER JOIN tramites_licencias_asignaciones gb ON gb.id_tramite_licencia = ga.id_tramite_licencia
						WHERE
							a.id_tramites_licencias_asignaciones = gb.id_tramite_licencia_asignacion
							AND gb.id_componente = _id_componente
							AND ga.fecha_hasta >= CAST(substring(CAST(now() as text),1,10) as date)
					) > 0 THEN true ELSE false END

				ELSE
					false
				END	
			) as sustituye_base_activo
		FROM asignacion_tiempo_fijo_optativas a
		INNER JOIN empleados b ON a.id_empleado = b.id_empleado
		INNER JOIN detalle_materias c ON c.id_detalle_materia = a.id_detalle_materia
		INNER JOIN cat_materias d ON d.id_materia = c.id_materia
		INNER JOIN grupos_optativas e ON e.id_grupo_optativa = a.id_grupo_optativa
		INNER JOIN cat_categorias_padre f ON f.id_cat_categoria_padre = a.id_cat_categoria_padre
		INNER JOIN cat_tipo_movimiento_personal g ON g.id_tipo_movimiento_personal = a.id_tipo_movimiento_personal
		WHERE 
			a.id_subprograma = _id_subprograma
			AND a.id_estructura_ocupacional = _id_estructura
		ORDER BY 
			a.id_detalle_materia, 
			a.id_grupo_optativa,
			a.id_asignacion_tiempo_fijo_optativa ASC;

	ELSIF _id_componente = 3 THEN

		INSERT INTO temp_planteles_asignaciones_tf(id_asignacion, id_componente, id_empleado, nombre_empleado, id_materia, nombre_materia, id_grupo, nombre_grupo, id_cat_categoria_padre, categoria_padre, horas_asignadas, tipo_alta, qna_desde, qna_hasta, doc_acuerdo, perfil, baja_tf, licencia_tf, licencia_tf_activa, sustituye_tf, sustituye_tf_activo, sustituye_base, sustituye_base_activo)
		SELECT 
			a.id_asignacion_tiempo_fijo_capacitacion, 3
			,b.id_empleado, b.paterno||' '||b.materno||' '||b.nombre
			,c.id_detalle_materia, d.materia
			,e.id_grupo_capacitacion, e.nombre_grupo_capacitacion
			,f.id_cat_categoria_padre, f.categoria_padre
			,a.horas_grupo, g.codigo, a.qna_desde, a.qna_hasta, a.doc_acuerdo
			,planteles_valida_perfil_1(b.id_empleado, c.id_detalle_materia)
			,(
				CASE WHEN (
					SELECT ba.id_tramite_baja_tiempo_fijo
					FROM tramites_bajas_tiempo_fijo ba
					INNER JOIN tramites_bajas bb ON ba.id_tramite_baja = bb.id_tramite_baja
					WHERE 
						ba.id_asignacion = a.id_asignacion_tiempo_fijo_capacitacion
					AND ba.id_componente = _id_componente
					AND bb.id_cat_tramite_status = 3
				) > 0 THEN true ELSE false END
			) as baja_tf
			,(
				CASE WHEN(
					SELECT ca.id_tramite_licencia_asignacion_tf
					FROM tramites_licencias_asignaciones_tf ca
					INNER JOIN tramites_licencias cb ON cb.id_tramite_licencia = ca.id_tramite_licencia
					WHERE 
						ca.id_asignacion = a.id_asignacion_tiempo_fijo_capacitacion
						AND ca.id_componente = _id_componente 
					ORDER BY ca.id_tramite_licencia_asignacion_tf DESC
					LIMIT 1
				) > 0 THEN true ELSE false END
			) as licencia
			,(
				CASE WHEN(
					SELECT ca.id_tramite_licencia_asignacion_tf
					FROM tramites_licencias_asignaciones_tf ca
					INNER JOIN tramites_licencias cb ON cb.id_tramite_licencia = ca.id_tramite_licencia
					WHERE 
						ca.id_asignacion = a.id_asignacion_tiempo_fijo_capacitacion
						AND ca.id_componente = _id_componente 
						AND cb.fecha_hasta >= CAST(substring(CAST(now() as text),1,10) as date)
					ORDER BY ca.id_tramite_licencia_asignacion_tf DESC
					LIMIT 1
				) > 0 THEN true ELSE false END
			) as licencia_activa
			,(		
				SELECT
				ed.paterno||' '||ed.materno||' '||ed.nombre||'--'||ec.horas_grupo||'--'||convierte_de_fecha_a_qna(eb.fecha_desde)||'--'||convierte_de_fecha_a_qna(eb.fecha_hasta)||'--'||ef.codigo
				FROM tramites_licencias_asignaciones_tf ea
				INNER JOIN tramites_licencias eb ON ea.id_tramite_licencia = eb.id_tramite_licencia
				INNER JOIN asignacion_tiempo_fijo_capacitacion ec ON ec.id_asignacion_tiempo_fijo_capacitacion = ea.id_asignacion
				INNER JOIN empleados ed ON ed.id_empleado = ec.id_empleado
				INNER JOIN cat_categorias_padre ee ON ee.id_cat_categoria_padre = ec.id_cat_categoria_padre
				INNER JOIN cat_tipo_movimiento_personal ef ON ef.id_tipo_movimiento_personal = ec.id_tipo_movimiento_personal
				WHERE
					ea.id_componente = _id_componente
					AND ea.id_tramite_licencia_asignacion_tf = a.id_tramites_licencias_asignaciones_tf
				ORDER BY eb.id_tramite_licencia DESC
				LIMIT 1	
			)as sustituye_tf
			,(
				CASE WHEN a.id_tramites_licencias_asignaciones_tf IS NOT NULL THEN
					CASE WHEN (
						SELECT da.id_tramite_licencia_asignacion_tf
						FROM tramites_licencias_asignaciones_tf da
						INNER JOIN tramites_licencias dc ON dc.id_tramite_licencia = da.id_tramite_licencia
						WHERE 
							da.id_tramite_licencia_asignacion_tf = a.id_tramites_licencias_asignaciones_tf
							AND dc.fecha_hasta >= CAST(substring(CAST(now() as text),1,10) as date)
							AND da.id_componente = _id_componente
					) > 0 THEN true ELSE false END
				ELSE
					false
				END
			) as sustituye_tf_activo
			,(
				SELECT
				ge.paterno||' '||ge.materno||' '||ge.nombre||'--'||gc.horas_grupo_capacitacion||'--'||convierte_de_fecha_a_qna(ga.fecha_desde)||'--'||convierte_de_fecha_a_qna(ga.fecha_hasta)
				FROM tramites_licencias ga
				INNER JOIN tramites_licencias_asignaciones gb ON gb.id_tramite_licencia = ga.id_tramite_licencia
				INNER JOIN profesores_profesor_asignado_capacitacion gc ON gb.id_asignacion = gc.id_profesores_profesor_asignado_capacitacion
				INNER JOIN plantilla_base_docente_rh gd ON gd.id_plantilla_base_docente_rh = gc.id_plantilla_base_docente_rh
				INNER JOIN empleados ge ON ge.id_empleado = gd.id_empleado
				WHERE 
					gb.id_componente = _id_componente
					AND a.id_tramites_licencias_asignaciones = gb.id_tramite_licencia_asignacion
				ORDER BY ga.id_tramite_licencia DESC
				LIMIT 1
			)as sustituye_base
			,(
				CASE WHEN a.id_tramites_licencias_asignaciones IS NOT NULL THEN
					CASE WHEN (
						SELECT ga.id_tramite_licencia
						FROM tramites_licencias ga
						INNER JOIN tramites_licencias_asignaciones gb ON gb.id_tramite_licencia = ga.id_tramite_licencia
						WHERE
							a.id_tramites_licencias_asignaciones = gb.id_tramite_licencia_asignacion
							AND gb.id_componente = _id_componente
							AND ga.fecha_hasta >= CAST(substring(CAST(now() as text),1,10) as date)
					) > 0 THEN true ELSE false END

				ELSE
					false
				END	
			) as sustituye_base_activo
		FROM asignacion_tiempo_fijo_capacitacion a
		INNER JOIN empleados b ON a.id_empleado = b.id_empleado
		INNER JOIN detalle_materias c ON c.id_detalle_materia = a.id_detalle_materia
		INNER JOIN cat_materias d ON d.id_materia = c.id_materia
		INNER JOIN grupos_capacitacion e ON e.id_grupo_capacitacion = a.id_grupo_capacitacion
		INNER JOIN cat_categorias_padre f ON f.id_cat_categoria_padre = a.id_cat_categoria_padre
		INNER JOIN cat_tipo_movimiento_personal g ON g.id_tipo_movimiento_personal = a.id_tipo_movimiento_personal
		WHERE 
			a.id_subprograma = _id_subprograma
			AND a.id_estructura_ocupacional = _id_estructura
		ORDER BY 
			a.id_detalle_materia, 
			a.id_grupo_capacitacion,
			a.id_asignacion_tiempo_fijo_capacitacion ASC;

	ELSE

		INSERT INTO temp_planteles_asignaciones_tf(id_asignacion, id_componente, id_empleado, nombre_empleado, id_materia, nombre_materia, id_grupo, nombre_grupo, id_cat_categoria_padre, categoria_padre, horas_asignadas, tipo_alta, qna_desde, qna_hasta, doc_acuerdo, perfil, baja_tf, licencia_tf, licencia_tf_activa, sustituye_tf, sustituye_tf_activo, sustituye_base, sustituye_base_activo)
		SELECT  
		a.id_asignacion_tiempo_fijo_paraescolares, 4
		,b.id_empleado, b.paterno||' '||b.materno||' '||b.nombre
		,c.id_paraescolar, c.nombre
		,d.id_grupo_paraescolar, d.nombre
		,e.id_cat_categoria_padre, e.categoria_padre
		,a.horas_grupo, f.codigo, a.qna_desde, a.qna_hasta, a.doc_acuerdo
		,planteles_valida_perfil_1(b.id_empleado, c.id_paraescolar)
		,(
			CASE WHEN (
				SELECT ba.id_tramite_baja_tiempo_fijo
				FROM tramites_bajas_tiempo_fijo ba
				INNER JOIN tramites_bajas bb ON ba.id_tramite_baja = bb.id_tramite_baja
				WHERE 
					ba.id_asignacion = a.id_asignacion_tiempo_fijo_paraescolares
				AND ba.id_componente = _id_componente
				AND bb.id_cat_tramite_status = 3
			) > 0 THEN true ELSE false END
		) as baja_tf
		,(
			CASE WHEN(
				SELECT ca.id_tramite_licencia_asignacion_tf
				FROM tramites_licencias_asignaciones_tf ca
				INNER JOIN tramites_licencias cb ON cb.id_tramite_licencia = ca.id_tramite_licencia
				WHERE 
					ca.id_asignacion = a.id_asignacion_tiempo_fijo_paraescolares
					AND ca.id_componente = _id_componente 
				ORDER BY ca.id_tramite_licencia_asignacion_tf DESC
				LIMIT 1
			) > 0 THEN true ELSE false END
		) as licencia
		,(
			CASE WHEN(
				SELECT ca.id_tramite_licencia_asignacion_tf
				FROM tramites_licencias_asignaciones_tf ca
				INNER JOIN tramites_licencias cb ON cb.id_tramite_licencia = ca.id_tramite_licencia
				WHERE 
					ca.id_asignacion = a.id_asignacion_tiempo_fijo_paraescolares
					AND ca.id_componente = _id_componente 
					AND cb.fecha_hasta >= CAST(substring(CAST(now() as text),1,10) as date)
				ORDER BY ca.id_tramite_licencia_asignacion_tf DESC
				LIMIT 1
			) > 0 THEN true ELSE false END
		) as licencia_activa
		,(		
			SELECT
			ed.paterno||' '||ed.materno||' '||ed.nombre||'--'||ec.horas_grupo||'--'||convierte_de_fecha_a_qna(eb.fecha_desde)||'--'||convierte_de_fecha_a_qna(eb.fecha_hasta)||'--'||ef.codigo
			FROM tramites_licencias_asignaciones_tf ea
			INNER JOIN tramites_licencias eb ON ea.id_tramite_licencia = eb.id_tramite_licencia
			INNER JOIN asignacion_tiempo_fijo_paraescolares ec ON ec.id_asignacion_tiempo_fijo_paraescolares = ea.id_asignacion
			INNER JOIN empleados ed ON ed.id_empleado = ec.id_empleado
			INNER JOIN cat_categorias_padre ee ON ee.id_cat_categoria_padre = ec.id_cat_categoria_padre
			INNER JOIN cat_tipo_movimiento_personal ef ON ef.id_tipo_movimiento_personal = ec.id_tipo_movimiento_personal
			WHERE
				ea.id_componente = _id_componente
				AND ea.id_tramite_licencia_asignacion_tf = a.id_tramites_licencias_asignaciones_tf
			ORDER BY eb.id_tramite_licencia DESC
			LIMIT 1	
		)as sustituye_tf
		,(
			CASE WHEN a.id_tramites_licencias_asignaciones_tf IS NOT NULL THEN
				CASE WHEN (
					SELECT da.id_tramite_licencia_asignacion_tf
					FROM tramites_licencias_asignaciones_tf da
					INNER JOIN tramites_licencias dc ON dc.id_tramite_licencia = da.id_tramite_licencia
					WHERE 
						da.id_tramite_licencia_asignacion_tf = a.id_tramites_licencias_asignaciones_tf
						AND dc.fecha_hasta >= CAST(substring(CAST(now() as text),1,10) as date)
						AND da.id_componente = _id_componente
				) > 0 THEN true ELSE false END
			ELSE
				false
			END
		) as sustituye_tf_activo
		,(
			SELECT
			ge.paterno||' '||ge.materno||' '||ge.nombre||'--'||gc.horas_grupo_paraescolares||'--'||convierte_de_fecha_a_qna(ga.fecha_desde)||'--'||convierte_de_fecha_a_qna(ga.fecha_hasta)
			FROM tramites_licencias ga
			INNER JOIN tramites_licencias_asignaciones gb ON gb.id_tramite_licencia = ga.id_tramite_licencia
			INNER JOIN profesores_profesor_asignado_paraescolares gc ON gb.id_asignacion = gc.id_profesores_profesor_asignado_paraescolares
			INNER JOIN plantilla_base_docente_rh gd ON gd.id_plantilla_base_docente_rh = gc.id_plantilla_base_docente_rh
			INNER JOIN empleados ge ON ge.id_empleado = gd.id_empleado
			WHERE 
				gb.id_componente = _id_componente
				AND a.id_tramites_licencias_asignaciones = gb.id_tramite_licencia_asignacion
			ORDER BY ga.id_tramite_licencia DESC
			LIMIT 1
		)as sustituye_base
		,(
			CASE WHEN a.id_tramites_licencias_asignaciones IS NOT NULL THEN
				CASE WHEN (
					SELECT ga.id_tramite_licencia
					FROM tramites_licencias ga
					INNER JOIN tramites_licencias_asignaciones gb ON gb.id_tramite_licencia = ga.id_tramite_licencia
					WHERE
						a.id_tramites_licencias_asignaciones = gb.id_tramite_licencia_asignacion
						AND gb.id_componente = _id_componente
						AND ga.fecha_hasta >= CAST(substring(CAST(now() as text),1,10) as date)
				) > 0 THEN true ELSE false END

			ELSE
				false
			END	
		) as sustituye_base_activo
	FROM asignacion_tiempo_fijo_paraescolares a
	INNER JOIN empleados b ON a.id_empleado = b.id_empleado
	INNER JOIN cat_materias_paraescolares c ON c.id_paraescolar = a.id_cat_materias_paraescolares
	INNER JOIN grupos_paraescolares d ON d.id_grupo_paraescolar = a.id_grupo_paraescolares
	INNER JOIN cat_categorias_padre e ON e.id_cat_categoria_padre = a.id_cat_categoria_padre
	INNER JOIN cat_tipo_movimiento_personal f ON f.id_tipo_movimiento_personal = a.id_tipo_movimiento_personal
	WHERE 
		a.id_subprograma = _id_subprograma
		AND a.id_estructura_ocupacional = _id_estructura
	ORDER BY 
		a.id_cat_materias_paraescolares, 
		a.id_grupo_paraescolares,
		a.id_asignacion_tiempo_fijo_paraescolares ASC;

	END IF;

	-- Actualizar activo de acuerdo al campo baja_tf
	UPDATE temp_planteles_asignaciones_tf a
	SET activo = false
	WHERE a.baja_tf = true;

	-- Actualizar activo de acuerdo al campo liencia y licencia_activa
	UPDATE temp_planteles_asignaciones_tf a
	SET activo = false
	WHERE a.licencia_tf = true AND a.licencia_tf_activa = true;

	-- Actualizar activo por descarte, los que esten en null son los activos
	UPDATE temp_planteles_asignaciones_tf a
	SET activo = true
	WHERE a.activo is null;

	-- Cuando sustituye en tiempo fijo y termino su periodo
	UPDATE temp_planteles_asignaciones_tf a
	SET activo = false
	WHERE a.sustituye_tf IS NOT NULL AND a.sustituye_tf_activo IS false;

	-- Cuando sustituye en base
	UPDATE temp_planteles_asignaciones_tf a
	SET activo = false
	WHERE a.sustituye_base IS NOT NULL AND a.sustituye_base_activo IS false;

	-- Retorno la query con la estructura deseada
	RETURN QUERY 
	SELECT 
		a.id_asignacion,
		a.id_componente,
		a.id_empleado,
		a.nombre_empleado,
		a.id_materia,
		a.nombre_materia,
		a.id_grupo,
		a.nombre_grupo,
		a.id_cat_categoria_padre,
		a.categoria_padre,
		a.horas_asignadas,
		a.tipo_alta ,
		a.qna_desde,
		a.qna_hasta,
		a.doc_acuerdo,
		a.perfil,
		a.sustituye_base,
		a.sustituye_base_activo,
		a.sustituye_tf,
		a.sustituye_tf_activo,
		a.licencia_tf,
		a.licencia_tf_activa,
		a.baja_tf,
		a.activo
	FROM temp_planteles_asignaciones_tf a
	ORDER BY a.id_materia, a.id_grupo, id_asignacion ASC;

	/* Al retornar se destruye la tambla temporal */
	DROP TABLE temp_planteles_asignaciones_tf;	

END; $$ 
LANGUAGE 'plpgsql';