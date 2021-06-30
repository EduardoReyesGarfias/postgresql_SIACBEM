SELECT
	b.qnapago,b.consecU, b.descripcion_nomina,
	a.id_cfdi, a.no_empleado, a.receptor_nombre, a.receptor_rfc,
	a.ct, a.nombre_ct,
	STRING_AGG(DISTINCT CASE WHEN c.numero_hr is not null THEN c.categoria||'/'||c.numero_plz||'/'||c.numero_hr ELSE c.categoria||'/'||c.numero_plz END, ',') as clave_plaza,
	a.fecha_pago, a.fecha_inicial_pago, a.fecha_final_pago,
	a.total_liquido, a.total_impuestos_retenidos,
	e.uuid
	,sum(
		CASE WHEN pds.cod_pd in('80', '81', '31') THEN pds.importe END
	)as isr_devolucion
	,(
		CASE WHEN (a.total_impuestos_retenidos != sum(CASE WHEN pds.cod_pd in('80', '81', '31') THEN pds.importe END) ) THEN
			'Devolución parcial'
		ELSE
			'Devolución completa'
		END
	) as observacion
	,nom.consecu as consecu_dev, nom.qnapago as qnapago_dev
	--, STRING_AGG(DISTINCT pds.desde_pag||' al '||pds.hasta_pag, ',') AS efectos_devolucion
FROM timbrado_cfdi a
INNER JOIN nominas_sispagos b ON b.id_nomina = CAST(a.nominas as int)
INNER JOIN pagos_sispagos c ON c.id_nomina = b.id_nomina
INNER JOIN percepciones_deducciones_sispagos pds ON pds.id_pago = c.id_pago
LEFT JOIN devoluciones_pagos_sispagos d ON d.id_pago_ordinario = c.id_pago
LEFT JOIN timbrado_respuesta e ON e.id_cfdi = a.id_cfdi
LEFT JOIN nominas_sispagos nom ON nom.id_nomina = d.id_nomina_devolucion
WHERE 
	b.qnapago between 202019 AND 202024
	AND d.id_pago_ordinario is not null
	AND b.id_tipo_nomina != 2
	AND CAST(a.no_empleado AS int) = c.id_empleado
GROUP BY 
	b.qnapago,b.consecU, b.descripcion_nomina,
	a.id_cfdi, a.no_empleado, a.receptor_nombre, a.receptor_rfc,
	a.total_liquido, a.total_impuestos_retenidos, a.id_cfdi,
	e.uuid, nom.consecu, nom.qnapago
ORDER BY b.qnapago ASC, b.consecu ASC, a.receptor_nombre ASC
