CREATE OR REPLACE FUNCTION planteles_listado(id_subprograma int, id_estructura int)
  RETURNS TABLE(
	  	id_temp integer,
	  	id_plantilla_base_docente_rh int, 
		filiacion text, 
		paterno text,
		materno text, 
		nombre text,
		categoria_padre text,
		num_plz text,
		hrs_categoria smallint,
		componente smallint,
		hrs_asignadas bigint,
		materia text,
	  	reg_nuevo boolean
  )
  AS $$
  BEGIN
  	CREATE TEMP TABLE temp_planteles_lista(
		id_temp SERIAL PRIMARY KEY,
	  	id_plantilla_base_docente_rh int, 
		filiacion text, 
		paterno text,
		materno text, 
		nombre text,
		categoria_padre text,
		num_plz text,
		hrs_categoria smallint,
		componente smallint,
		hrs_asignadas bigint,
		materia text,
	  	reg_nuevo boolean
	);
  	/* 
		Meter empleados, sin repetir para que aparezcan los que no tienen 
		asignacion pero tienen descarga , caso subp briseñas empl ernestina
	*/
	INSERT INTO temp_planteles_lista(filiacion,paterno,materno,nombre,categoria_padre,num_plz,hrs_categoria)
	(
		SELECT b.filiacion,b.paterno,b.materno,b.nombre,c.categoria_padre,a.num_plz,a.hrs_categoria
		FROM plantilla_base_docente_rh a
		INNER JOIN empleados b ON a.id_empleado = b.id_empleado
		INNER JOIN cat_categorias_padre c ON c.id_cat_categoria_padre = a.id_cat_categoria_padre
		WHERE a.id_subprograma = $1 AND a.id_estructura_ocupacional = $2
		AND a.revision_rh = true
		--GROUP BY b.filiacion,b.paterno,b.materno,b.nombre,b.id_empleado
		ORDER BY b.paterno,b.materno,b.nombre
	);
	
	/* Inserta horas asignadas Basico, capacitacion, optativas, paraescolares */
	INSERT INTO temp_planteles_lista(id_plantilla_base_docente_rh,filiacion,paterno,materno,nombre,categoria_padre,num_plz,hrs_categoria,componente,hrs_asignadas,materia)
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
	DELETE FROM temp_planteles_lista t 
	WHERE t.id_plantilla_base_docente_rh is null AND
	(
		SELECT CASE WHEN count(*) > 1 THEN
			1
		ELSE
			0
		END
		FROM temp_planteles_lista t2
		WHERE t2.categoria_padre||''||t2.num_plz||''||t2.hrs_categoria = t.categoria_padre||''||t.num_plz||''||t.hrs_categoria
	) = 1;
	
	RETURN QUERY SELECT * FROM temp_planteles_lista 
	ORDER BY paterno,materno,nombre;
	DROP TABLE temp_planteles_lista;
  END; $$ 
  LANGUAGE 'plpgsql';
  
  SELECT *  FROM planteles_listado(142,27)
  
  