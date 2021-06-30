CREATE OR REPLACE FUNCTION planteles_propuesta_nombramiento(tipo integer, id_estructura integer, id_componente integer, id_asignacion integer, id_detalle_materia integer, id_empleado integer, id_subprograma integer)
RETURNS TABLE(
	filiacion character varying(13),
	nombre_completo character varying, 
	genero character varying(1),
	fecha_nacimiento date,
	nacionalidad character varying,
	estado_civil character varying,
	lugar_nacimiento character varying,
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
	rfc_sustituye character varying,
	nombre_sustituye character varying,
	fecha_desde_sustituye character varying,
	fecha_hasta_sustituye character varying,
	motivo_sustituye character varying
)
AS $$
DECLARE

	var_tipo  integer;
	var_id_estructura integer;
	var_id_componente integer;
	var_id_asignacion integer;
	var_id_detalle_materia integer;
	var_id_empleado integer;
	var_id_subprograma integer;

BEGIN
	
	-- Defino un nombre para cada parametro que recibe la funcion
	var_tipo:= $1;
	var_id_estructura:= $2;
	var_id_componente:= $3;
	var_id_asignacion:= $4;
	var_id_detalle_materia:= $5;
	var_id_empleado:= $6;
	var_id_subprograma:= $7;

	-- Creo tabla temporal para crear la estructura de mi salida
	CREATE TEMP TABLE temp_planteles_propuesta_nombramiento(
		filiacion character varying(13),
		nombre_completo character varying, 
		genero character varying(1),
		fecha_nacimiento date,
		nacionalidad character varying,
		estado_civil character varying,
		lugar_nacimiento character varying,
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
		rfc_sustituye character varying,
		nombre_sustituye character varying,
		fecha_desde_sustituye character varying,
		fecha_hasta_sustituye character varying,
		motivo_sustituye character varying
	);

	/*
		var_tipo = 1 -> Es por grupo
		var_tipo = 2 -> Es por materia
	*/

	-- Por grupo
	IF(var_tipo = 1) THEN



		-- Distingo el id_componente para saber que query usar
		IF (var_id_componente = 1) THEN

			INSERT INTO temp_planteles_propuesta_nombramiento(filiacion, nombre_completo, genero, fecha_nacimiento, nacionalidad, estado_civil, lugar_nacimiento, calle, no_ext, no_int, d_codigo, d_asenta, d_mnpio, d_estado, d_ciudad, grado_academico, profesion, fecha_ingreso, fecha_ingreso_sispagos_impresion, categoria_padre, descripcion_cat_padre, horas_grupo, materia, qna_desde, qna_hasta, codigo, descripcion, nombre_subprograma, clave_sep, rfc_sustituye)
			SELECT 
			b.filiacion,b.paterno||' '||b.materno||' '||b.nombre, b.genero, b.fecha_nacimiento
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
				AND tla.id_componente = 1
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
			WHERE a.id_asignacion_tiempo_fijo_basico = var_id_asignacion;

		
		ELSIF (var_id_componente = 2) THEN

			INSERT INTO temp_planteles_propuesta_nombramiento(filiacion, nombre_completo, genero, fecha_nacimiento, nacionalidad, estado_civil, lugar_nacimiento, calle, no_ext, no_int, d_codigo, d_asenta, d_mnpio, d_estado, d_ciudad, grado_academico, profesion, fecha_ingreso, fecha_ingreso_sispagos_impresion, categoria_padre, descripcion_cat_padre, horas_grupo, materia, qna_desde, qna_hasta, codigo, descripcion, nombre_subprograma, clave_sep, rfc_sustituye)
			SELECT 
			b.filiacion,b.paterno||' '||b.materno||' '||b.nombre, b.genero, b.fecha_nacimiento
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
				AND tla.id_componente = 2
			)as sustituye
			FROM asignacion_tiempo_fijo_optativas a
			INNER JOIN empleados b ON a.id_empleado = b.id_empleado
			INNER JOIN cat_categorias_padre c ON c.id_cat_categoria_padre = a.id_cat_categoria_padre
			INNER JOIN detalle_materias d ON d.id_detalle_materia = a.id_detalle_materia
			INNER JOIN cat_materias e ON e.id_materia = d.id_materia
			INNER JOIN cat_tipo_movimiento_personal f ON f.id_tipo_movimiento_personal = a.id_tipo_movimiento_personal
			INNER JOIN subprogramas g ON g.id_subprograma = a.id_subprograma
			INNER JOIN claves_sep h ON h.id_sep = g.id_sep
			INNER JOIN codigos_postales i ON i.id_cp = b.id_cp
			WHERE a.id_asignacion_tiempo_fijo_optativa = var_id_asignacion;

		
		ELSIF (var_id_componente = 3) THEN

			INSERT INTO temp_planteles_propuesta_nombramiento(filiacion, nombre_completo, genero, fecha_nacimiento, nacionalidad, estado_civil, lugar_nacimiento, calle, no_ext, no_int, d_codigo, d_asenta, d_mnpio, d_estado, d_ciudad, grado_academico, profesion, fecha_ingreso, fecha_ingreso_sispagos_impresion, categoria_padre, descripcion_cat_padre, horas_grupo, materia, qna_desde, qna_hasta, codigo, descripcion, nombre_subprograma, clave_sep, rfc_sustituye)
			SELECT 
			b.filiacion,b.paterno||' '||b.materno||' '||b.nombre, b.genero, b.fecha_nacimiento
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
				AND tla.id_componente = 3
			)as sustituye
			FROM asignacion_tiempo_fijo_capacitacion a
			INNER JOIN empleados b ON a.id_empleado = b.id_empleado
			INNER JOIN cat_categorias_padre c ON c.id_cat_categoria_padre = a.id_cat_categoria_padre
			INNER JOIN detalle_materias d ON d.id_detalle_materia = a.id_detalle_materia
			INNER JOIN cat_materias e ON e.id_materia = d.id_materia
			INNER JOIN cat_tipo_movimiento_personal f ON f.id_tipo_movimiento_personal = a.id_tipo_movimiento_personal
			INNER JOIN subprogramas g ON g.id_subprograma = a.id_subprograma
			INNER JOIN claves_sep h ON h.id_sep = g.id_sep
			INNER JOIN codigos_postales i ON i.id_cp = b.id_cp
			WHERE a.id_asignacion_tiempo_fijo_capacitacion = var_id_asignacion;	

		ELSIF (var_id_componente = 4) THEN

			INSERT INTO temp_planteles_propuesta_nombramiento(filiacion, nombre_completo, genero, fecha_nacimiento, nacionalidad, estado_civil, lugar_nacimiento, calle, no_ext, no_int, d_codigo, d_asenta, d_mnpio, d_estado, d_ciudad, grado_academico, profesion, fecha_ingreso, fecha_ingreso_sispagos_impresion, categoria_padre, descripcion_cat_padre, horas_grupo, materia, qna_desde, qna_hasta, codigo, descripcion, nombre_subprograma, clave_sep, rfc_sustituye)
			SELECT 
			b.filiacion,b.paterno||' '||b.materno||' '||b.nombre, b.genero, b.fecha_nacimiento
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
			,d.nombre, a.qna_desde, a.qna_hasta
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
				AND tla.id_componente = 4
			)as sustituye
			FROM asignacion_tiempo_fijo_paraescolares a
			INNER JOIN empleados b ON a.id_empleado = b.id_empleado
			INNER JOIN cat_categorias_padre c ON c.id_cat_categoria_padre = a.id_cat_categoria_padre
			INNER JOIN cat_materias_paraescolares d ON d.id_paraescolar = a.id_cat_materias_paraescolares
			INNER JOIN cat_tipo_movimiento_personal f ON f.id_tipo_movimiento_personal = a.id_tipo_movimiento_personal
			INNER JOIN subprogramas g ON g.id_subprograma = a.id_subprograma
			INNER JOIN claves_sep h ON h.id_sep = g.id_sep
			INNER JOIN codigos_postales i ON i.id_cp = b.id_cp
			WHERE a.id_asignacion_tiempo_fijo_paraescolares = var_id_asignacion;		


		END IF;


		-- Del campo rfc_susituye, descompongo y agrego en las demas columnas
		UPDATE temp_planteles_propuesta_nombramiento tppn
		SET 
		nombre_sustituye = split_part(tppn.rfc_sustituye,'|', 2),
		fecha_desde_sustituye = split_part(tppn.rfc_sustituye,'|', 3),
		fecha_hasta_sustituye = split_part(tppn.rfc_sustituye,'|', 4),
		motivo_sustituye = split_part(tppn.rfc_sustituye,'|', 5),
		rfc_sustituye = split_part(tppn.rfc_sustituye,'|', 1);


	




	-- Por materia	
	ELSIF(var_tipo = 2) THEN
	
		IF(var_id_componente = 1) THEN

			INSERT INTO temp_planteles_propuesta_nombramiento(filiacion, nombre_completo, genero, fecha_nacimiento, nacionalidad, estado_civil, lugar_nacimiento, calle, no_ext, no_int, d_codigo, d_asenta, d_mnpio, d_estado, d_ciudad, grado_academico, profesion, fecha_ingreso, fecha_ingreso_sispagos_impresion, categoria_padre, descripcion_cat_padre, horas_grupo, materia, qna_desde, qna_hasta, codigo, descripcion, nombre_subprograma, clave_sep, rfc_sustituye, nombre_sustituye, fecha_desde_sustituye,fecha_hasta_sustituye,motivo_sustituye)
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
					SELECT za.id_tramites_licencias_asignaciones
					FROM asignacion_tiempo_fijo_basico za
					WHERE za.id_empleado = var_id_empleado
					AND za.id_detalle_materia = var_id_detalle_materia
					AND za.id_subprograma = var_id_subprograma
					AND za.id_estructura_ocupacional = var_id_estructura
				)
				AND tl.id_cat_tramite_status = 3
				AND tla.id_componente = 1
			)as sustituye_rfc
			,(
				SELECT 
				string_agg(
				emp.paterno||' '||emp.materno||' '||emp.nombre||' - '||ppa.horas_grupo_base||' hrs'
				,',')
				FROM tramites_licencias_asignaciones tla
				INNER JOIN tramites_licencias tl ON tl.id_tramite_licencia = tla.id_tramite_licencia
				INNER JOIN profesores_profesor_asignado_base ppa ON ppa.id_profesores_profesor_asignado_base = tla.id_asignacion
				INNER JOIN plantilla_base_docente_rh pbdr ON pbdr.id_plantilla_base_docente_rh = ppa.id_plantilla_base_docente_rh
				INNER JOIN empleados emp ON emp.id_empleado = pbdr.id_empleado 
				INNER JOIN cat_tipo_movimiento_personal ctmp ON ctmp.id_tipo_movimiento_personal = tl.id_movimiento_titular
				WHERE tla.id_tramite_licencia_asignacion in(
					SELECT za.id_tramites_licencias_asignaciones
					FROM asignacion_tiempo_fijo_basico za
					WHERE za.id_empleado = var_id_empleado
					AND za.id_detalle_materia = var_id_detalle_materia
					AND za.id_subprograma = var_id_subprograma
					AND za.id_estructura_ocupacional = var_id_estructura
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
					SELECT za.id_tramites_licencias_asignaciones
					FROM asignacion_tiempo_fijo_basico za
					WHERE za.id_empleado = var_id_empleado
					AND za.id_detalle_materia = var_id_detalle_materia
					AND za.id_subprograma = var_id_subprograma
					AND za.id_estructura_ocupacional = var_id_estructura
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
					SELECT za.id_tramites_licencias_asignaciones
					FROM asignacion_tiempo_fijo_basico za
					WHERE za.id_empleado = var_id_empleado
					AND za.id_detalle_materia = var_id_detalle_materia
					AND za.id_subprograma = var_id_subprograma
					AND za.id_estructura_ocupacional = var_id_estructura
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
					SELECT za.id_tramites_licencias_asignaciones
					FROM asignacion_tiempo_fijo_basico za
					WHERE za.id_empleado = var_id_empleado
					AND za.id_detalle_materia = var_id_detalle_materia
					AND za.id_subprograma = var_id_subprograma
					AND za.id_estructura_ocupacional = var_id_estructura
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
			WHERE b.id_empleado = var_id_empleado
			AND d.id_detalle_materia = var_id_detalle_materia
			AND a.id_estructura_ocupacional = var_id_estructura
			AND a.id_subprograma = var_id_subprograma
			GROUP BY
			b.id_empleado,b.filiacion,b.paterno,b.materno,b.nombre, b.genero, b.fecha_nacimiento
			,b.nacionalidad,b.estado_civil, b.lugar_nacimiento
			,b.calle,b.no_ext,b.no_int,i.d_codigo,i.d_asenta,i.d_mnpio,i.d_estado,i.d_ciudad
			,b.fecha_ingreso, b.fecha_ingreso_sispagos_impresion
			,c.categoria_padre, c.descripcion_cat_padre
			,e.materia, a.qna_desde, a.qna_hasta
			,f.codigo, f.descripcion, g.nombre_subprograma, h.clave_sep;


		END IF;	


	END IF;

	
	RETURN QUERY SELECT * FROM temp_planteles_propuesta_nombramiento;
	
	/* Al retornar se destruye la tambla temporal */
	DROP TABLE temp_planteles_propuesta_nombramiento;	



END; $$ 
LANGUAGE 'plpgsql';

/*
-- Por grupo
SELECT *
FROM planteles_propuesta_nombramiento(1, 28, 4, 904, 0, 0, 0);


-- Por materia
SELECT *
FROM planteles_propuesta_nombramiento(2, 28, 1, 0, 754, 9355, 210);

*/