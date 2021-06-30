select 
categoria_padre,descripcion_cat_padre,b.tipo_categoria
,(
	CASE WHEN categoria_federal is null
	THEN
		'-'
	ELSE
		categoria_federal
	END
) as categoria_federal
FROM cat_categorias_padre a
INNER JOIN cat_tipo_categoria b ON b.id_tipo_categoria = a.tipo_categoria
WHERE fecha_fin is null