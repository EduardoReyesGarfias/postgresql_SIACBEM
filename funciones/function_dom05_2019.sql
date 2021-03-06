CREATE OR REPLACE FUNCTION planteles_dom05_1 (id_subprograma int, id_estructura int)
  RETURNS TABLE(
	  	id_temp integer,
	  	id_plantilla_base_docente_rh int, 
		filiacion text, 
		paterno text,
		materno text, 
		nombre text,
	  	profesion text,
	  	prefijo text,
	  	grado_academico text,
	  	validacion text,
		categoria_padre text,
		num_plz text,
		hrs_categoria smallint,
		componente smallint,
		hrs_asignadas bigint,
		materia text,
	  	total_hrs_base bigint,
	  	total_hrs_base_x_trabajador bigint,
		total_hrs_asignadas smallint,
		total_hrs_asignadas_todos_planteles smallint,
		hrs_fort smallint,
	  	hrs_fort_final smallint,
	  	hrs_desc smallint,
	    pintar_fort_desc boolean,
	  	total_hrs_basi integer,
	  	total_hrs_prope integer,
	  	total_hrs_formtraba integer,
	  	total_hrs_para integer,
	  	total_hrs_orienta integer,
	  	total_hrs_fort_subp integer,
	  	total_hrs_desc_subp integer,
	  	director text,
	  	coordinador text,
	  	puesto_direc text,
	  	puesto_coordina text,
	  	reg_nuevo boolean
  )
AS $$
DECLARE
	reg RECORD;
	cur CURSOR FOR (SELECT temp_planteles_dom05_1.filiacion from temp_planteles_dom05_1);
	reg_desc RECORD;
	cur_desc CURSOR FOR (
		SELECT distinct t.filiacion, t.hrs_desc
		FROM temp_planteles_dom05_1 t
		WHERE t.hrs_desc > 0
	);
	reg_fort RECORD;
	cur_fort CURSOR FOR (
		SELECT distinct t.filiacion, t.hrs_fort_final
		FROM temp_planteles_dom05_1 t
		WHERE t.hrs_fort_final > 0
	);
	reg_unico RECORD;
	cur_unico CURSOR FOR (
		SELECT t.filiacion, t.id_temp 
		FROM temp_planteles_dom05_1 t
		ORDER BY t.paterno,t.materno,t.nombre,t.componente,t.categoria_padre,t.num_plz,t.hrs_categoria,t.materia,t.hrs_fort_final
	);
	var_filiacion_anterior text;
	var_prefijo text;
	var_profesion text;
	var_grado_academico text;
	var_validacion text;
	var_director text;
	var_coordinador text;
	var_puesto_director text;
	var_puesto_coordinador text;
	sum_hrs_basi integer;
	sum_hrs_prope integer;
	sum_hrs_formtraba integer;
	sum_hrs_para integer;
	sum_hrs_orienta integer;
	sum_hrs_fort_subp integer;
	sum_hrs_desc_subp integer;
