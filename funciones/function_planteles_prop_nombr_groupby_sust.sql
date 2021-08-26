CREATE OR REPLACE FUNCTION planteles_prop_nombr_groupby_sust(_tipo int, _id_asignacion int, _id_componente int)
RETURNS TABLE(
	filiacion character varying(13),
	nombre_completo character varying, 
	genero character varying(1),
	lugar_nacimiento character varying,
	fecha_nacimiento date,
	nacionalidad character varying,
	estado_civil character varying,
	calle character varying,
	no_ext character varying,
	no_int character varying,
	d_codigo character varying,
	d_asenta character varying,
	d_mnpio character varying,
	d_estado character varying,
	d_ciudad character varying,
	grado_academico character varying,
	profesion character varying,
	fecha_ingreso date,
	fecha_ingreso_sispagos_impresion date,
	categoria_padre character varying,
	descripcion_cat_padre character varying,
	horas_grupo integer,
	materia character varying,
	qna_desde integer,
	qna_hasta integer,
	codigo smallint,
	descripcion character varying,
	nombre_subprograma character varying,
	clave_sep character varying,
	nombre_grupo character varying,
	rfc_sustituye character varying,
	nombre_sustituye character varying,
	fecha_desde_sustituye character varying,
	fecha_hasta_sustituye character varying,
	motivo_sustituye character varying,
	rfc_sustituye_tf character varying,
	nombre_sustituye_tf character varying,
	fecha_desde_sustituye_tf character varying,
	fecha_hasta_sustituye_tf character varying,
	motivo_sustituye_tf character varying
)
AS $$
DECLARE
BEGIN
	
	-- Creo la tabla temporal para ayudarme a acomodar la info
	CREATE TEMP TABLE temp_planteles_propuesta_nombramiento(
		filiacion character varying(13),
		nombre_completo character varying, 
		genero character varying(1),
		lugar_nacimiento character varying,
		fecha_nacimiento date,
		nacionalidad character varying,
		estado_civil character varying,
		calle character varying,
		no_ext character varying,
		no_int character varying,
		d_codigo character varying,
		d_asenta character varying,
		d_mnpio character varying,
		d_estado character varying,
		d_ciudad character varying,
		grado_academico character varying,
		profesion character varying,
		fecha_ingreso date,
		fecha_ingreso_sispagos_impresion date,
		categoria_padre character varying,
		descripcion_cat_padre character varying,
		horas_grupo integer,
		materia character varying,
		qna_desde integer,
		qna_hasta integer,
		codigo smallint,
		descripcion character varying,
		nombre_subprograma character varying,
		clave_sep character varying,
		nombre_grupo character varying,
		rfc_sustituye character varying,
		nombre_sustituye character varying,
		fecha_desde_sustituye character varying,
		fecha_hasta_sustituye character varying,
		motivo_sustituye character varying,
		rfc_sustituye_tf character varying,
		nombre_sustituye_tf character varying,
		fecha_desde_sustituye_tf character varying,
		fecha_hasta_sustituye_tf character varying,
		motivo_sustituye_tf character varying
	);


	/*
	tipo 1 = Agrupa por grupo
	tipo 2 = Agrupado por materia
	*/
	IF( _tipo = 2 ) THEN

		-- Basico
		IF(_id_componente = 1) THEN

			INSERT INTO temp_planteles_propuesta_nombramiento(filiacion, nombre_completo, genero, lugar_nacimiento, fecha_nacimiento, nacionalidad, estado_civil, calle, no_ext, no_int, d_codigo, d_asenta, d_mnpio, d_estado, d_ciudad, grado_academico, profesion, fecha_ingreso, fecha_ingreso_sispagos_impresion, categoria_padre, descripcion_cat_padre, horas_grupo, materia, qna_desde, qna_hasta, codigo, descripcion, nombre_subprograma, clave_sep, nombre_grupo, rfc_sustituye, rfc_sustituye_tf)
			SELECT 
			emp_asign.filiacion,
			emp_asign.paterno||' '||emp_asign.materno||' '||emp_asign.nombre AS nombre_completo,
			emp_asign.genero,
			upper(emp_asign.lugar_nacimiento) AS lugar_nacimiento,
			emp_asign.fecha_nacimiento,
			UPPER(emp_asign.nacionalidad) AS nacionalidad,
			UPPER(emp_asign.estado_civil) AS estado_civil,
			UPPER(emp_asign.calle) AS calle,
			emp_asign.no_ext,
			emp_asign.no_int,
			UPPER(cp1.d_asenta) AS d_asenta,
			UPPER(cp1.d_ciudad) AS d_ciudad,
			UPPER(cp1.d_estado) AS d_estado,
			UPPER(cp1.d_codigo) AS d_codigo,
			emp_asign.telefono,
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
			emp_asign.fecha_ingreso, 
			emp_asign.fecha_ingreso_sispagos_impresion,
			catego.categoria_padre, 
			catego.descripcion_cat_padre,
			SUM(atfb1.horas_grupo) AS horas_grupo,
			mat.materia, 
			atfb1.qna_desde,
			atfb1.qna_hasta,
			mov.codigo, 
			mov.descripcion,
			(
				case 
					when subp.clave_subprograma = '001' 
					then subp.clave_extension_u_organica 
					else subp.clave_subprograma 
				end || ' ' || UPPER(subp.nombre_subprograma)
			) as nombre_subprograma,
			sep.clave_sep,
			STRING_AGG(gpos.nombre_grupo, ',' ORDER BY gpos.nombre_grupo ASC) as nombre_grupo,
			STRING_AGG(
				DISTINCT
				emp1.rfc||'|'||
				emp1.paterno||' '||emp1.materno||' '||emp1.nombre||'|'||
				mov1.codigo||'|'||
				(CASE WHEN licencia1.fecha_desde IS NOT NULL THEN convierte_de_fecha_a_qna(licencia1.fecha_desde) ELSE '' END)||'|'||
				(CASE WHEN licencia1.fecha_desde IS NOT NULL THEN convierte_de_fecha_a_qna(licencia1.fecha_hasta) ELSE '' END)
				, ','
			) AS sustituye,
			STRING_AGG(
				DISTINCT
				emp_tf1.rfc||'|'||
				emp_tf1.paterno||' '||emp_tf1.materno||' '||emp_tf1.nombre||'|'||
				mov2.codigo||'|'||
				(CASE WHEN licencia3.fecha_desde IS NOT NULL THEN convierte_de_fecha_a_qna(licencia3.fecha_desde) ELSE '' END)||'|'||
				(CASE WHEN licencia3.fecha_desde IS NOT NULL THEN convierte_de_fecha_a_qna(licencia3.fecha_hasta) ELSE '' END)
				, ','
			) AS sustituye_tf
			FROM asignacion_tiempo_fijo_basico atfb1
			LEFT JOIN tramites_licencias_asignaciones licencia_asign1 ON licencia_asign1.id_tramite_licencia_asignacion = atfb1.id_tramites_licencias_asignaciones
			LEFT JOIN tramites_licencias licencia1 ON licencia1.id_tramite_licencia = licencia_asign1.id_tramite_licencia
			LEFT JOIN empleados emp1 ON emp1.id_empleado = licencia1.id_empleado
			LEFT JOIN empleados emp_asign ON emp_asign.id_empleado = atfb1.id_empleado
			LEFT JOIN codigos_postales cp1 ON cp1.id_cp = emp_asign.id_cp
			LEFT JOIN cat_categorias_padre catego ON catego.id_cat_categoria_padre = atfb1.id_cat_categoria_padre
			LEFT JOIN detalle_materias detalle_mat ON detalle_mat.id_detalle_materia = atfb1.id_detalle_materia
			LEFT JOIN cat_materias mat ON mat.id_materia = detalle_mat.id_materia
			LEFT JOIN cat_tipo_movimiento_personal mov ON mov.id_tipo_movimiento_personal = atfb1.id_tipo_movimiento_personal
			LEFT JOIN cat_tipo_movimiento_personal mov1 ON mov1.id_tipo_movimiento_personal = licencia1.id_movimiento_titular
			LEFT JOIN subprogramas subp ON subp.id_subprograma = atfb1.id_subprograma
			LEFT JOIN claves_sep sep ON sep.id_sep = subp.id_sep
			LEFT JOIN grupos_estructura_base gpos ON atfb1.id_grupo_estructura_base = gpos.id_grupo_estructura_base
			LEFT JOIN tramites_licencias_asignaciones_tf licencia_tf1 ON licencia_tf1.id_tramite_licencia_asignacion_tf = atfb1.id_tramites_licencias_asignaciones_tf 
			LEFT JOIN tramites_licencias licencia3 ON licencia3.id_tramite_licencia = licencia_tf1.id_tramite_licencia
			LEFT JOIN empleados emp_tf1 ON emp_tf1.id_empleado = licencia3.id_empleado
			LEFT JOIN cat_tipo_movimiento_personal mov2 ON mov2.id_tipo_movimiento_personal = licencia3.id_movimiento_titular
			WHERE
				CAST(COALESCE(atfb1.id_empleado,'0') AS text)||
				CAST(COALESCE(atfb1.id_detalle_materia,'0') AS text)||
				CAST(COALESCE(atfb1.id_subprograma,'0') AS text)||
				CAST(COALESCE(atfb1.id_estructura_ocupacional,'0') AS text)||
				COALESCE(emp1.paterno||emp1.materno||emp1.nombre,'')
				= (
					SELECT 
						CAST(COALESCE(atfb2.id_empleado, '0') AS text)||
						CAST(COALESCE(atfb2.id_detalle_materia,'0') AS text)||
						CAST(COALESCE(atfb2.id_subprograma,'0') AS text)||
						CAST(COALESCE(atfb2.id_estructura_ocupacional,'0') AS text)||
						COALESCE(emp2.paterno||emp2.materno||emp2.nombre, '')
					FROM asignacion_tiempo_fijo_basico atfb2
					LEFT JOIN tramites_licencias_asignaciones licencia_asign2 ON licencia_asign2.id_tramite_licencia_asignacion = atfb2.id_tramites_licencias_asignaciones
					LEFT JOIN tramites_licencias licencia2 ON licencia2.id_tramite_licencia = licencia_asign2.id_tramite_licencia
					LEFT JOIN empleados emp2 ON emp2.id_empleado = licencia2.id_empleado
					WHERE atfb2.id_asignacion_tiempo_fijo_basico = _id_asignacion 
				)
			GROUP BY 
				emp_asign.filiacion,
				emp_asign.paterno,
				emp_asign.materno,
				emp_asign.nombre,
				emp_asign.genero,
				emp_asign.lugar_nacimiento,
				emp_asign.fecha_nacimiento,
				emp_asign.nacionalidad,
				emp_asign.estado_civil,
				emp_asign.calle,
				emp_asign.no_ext,
				emp_asign.no_int,
				cp1.d_asenta,
				cp1.d_ciudad,
				cp1.d_estado,
				cp1.d_codigo,
				emp_asign.telefono,
				emp_asign.id_empleado,
				catego.categoria_padre,
				catego.descripcion_cat_padre,
				mat.materia,
				atfb1.qna_desde,
				atfb1.qna_hasta,
				mov.codigo,
				mov.descripcion,
				subp.clave_subprograma,
				subp.clave_extension_u_organica,
				subp.nombre_subprograma,
				sep.clave_sep;

		END IF;

		-- Optativas
		IF(_id_componente = 2) THEN

			INSERT INTO temp_planteles_propuesta_nombramiento(filiacion, nombre_completo, genero, lugar_nacimiento, fecha_nacimiento, nacionalidad, estado_civil, calle, no_ext, no_int, d_codigo, d_asenta, d_mnpio, d_estado, d_ciudad, grado_academico, profesion, fecha_ingreso, fecha_ingreso_sispagos_impresion, categoria_padre, descripcion_cat_padre, horas_grupo, materia, qna_desde, qna_hasta, codigo, descripcion, nombre_subprograma, clave_sep, nombre_grupo, rfc_sustituye, rfc_sustituye_tf)
			SELECT 
			emp_asign.filiacion,
			emp_asign.paterno||' '||emp_asign.materno||' '||emp_asign.nombre AS nombre_completo,
			emp_asign.genero,
			upper(emp_asign.lugar_nacimiento) AS lugar_nacimiento,
			emp_asign.fecha_nacimiento,
			UPPER(emp_asign.nacionalidad) AS nacionalidad,
			UPPER(emp_asign.estado_civil) AS estado_civil,
			UPPER(emp_asign.calle) AS calle,
			emp_asign.no_ext,
			emp_asign.no_int,
			UPPER(cp1.d_asenta) AS d_asenta,
			UPPER(cp1.d_ciudad) AS d_ciudad,
			UPPER(cp1.d_estado) AS d_estado,
			UPPER(cp1.d_codigo) AS d_codigo,
			emp_asign.telefono,
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
			emp_asign.fecha_ingreso, 
			emp_asign.fecha_ingreso_sispagos_impresion,
			catego.categoria_padre, 
			catego.descripcion_cat_padre,
			SUM(atfb1.horas_grupo) AS horas_grupo,
			mat.materia, 
			atfb1.qna_desde,
			atfb1.qna_hasta,
			mov.codigo, 
			mov.descripcion,
			(
				case 
					when subp.clave_subprograma = '001' 
					then subp.clave_extension_u_organica 
					else subp.clave_subprograma 
				end || ' ' || UPPER(subp.nombre_subprograma)
			) as nombre_subprograma,
			sep.clave_sep,
			STRING_AGG(gpos.nombre_grupo_optativas, ',' ORDER BY gpos.nombre_grupo_optativas ASC) as nombre_grupo,
			STRING_AGG(
				DISTINCT
				emp1.rfc||'|'||
				emp1.paterno||' '||emp1.materno||' '||emp1.nombre||'|'||
				mov1.codigo||'|'||
				(CASE WHEN licencia1.fecha_desde IS NOT NULL THEN convierte_de_fecha_a_qna(licencia1.fecha_desde) ELSE '' END)||'|'||
				(CASE WHEN licencia1.fecha_desde IS NOT NULL THEN convierte_de_fecha_a_qna(licencia1.fecha_hasta) ELSE '' END)
				, ','
			) AS sustituye,
			STRING_AGG(
				DISTINCT
				emp_tf1.rfc||'|'||
				emp_tf1.paterno||' '||emp_tf1.materno||' '||emp_tf1.nombre||'|'||
				mov2.codigo||'|'||
				(CASE WHEN licencia3.fecha_desde IS NOT NULL THEN convierte_de_fecha_a_qna(licencia3.fecha_desde) ELSE '' END)||'|'||
				(CASE WHEN licencia3.fecha_desde IS NOT NULL THEN convierte_de_fecha_a_qna(licencia3.fecha_hasta) ELSE '' END)
				, ','
			) AS sustituye_tf
			FROM asignacion_tiempo_fijo_optativas atfb1
			LEFT JOIN tramites_licencias_asignaciones licencia_asign1 ON licencia_asign1.id_tramite_licencia_asignacion = atfb1.id_tramites_licencias_asignaciones
			LEFT JOIN tramites_licencias licencia1 ON licencia1.id_tramite_licencia = licencia_asign1.id_tramite_licencia
			LEFT JOIN empleados emp1 ON emp1.id_empleado = licencia1.id_empleado
			LEFT JOIN empleados emp_asign ON emp_asign.id_empleado = atfb1.id_empleado
			LEFT JOIN codigos_postales cp1 ON cp1.id_cp = emp_asign.id_cp
			LEFT JOIN cat_categorias_padre catego ON catego.id_cat_categoria_padre = atfb1.id_cat_categoria_padre
			LEFT JOIN detalle_materias detalle_mat ON detalle_mat.id_detalle_materia = atfb1.id_detalle_materia
			LEFT JOIN cat_materias mat ON mat.id_materia = detalle_mat.id_materia
			LEFT JOIN cat_tipo_movimiento_personal mov ON mov.id_tipo_movimiento_personal = atfb1.id_tipo_movimiento_personal
			LEFT JOIN cat_tipo_movimiento_personal mov1 ON mov1.id_tipo_movimiento_personal = licencia1.id_movimiento_titular
			LEFT JOIN subprogramas subp ON subp.id_subprograma = atfb1.id_subprograma
			LEFT JOIN claves_sep sep ON sep.id_sep = subp.id_sep
			LEFT JOIN grupos_optativas gpos ON atfb1.id_grupo_optativa = gpos.id_grupo_optativa
			LEFT JOIN tramites_licencias_asignaciones_tf licencia_tf1 ON licencia_tf1.id_tramite_licencia_asignacion_tf = atfb1.id_tramites_licencias_asignaciones_tf 
			LEFT JOIN tramites_licencias licencia3 ON licencia3.id_tramite_licencia = licencia_tf1.id_tramite_licencia
			LEFT JOIN empleados emp_tf1 ON emp_tf1.id_empleado = licencia3.id_empleado
			LEFT JOIN cat_tipo_movimiento_personal mov2 ON mov2.id_tipo_movimiento_personal = licencia3.id_movimiento_titular
			WHERE
				CAST(COALESCE(atfb1.id_empleado,'0') AS text)||
				CAST(COALESCE(atfb1.id_detalle_materia,'0') AS text)||
				CAST(COALESCE(atfb1.id_subprograma,'0') AS text)||
				CAST(COALESCE(atfb1.id_estructura_ocupacional,'0') AS text)||
				COALESCE(emp1.paterno||emp1.materno||emp1.nombre,'')
				= (
					SELECT 
						CAST(COALESCE(atfb2.id_empleado, '0') AS text)||
						CAST(COALESCE(atfb2.id_detalle_materia,'0') AS text)||
						CAST(COALESCE(atfb2.id_subprograma,'0') AS text)||
						CAST(COALESCE(atfb2.id_estructura_ocupacional,'0') AS text)||
						COALESCE(emp2.paterno||emp2.materno||emp2.nombre, '')
					FROM asignacion_tiempo_fijo_optativas atfb2
					LEFT JOIN tramites_licencias_asignaciones licencia_asign2 ON licencia_asign2.id_tramite_licencia_asignacion = atfb2.id_tramites_licencias_asignaciones
					LEFT JOIN tramites_licencias licencia2 ON licencia2.id_tramite_licencia = licencia_asign2.id_tramite_licencia
					LEFT JOIN empleados emp2 ON emp2.id_empleado = licencia2.id_empleado
					WHERE atfb2.id_asignacion_tiempo_fijo_optativa = _id_asignacion 
				)
			GROUP BY 
				emp_asign.filiacion,
				emp_asign.paterno,
				emp_asign.materno,
				emp_asign.nombre,
				emp_asign.genero,
				emp_asign.lugar_nacimiento,
				emp_asign.fecha_nacimiento,
				emp_asign.nacionalidad,
				emp_asign.estado_civil,
				emp_asign.calle,
				emp_asign.no_ext,
				emp_asign.no_int,
				cp1.d_asenta,
				cp1.d_ciudad,
				cp1.d_estado,
				cp1.d_codigo,
				emp_asign.telefono,
				emp_asign.id_empleado,
				catego.categoria_padre,
				catego.descripcion_cat_padre,
				mat.materia,
				atfb1.qna_desde,
				atfb1.qna_hasta,
				mov.codigo,
				mov.descripcion,
				subp.clave_subprograma,
				subp.clave_extension_u_organica,
				subp.nombre_subprograma,
				sep.clave_sep;

		END IF;

		-- Capacitacion
		IF(_id_componente = 3) THEN

			INSERT INTO temp_planteles_propuesta_nombramiento(filiacion, nombre_completo, genero, lugar_nacimiento, fecha_nacimiento, nacionalidad, estado_civil, calle, no_ext, no_int, d_codigo, d_asenta, d_mnpio, d_estado, d_ciudad, grado_academico, profesion, fecha_ingreso, fecha_ingreso_sispagos_impresion, categoria_padre, descripcion_cat_padre, horas_grupo, materia, qna_desde, qna_hasta, codigo, descripcion, nombre_subprograma, clave_sep, nombre_grupo, rfc_sustituye, rfc_sustituye_tf)
			SELECT 
			emp_asign.filiacion,
			emp_asign.paterno||' '||emp_asign.materno||' '||emp_asign.nombre AS nombre_completo,
			emp_asign.genero,
			upper(emp_asign.lugar_nacimiento) AS lugar_nacimiento,
			emp_asign.fecha_nacimiento,
			UPPER(emp_asign.nacionalidad) AS nacionalidad,
			UPPER(emp_asign.estado_civil) AS estado_civil,
			UPPER(emp_asign.calle) AS calle,
			emp_asign.no_ext,
			emp_asign.no_int,
			UPPER(cp1.d_asenta) AS d_asenta,
			UPPER(cp1.d_ciudad) AS d_ciudad,
			UPPER(cp1.d_estado) AS d_estado,
			UPPER(cp1.d_codigo) AS d_codigo,
			emp_asign.telefono,
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
			emp_asign.fecha_ingreso, 
			emp_asign.fecha_ingreso_sispagos_impresion,
			catego.categoria_padre, 
			catego.descripcion_cat_padre,
			SUM(atfb1.horas_grupo) AS horas_grupo,
			mat.materia, 
			atfb1.qna_desde,
			atfb1.qna_hasta,
			mov.codigo, 
			mov.descripcion,
			(
				case 
					when subp.clave_subprograma = '001' 
					then subp.clave_extension_u_organica 
					else subp.clave_subprograma 
				end || ' ' || UPPER(subp.nombre_subprograma)
			) as nombre_subprograma,
			sep.clave_sep,
			STRING_AGG(gpos.nombre_grupo_capacitacion, ',' ORDER BY gpos.nombre_grupo_capacitacion ASC) as nombre_grupo,
			STRING_AGG(
				DISTINCT
				emp1.rfc||'|'||
				emp1.paterno||' '||emp1.materno||' '||emp1.nombre||'|'||
				mov1.codigo||'|'||
				(CASE WHEN licencia1.fecha_desde IS NOT NULL THEN convierte_de_fecha_a_qna(licencia1.fecha_desde) ELSE '' END)||'|'||
				(CASE WHEN licencia1.fecha_desde IS NOT NULL THEN convierte_de_fecha_a_qna(licencia1.fecha_hasta) ELSE '' END)
				, ','
			) AS sustituye,
			STRING_AGG(
				DISTINCT
				emp_tf1.rfc||'|'||
				emp_tf1.paterno||' '||emp_tf1.materno||' '||emp_tf1.nombre||'|'||
				mov2.codigo||'|'||
				(CASE WHEN licencia3.fecha_desde IS NOT NULL THEN convierte_de_fecha_a_qna(licencia3.fecha_desde) ELSE '' END)||'|'||
				(CASE WHEN licencia3.fecha_desde IS NOT NULL THEN convierte_de_fecha_a_qna(licencia3.fecha_hasta) ELSE '' END)
				, ','
			) AS sustituye_tf
			FROM asignacion_tiempo_fijo_capacitacion atfb1
			LEFT JOIN tramites_licencias_asignaciones licencia_asign1 ON licencia_asign1.id_tramite_licencia_asignacion = atfb1.id_tramites_licencias_asignaciones
			LEFT JOIN tramites_licencias licencia1 ON licencia1.id_tramite_licencia = licencia_asign1.id_tramite_licencia
			LEFT JOIN empleados emp1 ON emp1.id_empleado = licencia1.id_empleado
			LEFT JOIN empleados emp_asign ON emp_asign.id_empleado = atfb1.id_empleado
			LEFT JOIN codigos_postales cp1 ON cp1.id_cp = emp_asign.id_cp
			LEFT JOIN cat_categorias_padre catego ON catego.id_cat_categoria_padre = atfb1.id_cat_categoria_padre
			LEFT JOIN detalle_materias detalle_mat ON detalle_mat.id_detalle_materia = atfb1.id_detalle_materia
			LEFT JOIN cat_materias mat ON mat.id_materia = detalle_mat.id_materia
			LEFT JOIN cat_tipo_movimiento_personal mov ON mov.id_tipo_movimiento_personal = atfb1.id_tipo_movimiento_personal
			LEFT JOIN cat_tipo_movimiento_personal mov1 ON mov1.id_tipo_movimiento_personal = licencia1.id_movimiento_titular
			LEFT JOIN subprogramas subp ON subp.id_subprograma = atfb1.id_subprograma
			LEFT JOIN claves_sep sep ON sep.id_sep = subp.id_sep
			LEFT JOIN grupos_capacitacion gpos ON atfb1.id_grupo_capacitacion = gpos.id_grupo_capacitacion
			LEFT JOIN tramites_licencias_asignaciones_tf licencia_tf1 ON licencia_tf1.id_tramite_licencia_asignacion_tf = atfb1.id_tramites_licencias_asignaciones_tf 
			LEFT JOIN tramites_licencias licencia3 ON licencia3.id_tramite_licencia = licencia_tf1.id_tramite_licencia
			LEFT JOIN empleados emp_tf1 ON emp_tf1.id_empleado = licencia3.id_empleado
			LEFT JOIN cat_tipo_movimiento_personal mov2 ON mov2.id_tipo_movimiento_personal = licencia3.id_movimiento_titular
			WHERE
				CAST(COALESCE(atfb1.id_empleado,'0') AS text)||
				CAST(COALESCE(atfb1.id_detalle_materia,'0') AS text)||
				CAST(COALESCE(atfb1.id_subprograma,'0') AS text)||
				CAST(COALESCE(atfb1.id_estructura_ocupacional,'0') AS text)||
				COALESCE(emp1.paterno||emp1.materno||emp1.nombre,'')
				= (
					SELECT 
						CAST(COALESCE(atfb2.id_empleado, '0') AS text)||
						CAST(COALESCE(atfb2.id_detalle_materia,'0') AS text)||
						CAST(COALESCE(atfb2.id_subprograma,'0') AS text)||
						CAST(COALESCE(atfb2.id_estructura_ocupacional,'0') AS text)||
						COALESCE(emp2.paterno||emp2.materno||emp2.nombre, '')
					FROM asignacion_tiempo_fijo_capacitacion atfb2
					LEFT JOIN tramites_licencias_asignaciones licencia_asign2 ON licencia_asign2.id_tramite_licencia_asignacion = atfb2.id_tramites_licencias_asignaciones
					LEFT JOIN tramites_licencias licencia2 ON licencia2.id_tramite_licencia = licencia_asign2.id_tramite_licencia
					LEFT JOIN empleados emp2 ON emp2.id_empleado = licencia2.id_empleado
					WHERE atfb2.id_asignacion_tiempo_fijo_capacitacion = _id_asignacion 
				)
			GROUP BY 
				emp_asign.filiacion,
				emp_asign.paterno,
				emp_asign.materno,
				emp_asign.nombre,
				emp_asign.genero,
				emp_asign.lugar_nacimiento,
				emp_asign.fecha_nacimiento,
				emp_asign.nacionalidad,
				emp_asign.estado_civil,
				emp_asign.calle,
				emp_asign.no_ext,
				emp_asign.no_int,
				cp1.d_asenta,
				cp1.d_ciudad,
				cp1.d_estado,
				cp1.d_codigo,
				emp_asign.telefono,
				emp_asign.id_empleado,
				catego.categoria_padre,
				catego.descripcion_cat_padre,
				mat.materia,
				atfb1.qna_desde,
				atfb1.qna_hasta,
				mov.codigo,
				mov.descripcion,
				subp.clave_subprograma,
				subp.clave_extension_u_organica,
				subp.nombre_subprograma,
				sep.clave_sep;

		END IF;

	ELSE
		-- basico
		IF( _id_componente = 1) THEN

			INSERT INTO temp_planteles_propuesta_nombramiento(filiacion, nombre_completo, genero, lugar_nacimiento, fecha_nacimiento, nacionalidad, estado_civil, calle, no_ext, no_int, d_codigo, d_asenta, d_mnpio, d_estado, d_ciudad, grado_academico, profesion, fecha_ingreso, fecha_ingreso_sispagos_impresion, categoria_padre, descripcion_cat_padre, horas_grupo, materia, qna_desde, qna_hasta, codigo, descripcion, nombre_subprograma, clave_sep, nombre_grupo, rfc_sustituye, rfc_sustituye_tf)
			SELECT 
			emp_asign.filiacion,
			emp_asign.paterno||' '||emp_asign.materno||' '||emp_asign.nombre AS nombre_completo,
			emp_asign.genero,
			upper(emp_asign.lugar_nacimiento) AS lugar_nacimiento,
			emp_asign.fecha_nacimiento,
			UPPER(emp_asign.nacionalidad) AS nacionalidad,
			UPPER(emp_asign.estado_civil) AS estado_civil,
			UPPER(emp_asign.calle) AS calle,
			emp_asign.no_ext,
			emp_asign.no_int,
			UPPER(cp1.d_asenta) AS d_asenta,
			UPPER(cp1.d_ciudad) AS d_ciudad,
			UPPER(cp1.d_estado) AS d_estado,
			UPPER(cp1.d_codigo) AS d_codigo,
			emp_asign.telefono,
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
			emp_asign.fecha_ingreso, 
			emp_asign.fecha_ingreso_sispagos_impresion,
			catego.categoria_padre, 
			catego.descripcion_cat_padre,
			atfb1.horas_grupo,
			mat.materia, 
			atfb1.qna_desde,
			atfb1.qna_hasta,
			mov.codigo, 
			mov.descripcion,
			(
				case 
					when subp.clave_subprograma = '001' 
					then subp.clave_extension_u_organica 
					else subp.clave_subprograma 
				end || ' ' || UPPER(subp.nombre_subprograma)
			) as nombre_subprograma,
			sep.clave_sep,
			STRING_AGG(gpos.nombre_grupo, ',' ORDER BY gpos.nombre_grupo ASC) as nombre_grupo,
			STRING_AGG(
				DISTINCT
				emp1.rfc||'|'||
				emp1.paterno||' '||emp1.materno||' '||emp1.nombre||'|'||
				mov1.codigo||'|'||
				(CASE WHEN licencia1.fecha_desde IS NOT NULL THEN convierte_de_fecha_a_qna(licencia1.fecha_desde) ELSE '' END)||'|'||
				(CASE WHEN licencia1.fecha_desde IS NOT NULL THEN convierte_de_fecha_a_qna(licencia1.fecha_hasta) ELSE '' END)
				, ','
			) AS sustituye,
			STRING_AGG(
				DISTINCT
				emp_tf1.rfc||'|'||
				emp_tf1.paterno||' '||emp_tf1.materno||' '||emp_tf1.nombre||'|'||
				mov2.codigo||'|'||
				(CASE WHEN licencia3.fecha_desde IS NOT NULL THEN convierte_de_fecha_a_qna(licencia3.fecha_desde) ELSE '' END)||'|'||
				(CASE WHEN licencia3.fecha_desde IS NOT NULL THEN convierte_de_fecha_a_qna(licencia3.fecha_hasta) ELSE '' END)
				, ','
			) AS sustituye_tf
			FROM asignacion_tiempo_fijo_basico atfb1
			LEFT JOIN tramites_licencias_asignaciones licencia_asign1 ON licencia_asign1.id_tramite_licencia_asignacion = atfb1.id_tramites_licencias_asignaciones
			LEFT JOIN tramites_licencias licencia1 ON licencia1.id_tramite_licencia = licencia_asign1.id_tramite_licencia
			LEFT JOIN empleados emp1 ON emp1.id_empleado = licencia1.id_empleado
			LEFT JOIN empleados emp_asign ON emp_asign.id_empleado = atfb1.id_empleado
			LEFT JOIN codigos_postales cp1 ON cp1.id_cp = emp_asign.id_cp
			LEFT JOIN cat_categorias_padre catego ON catego.id_cat_categoria_padre = atfb1.id_cat_categoria_padre
			LEFT JOIN detalle_materias detalle_mat ON detalle_mat.id_detalle_materia = atfb1.id_detalle_materia
			LEFT JOIN cat_materias mat ON mat.id_materia = detalle_mat.id_materia
			LEFT JOIN cat_tipo_movimiento_personal mov ON mov.id_tipo_movimiento_personal = atfb1.id_tipo_movimiento_personal
			LEFT JOIN cat_tipo_movimiento_personal mov1 ON mov1.id_tipo_movimiento_personal = licencia1.id_movimiento_titular
			LEFT JOIN subprogramas subp ON subp.id_subprograma = atfb1.id_subprograma
			LEFT JOIN claves_sep sep ON sep.id_sep = subp.id_sep
			LEFT JOIN grupos_estructura_base gpos ON atfb1.id_grupo_estructura_base = gpos.id_grupo_estructura_base
			LEFT JOIN tramites_licencias_asignaciones_tf licencia_tf1 ON licencia_tf1.id_tramite_licencia_asignacion_tf = atfb1.id_tramites_licencias_asignaciones_tf 
			LEFT JOIN tramites_licencias licencia3 ON licencia3.id_tramite_licencia = licencia_tf1.id_tramite_licencia
			LEFT JOIN empleados emp_tf1 ON emp_tf1.id_empleado = licencia3.id_empleado
			LEFT JOIN cat_tipo_movimiento_personal mov2 ON mov2.id_tipo_movimiento_personal = licencia3.id_movimiento_titular
			WHERE
				atfb1.id_asignacion_tiempo_fijo_basico = _id_asignacion
			GROUP BY 
				emp_asign.filiacion,
				emp_asign.paterno,
				emp_asign.materno,
				emp_asign.nombre,
				emp_asign.genero,
				emp_asign.lugar_nacimiento,
				emp_asign.fecha_nacimiento,
				emp_asign.nacionalidad,
				emp_asign.estado_civil,
				emp_asign.calle,
				emp_asign.no_ext,
				emp_asign.no_int,
				cp1.d_asenta,
				cp1.d_ciudad,
				cp1.d_estado,
				cp1.d_codigo,
				emp_asign.telefono,
				emp_asign.id_empleado,
				catego.categoria_padre,
				catego.descripcion_cat_padre,
				mat.materia,
				atfb1.qna_desde,
				atfb1.qna_hasta,
				mov.codigo,
				mov.descripcion,
				subp.clave_subprograma,
				subp.clave_extension_u_organica,
				subp.nombre_subprograma,
				sep.clave_sep,
				atfb1.horas_grupo;

		END IF;

		-- Optativas
		IF (_id_componente = 2) THEN
			
			INSERT INTO temp_planteles_propuesta_nombramiento(filiacion, nombre_completo, genero, lugar_nacimiento, fecha_nacimiento, nacionalidad, estado_civil, calle, no_ext, no_int, d_codigo, d_asenta, d_mnpio, d_estado, d_ciudad, grado_academico, profesion, fecha_ingreso, fecha_ingreso_sispagos_impresion, categoria_padre, descripcion_cat_padre, horas_grupo, materia, qna_desde, qna_hasta, codigo, descripcion, nombre_subprograma, clave_sep, nombre_grupo, rfc_sustituye, rfc_sustituye_tf)
			SELECT 
			emp_asign.filiacion,
			emp_asign.paterno||' '||emp_asign.materno||' '||emp_asign.nombre AS nombre_completo,
			emp_asign.genero,
			upper(emp_asign.lugar_nacimiento) AS lugar_nacimiento,
			emp_asign.fecha_nacimiento,
			UPPER(emp_asign.nacionalidad) AS nacionalidad,
			UPPER(emp_asign.estado_civil) AS estado_civil,
			UPPER(emp_asign.calle) AS calle,
			emp_asign.no_ext,
			emp_asign.no_int,
			UPPER(cp1.d_asenta) AS d_asenta,
			UPPER(cp1.d_ciudad) AS d_ciudad,
			UPPER(cp1.d_estado) AS d_estado,
			UPPER(cp1.d_codigo) AS d_codigo,
			emp_asign.telefono,
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
			emp_asign.fecha_ingreso, 
			emp_asign.fecha_ingreso_sispagos_impresion,
			catego.categoria_padre, 
			catego.descripcion_cat_padre,
			atfb1.horas_grupo,
			mat.materia, 
			atfb1.qna_desde,
			atfb1.qna_hasta,
			mov.codigo, 
			mov.descripcion,
			(
				case 
					when subp.clave_subprograma = '001' 
					then subp.clave_extension_u_organica 
					else subp.clave_subprograma 
				end || ' ' || UPPER(subp.nombre_subprograma)
			) as nombre_subprograma,
			sep.clave_sep,
			STRING_AGG(gpos.nombre_grupo_optativas, ',' ORDER BY gpos.nombre_grupo_optativas ASC) as nombre_grupo,
			STRING_AGG(
				DISTINCT
				emp1.rfc||'|'||
				emp1.paterno||' '||emp1.materno||' '||emp1.nombre||'|'||
				mov1.codigo||'|'||
				(CASE WHEN licencia1.fecha_desde IS NOT NULL THEN convierte_de_fecha_a_qna(licencia1.fecha_desde) ELSE '' END)||'|'||
				(CASE WHEN licencia1.fecha_desde IS NOT NULL THEN convierte_de_fecha_a_qna(licencia1.fecha_hasta) ELSE '' END)
				, ','
			) AS sustituye,
			STRING_AGG(
				DISTINCT
				emp_tf1.rfc||'|'||
				emp_tf1.paterno||' '||emp_tf1.materno||' '||emp_tf1.nombre||'|'||
				mov2.codigo||'|'||
				(CASE WHEN licencia3.fecha_desde IS NOT NULL THEN convierte_de_fecha_a_qna(licencia3.fecha_desde) ELSE '' END)||'|'||
				(CASE WHEN licencia3.fecha_desde IS NOT NULL THEN convierte_de_fecha_a_qna(licencia3.fecha_hasta) ELSE '' END)
				, ','
			) AS sustituye_tf
			FROM asignacion_tiempo_fijo_optativas atfb1
			LEFT JOIN tramites_licencias_asignaciones licencia_asign1 ON licencia_asign1.id_tramite_licencia_asignacion = atfb1.id_tramites_licencias_asignaciones
			LEFT JOIN tramites_licencias licencia1 ON licencia1.id_tramite_licencia = licencia_asign1.id_tramite_licencia
			LEFT JOIN empleados emp1 ON emp1.id_empleado = licencia1.id_empleado
			LEFT JOIN empleados emp_asign ON emp_asign.id_empleado = atfb1.id_empleado
			LEFT JOIN codigos_postales cp1 ON cp1.id_cp = emp_asign.id_cp
			LEFT JOIN cat_categorias_padre catego ON catego.id_cat_categoria_padre = atfb1.id_cat_categoria_padre
			LEFT JOIN detalle_materias detalle_mat ON detalle_mat.id_detalle_materia = atfb1.id_detalle_materia
			LEFT JOIN cat_materias mat ON mat.id_materia = detalle_mat.id_materia
			LEFT JOIN cat_tipo_movimiento_personal mov ON mov.id_tipo_movimiento_personal = atfb1.id_tipo_movimiento_personal
			LEFT JOIN cat_tipo_movimiento_personal mov1 ON mov1.id_tipo_movimiento_personal = licencia1.id_movimiento_titular
			LEFT JOIN subprogramas subp ON subp.id_subprograma = atfb1.id_subprograma
			LEFT JOIN claves_sep sep ON sep.id_sep = subp.id_sep
			LEFT JOIN grupos_optativas gpos ON atfb1.id_grupo_optativa = gpos.id_grupo_optativa
			LEFT JOIN tramites_licencias_asignaciones_tf licencia_tf1 ON licencia_tf1.id_tramite_licencia_asignacion_tf = atfb1.id_tramites_licencias_asignaciones_tf 
			LEFT JOIN tramites_licencias licencia3 ON licencia3.id_tramite_licencia = licencia_tf1.id_tramite_licencia
			LEFT JOIN empleados emp_tf1 ON emp_tf1.id_empleado = licencia3.id_empleado
			LEFT JOIN cat_tipo_movimiento_personal mov2 ON mov2.id_tipo_movimiento_personal = licencia3.id_movimiento_titular
			WHERE
				atfb1.id_asignacion_tiempo_fijo_optativa = _id_asignacion 
			GROUP BY 
				emp_asign.filiacion,
				emp_asign.paterno,
				emp_asign.materno,
				emp_asign.nombre,
				emp_asign.genero,
				emp_asign.lugar_nacimiento,
				emp_asign.fecha_nacimiento,
				emp_asign.nacionalidad,
				emp_asign.estado_civil,
				emp_asign.calle,
				emp_asign.no_ext,
				emp_asign.no_int,
				cp1.d_asenta,
				cp1.d_ciudad,
				cp1.d_estado,
				cp1.d_codigo,
				emp_asign.telefono,
				emp_asign.id_empleado,
				catego.categoria_padre,
				catego.descripcion_cat_padre,
				mat.materia,
				atfb1.qna_desde,
				atfb1.qna_hasta,
				mov.codigo,
				mov.descripcion,
				subp.clave_subprograma,
				subp.clave_extension_u_organica,
				subp.nombre_subprograma,
				sep.clave_sep,
				atfb1.horas_grupo;
		END IF;

		-- Capacitacion
		IF(_id_componente = 3) THEN
			
			INSERT INTO temp_planteles_propuesta_nombramiento(filiacion, nombre_completo, genero, lugar_nacimiento, fecha_nacimiento, nacionalidad, estado_civil, calle, no_ext, no_int, d_codigo, d_asenta, d_mnpio, d_estado, d_ciudad, grado_academico, profesion, fecha_ingreso, fecha_ingreso_sispagos_impresion, categoria_padre, descripcion_cat_padre, horas_grupo, materia, qna_desde, qna_hasta, codigo, descripcion, nombre_subprograma, clave_sep, nombre_grupo, rfc_sustituye, rfc_sustituye_tf)
			SELECT 
			emp_asign.filiacion,
			emp_asign.paterno||' '||emp_asign.materno||' '||emp_asign.nombre AS nombre_completo,
			emp_asign.genero,
			upper(emp_asign.lugar_nacimiento) AS lugar_nacimiento,
			emp_asign.fecha_nacimiento,
			UPPER(emp_asign.nacionalidad) AS nacionalidad,
			UPPER(emp_asign.estado_civil) AS estado_civil,
			UPPER(emp_asign.calle) AS calle,
			emp_asign.no_ext,
			emp_asign.no_int,
			UPPER(cp1.d_asenta) AS d_asenta,
			UPPER(cp1.d_ciudad) AS d_ciudad,
			UPPER(cp1.d_estado) AS d_estado,
			UPPER(cp1.d_codigo) AS d_codigo,
			emp_asign.telefono,
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
			emp_asign.fecha_ingreso, 
			emp_asign.fecha_ingreso_sispagos_impresion,
			catego.categoria_padre, 
			catego.descripcion_cat_padre,
			atfb1.horas_grupo,
			mat.materia, 
			atfb1.qna_desde,
			atfb1.qna_hasta,
			mov.codigo, 
			mov.descripcion,
			(
				case 
					when subp.clave_subprograma = '001' 
					then subp.clave_extension_u_organica 
					else subp.clave_subprograma 
				end || ' ' || UPPER(subp.nombre_subprograma)
			) as nombre_subprograma,
			sep.clave_sep,
			STRING_AGG(gpos.nombre_grupo_capacitacion, ',' ORDER BY gpos.nombre_grupo_capacitacion ASC) as nombre_grupo,
			STRING_AGG(
				DISTINCT
				emp1.rfc||'|'||
				emp1.paterno||' '||emp1.materno||' '||emp1.nombre||'|'||
				mov1.codigo||'|'||
				(CASE WHEN licencia1.fecha_desde IS NOT NULL THEN convierte_de_fecha_a_qna(licencia1.fecha_desde) ELSE '' END)||'|'||
				(CASE WHEN licencia1.fecha_desde IS NOT NULL THEN convierte_de_fecha_a_qna(licencia1.fecha_hasta) ELSE '' END)
				, ','
			) AS sustituye,
			STRING_AGG(
				DISTINCT
				emp_tf1.rfc||'|'||
				emp_tf1.paterno||' '||emp_tf1.materno||' '||emp_tf1.nombre||'|'||
				mov2.codigo||'|'||
				(CASE WHEN licencia3.fecha_desde IS NOT NULL THEN convierte_de_fecha_a_qna(licencia3.fecha_desde) ELSE '' END)||'|'||
				(CASE WHEN licencia3.fecha_desde IS NOT NULL THEN convierte_de_fecha_a_qna(licencia3.fecha_hasta) ELSE '' END)
				, ','
			) AS sustituye_tf
			FROM asignacion_tiempo_fijo_capacitacion atfb1
			LEFT JOIN tramites_licencias_asignaciones licencia_asign1 ON licencia_asign1.id_tramite_licencia_asignacion = atfb1.id_tramites_licencias_asignaciones
			LEFT JOIN tramites_licencias licencia1 ON licencia1.id_tramite_licencia = licencia_asign1.id_tramite_licencia
			LEFT JOIN empleados emp1 ON emp1.id_empleado = licencia1.id_empleado
			LEFT JOIN empleados emp_asign ON emp_asign.id_empleado = atfb1.id_empleado
			LEFT JOIN codigos_postales cp1 ON cp1.id_cp = emp_asign.id_cp
			LEFT JOIN cat_categorias_padre catego ON catego.id_cat_categoria_padre = atfb1.id_cat_categoria_padre
			LEFT JOIN detalle_materias detalle_mat ON detalle_mat.id_detalle_materia = atfb1.id_detalle_materia
			LEFT JOIN cat_materias mat ON mat.id_materia = detalle_mat.id_materia
			LEFT JOIN cat_tipo_movimiento_personal mov ON mov.id_tipo_movimiento_personal = atfb1.id_tipo_movimiento_personal
			LEFT JOIN cat_tipo_movimiento_personal mov1 ON mov1.id_tipo_movimiento_personal = licencia1.id_movimiento_titular
			LEFT JOIN subprogramas subp ON subp.id_subprograma = atfb1.id_subprograma
			LEFT JOIN claves_sep sep ON sep.id_sep = subp.id_sep
			LEFT JOIN grupos_capacitacion gpos ON atfb1.id_grupo_capacitacion = gpos.id_grupo_capacitacion
			LEFT JOIN tramites_licencias_asignaciones_tf licencia_tf1 ON licencia_tf1.id_tramite_licencia_asignacion_tf = atfb1.id_tramites_licencias_asignaciones_tf 
			LEFT JOIN tramites_licencias licencia3 ON licencia3.id_tramite_licencia = licencia_tf1.id_tramite_licencia
			LEFT JOIN empleados emp_tf1 ON emp_tf1.id_empleado = licencia3.id_empleado
			LEFT JOIN cat_tipo_movimiento_personal mov2 ON mov2.id_tipo_movimiento_personal = licencia3.id_movimiento_titular
			WHERE
				atfb1.id_asignacion_tiempo_fijo_capacitacion = _id_asignacion
			GROUP BY 
				emp_asign.filiacion,
				emp_asign.paterno,
				emp_asign.materno,
				emp_asign.nombre,
				emp_asign.genero,
				emp_asign.lugar_nacimiento,
				emp_asign.fecha_nacimiento,
				emp_asign.nacionalidad,
				emp_asign.estado_civil,
				emp_asign.calle,
				emp_asign.no_ext,
				emp_asign.no_int,
				cp1.d_asenta,
				cp1.d_ciudad,
				cp1.d_estado,
				cp1.d_codigo,
				emp_asign.telefono,
				emp_asign.id_empleado,
				catego.categoria_padre,
				catego.descripcion_cat_padre,
				mat.materia,
				atfb1.qna_desde,
				atfb1.qna_hasta,
				mov.codigo,
				mov.descripcion,
				subp.clave_subprograma,
				subp.clave_extension_u_organica,
				subp.nombre_subprograma,
				sep.clave_sep,
				atfb1.horas_grupo;
		END IF;

	END IF;


	-- Del campo rfc_susituye, descompongo y agrego en las demas columnas
	UPDATE temp_planteles_propuesta_nombramiento tppn
	SET 
	nombre_sustituye = split_part(tppn.rfc_sustituye,'|', 2),
	fecha_desde_sustituye = split_part(tppn.rfc_sustituye,'|', 4), 
	fecha_hasta_sustituye = split_part(tppn.rfc_sustituye,'|', 5),
	motivo_sustituye = split_part(tppn.rfc_sustituye,'|', 3),
	rfc_sustituye = split_part(tppn.rfc_sustituye,'|', 1);

	-- Del campo rfc_susituye_tf, descompongo y agrego en las demas columnas
	UPDATE temp_planteles_propuesta_nombramiento tppn
	SET 
	nombre_sustituye_tf = split_part(tppn.rfc_sustituye_tf,'|', 2),
	fecha_desde_sustituye_tf = split_part(tppn.rfc_sustituye_tf,'|', 4), 
	fecha_hasta_sustituye_tf = split_part(tppn.rfc_sustituye_tf,'|', 5),
	motivo_sustituye_tf = split_part(tppn.rfc_sustituye_tf,'|', 3),
	rfc_sustituye_tf = split_part(tppn.rfc_sustituye_tf,'|', 1);


	RETURN QUERY SELECT * FROM temp_planteles_propuesta_nombramiento;
	
	/* Al retornar se destruye la tambla temporal */
	DROP TABLE temp_planteles_propuesta_nombramiento;	

END; $$ 
LANGUAGE 'plpgsql';
