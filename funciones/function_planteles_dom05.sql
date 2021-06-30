CREATE OR REPLACE FUNCTION planteles_dom05 (id_subprograma int, id_estructura int)
  RETURNS TABLE(
	  	id_plantilla_base_docente_rh int, 
		filiacion text, 
		paterno text,
		materno text, 
		nombre text,
	  	profesion text,
	  	prefijo text,
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
	    pintar_fort_desc boolean
  )
AS $$
BEGIN
	/* CREO TABLA TEMP PARA ACOMODAR LA INFO CON LA ESTRUCTURA DESEADA */
	CREATE TEMP TABLE temp_planteles_dom05(
		id_plantilla_base_docente_rh int, 
		filiacion text, 
		paterno text,
		materno text, 
		nombre text, 
		profesion text,
	  	prefijo text,
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
	    pintar_fort_desc boolean
	);
	
	/* 
		Meter empleados, sin repetir para que aparezcan los que no tienen 
		asignacion pero tienen descarga , caso subp briseñas empl ernestina
	*/
	INSERT INTO temp_planteles_dom05(filiacion,paterno,materno,nombre)
	(
		SELECT b.filiacion,b.paterno,b.materno,b.nombre
		FROM plantilla_base_docente_rh a
		INNER JOIN empleados b ON a.id_empleado = b.id_empleado
		WHERE a.id_subprograma = $1 AND a.id_estructura_ocupacional = $2
		AND a.revision_rh = true
		GROUP BY b.filiacion,b.paterno,b.materno,b.nombre,b.id_empleado
		ORDER BY b.paterno,b.materno,b.nombre
	);
	
	
	/* Inserta horas asignadas Basico */
	INSERT INTO temp_planteles_dom05(id_plantilla_base_docente_rh,filiacion,paterno,materno,nombre,categoria_padre,num_plz,hrs_categoria,componente,hrs_asignadas,materia)
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

	);
	
	/* Inserta horas asignadas Capacitacion */
	INSERT INTO temp_planteles_dom05(id_plantilla_base_docente_rh,filiacion,paterno,materno,nombre,categoria_padre,num_plz,hrs_categoria,componente,hrs_asignadas,materia)
	(
	SELECT a.id_plantilla_base_docente_rh,b.filiacion,b.paterno,b.materno,b.nombre
	,g.categoria_padre,a.num_plz,a.hrs_categoria,2 as componente
	,SUM(ba.horas_grupo_capacitacion) as horas_grupo_capacitacion,
	(
		CASE WHEN bd.id_formacion_trabajo = 14 THEN
		be.materia||' - TICS'
		WHEN bd.id_formacion_trabajo = 15 THEN
		be.materia||' - Robótica'
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
	);
	
	/* Inserta horas asignadas Optativas	*/
	INSERT INTO temp_planteles_dom05(id_plantilla_base_docente_rh,filiacion,paterno,materno,nombre,categoria_padre,num_plz,hrs_categoria,componente,hrs_asignadas,materia)
	(
	SELECT a.id_plantilla_base_docente_rh,b.filiacion,b.paterno,b.materno,b.nombre
	,g.categoria_padre,a.num_plz,a.hrs_categoria,3 as componente,ca.horas_grupo_optativas,cd.materia
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
	);
	
	/* Inserta horas asignadas Paraescolares */
	INSERT INTO temp_planteles_dom05(id_plantilla_base_docente_rh,filiacion,paterno,materno,nombre,categoria_padre,num_plz,hrs_categoria,componente,hrs_asignadas,materia)
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
	);
	
	/*Quitar la estructura inicial */
	DELETE FROM temp_planteles_dom05 t 
	WHERE t.id_plantilla_base_docente_rh is null AND
	(
		SELECT CASE WHEN count(*) > 1 THEN
			1
		ELSE
			0
		END
		FROM temp_planteles_dom05 t2
		WHERE t2.filiacion = t.filiacion
	) = 1;
	
	/* Actualiza profesion y prefijo */
	UPDATE temp_planteles_dom05 SET profesion = 
	(
		SELECT xb.profesion
		FROM curricula_estudios_empleados xa
		INNER JOIN cat_profesiones xb ON xb.id_profesion = xa.id_profesion
		INNER JOIN cat_grados_academicos xc ON xc.id_grado_academico = xb.id_grado_academico
		INNER JOIN empleados xz ON xz.id_empleado = xa.id_empleado
		WHERE xz.filiacion = temp_planteles_dom05.filiacion
		ORDER BY xc.nivel_grado_academico DESC
		LIMIT 1
	)
	, prefijo = 
	(
		SELECT 
		(
			CASE WHEN xz.genero = 'F' THEN 
				xb.prefijo_fem
			ELSE
				xb.prefijo
			END
		)
		FROM curricula_estudios_empleados xa
		INNER JOIN cat_profesiones xb ON xb.id_profesion = xa.id_profesion
		INNER JOIN cat_grados_academicos xc ON xc.id_grado_academico = xb.id_grado_academico
		INNER JOIN empleados xz ON xz.id_empleado = xa.id_empleado
		WHERE xz.filiacion = temp_planteles_dom05.filiacion
		ORDER BY xc.nivel_grado_academico DESC
		LIMIT 1	
	);
	
	
	/* Actualiza horas asignadas totales de cada trabajador */
	UPDATE temp_planteles_dom05 SET total_hrs_asignadas = planteles_hrs_totales_asignadas(temp_planteles_dom05.filiacion,$1,$2);
	
	/* Actualiza horas fortalecimiento de cada trabajador */
	UPDATE temp_planteles_dom05 SET hrs_fort = COALESCE(planteles_hrs_fort_40_profesor1($1,temp_planteles_dom05.filiacion,$2),0);
	
	/* Actualiza horas totales base - unicamente las de este plantel */
	UPDATE temp_planteles_dom05 SET total_hrs_base = planteles_hrs_base_plantel($1,$2,temp_planteles_dom05.filiacion);
	
	/* Actualiza horas totales base x trabajador -suma la de todos los planteles incluyendo este */
	UPDATE temp_planteles_dom05 SET total_hrs_base_x_trabajador = planteles_hrs_base_x_trabajador($2,temp_planteles_dom05.filiacion);
	
	/* Actualizar horas totales asignadas en todos los planteles por filiacion */
	UPDATE temp_planteles_dom05 SET total_hrs_asignadas_todos_planteles = planteles_hrs_totales_asignadas_todos_planteles(temp_planteles_dom05.filiacion,$2);
	
	/* Acualiza hrs_fortalecimiento 'finales' */
	/*UPDATE temp_planteles_dom05 SET hrs_fort_final = 
	(
		SELECT CASE WHEN (temp_planteles_dom05.total_hrs_base_x_trabajador - (temp_planteles_dom05.total_hrs_asignadas_todos_planteles + temp_planteles_dom05.hrs_fort)) < 0 THEN
			temp_planteles_dom05.hrs_fort - ((temp_planteles_dom05.total_hrs_base_x_trabajador - (temp_planteles_dom05.total_hrs_asignadas_todos_planteles + temp_planteles_dom05.hrs_fort)) * -1)
		ELSE
			temp_planteles_dom05.hrs_fort
		END
	);
	*/
	/* Actualizar fort final */
	/*UPDATE temp_planteles_dom05 SET hrs_fort_final = 
	(
		SELECT CASE WHEN temp_planteles_dom05.total_hrs_base - (temp_planteles_dom05.total_hrs_asignadas + temp_planteles_dom05.hrs_fort_final) <0 THEN
			temp_planteles_dom05.hrs_fort_final - ((temp_planteles_dom05.total_hrs_base - (temp_planteles_dom05.total_hrs_asignadas + temp_planteles_dom05.hrs_fort_final)) * -1)
		ELSE
			temp_planteles_dom05.hrs_fort_final
		END
	);
	*/
	
	
	/* Acualiza hrs_descarga */
	/*UPDATE temp_planteles_dom05 SET hrs_desc = 
	(
		SELECT CASE WHEN (temp_planteles_dom05.total_hrs_base_x_trabajador - (temp_planteles_dom05.total_hrs_asignadas_todos_planteles + temp_planteles_dom05.hrs_fort_final)) > 0 THEN
			(temp_planteles_dom05.total_hrs_base_x_trabajador - (temp_planteles_dom05.total_hrs_asignadas_todos_planteles + temp_planteles_dom05.hrs_fort_final))
		ELSE
			0
		END
	);*/
		
	/* Saber si pintar hrs fort y hrs desc */
	UPDATE temp_planteles_dom05 SET pintar_fort_desc = planteles_pinta_fort_desc(temp_planteles_dom05.filiacion,temp_planteles_dom05.total_hrs_base,$1,$2);
	
	/* Distinguir si se pinta o no las de descarga en este plantel */
	UPDATE temp_planteles_dom05 SET hrs_fort_final = 
	(
		CASE WHEN temp_planteles_dom05.pintar_fort_desc = true THEN
			
			CASE WHEN (temp_planteles_dom05.total_hrs_base - (temp_planteles_dom05.total_hrs_asignadas + temp_planteles_dom05.hrs_fort)) <0 THEN
				temp_planteles_dom05.hrs_fort + (temp_planteles_dom05.total_hrs_base - (temp_planteles_dom05.total_hrs_asignadas + temp_planteles_dom05.hrs_fort))
			ELSE
				temp_planteles_dom05.hrs_fort
			END
		
		ELSE
			0
		END
	); 
	
	UPDATE temp_planteles_dom05 SET hrs_desc = 
	(
		CASE WHEN temp_planteles_dom05.pintar_fort_desc = true THEN
			
			CASE WHEN (temp_planteles_dom05.total_hrs_base - (temp_planteles_dom05.total_hrs_asignadas + temp_planteles_dom05.hrs_fort)) > 0 THEN
				temp_planteles_dom05.total_hrs_base - (temp_planteles_dom05.total_hrs_asignadas + temp_planteles_dom05.hrs_fort)
			ELSE
				0
			END
		
		ELSE
			temp_planteles_dom05.total_hrs_base - temp_planteles_dom05.total_hrs_asignadas
		END
	); 
	
	
	/* Regreso consulta a la tabla temporal */	
	RETURN QUERY SELECT 
		t.id_plantilla_base_docente_rh,t.filiacion,t.paterno,t.materno,	t.nombre,t.profesion,t.prefijo, 
		t.categoria_padre,t.num_plz,t.hrs_categoria,
		t.componente,CAST(sum(t.hrs_asignadas) as bigint) as horas_asignadas,t.materia,t.total_hrs_base
		,t.total_hrs_base_x_trabajador,t.total_hrs_asignadas,
		t.total_hrs_asignadas_todos_planteles,t.hrs_fort,t.hrs_fort_final,t.hrs_desc,t.pintar_fort_desc
	FROM temp_planteles_dom05 t
	GROUP BY 
		t.id_plantilla_base_docente_rh,t.filiacion,t.paterno,t.materno,	t.nombre,t.profesion,t.prefijo, 
		t.categoria_padre,t.num_plz,t.hrs_categoria,
		t.componente,t.hrs_asignadas,t.materia,t.total_hrs_base
		,t.total_hrs_base_x_trabajador,t.total_hrs_asignadas,
		t.total_hrs_asignadas_todos_planteles,t.hrs_fort,t.hrs_fort_final,t.hrs_desc,t.pintar_fort_desc
	ORDER BY t.paterno,t.materno,t.nombre,t.componente,t.categoria_padre,t.num_plz,t.hrs_categoria,t.materia,t.hrs_fort_final;
	
	/* Al retornar se destruye la tambla temporal */
	DROP TABLE temp_planteles_dom05;	
   
END; $$ 
 
LANGUAGE 'plpgsql';

select * from planteles_dom05(98,26);
-- select * from planteles_dom05(86,26);
--select * from planteles_dom05(123,26);
