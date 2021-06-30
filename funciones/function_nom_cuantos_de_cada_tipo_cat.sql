CREATE OR REPLACE FUNCTION nominas_sispagos_cuantos_de_cada_tipo_plaza (id_nomina int)
RETURNS TABLE(
	tipo_categoria text,
	num smallint
)
AS $$
DECLARE
	var_emp text;
	var_tipo text;
	reg_nomina     RECORD;
	cur_nomina CURSOR FOR SELECT b.filiacion,
	(
		CASE WHEN c.tipo_categoria = 2 OR c.tipo_categoria = 4 THEN
			b.categoria||'/'||b.numero_plz||'/'||b.numero_hr
		ELSE
			b.categoria||'/'||b.numero_plz
		END
	) as categoria,	
	(
		CASE WHEN c.tipo_categoria = 1 THEN
			'Directiva'
		WHEN c.tipo_categoria = 2 OR c.tipo_categoria = 4 THEN
			'Docente'
		WHEN c.tipo_categoria = 3 THEN
			'Administrativa'
		END
	) as tipo
	FROM pagos_sispagos b
	INNER JOIN cat_categorias_padre c ON c.categoria_padre = b.categoria
	WHERE b.id_nomina = $1
	GROUP BY b.filiacion,b.categoria,b.numero_plz,b.numero_hr,c.tipo_categoria
	ORDER BY b.filiacion,b.categoria,b.numero_plz,b.numero_hr;
BEGIN
	
	CREATE TEMP TABLE temp_nom_tipo_cat(
		tipo_categoria text,
		num smallint
	);
	
	INSERT INTO temp_nom_tipo_cat(tipo_categoria,num) VALUES
	('Directiva',0),('Docente',0),('Administrativa',0);
	
	/* recorro query para saber cuantos hay de cada tipo */
	var_emp:='';
	var_tipo:='';
	FOR reg IN cur_nomina LOOP
		IF var_emp = reg.filiacion THEN
			IF var_tipo <> reg.tipo THEN
				/* añade */
				UPDATE temp_nom_tipo_cat t SET num = t.num + 1 WHERE t.tipo_categoria = reg.tipo;
			END IF;
		ELSE
			/* añade */
			UPDATE temp_nom_tipo_cat t SET num = t.num + 1 WHERE t.tipo_categoria = reg.tipo; 
		END IF;
	
		var_emp:=reg.filiacion;
		var_tipo:=reg.tipo;
	END LOOP;
	
	RETURN QUERY SELECT * FROM temp_nom_tipo_cat; 
	DROP TABLE temp_nom_tipo_cat;	

END; $$ 
 
LANGUAGE 'plpgsql';

SELECT * FROM nominas_sispagos_cuantos_de_cada_tipo_plaza(730)
--896
