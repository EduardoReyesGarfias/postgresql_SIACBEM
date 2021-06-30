SELECT 
--*
b.categoria,b.descripcion,b.descripcion_planteles,b.id_cat_categoria_padre,c.id_tipo_categoria,c.tipo_categoria
,d.id_subprograma,d.id_zona_economica
FROM plazas a
INNER JOIN cat_categorias b ON a.id_categoria = b.id_categoria 
INNER JOIN cat_tipo_categoria c ON c.id_tipo_categoria = b.tipo_categoria
INNER JOIN subprogramas d ON d.id_subprograma = a.id_subprograma
WHERE qna_hasta = 999999
and id_estructura_ocupacional = (SELECT id_estructura_ocupacional_modifica FROM cat_estructuras_ocupacionales WHERE periodo = '2018-2' ) 
GROUP BY b.categoria,b.descripcion,b.descripcion_planteles,b.id_cat_categoria_padre,c.id_tipo_categoria,c.tipo_categoria
,d.id_subprograma,d.id_zona_economica
ORDER BY c.id_tipo_categoria,descripcion


select * from subprogramas limit 10

select * from cat_zonas_economicas