BEGIN
	sum_hrs_basi:= 0;
	sum_hrs_prope:= 0;
	sum_hrs_formtraba:= 0;
	sum_hrs_para:= 0;
	sum_hrs_orienta:= 0;
	sum_hrs_fort_subp:= 0;
	sum_hrs_desc_subp:= 0;
	var_filiacion_anterior:= '';
	/* CREO TABLA TEMP PARA ACOMODAR LA INFO CON LA ESTRUCTURA DESEADA */
	CREATE TEMP TABLE temp_planteles_dom05_1(
		id_temp SERIAL PRIMARY KEY,
		id_plantilla_base_docente_rh int, 
		filiacion text, 
		paterno text,
		materno text, 
		nombre text, 
		profesion text,
	  	prefijo text,
		grado_academico text,
		validacion text,
		categoria_padre text,
		num_plz text,
		hrs_categoria smallint,
		componente smallint,
		hrs_asignadas bigint,
		materia text,
		total_hrs_base bigint,
		total_hrs_base_x_trabajador bigint,
		total_hrs_asignadas smallint,
		total_hrs_asignadas_todos_planteles smallint,
		hrs_fort smallint,
	  	hrs_fort_final smallint,
	  	hrs_desc smallint,
	    pintar_fort_desc boolean,
		total_hrs_basi integer,
	  	total_hrs_prope integer,
	  	total_hrs_formtraba integer,
	  	total_hrs_para integer,
	  	total_hrs_orienta integer,
	  	total_hrs_fort_subp integer,
	  	total_hrs_desc_subp integer,
		director text,
		puesto_direc text,
		puesto_coordina text,
		coordinador text,
		reg_nuevo boolean
	);
	
	/* 
		Meter empleados, sin repetir para que aparezcan los que no tienen 
		asignacion pero tienen descarga , caso subp brise??as empl ernestina
	*/
	/*INSERT INTO temp_planteles_dom05_1(filiacion,paterno,materno,nombre)
	(
		SELECT b.filiacion,b.paterno,b.materno,b.nombre
		FROM plantilla_base_docente_rh a
		INNER JOIN empleados b ON a.id_empleado = b.id_empleado
		WHERE a.id_subprograma = $1 AND a.id_estructura_ocupacional = $2
		AND a.revision_rh = true
		GROUP BY b.filiacion,b.paterno,b.materno,b.nombre,b.id_empleado
		ORDER BY b.paterno,b.materno,b.nombre
	);
	*/
	/*
		Meter la plantilla base, cada profesor con sus respectivas plazas para que aparezcan los que no tienen 
		asignacion pero tienen descarga.

		- caso subp brise??as empl ernestina
		- caso subp jiquilpan Lucila le hacia alta su CBV
	*/
	INSERT INTO temp_planteles_dom05_1(filiacion,paterno,materno,nombre,categoria_padre,num_plz,hrs_categoria)
	(
		SELECT b.filiacion,b.paterno,b.materno,b.nombre,c.categoria_padre,a.num_plz,a.hrs_categoria
		FROM plantilla_base_docente_rh a
		INNER JOIN empleados b ON a.id_empleado = b.id_empleado
		INNER JOIN cat_categorias_padre c ON c.id_cat_categoria_padre = a.id_cat_categoria_padre
		WHERE a.id_subprograma = $1 AND a.id_estructura_ocupacional = $2
		AND a.revision_rh = true
		GROUP BY b.filiacion,b.paterno,b.materno,b.nombre,c.categoria_padre,a.num_plz,a.hrs_categoria
		ORDER BY b.paterno,b.materno,b.nombre
	);
	
	
	/* Inserta horas asignadas Basico, capacitacion, optativas, paraescolares */
	INSERT INTO temp_planteles_dom05_1(id_plantilla_base_docente_rh,filiacion,paterno,materno,nombre,categoria_padre,num_plz,hrs_categoria,componente,hrs_asignadas,materia)
	(
		(
			SELECT a.id_plantilla_base_docente_rh,b.filiacion,b.paterno,b.materno,b.nombre
			,g.categoria_padre,a.num_plz,a.hrs_categoria,1 as componente,sum(c.horas_grupo_base)as horas_grupo_base,f.materia

			FROM plantilla_base_docente_rh a
			INNER JOIN empleados b ON a.id_empleado = b.id_empleado 
			INNER JOIN cat_categorias_padre g ON g.id_cat_categoria_padre = a.id_cat_categoria_padre

			INNER JOIN profesores_profesor_asignado_base c ON c.id_plantilla_base_docente_rh = a.id_plantilla_base_docente_rh
			INNER JOIN profesor_asignado_base d ON d.id_profesor_asignado_base = c.id_profesor_asignado_base
			INNER JOIN detalle_materias e ON e.id_detalle_materia = d.id_detalle_materia 
			INNER JOIN cat_materias f ON f.id_materia = e.id_materia

			WHERE 
			a.id_subprograma = $1 AND 
			a.id_estructura_ocupacional = $2 AND
			a.revision_rh = true
			GROUP BY a.id_plantilla_base_docente_rh,b.filiacion,b.paterno,b.materno,b.nombre
			,g.categoria_padre,a.num_plz,a.hrs_categoria,f.materia
			ORDER BY b.paterno,b.materno,b.nombre,g.categoria_padre,a.num_plz,f.materia
		)
		UNION ALL
		(
			SELECT a.id_plantilla_base_docente_rh,b.filiacion,b.paterno,b.materno,b.nombre
			,g.categoria_padre,a.num_plz,a.hrs_categoria,3 as componente
			,SUM(ba.horas_grupo_capacitacion) as horas_grupo_capacitacion,
			(
				CASE WHEN bd.id_formacion_trabajo = 14 THEN
				be.materia||' - TICS'
				WHEN bd.id_formacion_trabajo = 15 THEN
				be.materia||' - Rob??tica'
				ELSE
				be.materia
				END
			)as materia		
			FROM plantilla_base_docente_rh a
			INNER JOIN empleados b ON a.id_empleado = b.id_empleado 
			INNER JOIN cat_categorias_padre g ON g.id_cat_categoria_padre = a.id_cat_categoria_padre

			INNER JOIN profesores_profesor_asignado_capacitacion ba ON ba.id_plantilla_base_docente_rh = a.id_plantilla_base_docente_rh
			INNER JOIN profesor_asignado_capacitacion bb ON bb.id_profesor_asignado_capacitacion = ba.id_profesor_asignado_capacitacion
			INNER JOIN detalle_materias bc ON bc.id_detalle_materia = bb.id_detalle_materia 
			LEFT JOIN materias_componente_trabajo bd ON bd.id_detalle_materia = bc.id_detalle_materia
			INNER JOIN cat_materias be ON be.id_materia = bc.id_materia

			WHERE 
			a.id_subprograma = $1 AND 
			a.id_estructura_ocupacional = $2 AND
			a.revision_rh = true
			GROUP BY a.id_plantilla_base_docente_rh,b.filiacion,b.paterno,b.materno,b.nombre
			,g.categoria_padre,a.num_plz,a.hrs_categoria,be.materia,bd.id_formacion_trabajo
			ORDER BY b.paterno,b.materno,b.nombre,g.categoria_padre,a.num_plz,be.materia
		)
		UNION ALL
		(
			SELECT a.id_plantilla_base_docente_rh,b.filiacion,b.paterno,b.materno,b.nombre
			,g.categoria_padre,a.num_plz,a.hrs_categoria,2 as componente,ca.horas_grupo_optativas,cd.materia
			FROM plantilla_base_docente_rh a
			INNER JOIN empleados b ON a.id_empleado = b.id_empleado 
			INNER JOIN cat_categorias_padre g ON g.id_cat_categoria_padre = a.id_cat_categoria_padre

			INNER JOIN profesores_profesor_asignado_optativas ca ON ca.id_plantilla_base_docente_rh = a.id_plantilla_base_docente_rh
			INNER JOIN profesor_asignado_optativas cb ON cb.id_profesor_asignado_optativa = ca.id_profesor_asignado_optativa
			INNER JOIN detalle_materias cc ON cc.id_detalle_materia = cb.id_detalle_materia
			INNER JOIN cat_materias cd ON cd.id_materia = cc.id_materia

			WHERE 
			a.id_subprograma = $1 AND 
			a.id_estructura_ocupacional = $2 AND
			a.revision_rh = true
			ORDER BY b.paterno,b.materno,b.nombre,g.categoria_padre,a.num_plz,cd.materia
		)
		UNION ALL
		(
			SELECT a.id_plantilla_base_docente_rh,b.filiacion,b.paterno,b.materno,b.nombre
			,g.categoria_padre,a.num_plz,a.hrs_categoria,4 as componente,da.horas_grupo_paraescolares,dc.nombre
			FROM plantilla_base_docente_rh a
			INNER JOIN empleados b ON a.id_empleado = b.id_empleado 
			INNER JOIN cat_categorias_padre g ON g.id_cat_categoria_padre = a.id_cat_categoria_padre

			INNER JOIN profesores_profesor_asignado_paraescolares da ON da.id_plantilla_base_docente_rh = a.id_plantilla_base_docente_rh
			INNER JOIN profesor_asignado_paraescolares db ON db.id_profesor_asignado_paraescolares = da.id_profesor_asignado_paraescolares 
			INNER JOIN cat_materias_paraescolares dc ON dc.id_paraescolar = da.id_cat_materias_paraescolares

			WHERE 
			a.id_subprograma = $1 AND 
			a.id_estructura_ocupacional = $2 AND
			a.revision_rh = true
			ORDER BY b.paterno,b.materno,b.nombre,g.categoria_padre,a.num_plz,dc.nombre
		)

	);
	
	/*Quitar la estructura inicial */
	/*DELETE FROM temp_planteles_dom05_1 t 
	WHERE t.id_plantilla_base_docente_rh is null AND
	(
		SELECT CASE WHEN count(*) > 1 THEN
			1
		ELSE
			0
		END
		FROM temp_planteles_dom05_1 t2
		WHERE t2.filiacion = t.filiacion
	) = 1;
	*/
	/*Quitar la estructura inicial */
	DELETE FROM temp_planteles_dom05_1 t 
	WHERE t.id_plantilla_base_docente_rh is null AND
	(
		SELECT CASE WHEN count(*) > 1 THEN
			1
		ELSE
			0
		END
		FROM temp_planteles_dom05_1 t2
		WHERE t2.categoria_padre||''||t2.num_plz||''||t2.hrs_categoria = t.categoria_padre||''||t.num_plz||''||t.hrs_categoria
	) = 1;
	
	/* Actualiza profesion, prefijo, grado academico, validacion */
	FOR reg IN cur LOOP
		
		var_profesion:='';
		var_grado_academico:='';
		var_validacion:='';

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
		-- AND (xc.nivel_grado_academico >= 23 OR xc.nivel_grado_academico = 20 );

		SELECT INTO var_profesion, var_grado_academico, var_validacion  
		STRING_AGG(e.profesion,',' ORDER BY b.nivel_grado_academico),
		STRING_AGG(b.grado_academico,',' ORDER BY b.nivel_grado_academico),
		STRING_AGG(
		(CASE WHEN (a.valida_archivo is null) THEN
			'PEN'
			WHEN (a.valida_archivo = true) THEN
				'SI'
			WHEN (a.valida_archivo = false) THEN
				'NO'
		END)
		,',' ORDER BY b.nivel_grado_academico)
		FROM empleado_grados_academicos a
		INNER JOIN cat_grados_academicos b ON a.id_grado_academico = b.id_grado_academico
		INNER JOIN empleados c ON c.id_empleado = a.id_empleado
		INNER JOIN curricula_estudios_empleados d ON d.id_empleado = a.id_empleado
		INNER JOIN cat_profesiones e ON e.id_profesion = d.id_profesion
		WHERE c.filiacion = reg.filiacion
		AND d.id_empleado_grado_academico = a.id_empleado_grado_academico
		AND (b.nivel_grado_academico >= 23 OR b.nivel_grado_academico = 20 );
		
		UPDATE temp_planteles_dom05_1
		SET prefijo = var_prefijo, profesion = var_profesion, grado_academico = var_grado_academico, validacion = var_validacion
		WHERE temp_planteles_dom05_1.filiacion = reg.filiacion;
		
	END LOOP;
	
	UPDATE temp_planteles_dom05_1 
	SET total_hrs_asignadas = planteles_hrs_totales_asignadas(temp_planteles_dom05_1.filiacion,$1,$2),
	hrs_fort = COALESCE(planteles_hrs_fort_40_profesor1($1,temp_planteles_dom05_1.filiacion,$2),0),
	total_hrs_base = planteles_hrs_base_plantel($1,$2,temp_planteles_dom05_1.filiacion),
	total_hrs_base_x_trabajador = planteles_hrs_base_x_trabajador($2,temp_planteles_dom05_1.filiacion),
	total_hrs_asignadas_todos_planteles = planteles_hrs_totales_asignadas_todos_planteles(temp_planteles_dom05_1.filiacion,$2);
	
	UPDATE temp_planteles_dom05_1 
	SET pintar_fort_desc = planteles_pinta_fort_desc1(temp_planteles_dom05_1.filiacion,temp_planteles_dom05_1.total_hrs_base,$1,$2);
		
	
	/* Distinguir si se pinta o no las de descarga en este plantel */
	UPDATE temp_planteles_dom05_1 SET hrs_fort_final = 
	(
		CASE WHEN temp_planteles_dom05_1.pintar_fort_desc = true THEN
			
			CASE WHEN (temp_planteles_dom05_1.total_hrs_base - (temp_planteles_dom05_1.total_hrs_asignadas + temp_planteles_dom05_1.hrs_fort)) <0 THEN
				temp_planteles_dom05_1.hrs_fort + (temp_planteles_dom05_1.total_hrs_base - (temp_planteles_dom05_1.total_hrs_asignadas + temp_planteles_dom05_1.hrs_fort))
			ELSE
				temp_planteles_dom05_1.hrs_fort
			END
		
		ELSE
			0
		END
	); 
	
	UPDATE temp_planteles_dom05_1 SET hrs_desc = 
	(
		CASE WHEN temp_planteles_dom05_1.pintar_fort_desc = true THEN
			
			CASE WHEN (temp_planteles_dom05_1.total_hrs_base - (temp_planteles_dom05_1.total_hrs_asignadas + temp_planteles_dom05_1.hrs_fort)) > 0 THEN
				temp_planteles_dom05_1.total_hrs_base - (temp_planteles_dom05_1.total_hrs_asignadas + temp_planteles_dom05_1.hrs_fort)
			ELSE
				0
			END
		
		ELSE
			temp_planteles_dom05_1.total_hrs_base - temp_planteles_dom05_1.total_hrs_asignadas
		END
	); 
	
	/* sumar asignadas para sacar totales por subprograma */
	--basico
	SELECT COALESCE(sum(t.hrs_asignadas),0) INTO sum_hrs_basi
	FROM temp_planteles_dom05_1 t
	WHERE t.componente = 1
	AND t.materia NOT  like '%ORIENTACI??N EDUCATIVA%';
	
	-- prope
	SELECT COALESCE(sum(t.hrs_asignadas),0) INTO sum_hrs_prope
	FROM temp_planteles_dom05_1 t
	WHERE t.componente = 2;

	-- formacion trabajo
	SELECT COALESCE(sum(t.hrs_asignadas),0) INTO sum_hrs_formtraba
	FROM temp_planteles_dom05_1 t
	WHERE t.componente = 3;

	-- paraescolares
	SELECT COALESCE(sum(t.hrs_asignadas),0) INTO sum_hrs_para
	FROM temp_planteles_dom05_1 t
	WHERE t.componente = 4;

	-- Orientaci??n
	SELECT COALESCE(sum(t.hrs_asignadas),0) INTO sum_hrs_orienta
	FROM temp_planteles_dom05_1 t
	WHERE t.componente = 1
	AND t.materia like '%ORIENTACI??N EDUCATIVA%';

	-- fortalecimiento subp
	FOR reg_fort IN cur_fort LOOP
		sum_hrs_fort_subp:= sum_hrs_fort_subp + reg_fort.hrs_fort_final; 
	END LOOP;
	
	-- Descarga subp
	FOR reg_desc IN cur_desc LOOP
		sum_hrs_desc_subp:= sum_hrs_desc_subp + reg_desc.hrs_desc; 
	END LOOP;

	/* director y coordinador */
	SELECT INTO var_director, var_coordinador, var_puesto_director, var_puesto_coordinador
	COALESCE(prefijo_director,'')||' '||COALESCE(nombre_director,''),
	COALESCE(prefijo_coordinador,'')||' '||COALESCE(nombre_coordinador,''),
	puesto_director,puesto_coordinador
	FROM planteles_firmantes($1,$2);

	/* actualizo firmantes, totales por componente, fort x subp y desc x subp */
	UPDATE temp_planteles_dom05_1
	SET total_hrs_basi = sum_hrs_basi,
		total_hrs_prope = sum_hrs_prope,
		total_hrs_formtraba = sum_hrs_formtraba,
		total_hrs_para = sum_hrs_para,
		total_hrs_orienta = sum_hrs_orienta,
		total_hrs_fort_subp = sum_hrs_fort_subp,
		total_hrs_desc_subp = sum_hrs_desc_subp,
		director = var_director,
		coordinador = var_coordinador,
		puesto_direc = var_puesto_director,
		puesto_coordina = var_puesto_coordinador;
	
	/* actualizo para saber si es registro unico o no */
	FOR reg_unico IN cur_unico LOOP
		IF reg_unico.filiacion != var_filiacion_anterior THEN 
			UPDATE temp_planteles_dom05_1 t
			SET reg_nuevo = true
			WHERE t.id_temp = reg_unico.id_temp;
		END IF;
		var_filiacion_anterior = reg_unico.filiacion;
	END LOOP;
	
	
	/* Pinto los datos del plantel (plantilla base con/sin asigncion) */	
	RETURN QUERY SELECT 
		t.id_temp,t.id_plantilla_base_docente_rh,t.filiacion,t.paterno,t.materno,	t.nombre,t.profesion,t.prefijo,t.grado_academico, t.validacion,
		t.categoria_padre,t.num_plz,t.hrs_categoria,
		t.componente,CAST(COALESCE(sum(t.hrs_asignadas),0) as bigint) as horas_asignadas,t.materia,t.total_hrs_base
		,t.total_hrs_base_x_trabajador,t.total_hrs_asignadas,
		t.total_hrs_asignadas_todos_planteles,t.hrs_fort,t.hrs_fort_final,t.hrs_desc,t.pintar_fort_desc,t.total_hrs_basi,
	  	t.total_hrs_prope,t.total_hrs_formtraba,t.total_hrs_para,t.total_hrs_orienta,t.total_hrs_fort_subp,t.total_hrs_desc_subp,
		t.director,t.coordinador,t.puesto_direc,t.puesto_coordina,t.reg_nuevo
	FROM temp_planteles_dom05_1 t
	GROUP BY 
		t.id_temp,t.id_plantilla_base_docente_rh,t.filiacion,t.paterno,t.materno,	t.nombre,t.profesion,t.prefijo,t.grado_academico, t.validacion,  
		t.categoria_padre,t.num_plz,t.hrs_categoria,
		t.componente,t.hrs_asignadas,t.materia,t.total_hrs_base
		,t.total_hrs_base_x_trabajador,t.total_hrs_asignadas,
		t.total_hrs_asignadas_todos_planteles,t.hrs_fort,t.hrs_fort_final,t.hrs_desc,t.pintar_fort_desc,t.total_hrs_basi,
	  	t.total_hrs_prope,t.total_hrs_formtraba,t.total_hrs_para,t.total_hrs_orienta,t.total_hrs_fort_subp,t.total_hrs_desc_subp,
		t.director,t.coordinador,t.puesto_direc,t.puesto_coordina,t.reg_nuevo
	ORDER BY t.paterno,t.materno,t.nombre,t.componente,t.categoria_padre,t.num_plz,t.hrs_categoria,t.materia,t.hrs_fort_final;
	
	/* Al retornar se destruye la tambla temporal */
	DROP TABLE temp_planteles_dom05_1;	

END; $$ 
 
LANGUAGE 'plpgsql';

select * from planteles_dom05_1(14,27);

