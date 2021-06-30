-- julio,agosto,septiembre
SELECT 
--*
b.filiacion,c.nombre,c.paterno,c.materno,c.genero,f.clave_tipo_nombramiento,categoria,descripcion_cat_padre
,e.tipo_categoria, f.descripcion,g.nombre_subprograma
,sum(
	CASE WHEN h.id_tipo_pd = 1
	THEN
		importe
	ELSE 
		importe*-1
	END
)as rem_bruta
,sum(
	CASE WHEN h.id_tipo_pd = 1
	THEN
		importe
	ELSE 
		0
	END
)as rem_neta
FROM nominas_sispagos a
INNER JOIN pagos_sispagos b ON a.id_nomina = b.id_nomina
INNER JOIN empleados c ON c.id_empleado = b.id_empleado
INNER JOIN cat_categorias_padre d ON d.categoria_padre = b.categoria
INNER JOIN cat_tipo_categoria e ON e.id_tipo_categoria = d.tipo_categoria
INNER JOIN cat_tipo_nombramiento f ON f.clave_tipo_nombramiento = CAST(b.clave_tipo_nombramiento as integer)
INNER JOIN subprogramas g ON g.id_subprograma = b.id_subprograma
INNER JOIN percepciones_deducciones_sispagos pds ON pds.id_pago = b.id_pago
INNER JOIN cat_percepciones_deducciones_sispagos h ON h.clave = pds.cod_pd
WHERE a.qnapago in(201813,201814,201815,201816,201817,201818)
AND id_tipo_nomina in(1)
AND b.filiacion = 'AAAR860110000'
GROUP BY b.filiacion,c.nombre,c.paterno,c.materno,f.clave_tipo_nombramiento,categoria,descripcion_cat_padre
,e.tipo_categoria,f.descripcion,g.nombre_subprograma,c.genero
ORDER BY b.filiacion,clave_tipo_nombramiento ASC

--select * from cat_categorias_padre
--select * from cat_tipo_categoria
--select * from cat_tipo_nombramiento
--select * from percepciones_deducciones_sispagos limit 10
--select * from cat_percepciones_deducciones_sispagos
