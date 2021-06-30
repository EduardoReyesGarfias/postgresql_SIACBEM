-- temporal
SELECT *
FROM timbrado_cfdi
WHERE fecha_pago like  '2018-%'
AND filiacion = 'LIAC900908000'
AND cancelado = false
ORDER BY ID_CFDI

/*** insert desde un select en cfdi ***/

INSERT INTO timbrado_cfdi (
	ct,nombre_ct,filiacion,origen_recurso,monto_recurso_propio,receptor_nombre,receptor_rfc,tipo_nomina,
 fecha_pago,fecha_inicial_pago,fecha_final_pago,dias_pagados,subsidio_causado,total_percepciones,
 total_deducciones,total_otros_pagos,total_liquido,registro_patronal,recepetor_curp,nss,fecha_ingreso,antiguedad,
 tipo_contrato,sindicalizado,tipo_jornada,tipo_regimen,no_empleado,departamento,puesto,riesgo_puesto,
 perioricidad_pago,salario_base,salario_diario_integrado,entidad_federativa,total_sueldos,total_gravado,total_exento,
 total_otras_deducciones,total_impuestos_retenidos,qna,nominas,cancelado,id_cfdi_original,fecha_sistema,devolucion
)

SELECT ct,nombre_ct,filiacion,origen_recurso,monto_recurso_propio,'LINO ALEJANDRE CESAR IBRHAIM',receptor_rfc,tipo_nomina,
 fecha_pago,fecha_inicial_pago,fecha_final_pago,dias_pagados,subsidio_causado,total_percepciones,
 total_deducciones,total_otros_pagos,total_liquido,registro_patronal,recepetor_curp,nss,fecha_ingreso,antiguedad,
 tipo_contrato,sindicalizado,tipo_jornada,tipo_regimen,no_empleado,departamento,puesto,riesgo_puesto,
 perioricidad_pago,salario_base,salario_diario_integrado,entidad_federativa,total_sueldos,total_gravado,total_exento,
 total_otras_deducciones,total_impuestos_retenidos,qna,nominas,cancelado,id_cfdi,fecha_sistema,devolucion
FROM timbrado_cfdi 
WHERE id_cfdi = 278365
RETURNING id_cfdi

/* insert desde un select en conceptos */
SELECT * 
FROM timbrado_conceptos a
INNER JOIN timbrado_cfdi b ON a.id_cfdi = b.id_cfdi_original
WHERE b.id_cfdi_original = '278365'

SELECT * FROM TIMBRADO_CFDI WHERE ID_CFDI = 298484

select * from timbrado_cfdi where id_cfdi = 278365

UPDATE timbrado_cfdi set cancelado = true WHERE id_cfdi = 270693;
update timbrado_conceptos set cancelado = true where id_cfdi = 270693;


INSERT INTO timbrado_conceptos(id_cfdi,clave_plaza,tipo_concepto,tipo,clave,concepto,importe,importe_exento,
id_pago,cancelado,id_conceptos_original,devolucion
)
(
SELECT b.id_cfdi,clave_plaza,tipo_concepto,tipo,clave,concepto,importe,importe_exento,
id_pago,false,id_conceptos,false 
FROM timbrado_conceptos a
INNER JOIN timbrado_cfdi b ON a.id_cfdi = b.id_cfdi_original
WHERE b.id_cfdi_original = '270693'
)
RETURNING id_conceptos



select * 
FROM timbrado_conceptos 
WHERE id_cfdi = 298518

SELECT * 
FROM TIMBRADO_CFDI WHERE ID_CFDI_ORIGINAL= 270693
