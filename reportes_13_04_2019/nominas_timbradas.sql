SELECT b.qnapago,b.consecu,b.fecha_pago_tesoreria
,SUM(
	CASE WHEN id_tipo_pd = 1 THEN
		importe
	ELSE
		0
	END
)as tp
,SUM(
	CASE WHEN id_tipo_pd = 2 THEN
		importe
	ELSE
		0
	END
)as td
FROM timbrado_cfdi a
INNER JOIN nominas_sispagos b ON b.id_nomina = CAST(a.nominas as int) 
INNER JOIN pagos_sispagos c ON c.id_nomina = b.id_nomina
INNER JOIN percepciones_deducciones_sispagos d ON d.id_pago = c.id_pago
INNER JOIN cat_percepciones_deducciones_sispagos e ON e.clave = d.cod_pd
WHERE (CAST(fecha_pago_tesoreria as text) like '2018-%' OR CAST(fecha_pago_tesoreria as text) like '2019-%')
AND ((CAST(b.qnapago as text) BETWEEN '201801' AND '201824'))
GROUP BY a.qna,b.consecu,a.fecha_pago,b.fecha_pago_tesoreria,b.qnapago
ORDER BY qna