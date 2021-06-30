



CREATE OR REPLACE FUNCTION timbrado_cfdi_con_totper_no_coin(id_nomina int)
RETURNS TABLE (
	id_cfdi int,
	importe_cfdi float,
	importe_con float
)

AS $$

BEGIN

	/* CREO TABLA TEMP PARA ACOMODAR LA INFO CON LA ESTRUCTURA DESEADA */
	CREATE TEMP TABLE temp_timbrado_per_no_coin(
		id_cfdi int,
		importe_cfdi float,
		importe_con float
	);
	
	/* inserto datos en la tabla temp */
	
	INSERT INTO temp_timbrado_per_no_coin(id_cfdi,importe_cfdi,importe_con)
	SELECT a.id_cfdi,a.total_percepciones,
	(
		SELECT sum(b.importe) + sum(b.importe_exento)  
		FROM timbrado_conceptos b
		WHERE b.tipo_concepto = 'P'
		AND b.id_cfdi = a.id_cfdi
		GROUP BY b.id_cfdi
		ORDER BY b.id_cfdi
	)
	FROM timbrado_cfdi a
	WHERE CAST(a.nominas as int) = $1
	ORDER BY a.id_cfdi;
	
	/* regreso datos deseados */
	RETURN QUERY SELECT * FROM temp_timbrado_per_no_coin t 
	WHERE trim(CAST(t.importe_cfdi as varchar)) <> trim(CAST(t.importe_con as varchar));
	/* borro tabla temp */
	DROP TABLE temp_timbrado_per_no_coin;

END; $$
LANGUAGE 'plpgsql';


select * from timbrado_cfdi_con_totper_no_coin(773)

