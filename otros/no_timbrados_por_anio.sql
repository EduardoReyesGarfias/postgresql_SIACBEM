/* Saca los anios que no estan timbrados */
SELECT substring(a.fecha_pago from 0 for 5) 
FROM timbrado_cfdi a
LEFT JOIN timbrado_respuesta b ON a.id_cfdi = b.id_cfdi
INNER JOIN nominas_sispagos c ON c.id_nomina = CAST(a.nominas as int)
WHERE b.id_timbrado_respuesta is null and a.cancelado = false
GROUP BY substring(a.fecha_pago from 0 for 5)
ORDER BY substring(a.fecha_pago from 0 for 5) DESC

/* saca los NO timbrados por un anio */
SELECT 
a.id_cfdi,a.filiacion,a.origen_recurso,a.monto_recurso_propio,a.receptor_nombre,a.receptor_rfc
,a.tipo_nomina,a.fecha_pago,a.fecha_inicial_pago,a.fecha_final_pago,a.subsidio_causado
,a.total_percepciones,a.total_deducciones,a.total_otros_pagos,a.total_liquido,a.recepetor_curp
,a.nss,a.fecha_ingreso,a.antiguedad,a.sindicalizado,a.no_empleado,a.perioricidad_pago
,a.salario_base,a.salario_diario_integrado,a.total_sueldos,a.total_gravado,a.total_exento
,a.total_otras_deducciones,a.total_impuestos_retenidos,c.qnapago,c.consecu
FROM timbrado_cfdi a
LEFT JOIN timbrado_respuesta b ON a.id_cfdi = b.id_cfdi
INNER JOIN nominas_sispagos c ON c.id_nomina = CAST(a.nominas as int)
WHERE b.id_timbrado_respuesta is null and a.fecha_pago like '%2018-%'
AND a.cancelado = false
ORDER BY c.qnapago,c.consecu