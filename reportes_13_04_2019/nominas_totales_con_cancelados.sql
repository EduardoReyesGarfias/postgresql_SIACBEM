SELECT a.qnapago,a.consecu
,(
	select count(ya.id_nomina) 
	from nominas_sispagos ya 
	INNER JOIN pagos_sispagos yb ON ya.id_nomina = yb.id_nomina
	where ya.consecu = a.consecu
	LIMIT 1
)as registros
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
FROM nominas_sispagos a
INNER JOIN pagos_sispagos c ON c.id_nomina = a.id_nomina
INNER JOIN percepciones_deducciones_sispagos d ON d.id_pago = c.id_pago
INNER JOIN cat_percepciones_deducciones_sispagos e ON e.clave = d.cod_pd
LEFT JOIN pagos_sispagos_cancelados f ON f.id_pago = c.id_pago
WHERE consecu in('4685'
)
and id_pago_cancelado is null
GROUP BY a.qnapago,a.consecu
ORDER BY a.qnapago