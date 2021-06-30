CREATE OR REPLACE FUNCTION planteles_reporte_fort_desc_subp_periodo_detalle(id_estructura_oc int, proceso int)
RETURNS TABLE(
	id_subprograma int,
	nombre_subprograma varchar,
	clave_subprograma varchar,
	coordinacion int,
	filiacion varchar,
	nombre varchar,
	hrs_fort smallint,
	hrs_desc smallint,
	id_estructura int
)

AS $$

BEGIN
	/*
		Tabla temp con la estructura deseada, solo se creara una ves
	
	CREATE TABLE temp_planteles_reporte_fort_desc_detalle(
		id_subprograma int,
		nombre_subprograma varchar,
		clave_subprograma varchar,
		coordinacion int,
		filiacion varchar,
		nombre varchar,
		hrs_fort smallint,
		hrs_desc smallint,
		id_estructura int
	);
	*/
	
	/*
	proceso = 1 solo se hace consulta
	proceso = 2 se borra data del periodo y se inserta y despues regresa la consulta
	*/
	
	/* Se borra la data y se inserta de nuevo */
	IF $2 = 2 THEN
		
		DELETE FROM temp_planteles_reporte_fort_desc_detalle t WHERE t.id_estructura = $1;
		
		INSERT INTO temp_planteles_reporte_fort_desc_detalle(id_subprograma,nombre_subprograma,clave_subprograma,
		coordinacion,filiacion,nombre,hrs_fort,hrs_desc,id_estructura)
		SELECT a.id_subprograma,a.nombre_subprograma,a.clave_subprograma,a.coordinacion,
		b.filiacion,(c.paterno||' '||c.materno||' '||c.nombre)as nombre,b.hrs_fort_final,b.hrs_desc,$1
		FROM subprogramas a
		LEFT JOIN planteles_dom05_fort_desc(a.id_subprograma,$1) b ON a.id_subprograma = a.id_subprograma
		LEFT JOIN empleados c ON c.filiacion = b.filiacion
		WHERE a.id_programa = 1 AND a.fecha_fin is null
		ORDER BY a.nombre_subprograma;
		
	END IF;
	
	RETURN QUERY SELECT * 
	FROM temp_planteles_reporte_fort_desc_detalle t 
	WHERE t.id_estructura = $1 
	ORDER BY t.nombre_subprograma,t.nombre;
	
END; $$
LANGUAGE 'plpgsql';

select filiacion,nombre,hrs_fort,hrs_desc
FROM planteles_reporte_fort_desc_subp_periodo_detalle(26,1)
WHERE (hrs_fort > 0 OR hrs_desc > 0)
AND id_subprograma = 36
ORDER BY nombre_subprograma



SELECT a.id_subprograma,a.nombre_subprograma,a.clave_subprograma,a.coordinacion,
b.filiacion,(c.paterno||' '||c.materno||' '||c.nombre)as nombre,b.hrs_fort_final,b.hrs_desc
FROM subprogramas a
LEFT JOIN planteles_dom05_fort_desc(a.id_subprograma,26) b ON a.id_subprograma = a.id_subprograma
LEFT JOIN empleados c ON c.filiacion = b.filiacion
WHERE a.id_programa = 1 AND a.fecha_fin is null
AND a.id_subprograma = 36
ORDER BY a.nombre_subprograma;


