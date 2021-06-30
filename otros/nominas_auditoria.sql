--752
SELECT 
--*
a.qnapago,b.filiacion,b.categoria,b.numero_plz,b.numero_hr,b.clave_tipo_nombramiento
,cod_pd,importe,desde_pag,hasta_pag
,
(
	CASE WHEN c.nombre_subprograma = 'Comité Ejecutivo Estatal del SITCBEM' THEN
		(
			SELECT zb.nombre_subprograma
			from plazas_nomina_rh_recibe za  
			INNER JOIN subprogramas zb ON (zb.clave_subprograma=substring(za.subprograma from 2 for 3) or zb.clave_extension_u_organica=substring(za.subprograma from 2 for 3))
			where id_plaza_nomina_rh_datos=32
				and filiacion = b.filiacion
				and estado_rec='0'
				and subprograma != '5601'
			order by id_plaza_nomina_rh_recibe
			LIMIT 1
		)
	ELSE
		c.nombre_subprograma
	END
) as nombre_subprograma
FROM nominas_sispagos a
INNER JOIN pagos_sispagos b ON b.id_nomina = a.id_nomina
INNER JOIN subprogramas c ON c.id_subprograma = b.id_subprograma
INNER JOIN percepciones_deducciones_sispagos d ON d.id_pago = b.id_pago
WHERE A.id_nomina = 752
ORDER BY b.filiacion,b.categoria,b.numero_plz,b.numero_hr

--"AAEJ670610000"
