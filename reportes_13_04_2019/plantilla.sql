/* Matriz PDS por trabajadores */
SELECT --* 
e.filiacion,e.rfc,e.nombre,e.paterno,e.materno
,b.categoria,b.numero_plz,b.numero_hr,g.tipo_categoria,descripcion_cat_padre,b.clave_tipo_nombramiento,h.descripcion
,
(
	CASE WHEN i.nombre_subprograma = 'Comité Ejecutivo Estatal del SITCBEM' THEN
		(
			SELECT zb.nombre_subprograma
			from plazas_nomina_rh_recibe za  
			INNER JOIN subprogramas zb ON (zb.clave_subprograma=substring(za.subprograma from 2 for 3) or zb.clave_extension_u_organica=substring(za.subprograma from 2 for 3))
			where id_plaza_nomina_rh_datos=32
				and filiacion = e.filiacion
				and estado_rec='0'
				and subprograma != '5601'
			order by id_plaza_nomina_rh_recibe
			LIMIT 1
		)
	ELSE
		i.nombre_subprograma
	END
)
,SUM(
	case WHEN d.id_tipo_pd = 1 THEN
		importe*2
	ELSE
		0
	END
)as per
,SUM(
	CASE WHEN d.id_tipo_pd = 2 THEN
		importe*2
	ELSE 
		0
	END
) as ded
,SUM(
	CASE WHEN cod_pd = '66' OR cod_pd = '43' THEN
		importe
	ELSE
		0
	END
)as compensacion
,SUM(
	CASE WHEN cod_pd = '61' OR cod_pd = '19' OR cod_pd = '53' OR cod_pd = '14' THEN
		importe
	ELSE
		0
	END
) as prestaciones

FROM nominas_sispagos a
INNER JOIN pagos_sispagos b ON a.id_nomina = b.id_nomina
INNER JOIN percepciones_deducciones_sispagos c ON c.id_pago = b.id_pago
INNER JOIN cat_percepciones_deducciones_sispagos d ON d.clave = c.cod_pd
INNER JOIN cat_categorias_padre f ON f.categoria_padre = b.categoria
INNER JOIN cat_tipo_categoria g ON g.id_tipo_categoria = f.tipo_categoria
INNER JOIN empleados e ON e.filiacion = b.filiacion
INNER JOIN cat_tipo_nombramiento h ON h.clave_tipo_nombramiento = CAST(b.clave_tipo_nombramiento as int)
INNER JOIN subprogramas i ON i.id_subprograma = b.id_subprograma
WHERE a.qnapago = '201823'
AND a.consecu = '4815'
--AND b.filiacion = 'REGE920409000'
--and nombre_subprograma ilike '%SITCBEM%'
GROUP BY e.filiacion,e.rfc,e.nombre,e.paterno,e.materno
,b.categoria,b.numero_plz,b.numero_hr,g.tipo_categoria,descripcion_cat_padre,b.clave_tipo_nombramiento,h.descripcion,i.nombre_subprograma
ORDER BY e.filiacion