CREATE OR REPLACE FUNCTION planteles_plazas_empleado(filiacion text, id_estructura integer)
RETURNS TABLE(
	tipo_plaza varchar,
	categoria varchar,
	num_plz varchar,
	num_hrs integer,
	id_cat_categoria_padre integer,
	id_categoria_equivalencia integer,
	categoria_equivalencia varchar
)

AS $$
BEGIN
	
	/* Evaluar si existe en plazas docentes */
	RETURN QUERY SELECT --*,
	CAST('Docente' as varchar),c.categoria_padre,CAST(a.num_plz as varchar),CAST(sum(a.hrs_categoria) as integer),a.id_cat_categoria_padre
	,(
		SELECT ba.id_categoria
		FROM cat_categorias ba
		WHERE ba.id_cat_categoria_padre = a.id_cat_categoria_padre 
	) id_categoria_equivalencia
	,(
		SELECT 
		CASE WHEN (ba.equivalencia is null OR ba.equivalencia = '') THEN
			null
		ELSE 
			ba.equivalencia
		END	
		FROM cat_categorias ba
		WHERE ba.id_cat_categoria_padre = a.id_cat_categoria_padre 
	) categoria_equivalencia
	FROM plantilla_base_docente_rh a
	INNER JOIN empleados b ON a.id_empleado = b.id_empleado
	INNER JOIN cat_categorias_padre c ON c.id_cat_categoria_padre = a.id_cat_categoria_padre
	WHERE b.filiacion = UPPER($1)
	AND a.id_estructura_ocupacional = $2
	AND revision_rh is true
	GROUP BY a.id_cat_categoria_padre,c.categoria_padre, a.num_plz
	ORDER BY c.categoria_padre,a.num_plz;

END; $$ 
 
LANGUAGE 'plpgsql';

SELECT * FROM planteles_plazas_empleado('HESM920122000',27)

