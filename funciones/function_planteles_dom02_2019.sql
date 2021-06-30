CREATE OR REPLACE FUNCTION planteles_dom02(id_subprograma int, id_estructura int)
RETURNS TABLE(
	id_plaza int,
	nombre_subprograma varchar,
	clave_sep varchar,
	coordinacion varchar,
	filiacion varchar,
	empleado varchar,
	categoria varchar,
	num_plz varchar,
	descripcion varchar,
	descripcion_planteles varchar,
	alta int,
	profesion text,
	grado_academico text,
	validado text,
	director varchar,
	coordinador varchar,
	puesto_director varchar,
	puesto_coordinador varchar,
	periodo varchar
)
AS $$
DECLARE
	reg RECORD;
	cur CURSOR FOR SELECT t.filiacion FROM temp_planteles_dom02 t;
	var_nombre_subprograma varchar;
	var_id_adcen int;
	var_coord varchar;
	var_nombre_coord varchar;
	var_clave_sep varchar;
	var_profesion text;
	var_grado_academico text;
	var_validacion text;
	var_director varchar;
	var_puesto_director varchar;
	var_coordinador varchar;
	var_puesto_coordinador varchar;
BEGIN

	/* creo tabla temporal para ajustar la informacion a una estructura deseada */
	CREATE TEMP TABLE temp_planteles_dom02(
		id_plaza int,
		nombre_subprograma varchar,
		clave_sep varchar,
		coordinacion varchar,
		filiacion varchar,
		empleado varchar,
		categoria varchar,
		num_plz varchar,
		descripcion varchar,
		descripcion_planteles varchar,
		alta int,
		profesion text,
		grado_academico text,
		validado text,
		director varchar,
		coordinador varchar,
		puesto_director varchar,
		puesto_coordinador varchar,
		periodo varchar
	);
	
	/* obtengo datos relacionados al subprograma */
	SELECT INTO var_nombre_subprograma, var_id_adcen, var_coord, var_clave_sep
	a.nombre_subprograma,b.id_adcen,a.coordinacion,c.clave_sep
	FROM subprogramas a
	INNER JOIN adcen b ON a.id_subprograma = b.id_subprograma
	INNER JOIN claves_sep c ON c.id_sep = a.id_sep
	WHERE a.id_subprograma = $1
	AND b.id_subprograma = $1
	AND b.id_estructura_ocupacional = $2;
	
	/* obtengo nombre de la coordinación */
	SELECT INTO var_nombre_coord
	substring(a.nombre_subprograma from 24)
	FROM subprogramas a
	WHERE a.nombre_subprograma ilike '%COORDINACIÓN SECTORIAL No. '||var_coord||',%'
	AND a.fecha_fin IS NULL
	ORDER BY a.nombre_subprograma
	LIMIT 1;
	
	/* obtengo las plazas del subprograma */
	INSERT INTO temp_planteles_dom02(id_plaza,filiacion,empleado,categoria,num_plz,descripcion,descripcion_planteles,alta,periodo)
	SELECT 
	a.id_plaza,h.filiacion,h.paterno||' '||h.materno||' '||h.nombre as empleado,c.categoria,g.num_plz,c.descripcion,c.descripcion_planteles,
	(
	CASE WHEN d.des_tipo_plaza = 'BASE' THEN
		14
	ELSE
		15
	END
	) as alta,i.periodo
	FROM plazas a
	INNER JOIN subprogramas b ON a.id_subprograma = b.id_subprograma
	INNER JOIN claves_sep z ON z.id_sep = b.id_sep
	INNER JOIN cat_categorias c ON a.id_categoria = c.id_categoria
	INNER JOIN cat_tipo_plaza_admon d ON d.id_tipo_plaza_admon = a.id_tipo_plaza_admon 
	LEFT JOIN notas_explicativas_plazas e ON e.id_plaza = a.id_plaza
	LEFT JOIN cat_status_plaza_movimientos_personal f ON f.id_status_plaza_movimiento_personal = a.id_status_plaza_movimiento_personal
	LEFT JOIN plantilla_base_administrativo_plantel g ON g.id_plaza = a.id_plaza AND g.id_subprograma = $1 AND g.id_estructura_ocupacional = $2
	LEFT JOIN empleados h ON h.id_empleado = g.id_empleado
	LEFT JOIN cat_estructuras_ocupacionales i ON i.id_estructura_ocupacional = g.id_estructura_ocupacional
	WHERE a.id_subprograma = $1
	AND a.id_status_plaza_estructura_ocupacional in(1,2,8)
	AND (e.id_adcen = var_id_adcen or e.id_adcen IS NULL)
	ORDER BY a.id_plaza;
	
	/* actualizo tabla, ingreso datos del subprograma */
	UPDATE temp_planteles_dom02
	SET nombre_subprograma = var_nombre_subprograma,
		clave_sep = var_clave_sep,
		coordinacion = var_nombre_coord;
	
	/* actualizao perfil del empleado (profesion, grado academico, validacion rh) */
	FOR reg IN cur LOOP

		SELECT INTO var_profesion, var_grado_academico, var_validacion
		d.profesion,b.grado_academico,
		(CASE WHEN (a.valida_archivo is null) THEN
			'PEN'
			WHEN (a.valida_archivo = true) THEN
				'SI'
			WHEN (a.valida_archivo = false) THEN
				'NO'
		END)
		FROM empleado_grados_academicos a
		INNER JOIN cat_grados_academicos b ON b.id_grado_academico = a.id_grado_academico
		INNER JOIN empleados z ON z.id_empleado = a.id_empleado
		LEFT JOIN curricula_estudios_empleados c ON c.id_empleado_grado_academico = a.id_empleado_grado_academico
		LEFT JOIN cat_profesiones d ON d.id_profesion = c.id_profesion
		LEFT JOIN cat_instituciones_educativas e ON e.id_institucion_educativa = c.id_institucion_educativa
		LEFT JOIN cat_documento_de_acreditacion f ON f.id_documento_acreditacion = a.id_documento_acreditacion
		LEFT JOIN empleado_grados_academicos_archivos g ON g.id_empleado_grado_academico = a.id_empleado_grado_academico
		WHERE z.filiacion = reg.filiacion
		ORDER BY b.nivel_grado_academico DESC
		LIMIT 1;
		
		-- SELECT INTO var_profesion, var_grado_academico, var_validacion 
		-- STRING_AGG(xb.profesion,',' ORDER BY xc.nivel_grado_academico),
		-- STRING_AGG(xc.grado_academico,',' ORDER BY xc.nivel_grado_academico),
		-- STRING_AGG(
		-- (CASE WHEN (xy.valida_archivo is null) THEN
		-- 	'PEN'
		-- 	WHEN (xy.valida_archivo = true) THEN
		-- 		'SI'
		-- 	WHEN (xy.valida_archivo = false) THEN
		-- 		'NO'
		-- END)
		-- ,',' ORDER BY xc.nivel_grado_academico)
		-- FROM curricula_estudios_empleados xa
		-- INNER JOIN cat_profesiones xb ON xb.id_profesion = xa.id_profesion
		-- INNER JOIN cat_grados_academicos xc ON xc.id_grado_academico = xb.id_grado_academico
		-- INNER JOIN empleados xz ON xz.id_empleado = xa.id_empleado
		-- INNER JOIN empleado_grados_academicos xy ON xy.id_empleado_grado_academico = xa.id_empleado_grado_academico 
		-- WHERE xz.filiacion = reg.filiacion
		-- AND xc.nivel_grado_academico >= 23;
		
		UPDATE temp_planteles_dom02
		SET profesion = var_profesion, grado_academico = var_grado_academico, validado = var_validacion
		WHERE temp_planteles_dom02.filiacion = reg.filiacion;
		
	END LOOP;
	
	/* obtengo firmantes y los agrego */
	SELECT 
	INTO var_director, var_puesto_director, var_coordinador, var_puesto_coordinador
	pf.prefijo_director||' '||pf.nombre_director, pf.puesto_director, pf.prefijo_coordinador||' '||pf.nombre_coordinador, pf.puesto_coordinador
	FROM planteles_firmantes($1,$2) pf;

	UPDATE temp_planteles_dom02 
	SET director = var_director,
	coordinador = var_coordinador,
	puesto_director = var_puesto_director,
	puesto_coordinador = var_puesto_coordinador;
	
	/* imprimo la tabla */
	RETURN QUERY SELECT * FROM temp_planteles_dom02 t ORDER BY t.id_plaza;
	DROP TABLE temp_planteles_dom02;
	
	
END; $$ 
LANGUAGE 'plpgsql';

SELECT *  FROM planteles_dom02(91,27)


