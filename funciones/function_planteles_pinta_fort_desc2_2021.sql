CREATE OR REPLACE FUNCTION planteles_pinta_fort_desc2(_filiacion text, _id_subprograma int, _id_estructura int)
RETURNS integer
AS $$
DECLARE

	array_hrs_diferencia  INTEGER[]  DEFAULT  ARRAY[]::INTEGER[];
	array_subprograma_diferencia  INTEGER[]  DEFAULT  ARRAY[]::INTEGER[];
	status integer;
	sumatoria_dif integer;
	subprograma_mayor_carga integer;
	hrs_mayor_carga integer;
	hrs_mayor_dif integer;
	subprograma_mayor_dif integer;

	reg_asignaciones RECORD;
	cur_asignaciones CURSOR FOR (
		SELECT 
			id_subprograma, 
			hrs_categoria, 
			sum(horas_usadas) as hrs_usadas,
			(hrs_categoria -  sum(horas_usadas)) as diferencia
		FROM view_planteles_asignacion_eb
		WHERE 
			id_estructura_ocupacional = _id_estructura
			AND filiacion = _filiacion
		GROUP BY 
			id_subprograma,hrs_categoria
		ORDER BY 
			hrs_categoria,hrs_usadas
	);



BEGIN
	
	status := 0;
	sumatoria_dif := 0;
	subprograma_mayor_carga := 0;
	hrs_mayor_carga := 0;
	hrs_mayor_dif := 0; 
	subprograma_mayor_dif := 0; 

	/**
	* Recorro los subprogramas de la persona
	* Saco diferencia entre la shrs base vs hrs asignadas
	*/
	FOR reg_asignaciones IN cur_asignaciones LOOP

		-- Guardar mayor carga horaria
		IF hrs_mayor_carga < reg_asignaciones.hrs_categoria THEN
			hrs_mayor_carga := reg_asignaciones.hrs_categoria;
			subprograma_mayor_carga := reg_asignaciones.id_subprograma;
		END IF; 

		-- Guardar los valores de diferencia para caso de desempate
		SELECT INTO array_subprograma_diferencia array_append(array_subprograma_diferencia, reg_asignaciones.id_subprograma::integer);
		SELECT INTO array_hrs_diferencia array_append(array_hrs_diferencia, reg_asignaciones.diferencia::integer);

		sumatoria_dif := sumatoria_dif + reg_asignaciones.diferencia;

	END LOOP;

	/**
	* Si la diferencia es > 10
	* Caso: Anayeli Castillo - id_estructura = 30
	* 	- Plantel La Mira (EH4829/20 hrs)
	* 	- CEM lazaro Cardenas (EH4829/20 hrs)
	* 	Como no tiene mayor carga horaria en un subprograma se ve en cual la diferencia es mayor.
	* Si la diferencia es < 10
	* 	- Se ve si el subprograma consultado es el de mayor carga horaria
	*/
	IF (sumatoria_dif > 10) THEN

		FOR i IN array_lower(array_hrs_diferencia, 1) .. array_upper(array_hrs_diferencia, 1) LOOP
		  -- RAISE NOTICE 'another_func(%,%)',arr[i][1], arr[i][2];

		  IF hrs_mayor_dif < array_hrs_diferencia[i] THEN

		  	hrs_mayor_dif:= array_hrs_diferencia[i];
		  	subprograma_mayor_dif:= array_subprograma_diferencia[i];

		  END IF;

		END LOOP;

		-- Indicar si al subprograma consultado si se le pone el fortalecimiento o no
		IF subprograma_mayor_dif = _id_subprograma THEN
			status := 1;
		ELSE
			status := 3;
		END IF;


	ELSE

		-- Ver si el subprograma con mayor carga horaria es el consultado
		IF subprograma_mayor_carga = _id_subprograma THEN
			status := 1;
		ELSE
			status := 0;	
		END IF;

	END IF;

	RETURN status;


END; $$ 
LANGUAGE 'plpgsql';