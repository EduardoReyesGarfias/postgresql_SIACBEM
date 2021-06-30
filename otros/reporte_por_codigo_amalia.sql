SELECT 
(
	CASE WHEN a.qnapago = 201901 OR a.qnapago = 201902 THEN
		'Enero'
	WHEN a.qnapago = 201903 OR a.qnapago = 201904 THEN
		'Febrero'
	WHEN a.qnapago = 201905 OR a.qnapago = 201906 THEN
		'Marzo'
	ELSE
		CAST(a.qnapago as text)
	END
) as mes
,cod_pd, sum(importe) as importe,count(*) as registros 
FROM nominas_sispagos a
INNER JOIN pagos_sispagos b ON b.id_nomina = a.id_nomina
INNER JOIN percepciones_deducciones_sispagos c ON c.id_pago = b.id_pago
LEFT JOIN pagos_sispagos_cancelados d ON d.id_pago =b.id_pago
LEFT JOIN devoluciones_pagos_sispagos e ON e.id_pago_ordinario = b.id_pago
WHERE ((a.qnapago between 201901 and 201906))
and cod_pd in('56','13','68','46','59','58','12','09','18')
and d.id_pago is null
and e.id_pago_ordinario is null
GROUP BY mes,cod_pd
ORDER BY mes,cod_pd
