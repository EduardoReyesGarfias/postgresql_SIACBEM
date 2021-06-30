CREATE OR REPLACE FUNCTION temp_reporte_docentes_evaluados(proceso int)
RETURNS TABLE(
	docente varchar,
	curp varchar,
	evaluacion varchar,
	resultado varchar,
	plantel varchar,
	nombramiento_base varchar,
	tiempo_fijo integer
)

AS $$

BEGIN
	/*
	CREATE TABLE temp_report_doc_evaluados(
		docente varchar,
		curp varchar,
		evaluacion varchar,
		resultado varchar,
		plantel varchar,
		nombramiento_base varchar,
		tiempo_fijo integer,
		fecha_sistema varchar
	);
	
	DROP TABLE temp_report_doc_evaluados
	
	COPY temp_report_doc_evaluados(docente,curp,evaluacion,resultado,plantel,nombramiento_base,tiempo_fijo,fecha_sistema) 
	FROM '/var/www/html/siacbem/SIACBEM/Timbrados2/docentes_evaluados.csv' 
	DELIMITER ',';
	
	*/
	
	IF $1 = 2 THEN
		/* borro data de la tabla */
		DELETE FROM temp_report_doc_evaluados;
		
		/* cargo data a la tabla desde un csv */
		COPY temp_report_doc_evaluados(docente,curp,evaluacion,resultado,plantel,nombramiento_base,tiempo_fijo,fecha_sistema) 
		FROM '/var/www/html/siacbem/SIACBEM/Timbrados2/docentes_evaluados.csv' 
		DELIMITER ',';
		
		/* Actualizo nombramiento base desde Asignacion de profesores */
		UPDATE temp_report_doc_evaluados t SET nombramiento_base = 
		(
			SELECT 
			STRING_AGG (d.categoria_padre||'/'||c.num_plz||'/'||c.hrs_categoria,',') 
			FROM empleados b
			LEFT JOIN plantilla_base_docente_rh c ON c.id_empleado = b.id_empleado
			LEFT JOIN cat_categorias_padre d ON d.id_cat_categoria_padre = c.id_cat_categoria_padre
			WHERE 
			b.curp = t.curp AND
			c.revision_rh = true AND
			c.id_estructura_ocupacional = (
				SELECT id_estructura_ocupacional 
				FROM cat_estructuras_ocupacionales
				ORDER BY periodo DESC
				LIMIT 1
			)
		),
		tiempo_fijo = (
			temp_reporte_docentes_evaludados_clave(t.curp,883,'12')
		);
		
		/* Actualizo plantel a los que no tienen */
		UPDATE temp_report_doc_evaluados t SET plantel = (
			CASE WHEN t.plantel = '' THEN
				(SELECT STRING_AGG(DISTINCT d.nombre_subprograma,',')
				FROM nominas_sispagos a
				INNER JOIN pagos_sispagos b ON a.id_nomina = b.id_nomina
				INNER JOIN empleados c ON c.id_empleado = b.id_empleado
				INNER JOIN subprogramas d ON d.id_subprograma = b.id_subprograma
				WHERE a.id_nomina = 883
				AND c.curp = t.curp
				AND clave_tipo_nombramiento in('14','12'))
			ELSE
				t.plantel
			END
		);
	
	END IF;
	
	RETURN QUERY SELECT t.docente,t.curp,t.evaluacion
	,t.resultado,t.plantel,t.nombramiento_base,t.tiempo_fijo
	FROM temp_report_doc_evaluados t
	ORDER BY evaluacion,docente;

END; $$
LANGUAGE 'plpgsql';

SELECT * FROM temp_reporte_docentes_evaluados(1);



CREATE OR REPLACE FUNCTION temp_reporte_docentes_evaludados_clave(curp varchar,id_nomina int,clave varchar)
RETURNS integer
AS $$

DECLARE
	
	var_hrs integer;
	reg_hrs RECORD;
	cur_hrs CURSOR FOR SELECT categoria,numero_plz,sum(numero_hr) as numero_hr
			FROM nominas_sispagos a
			INNER JOIN pagos_sispagos b ON a.id_nomina = b.id_nomina
			INNER JOIN empleados c ON c.id_empleado = b.id_empleado
			WHERE a.id_nomina = $2
			AND c.curp = $1
			AND clave_tipo_nombramiento = $3
			GROUP BY categoria,numero_plz;

BEGIN
	var_hrs:=0;
	FOR reg_hrs IN cur_hrs LOOP
		var_hrs:= var_hrs + reg_hrs.numero_hr;
	END LOOP;
	
	return var_hrs;

END; $$
LANGUAGE 'plpgsql';
