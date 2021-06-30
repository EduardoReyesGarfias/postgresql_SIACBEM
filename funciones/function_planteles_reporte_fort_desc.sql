CREATE OR REPLACE FUNCTION planteles_reporte_fort_desc_subp_periodo(id_estructura_oc int, proceso int)
RETURNS TABLE(
	id_subprograma int,
	nombre_subprograma varchar,
	clave_subprograma varchar,
	coordinacion int,
	id_estructura int,
	fort_desc varchar
)

AS $$

BEGIN
	/*
		Tabla temp con la estructura deseada, solo se creara una ves
	
	CREATE TABLE temp_planteles_reporte_fort_desc(
		id_subprograma int,
		nombre_subprograma varchar,
		clave_subprograma varchar,
		coordinacion int,
		id_estructura int,
		fort_desc varchar
	);
	*/
	
	/*
	proceso = 1 solo se hace consulta
	proceso = 2 se borra data del periodo y se inserta y despues regresa la consulta
	*/
	
	/* Se borra la data y se inserta de nuevo */
	IF $2 = 2 THEN
		
		DELETE FROM temp_planteles_reporte_fort_desc t WHERE t.id_estructura = $1;
		
		INSERT INTO temp_planteles_reporte_fort_desc(id_subprograma,nombre_subprograma,
		clave_subprograma,coordinacion,id_estructura,fort_desc)
		SELECT a.id_subprograma,a.nombre_subprograma,a.clave_subprograma,a.coordinacion,$1,
		(
			SELECT sum(hrs_fort_final)||','||sum(hrs_desc) as hrs_desc
			FROM planteles_dom05_fort_desc(a.id_subprograma,$1)
		)as fortdesc
		FROM subprogramas a
		WHERE a.id_programa = 1 AND a.fecha_fin is null
		ORDER BY a.nombre_subprograma;
		
	END IF;
	
	RETURN QUERY SELECT * 
	FROM temp_planteles_reporte_fort_desc t 
	WHERE t.id_estructura = $1 
	ORDER BY 	t.nombre_subprograma;
	
END; $$
LANGUAGE 'plpgsql';

select * from planteles_reporte_fort_desc_subp_periodo(26,1)

