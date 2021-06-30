CREATE OR REPLACE FUNCTION timbrado_compara_cfdi_con_conceptos(campo text,como int,valores integer[])
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

	IF $1 = 'percepcion' THEN

		/* 
		Recorro array de valores y 
		los voy insertando en la temporal	
		*/
		FOR i IN array_lower($3,1) .. array_upper($3,1) LOOP
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
			WHERE a.id_cfdi = $3[i]
			ORDER BY a.id_cfdi;
		END LOOP;

	ELSIF $1 = 'deduccion' THEN
		/* 
		Recorro array de valores y 
		los voy insertando en la temporal	
		*/
		FOR i IN array_lower($3,1) .. array_upper($3,1) LOOP
			INSERT INTO temp_timbrado_per_no_coin(id_cfdi,importe_cfdi,importe_con)
			SELECT a.id_cfdi,a.total_deducciones,
			(
				SELECT sum(b.importe) + sum(b.importe_exento)  
				FROM timbrado_conceptos b
				WHERE b.tipo_concepto = 'D'
				AND b.id_cfdi = a.id_cfdi
				GROUP BY b.id_cfdi
				ORDER BY b.id_cfdi
			)
			FROM timbrado_cfdi a
			WHERE a.id_cfdi = $3[i]
			ORDER BY a.id_cfdi;
		END LOOP;

	ELSIF $1 = 'liquido' THEN

	ELSIF $1 = 'gravado' THEN

		/* 
		Recorro array de valores y 
		los voy insertando en la temporal	
		*/
		FOR i IN array_lower($3,1) .. array_upper($3,1) LOOP
			INSERT INTO temp_timbrado_per_no_coin(id_cfdi,importe_cfdi,importe_con)
			SELECT a.id_cfdi,a.total_gravado,
			(
				SELECT sum(b.importe) 
				FROM timbrado_conceptos b
				WHERE b.tipo_concepto = 'P'
				AND b.id_cfdi = a.id_cfdi
				GROUP BY b.id_cfdi
				ORDER BY b.id_cfdi
			)
			FROM timbrado_cfdi a
			WHERE a.id_cfdi = $3[i]
			ORDER BY a.id_cfdi;
		END LOOP;

	ELSIF $1 = 'exento' THEN
		/* 
		Recorro array de valores y 
		los voy insertando en la temporal	
		*/
		FOR i IN array_lower($3,1) .. array_upper($3,1) LOOP
			INSERT INTO temp_timbrado_per_no_coin(id_cfdi,importe_cfdi,importe_con)
			SELECT a.id_cfdi,a.total_exento,
			(
				SELECT sum(b.importe_exento)  
				FROM timbrado_conceptos b
				WHERE b.tipo_concepto = 'P'
				AND b.id_cfdi = a.id_cfdi
				GROUP BY b.id_cfdi
				ORDER BY b.id_cfdi
			)
			FROM timbrado_cfdi a
			WHERE a.id_cfdi = $3[i]
			ORDER BY a.id_cfdi;
		END LOOP;

	END IF; 

	/* regreso datos deseados */
	RETURN QUERY SELECT * FROM temp_timbrado_per_no_coin t 
	WHERE trim(CAST(t.importe_cfdi as varchar)) <> trim(CAST(t.importe_con as varchar));
	/* borro tabla temp */
	DROP TABLE temp_timbrado_per_no_coin;

END; $$
LANGUAGE 'plpgsql';

select *  from timbrado_compara_cfdi_con_conceptos('exento',1,array[233277,233765,241491,236084,243821,232988,240707,233630,234834,236104,234628,236471,244208,234918,233078
,240797,241187,235257,242992,234371,235884,233088,240807,233349,241072,233658,241383,236328,244065,233534
,241259,235988,243725,233701,241426,234454,242185,236459,244196,234853,242587,250177,232973,240692,234275
,242004,234506,242237,233734,241459,234294,234904,235955,243692,234624,242357,236022,233237,235265,243000])