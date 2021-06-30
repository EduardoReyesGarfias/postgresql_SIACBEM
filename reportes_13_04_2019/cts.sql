SELECT  
--*
nombre_subprograma,clave_subprograma,clave_extension_u_organica
,(
	CASE WHEN coordinacion = 0
	THEN
		CAST('-' as text)
	ELSE
		CAST(coordinacion as text)
	END
) as cordinacion
,clave_sep

FROM subprogramas a
INNER JOIN claves_sep b ON a.id_sep = b.id_sep
WHERE fecha_fin is null
ORDER BY nombre_subprograma