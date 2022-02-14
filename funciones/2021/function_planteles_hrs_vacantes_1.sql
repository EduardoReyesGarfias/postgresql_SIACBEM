DECLARE
	var_activos text;
	var_sem_1 smallint;
	var_sem_2 smallint;
	var_sem_3 smallint;
	var_num_grupo1 smallint;
	var_num_grupo2 smallint;
	var_num_grupo3 smallint;
	var_id_grupo_combinacion_plan smallint;
	var_id_plan1 smallint;
	var_id_plan2 smallint;
	var_id_plan3 smallint;
	var_vuelta smallint;
	var_tipo_subprograma smallint;
	
	/*reg          RECORD;*/
	reg_gpos     RECORD;
	/*cur_activos CURSOR FOR SELECT 
					(CASE WHEN (CAST(substring(periodo FROM 6 FOR 2) as int)) = 2 THEN
						'1,3,5'
					ELSE
						'2,4,6'
					END) AS activos
				FROM cat_estructuras_ocupacionales
				WHERE id_estructura_ocupacional = $2;*/

	cur_grupos CURSOR FOR 
	SELECT 
		count(a.nombre_grupo) as num_grupos,
		substring(a.nombre_grupo from 1 for 1)::integer AS semestre
		,(CASE 
		   	WHEN substring(a.nombre_grupo from 1 for 1)='2' OR substring(a.nombre_grupo from 1 for 1)='1'  then id_plan_grupo_activo1
		    WHEN substring(a.nombre_grupo from 1 for 1)='4' OR substring(a.nombre_grupo from 1 for 1)='3' then id_plan_grupo_activo2
		    WHEN substring(a.nombre_grupo from 1 for 1)='6' OR substring(a.nombre_grupo from 1 for 1)='5' then id_plan_grupo_activo3  
			    END
		)id_plan_grupo_activo,
		GC.id_grupo_combinacion_plan
		FROM grupos_estructura_base a
		INNER JOIN horas_autorizadas b ON b.id_hora_autorizada = a.id_hora_autorizada
		INNER JOIN grupos c ON b.id_grupo = c.id_grupo
		INNER JOIN grupos_combinaciones_planes gc ON gc.id_grupo_combinacion_plan = c.id_grupo_combinacion_plan
		INNER JOIN periodos d ON c.id_periodo = d.id_periodo
		WHERE 
		d.id_subprograma = $1
		AND d.id_estructura_ocupacional = ($2) 
		AND d.id_tipo_periodo = 1
		GROUP BY substring(a.nombre_grupo from 1 for 1),id_plan_grupo_activo1,id_plan_grupo_activo2,id_plan_grupo_activo3,GC.id_grupo_combinacion_plan
		ORDER BY substring(a.nombre_grupo from 1 for 1);

