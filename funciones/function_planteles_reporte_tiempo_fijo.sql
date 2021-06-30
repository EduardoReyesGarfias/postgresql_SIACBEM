CREATE OR REPLACE FUNCTION planteles_reporte_tiempo_fijo_subp_periodo(id_estructura_oc int, proceso int)
RETURNS TABLE(
	id_subprograma int,
	nombre_subprograma varchar,
	clave_subprograma varchar,
	coordinacion int,
	semestre smallint,
	id_componente smallint,
	materia varchar,
	hsm smallint,
	hsm_vacantes bigint,
	id_estructura int
)

AS $$

BEGIN
		/*
		Tabla temp con la estructura deseada, solo se creara una ves
	
		CREATE TABLE temp_planteles_reporte_tiempo_fijo(
			id_subprograma int,
			nombre_subprograma varchar,
			clave_subprograma varchar,
			coordinacion int,
			semestre smallint,
			id_componente smallint,
			materia varchar,
			hsm smallint,
			hsm_vacantes bigint,
			id_estructura int
		);
		*/
		
		/* Se borra la data y se inserta de nuevo */
		IF $2 = 2 THEN
			DELETE FROM temp_planteles_reporte_tiempo_fijo t WHERE t.id_estructura = $1;
	
			INSERT INTO temp_planteles_reporte_tiempo_fijo(id_subprograma,nombre_subprograma,clave_subprograma,
			coordinacion,semestre,id_componente,materia,hsm,hsm_vacantes,id_estructura)
			SELECT a.id_subprograma,a.nombre_subprograma,a.clave_subprograma,a.coordinacion,
			b.semestre,b.id_componente,b.materia,b.hsm,b.hrs_vacantes,$1
			FROM subprogramas a
			LEFT JOIN planteles_hrs_vacantes(a.id_subprograma,$1) b ON a.id_subprograma = a.id_subprograma 
			WHERE a.id_programa = 1 AND a.fecha_fin is null
			ORDER BY a.nombre_subprograma;
		
		END IF;
	
		RETURN QUERY SELECT * 
		FROM temp_planteles_reporte_tiempo_fijo t 
		WHERE t.id_estructura = $1 
		ORDER BY t.nombre_subprograma;



END; $$
LANGUAGE 'plpgsql';

SELECT id_subprograma,nombre_subprograma,clave_subprograma,coordinacion,sum(hsm_vacantes) as hsm_vacantes,id_estructura
from planteles_reporte_tiempo_fijo_subp_periodo(26,1)
GROUP BY id_subprograma,nombre_subprograma,clave_subprograma,coordinacion,id_estructura
ORDER BY nombre_subprograma