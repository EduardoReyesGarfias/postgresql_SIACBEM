CREATE OR REPLACE FUNCTION planteles_dom08( id_subprograma int, id_estructura int )
RETURNS TABLE(
	nombre varchar,
	rfc character(13),
	profesion varchar,
	grado_academico varchar,
	valida_rh varchar,
	asignatura varchar,
	id_componente smallint,
	hsm smallint,
	clave varchar,
	tipo_alta integer,
	desde integer,
	hasta integer
)
AS $$
DECLARE
	var_profesion varchar;
	var_grado_academico varchar;
	var_validacion varchar;
	
	reg_temp RECORD;
	cur_temp CURSOR FOR SELECT temp_planteles_dom08.rfc FROM temp_planteles_dom08;
BEGIN

	CREATE TEMP TABLE temp_planteles_dom08(
	nombre varchar,
	rfc character(13),
	profesion varchar,
	grado_academico varchar,
	valida_rh varchar,
	asignatura varchar,
	id_componente smallint,
	hsm smallint,
	clave varchar,
	tipo_alta integer,
	desde integer,
	hasta integer
	);
	
	/* Inserta en Temporal Datos de asignación */
	INSERT INTO temp_planteles_dom08
	(
		SELECT 
		e.paterno||' '||e.materno||' '||e.nombre as nombre, e.rfc, '', '', ''
		, f.materia, 1, sum(a.horas_grupo)
		, c.categoria_padre, d.codigo, a.qna_desde, a.qna_hasta
		FROM asignacion_tiempo_fijo_basico a
		INNER JOIN detalle_materias b ON b.id_detalle_materia = a.id_detalle_materia
		INNER JOIN cat_categorias_padre c ON c.id_cat_categoria_padre = a.id_cat_categoria_padre
		INNER JOIN cat_tipo_movimiento_personal d ON d.id_tipo_movimiento_personal = a.id_tipo_movimiento_personal
		INNER JOIN empleados e ON e.id_empleado = a.id_empleado
		INNER JOIN cat_materias f ON f.id_materia = b.id_materia
		WHERE a.id_subprograma = $1
		AND a.id_estructura_ocupacional = $2
		GROUP BY e.paterno, e.materno, e.nombre, e.rfc, f.materia
		, c.categoria_padre, d.codigo, a.qna_desde, a.qna_hasta
		ORDER BY nombre, materia 	
	)
	UNION ALL
	(
		SELECT 
		e.paterno||' '||e.materno||' '||e.nombre as nombre, e.rfc, '', '', '', f.materia, 3, sum(a.horas_grupo)
		, c.categoria_padre, d.codigo, a.qna_desde, a.qna_hasta
		FROM asignacion_tiempo_fijo_capacitacion a
		INNER JOIN detalle_materias b ON b.id_detalle_materia = a.id_detalle_materia
		INNER JOIN cat_categorias_padre c ON c.id_cat_categoria_padre = a.id_cat_categoria_padre
		INNER JOIN cat_tipo_movimiento_personal d ON d.id_tipo_movimiento_personal = a.id_tipo_movimiento_personal
		INNER JOIN empleados e ON e.id_empleado = a.id_empleado
		INNER JOIN cat_materias f ON f.id_materia = b.id_materia
		WHERE a.id_subprograma = $1
		AND a.id_estructura_ocupacional = $2
		GROUP BY e.paterno, e.materno, e.nombre, e.rfc, f.materia
		, c.categoria_padre, d.codigo, a.qna_desde, a.qna_hasta
		ORDER BY nombre, materia 	
	)
	UNION ALL
	(
		SELECT 
		e.paterno||' '||e.materno||' '||e.nombre as nombre, e.rfc, '', '', '', f.materia, 3, sum(a.horas_grupo)
		, c.categoria_padre, d.codigo, a.qna_desde, a.qna_hasta
		FROM asignacion_tiempo_fijo_optativas a
		INNER JOIN detalle_materias b ON b.id_detalle_materia = a.id_detalle_materia
		INNER JOIN cat_categorias_padre c ON c.id_cat_categoria_padre = a.id_cat_categoria_padre
		INNER JOIN cat_tipo_movimiento_personal d ON d.id_tipo_movimiento_personal = a.id_tipo_movimiento_personal
		INNER JOIN empleados e ON e.id_empleado = a.id_empleado
		INNER JOIN cat_materias f ON f.id_materia = b.id_materia
		WHERE a.id_subprograma = $1
		AND a.id_estructura_ocupacional = $2
		GROUP BY e.paterno, e.materno, e.nombre, e.rfc, f.materia
		, c.categoria_padre, d.codigo, a.qna_desde, a.qna_hasta
		ORDER BY nombre, materia 	
	)
	UNION ALL
	(
		SELECT 
		e.paterno||' '||e.materno||' '||e.nombre as nombre, e.rfc, '', '', '', b.nombre, 3, sum(a.horas_grupo)
		, c.categoria_padre, d.codigo, a.qna_desde, a.qna_hasta
		FROM asignacion_tiempo_fijo_paraescolares a
		INNER JOIN cat_materias_paraescolares b ON b.id_paraescolar = a.id_cat_materias_paraescolares
		INNER JOIN cat_categorias_padre c ON c.id_cat_categoria_padre = a.id_cat_categoria_padre
		INNER JOIN cat_tipo_movimiento_personal d ON d.id_tipo_movimiento_personal = a.id_tipo_movimiento_personal
		INNER JOIN empleados e ON e.id_empleado = a.id_empleado
		WHERE a.id_subprograma = $1
		AND a.id_estructura_ocupacional = $2
		GROUP BY e.paterno, e.materno, e.nombre, e.rfc, b.nombre
		, c.categoria_padre, d.codigo, a.qna_desde, a.qna_hasta
		ORDER BY e.nombre, b.nombre 
	);
	
	/*actualizo profesion, grado academico, validacion rh*/
	FOR reg_temp IN cur_temp LOOP
	
		var_profesion:='';
		var_grado_academico:='';
		var_validacion:='';
		
		SELECT INTO var_profesion, var_grado_academico, var_validacion 
		STRING_AGG(vga.profesion,',' ORDER BY vga.id_profesion),
		STRING_AGG(vga.grado_academico,',' ORDER BY vga.id_profesion),
		STRING_AGG(vga.valida_archivo_reportes,',' ORDER BY vga.id_profesion)
		FROM view_empleado_grados_academicos_actual vga
		WHERE vga.rfc = reg_temp.rfc;

		UPDATE temp_planteles_dom08 SET 
		profesion = var_profesion,
		grado_academico = var_grado_academico,
		valida_rh = var_validacion
		WHERE temp_planteles_dom08.rfc = reg_temp.rfc;
	
	END LOOP;
	
	
	RETURN QUERY SELECT * FROM temp_planteles_dom08 ORDER BY nombre, asignatura, hsm;
	DROP TABLE temp_planteles_dom08;

END; $$ 
 
LANGUAGE 'plpgsql';


SELECT *
FROM planteles_dom08(94,27)