BEGIN
	
	/* CREO TABLA TEMP PARA ACOMODAR LA INFO CON LA ESTRUCTURA DESEADA */
	CREATE TEMP TABLE temp_planteles_hrs_vacantes(
		semestre smallint,
		id_componente smallint,
		id_detalle_materia smallint,
		materia text,
		alta smallint,
		hsm smallint,
		hrs_vacantes smallint,
		hrs_vacantes_subp smallint
	);
	
	/* Defino si es un Plantel/Extensión o si es un CEM */
	SELECT INTO var_tipo_subprograma
	(CASE WHEN a.nombre_subprograma ilike 'Plantel%' THEN 1 ELSE 2 END)
	FROM subprogramas a
	WHERE a.id_subprograma = $1;
	
	/* saco semestres activos */
	/*FOR reg IN cur_activos LOOP
		var_activos:=reg.activos;
	END LOOP;*/	
	SELECT INTO var_activos 
		(CASE WHEN (CAST(substring(periodo FROM 6 FOR 2) as int)) = 2 THEN
			'1,3,5'
		ELSE
			'2,4,6'
		END) AS activos
	FROM cat_estructuras_ocupacionales
	WHERE id_estructura_ocupacional = $2;

	SELECT INTO var_sem_1 CAST(substring(var_activos, 1,1) as int);
	SELECT INTO var_sem_2 CAST(substring(var_activos, 3,1) as int);
	SELECT INTO var_sem_3 CAST(substring(var_activos, 5,1) as int);
	
	/* saco num grupos y id_plan grupo y grupos combinaciones plan  */
	var_vuelta:=1;
	FOR reg_gpos IN cur_grupos LOOP
    	
		-- IF var_vuelta = 1 THEN
		-- 	var_num_grupo1:=reg_gpos.num_grupos;
		-- 	var_id_plan1:=reg_gpos.id_plan_grupo_activo;
		-- ELSIF var_vuelta = 2 THEN 	
		-- 	var_num_grupo2:=reg_gpos.num_grupos;
		-- 	var_id_plan2:=reg_gpos.id_plan_grupo_activo;
		-- ELSIF var_vuelta = 3 THEN 	
		-- 	var_num_grupo3:=reg_gpos.num_grupos;
		-- 	var_id_plan3:=reg_gpos.id_plan_grupo_activo;
		-- END IF;	


		IF reg_gpos.semestre = 1 OR reg_gpos.semestre = 2 THEN
			var_num_grupo1:=reg_gpos.num_grupos;
			var_id_plan1:=reg_gpos.id_plan_grupo_activo;
		ELSIF reg_gpos.semestre = 3 OR reg_gpos.semestre = 4 THEN 	
			var_num_grupo2:=reg_gpos.num_grupos;
			var_id_plan2:=reg_gpos.id_plan_grupo_activo;
		ELSIF reg_gpos.semestre = 5 OR reg_gpos.semestre = 6 THEN	
			var_num_grupo3:=reg_gpos.num_grupos;
			var_id_plan3:=reg_gpos.id_plan_grupo_activo;
		END IF;	
		
		var_id_grupo_combinacion_plan:=reg_gpos.id_grupo_combinacion_plan;
		var_vuelta := var_vuelta + 1;
		
   	END LOOP;
	
	/* Meter hrs basico */
	/* Si es tipo 1 (Plantel/Extensión) se muestra Orientacion Educativa, si es tipo 2 (CEM) se muestra Orientación Educativa CEM */
	IF var_tipo_subprograma = 1 THEN
		INSERT INTO temp_planteles_hrs_vacantes(id_componente,semestre,id_detalle_materia,hsm,materia,hrs_vacantes)
		SELECT 
		a.id_componente,a.semestre,a.id_detalle_materia,a.hora_semana_mes,b.materia 
		,(case 
		when a.semestre = '1' OR a.semestre = '2' THEN a.hora_semana_mes * var_num_grupo1
		when a.semestre = '3' OR a.semestre = '4' THEN a.hora_semana_mes * var_num_grupo2 
		when a.semestre = '5' OR a.semestre = '6' THEN a.hora_semana_mes * var_num_grupo3 
		END
		)
		-COALESCE((
		SELECT sum(zb.horas_grupo_base) 
		FROM profesor_asignado_base za
		INNER JOIN profesores_profesor_asignado_base zb ON za.id_profesor_asignado_base = zb.id_profesor_asignado_base
		INNER JOIN grupos_estructura_base zc ON zc.id_grupo_estructura_base = za.id_grupo_estructura_base
		INNER JOIN horas_autorizadas zd ON zd.id_hora_autorizada = zc.id_hora_autorizada
		INNER JOIN grupos ze ON ze.id_grupo = zd.id_grupo
		INNER JOIN periodos zf ON zf.id_periodo = ze.id_periodo
		WHERE 
		zf.id_subprograma = $1 
		and zf.id_estructura_ocupacional = $2
		and za.id_detalle_materia = a.id_detalle_materia
		),0) as horas_vacantes

		FROM detalle_materias a
		INNER JOIN cat_materias b ON b.id_materia = a.id_materia
		INNER JOIN plan_estudios c ON c.id_plan_estudio = a.id_plan_estudio 
		INNER JOIN grupos d ON d.id_grupo_combinacion_plan = var_id_grupo_combinacion_plan
		INNER JOIN periodos e ON e.id_periodo = d.id_periodo
		WHERE 
		(case 
		when a.semestre = '1' OR a.semestre = '2' THEN a.id_plan_estudio = var_id_plan1 
		when a.semestre = '3' OR a.semestre = '4' THEN a.id_plan_estudio = var_id_plan2 
		when a.semestre = '5' OR a.semestre = '6' THEN a.id_plan_estudio = var_id_plan3 
		END
		)

		and (a.id_componente = 1 OR a.id_componente = 6) 
		and a.semestre in(var_sem_1,var_sem_2,var_sem_3)
		and e.id_tipo_periodo = 1 
		and e.id_subprograma = $1 
		and e.id_estructura_ocupacional = $2
		and b.fecha_fin is null
		AND b.materia not ilike '%ORIENTACIÓN EDUCATIVA CEM%'
		ORDER BY a.semestre,a.id_componente desc, a.id_detalle_materia;
	ELSE
		INSERT INTO temp_planteles_hrs_vacantes(id_componente,semestre,id_detalle_materia,hsm,materia,hrs_vacantes)
		SELECT 
		a.id_componente,a.semestre,a.id_detalle_materia,a.hora_semana_mes,b.materia 
		,(case 
		when a.semestre = '1' OR a.semestre = '2' THEN a.hora_semana_mes * var_num_grupo1
		when a.semestre = '3' OR a.semestre = '4' THEN a.hora_semana_mes * var_num_grupo2 
		when a.semestre = '5' OR a.semestre = '6' THEN a.hora_semana_mes * var_num_grupo3 
		END
		)
		-COALESCE((
		SELECT sum(zb.horas_grupo_base) 
		FROM profesor_asignado_base za
		INNER JOIN profesores_profesor_asignado_base zb ON za.id_profesor_asignado_base = zb.id_profesor_asignado_base
		INNER JOIN grupos_estructura_base zc ON zc.id_grupo_estructura_base = za.id_grupo_estructura_base
		INNER JOIN horas_autorizadas zd ON zd.id_hora_autorizada = zc.id_hora_autorizada
		INNER JOIN grupos ze ON ze.id_grupo = zd.id_grupo
		INNER JOIN periodos zf ON zf.id_periodo = ze.id_periodo
		WHERE 
		zf.id_subprograma = $1 
		and zf.id_estructura_ocupacional = $2
		and za.id_detalle_materia = a.id_detalle_materia
		),0) as horas_vacantes

		FROM detalle_materias a
		INNER JOIN cat_materias b ON b.id_materia = a.id_materia
		INNER JOIN plan_estudios c ON c.id_plan_estudio = a.id_plan_estudio 
		INNER JOIN grupos d ON d.id_grupo_combinacion_plan = var_id_grupo_combinacion_plan
		INNER JOIN periodos e ON e.id_periodo = d.id_periodo
		WHERE 
		(case 
		when a.semestre = '1' OR a.semestre = '2' THEN a.id_plan_estudio = var_id_plan1 
		when a.semestre = '3' OR a.semestre = '4' THEN a.id_plan_estudio = var_id_plan2 
		when a.semestre = '5' OR a.semestre = '6' THEN a.id_plan_estudio = var_id_plan3 
		END
		)

		and (a.id_componente = 1 OR a.id_componente = 6) 
		and a.semestre in(var_sem_1,var_sem_2,var_sem_3)
		and e.id_tipo_periodo = 1 
		and e.id_subprograma = $1 
		and e.id_estructura_ocupacional = $2
		and b.fecha_fin is null
		AND (b.materia != 'ORIENTACIÓN EDUCATIVA I' AND b.materia != 'ORIENTACIÓN EDUCATIVA II' AND b.materia != 'ORIENTACIÓN EDUCATIVA III' AND b.materia != 'ORIENTACIÓN EDUCATIVA IV' AND b.materia != 'ORIENTACIÓN EDUCATIVA V' AND b.materia != 'ORIENTACIÓN EDUCATIVA VI')
		ORDER BY a.semestre,a.id_componente desc, a.id_detalle_materia;
	END IF;
	
	/* Meter hrs_optativas */
	INSERT INTO temp_planteles_hrs_vacantes(id_componente,semestre,id_detalle_materia,hsm,materia,hrs_vacantes)
	(
		SELECT
		(CAST (2 as int))as id_componente,i.semestre,i.id_detalle_materia,sum(i.hora_semana_mes) as hora_semana_mes
		,j.materia

		,(sum(i.hora_semana_mes)-(
		SELECT COALESCE(sum(xb.horas_grupo_optativas),0) 
		FROM profesor_asignado_optativas xa
		INNER JOIN profesores_profesor_asignado_optativas xb ON xa.id_profesor_asignado_optativa = xb.id_profesor_asignado_optativa
		INNER JOIN plantilla_base_docente_rh xc ON xc.id_plantilla_base_docente_rh = xb.id_plantilla_base_docente_rh
		WHERE xc.id_subprograma = $1 AND
		xc.id_estructura_ocupacional = $2 AND
		xa.id_detalle_materia = i.id_detalle_materia
		)) as hrs_vacantes
		FROM grupos_optativas a
		INNER JOIN horas_autorizadas b ON a.id_hora_autorizada = b.id_hora_autorizada
		INNER JOIN grupos c ON c.id_grupo = b.id_grupo
		INNER JOIN periodos d ON d.id_periodo = c.id_periodo
		INNER JOIN grupos_combinaciones_planes e ON e.id_grupo_combinacion_plan = c.id_grupo_combinacion_plan
		LEFT JOIN grupos_optativas_formacion f ON f.id_grupo_optativa = a.id_grupo_optativa

		LEFT JOIN cat_formacion_propedeutica g ON f.id_formacion_propedeutica = g.id_formacion_propedeutica 
		LEFT JOIN materias_componente_propedeutico h ON g.id_formacion_propedeutica = h.id_formacion_propedeutica
		LEFT JOIN detalle_materias i ON h.id_detalle_materia = i.id_detalle_materia and i.semestre = CAST(substring(nombre_grupo_optativas from 1 for 1)as int)
		LEFT JOIN cat_materias j ON i.id_materia = j.id_materia

		WHERE 
			d.id_subprograma = $1 
			AND d.id_estructura_ocupacional = $2
			AND d.id_tipo_periodo = 1
			AND 
			(CASE WHEN(i.semestre = 1 OR i.semestre = 2) THEN
			i.id_plan_estudio in(id_plan_grupo_activo1)
			WHEN (i.semestre = 3 OR i.semestre = 4) THEN
			i.id_plan_estudio in(id_plan_grupo_activo2)
			WHEN (i.semestre = 5 OR i.semestre = 6) THEN
			i.id_plan_estudio in(id_plan_grupo_activo3)
			END
			)	
		GROUP BY i.id_detalle_materia,j.materia
		ORDER BY j.materia
	);
	
	/* Meter hrs vacantes Capacitacion */
	INSERT INTO temp_planteles_hrs_vacantes(id_componente,semestre,id_detalle_materia,hsm,materia,hrs_vacantes)
	(
		SELECT
		(CAST (3 as int))as id_componente,i.semestre,i.id_detalle_materia,
		sum(DISTINCT i.hora_semana_mes) as hora_semana_mes
		,j.materia
		,(sum(i.hora_semana_mes)-(
		SELECT COALESCE(sum(xb.horas_grupo_capacitacion),0) 
		FROM profesor_asignado_capacitacion xa
		INNER JOIN profesores_profesor_asignado_capacitacion xb ON xa.id_profesor_asignado_capacitacion = xb.id_profesor_asignado_capacitacion
		INNER JOIN plantilla_base_docente_rh xc ON xc.id_plantilla_base_docente_rh = xb.id_plantilla_base_docente_rh
		WHERE xc.id_subprograma = $1 AND
		xc.id_estructura_ocupacional = $2 AND
		xa.id_detalle_materia = i.id_detalle_materia
		)) as hrs_vacantes
		FROM grupos_capacitacion a
		INNER JOIN horas_autorizadas b ON a.id_hora_autorizada = b.id_hora_autorizada
		INNER JOIN grupos c ON c.id_grupo = b.id_grupo
		INNER JOIN periodos d ON d.id_periodo = c.id_periodo
		INNER JOIN grupos_combinaciones_planes e ON e.id_grupo_combinacion_plan = c.id_grupo_combinacion_plan

		LEFT JOIN cat_formacion_trabajo g ON a.id_formacion_trabajo = g.id_formacion_trabajo 
		LEFT JOIN materias_componente_trabajo h ON g.id_formacion_trabajo = h.id_formacion_trabajo
		LEFT JOIN detalle_materias i ON h.id_detalle_materia = i.id_detalle_materia and i.semestre = CAST(substring(nombre_grupo_capacitacion from 1 for 1)as int)
		LEFT JOIN cat_materias j ON i.id_materia = j.id_materia

		WHERE 
			d.id_subprograma = $1 
			AND d.id_estructura_ocupacional = $2
			AND d.id_tipo_periodo = 1
			AND 
			(CASE WHEN(i.semestre = 1 OR i.semestre = 2) THEN
			i.id_plan_estudio in(id_plan_grupo_activo1)
			WHEN (i.semestre = 3 OR i.semestre = 4) THEN
			i.id_plan_estudio in(id_plan_grupo_activo2)
			WHEN (i.semestre = 5 OR i.semestre = 6) THEN
			i.id_plan_estudio in(id_plan_grupo_activo3)
			END
			)	
		GROUP BY i.id_detalle_materia,j.materia
		ORDER BY j.materia	
	);
	
	/* Meter hrs vacantes Paraescolares */
	INSERT INTO temp_planteles_hrs_vacantes(id_componente,semestre,id_detalle_materia,hsm,materia,hrs_vacantes)
	(
		SELECT 
		(4)as id_componente,CAST(substring(a.nombre FROM 1 FOR 1) as smallint)as semestre,(1123) as id_detalle_materia
		,(3) as hsm,('Paraescolares') as materia,(3 - COALESCE(sum(horas_grupo_paraescolares),0))as hrs_vacantes 

		FROM grupos_paraescolares a
		INNER JOIN horas_autorizadas b ON b.id_hora_autorizada = a.id_hora_autorizada
		INNER JOIN grupos d ON d.id_grupo = b.id_grupo
		INNER JOIN periodos e ON e.id_periodo = d.id_periodo

		LEFT JOIN profesor_asignado_paraescolares f ON f.id_grupo_paraescolares = a.id_grupo_paraescolar
		LEFT JOIN profesores_profesor_asignado_paraescolares g ON g.id_profesor_asignado_paraescolares = f.id_profesor_asignado_paraescolares

		WHERE 
			e.id_estructura_ocupacional = $2 
			AND e.id_subprograma = $1
			AND e.id_tipo_periodo = 1
		GROUP BY a.nombre
		ORDER BY a.nombre
	);
	
	/* Actualiza tipo de alta */
	UPDATE temp_planteles_hrs_vacantes SET alta = 12;
	/* Borrar los que no tienen hrs vacantes */
	DELETE FROM temp_planteles_hrs_vacantes WHERE temp_planteles_hrs_vacantes.hrs_vacantes = 0;
	
	/* retorno la query */
	RETURN QUERY SELECT 
		t.semestre,t.id_componente,t.id_detalle_materia,
		t.materia,t.alta,t.hsm,SUM(t.hrs_vacantes),t.hrs_vacantes_subp
	FROM temp_planteles_hrs_vacantes t 
	GROUP BY t.semestre,t.id_componente,t.id_detalle_materia,
		t.materia,t.alta,t.hsm,t.hrs_vacantes_subp
	ORDER BY t.semestre,t.id_componente;
	
	/* Al retornar se destruye la tambla temporal */
	DROP TABLE temp_planteles_hrs_vacantes;	

END; 