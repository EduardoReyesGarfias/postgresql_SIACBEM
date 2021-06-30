SELECT filiacion,cod_pd,sum(importe)
FROM nominas_sispagos a
INNER JOIN pagos_sispagos b ON a.id_nomina = b.id_nomina
INNER JOIN percepciones_deducciones_sispagos c ON c.id_pago = b.id_pago
WHERE a.consecu  in('4676','4678')
and b.filiacion = 'REGE920409000'
GROUP BY filiacion,cod_pd
ORDER BY b.filiacion,cod_pd