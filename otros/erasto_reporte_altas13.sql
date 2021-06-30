--CF2288
SELECT 
d.rfc,d.paterno,d.materno,d.nombre,c.nombre_subprograma,e.desde_pag,e.hasta_pag
,f.id_pago_cancelado,g.id_devolucion_pago_sispagos as id_pago_devolucion
FROM nominas_sispagos a
INNER JOIN pagos_sispagos b ON a.id_nomina = b.id_nomina
INNER JOIN subprogramas c ON c.id_subprograma = b.id_subprograma
INNER JOIN empleados d ON d.id_empleado = b.id_empleado
INNER JOIN percepciones_deducciones_sispagos e ON e.id_pago = b.id_pago

LEFT JOIN pagos_sispagos_cancelados f ON f.id_pago = b.id_pago
LEFT JOIN devoluciones_pagos_sispagos g ON g.id_pago_ordinario = b.id_pago 

WHERE a.qnapago = '201910' and id_tipo_nomina in(1,4)
AND clave_tipo_nombramiento = '13'
GROUP BY d.rfc,d.paterno,d.materno,d.nombre,c.nombre_subprograma,e.desde_pag,e.hasta_pag,id_pago_cancelado,g.id_devolucion_pago_sispagos 
ORDER BY d.rfc,d.paterno,d.materno,d.nombre,desde_pag

--42 rows
