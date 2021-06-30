CREATE OR REPLACE FUNCTION reporte_ordinaria_marca_filiacion(rango int[], codigos text[], filiacion_desde text[][])
RETURNS TABLE(
	id_temp integer,
	filiacion character varying,
	desde_plz integer,
	status boolean,
	donde text
)
AS $$
DECLARE
	
	reg_temp RECORD;
	cur_temp CURSOR FOR (
		SELECT a.id_temp, a.filiacion, a.desde_plz, a.status, a.donde  
		FROM nomina_ordinaria_marca_filiacion a
	);

	var_donde text;
	var_status boolean;

BEGIN
	
	/*
	Proposito de la funcion

	MARCAR LOS QUE COBRARON EN CODIGO 60 DESPUES DE LA QUINCENA  MARCADA EN CADA REGISTRO 
	EN CUALQUIER QUINCENA ORDINARIA DEL 202001 AL 202024
	

	En mis palabras: Buscar si se le pago codigo 60 a partir de la qna marcada en los rangos indicados
	* Nota: solo en nóminas ORDINARIAS

		Ejemplo

		AAMD891003000 a partir de 202004 buscar en el rango 202001 AL 202024

		Entonces buscaria si AAMD891003000 se le pago codigo 60 de la 
		qna 202004 a la 202024 unicamente en ORDINARIAS

	*Nota: tomar en cuenta que hay que ver si hay devoluciones o cancelaciones, en ese caso no se deberia de mostrar	
	*/	


	-- Creo tabla temporal para acomodar información
	CREATE TEMP TABLE nomina_ordinaria_marca_filiacion(
		id_temp SERIAL PRIMARY KEY,
		filiacion character varying,
		desde_plz integer,
		status boolean,
		donde text
	);	

	-- Inserto informacion en tabla temporal
	FOR i IN array_lower(filiacion_desde,1) .. array_upper(filiacion_desde,1) LOOP
		INSERT INTO nomina_ordinaria_marca_filiacion(filiacion,desde_plz) 
		VALUES(filiacion_desde[i][1], CAST(filiacion_desde[i][2] as integer));
	END LOOP;

	-- Recorro la tabla temporal para ver si cumple o no con la condicion
	FOR reg_temp IN cur_temp LOOP

		var_donde:= '';
		var_status:= false;
		
		SELECT INTO var_donde, var_status
		string_agg(CAST(a.qnapago as character varying(6)),',' ORDER BY a.qnapago ASC)
		,(
			CASE WHEN length(string_agg(CAST(a.qnapago as character varying(6)),',')) > 0 THEN
				true 
			ELSE
				false
		    END
		)
		FROM nominas_sispagos a
		INNER JOIN pagos_sispagos b ON b.id_nomina = a.id_nomina
		INNER JOIN percepciones_deducciones_sispagos c ON c.id_pago = b.id_pago 
		LEFT JOIN  devoluciones_pagos_sispagos d ON d.id_pago_ordinario = b.id_pago
		LEFT JOIN pagos_sispagos_cancelados e ON e.id_pago = b.id_pago
		WHERE a.qnapago between reg_temp.desde_plz AND rango[2]
		AND a.id_tipo_nomina = 1 
		AND a.descripcion_nomina ilike '%Ordinaria%'
		AND b.filiacion = reg_temp.filiacion
		AND c.cod_pd =  ANY(codigos)
		AND (d.id_pago_ordinario IS NULL AND e.id_pago_cancelado IS NULL); -- no esta en devoluciones o cancelados

		-- Actualizo la tabla temporal con los valore obtenidos
		UPDATE nomina_ordinaria_marca_filiacion a
		SET donde = var_donde, status = var_status
		WHERE a.id_temp = reg_temp.id_temp;


	END LOOP;


	-- Regreso la tabla como quedo al final
	RETURN QUERY 
	SELECT a.id_temp, a.filiacion, a.desde_plz, a.status, a.donde 
	FROM nomina_ordinaria_marca_filiacion a;

	-- Despues de retornar la repsuesta se borra la tabla temporal
	DROP TABLE nomina_ordinaria_marca_filiacion;


END; $$ 
LANGUAGE 'plpgsql';

/*
	LLamado a la funcion

	1er argumento es el rango de qnas a consultar en formato de arreglo ARRAY[202001,202024]
	
	2do argumento es los codigos a consultar en formato de arreglo ARRAY['60','800']
		(Nota: con que uno de los codigos se encuentre, marcara status true)
	
	3er argumetno son las filiaciones a consultar junto con el desde a partir del cual revisar 
		en formato de arreglo multidimensional

		ARRAY[
			ARRAY['AAMD891003000','202004'],
			ARRAY['AAMJ810204000','202016']	
		]

*/
SELECT *
FROM reporte_ordinaria_marca_filiacion(
	ARRAY[202001,202024],ARRAY['60'], 
	ARRAY[
		ARRAY['AAMD891003000','202004'],ARRAY['AAMJ810204000','202016'],ARRAY['AARL780629000','202016'],
		ARRAY['AINN730314000','202021'],ARRAY['AOVM751024000','202011'],ARRAY['AOZE750625000','202022'],
		ARRAY['AUGE880721000','202019'],ARRAY['BACJ860624000','202018'],ARRAY['CAAA720721000','202018'],
		ARRAY['CAVC810913000','202016'],ARRAY['CEGM660120000','202004'],ARRAY['CEMF730507000','202004'],
		ARRAY['CILA760604000','202005'],ARRAY['COMY680308000','202002'],ARRAY['CURJ580828000','202018'],
		ARRAY['DIMD910221000','202002'],ARRAY['EIVM630710000','202004'],ARRAY['FOBG851124000','202006'],
		ARRAY['GOAS890817000','202007'],ARRAY['GOLI840306000','202016'],ARRAY['GUBJ950106000','202004'],
		ARRAY['GUTJ910905000','202022'],ARRAY['HECS690402000','202004'],ARRAY['HEJE910114000','202005'],
		ARRAY['JUPJ900824000','202004'],ARRAY['LACM870412000','202002'],ARRAY['LEGA690205000','202021'],
		ARRAY['LIRK840412000','202004'],ARRAY['MAPE930929000','202018'],ARRAY['MULK720730000','202004'],
		ARRAY['NAPA951007000','202006'],ARRAY['OEGE950305000','202002'],ARRAY['QUGM950713000','202001'],
		ARRAY['ROAM830818000','202002'],ARRAY['ROAR850705000','202004'],ARRAY['ROCB820913000','202004'],
		ARRAY['SACM830630000','202004'],ARRAY['SAEP830119000','202010'],ARRAY['SINA580204000','202003'],
		ARRAY['SOAF890826000','202016'],ARRAY['SOAR890620000','202018'],ARRAY['VAAJ810126000','202013'],
		ARRAY['VAVF911228000','202013'],ARRAY['VEGS790430000','202001'],ARRAY['VIBE670724000','202018']
	
	]
)