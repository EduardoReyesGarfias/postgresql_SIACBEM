-- Claves EH que tenga
SELECT 
c.id_plantilla_base_docente_rh,d.id_cat_categoria_padre,d.categoria_padre,c.hrs_categoria 
FROM  plantilla_base_docente_rh c 
INNER JOIN cat_categorias_padre d ON d.id_cat_categoria_padre = c.id_cat_categoria_padre
WHERE c.id_estructura_ocupacional = 29
AND c.id_empleado = 5181
AND c.revision_rh is true
AND d.categoria_padre ilike 'EH4%'
ORDER BY c.hrs_categoria

-- Ver las asignadas en base de las EH
SELECT 
id_plantilla_base_docente_rh,id_cat_categoria_padre,categoria_padre,num_plz,hrs_categoria,COALESCE(sum(horas_asignadas),0)
FROM view_horas_asignadas_empleado
WHERE id_empleado = 5181
AND id_estructura_ocupacional = 29
AND id_plantilla_base_docente_rh in(68938)
GROUP BY id_plantilla_base_docente_rh,id_cat_categoria_padre,categoria_padre,num_plz,hrs_categoria
--AND licencia is false



CREATE OR REPLACE FUNCTION planteles_empleado_eh_hrs_sin_asignar(id_empleado int, id_estructura int, hrs_asignar int)
RETURNS TABLE(
	id_plantilla_base_docente_rh int,
	id_cat_categoria_padre int,
	categoria_padre character varying,
	num_plz character(3),
	hrs_categoria smallint,
	hrs_asignadas int,
	puede_asignar smallint
)
AS $$
DECLARE
	
	record_tf RECORD;
	cursor_tf cursor for(
		SELECT *
		FROM view_horas_asignadas_empleado_tf vhaetf
		WHERE vhaetf.id_empleado = $1
		AND vhaetf.id_estructura_ocupacional = $2
		AND vhaetf.categoria_padre = 'EH4%'
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
		puede_asignar smallint
	);
	

	-- Agrego las claves EH que tenga el empleado	
	INSERT INTO temp_empleado_eh_hrs_sin_asignar(id_cat_categoria_padre,categoria_padre,num_plz,hrs_categoria,hrs_asignadas)
	SELECT 
	vhae.id_cat_categoria_padre,
	vhae.categoria_padre,
	vhae.num_plz,
	SUM(DISTINCT vhae.hrs_categoria) AS hrs_categoria,
	COALESCE(sum(vhae.horas_asignadas),0)
	FROM view_horas_asignadas_empleado vhae
	WHERE vhae.id_empleado = $1
	AND vhae.id_estructura_ocupacional = $2
	AND vhae.categoria_padre ilike 'EH4%'
	GROUP BY vhae.id_cat_categoria_padre,vhae.categoria_padre,vhae.num_plz;	
	
	
	-- sumo las horas que tenga de EH en tiempo fijo
	FOR record_tf IN cursor_tf LOOP
		
		UPDATE temp_empleado_eh_hrs_sin_asignar
		SET hrs_asignadas = hrs_asignadas + record_tf.horas_grupo
		WHERE categoria_padre = record_tf.categoria_padre;
	
	END LOOP;
	

	-- Reviso si le quedan horas para asignar de cada clave EH que tenga el empleado
	FOR record_tabla IN cursor_tabla LOOP
		
		tope_hrs_asignar:= 0;
		hrs_disponibles:= 0;
		bandera_asignar:= 0;
		
		IF record_tabla.hrs_categoria = 40 OR record_tabla.hrs_categoria >=30 THEN
			tope_hrs_asignar:= 30;
		ELSE 
			tope_hrs_asignar:= record_tabla.hrs_categoria;
		END IF;
		
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
		
		UPDATE temp_empleado_eh_hrs_sin_asignar
		SET puede_asignar = bandera_asignar
		WHERE temp_empleado_eh_hrs_sin_asignar.categoria_padre = record_tabla.categoria_padre;
		
	
	END LOOP;
	
	
	RETURN QUERY
		SELECT * FROM temp_empleado_eh_hrs_sin_asignar;
	
	DROP table temp_empleado_eh_hrs_sin_asignar; 

END; $$ 
LANGUAGE 'plpgsql';

-- sosa gaspar jose flavio
SELECT *
FROM planteles_empleado_eh_hrs_sin_asignar(5181,27,4)
WHERE puede_asignar = 1




