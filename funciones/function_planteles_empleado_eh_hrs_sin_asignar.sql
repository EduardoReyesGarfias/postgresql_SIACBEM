FUNCTION planteles_empleado_eh_

DECLARE
	
	record_tf RECORD;
	cursor_tf cursor for(
		SELECT *
		FROM view_horas_asignadas_empleado_tf_1 vhaetf
		WHERE vhaetf.id_empleado = $1
		AND vhaetf.id_estructura_ocupacional = $2
		-- AND vhaetf.categoria_padre ilike 'EH4%'
	);
	
	record_tabla RECORD;
	cursor_tabla cursor for (
		SELECT * 
		FROM temp_empleado_eh_hrs_sin_asignar
	);
	
	tope_hrs_asignar int;
	hrs_disponibles int;
	bandera_asignar smallint;

BEGIN
	-- creo tabla temporal para almacenar los datos
	CREATE TEMP TABLE temp_empleado_eh_hrs_sin_asignar(
		id_plantilla_base_docente_rh int,
		id_cat_categoria_padre int,
		categoria_padre character varying,
		num_plz character(3),
		hrs_categoria smallint,
		hrs_asignadas int,
		hrs_licencia int,
		puede_asignar smallint
	);
	

	-- Agrego las claves que tenga el empleado	
	INSERT INTO temp_empleado_eh_hrs_sin_asignar(id_plantilla_base_docente_rh,id_cat_categoria_padre,categoria_padre,num_plz,hrs_categoria,hrs_asignadas, hrs_licencia)
	SELECT
	vhae.id_plantilla_base_docente_rh,
	vhae.id_cat_categoria_padre,
	vhae.categoria_padre,
	vhae.num_plz,
	vhae.hrs_categoria,
	SUM(vhae.horas_asignadas)
	,(
		SELECT hrs_licencia
		FROM tramites_licencias_plazas_docente licencia_docente
		INNER JOIN tramites_licencias licencia ON licencia.id_tramite_licencia = licencia_docente.id_tramite_licencia
		WHERE licencia.id_cat_tramite_status = 3
		AND licencia_docente.id_plantilla_base_docente_rh = vhae.id_plantilla_base_docente_rh
	) as hrs_liencia
	FROM view_horas_asignadas_empleado vhae
	WHERE vhae.id_empleado = $1
	AND vhae.id_estructura_ocupacional = $2
	-- AND vhae.categoria_padre ilike 'EH4%'
	GROUP BY vhae.id_plantilla_base_docente_rh, vhae.id_cat_categoria_padre,vhae.categoria_padre,vhae.num_plz, vhae.hrs_categoria
	ORDER BY categoria_padre, num_plz, hrs_categoria;	
	
	
	-- sumo las horas que tenga de EH en tiempo fijo
	FOR record_tf IN cursor_tf LOOP
		
		UPDATE temp_empleado_eh_hrs_sin_asignar
		SET hrs_asignadas = temp_empleado_eh_hrs_sin_asignar.hrs_asignadas + record_tf.horas_grupo
		WHERE temp_empleado_eh_hrs_sin_asignar.categoria_padre = record_tf.categoria_padre;
	
	END LOOP;
	

	-- Reviso si le quedan horas para asignar de cada clave EH que tenga el empleado
	-- Reviso si le quedan horas para asignar de cada una de las claves del empleado
	FOR record_tabla IN cursor_tabla LOOP
		
		tope_hrs_asignar:= 0;
		hrs_disponibles:= 0;
		bandera_asignar:= 0;
		
		IF record_tabla.hrs_categoria = 40 OR record_tabla.hrs_categoria >=30 THEN
			tope_hrs_asignar:= 30;
		ELSE 
			tope_hrs_asignar:= record_tabla.hrs_categoria;
		END IF;
		

		-- validar si puede o no asignar
		/*
			Horas base - horas licencia = 0
				SI: entonces no puede asignar
				NO: 
					Horas Disponibles = (Horas base - Horas licencia) - (Horas asignadas - Horas licencia) 
		*/
		IF( (tope_hrs_asignar - record_tabla.hrs_licencia) = 0 ) THEN
			puede_asignar:= 0;
		ELSE
			hrs_disponibles:= (tope_hrs_asignar - record_tabla.hrs_licencia) - (record_tabla.hrs_asignadas - record_tabla.hrs_licencia);
		END IF;		
		
		IF( hrs_disponibles > 0 ) THEN

			IF hrs_disponibles >= $3 THEN
				bandera_asignar:= 1;
			ELSE
				IF hrs_disponibles > 0 THEN
					bandera_asignar:= 2;
				ELSE	
					bandera_asignar:= 0;
				END IF;	
			END IF;	

		ELSE
			bandera_asignar:= 0;
		END IF;	
		
		/*
		hrs_disponibles:= tope_hrs_asignar - record_tabla.hrs_asignadas;

		IF hrs_disponibles >= $3 THEN
			bandera_asignar:= 1;
		ELSE
			IF hrs_disponibles > 0 THEN
				bandera_asignar:= 2;
			ELSE	
				bandera_asignar:= 0;
			END IF;	
		END IF;	
		*/
		
		UPDATE temp_empleado_eh_hrs_sin_asignar
		SET puede_asignar = bandera_asignar
		WHERE temp_empleado_eh_hrs_sin_asignar.categoria_padre = record_tabla.categoria_padre;
		
	
	END LOOP;
	
	
	RETURN QUERY
		SELECT 
			temp_empleado_eh_hrs_sin_asignar.id_plantilla_base_docente_rh,
			temp_empleado_eh_hrs_sin_asignar.id_cat_categoria_padre,
			temp_empleado_eh_hrs_sin_asignar.categoria_padre,
			temp_empleado_eh_hrs_sin_asignar.num_plz,
			temp_empleado_eh_hrs_sin_asignar.hrs_categoria,
			temp_empleado_eh_hrs_sin_asignar.hrs_asignadas,
			temp_empleado_eh_hrs_sin_asignar.puede_asignar 
		FROM temp_empleado_eh_hrs_sin_asignar ORDER BY categoria_padre DESC;
	
	DROP table temp_empleado_eh_hrs_sin_asignar; 

END; 