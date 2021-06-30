/* cancela pagos lino*/

/*cancela en cfdi*/
UPDATE timbrado_cfdi
SET cancelado = true
WHERE id_cfdi in(
128016,131892,135477,166005,169995,176894,179570,183306,
186886,190326,193353,222799,206934,210747,173983,196734,
200232,214671,218782,139785,143374,146953,150634,155636,
158972,162302,226806,230794,234591,242323,245190,247909,
251803,263092,270693,274543,278365
)
AND filiacion = 'LIAC900908000'

/* cancela en conceptos */
UPDATE timbrado_conceptos
SET cancelado = true
WHERE id_cfdi in(
128016,131892,135477,166005,169995,176894,179570,183306,
186886,190326,193353,222799,206934,210747,173983,196734,
200232,214671,218782,139785,143374,146953,150634,155636,
158972,162302,226806,230794,234591,242323,245190,247909,
251803,263092,270693,274543,278365
)

/* Crear los nuevos cfdi */
BEGIN;
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
 total_otras_deducciones,total_impuestos_retenidos,qna,nominas,false,id_cfdi,now(),false
FROM timbrado_cfdi 
WHERE id_cfdi in(
128016,131892,135477,166005,169995,176894,179570,183306,
186886,190326,193353,222799,206934,210747,173983,196734,
200232,214671,218782,139785,143374,146953,150634,155636,
158972,162302,226806,230794,234591,242323,245190,247909,
251803,263092,270693,274543,278365
)
RETURNING id_cfdi;
commit;

/* los id_cfdi nuevos */
SELECT * 
FROM timbrado_cfdi 
WHERE id_cfdi in(
306186,306187,306188,306189,306190,306191,306192,306193,
306194,306195,306196,306197,306198,306199,306200,306201,
306202,306203,306204,306205,306206,306207,306208,306209,
306210,306211,306212,306213,306214,306215,306216,306217,
306218,306219,306220,306221,306222)

/* Crear los nuevos conceptos */
BEGIN;
INSERT INTO timbrado_conceptos(id_cfdi,clave_plaza,tipo_concepto,tipo,clave,concepto,importe,importe_exento,
id_pago,cancelado,id_conceptos_original,devolucion
)
(
SELECT b.id_cfdi,clave_plaza,tipo_concepto,tipo,clave,concepto,importe,importe_exento,
id_pago,false,id_conceptos,false 
FROM timbrado_conceptos a
INNER JOIN timbrado_cfdi b ON a.id_cfdi = b.id_cfdi_original
WHERE b.id_cfdi_original in(
128016,131892,135477,166005,169995,176894,179570,183306,
186886,190326,193353,222799,206934,210747,173983,196734,
200232,214671,218782,139785,143374,146953,150634,155636,
158972,162302,226806,230794,234591,242323,245190,247909,
251803,263092,270693,274543,278365
)
)
RETURNING id_conceptos
commit;


/* los nuevos id_conceptos que se generaron */
SELECT * FROM timbrado_conceptos
WHERE id_cfdi in(
306186,306187,306188,306189,306190,306191,306192,306193,
306194,306195,306196,306197,306198,306199,306200,306201,
306202,306203,306204,306205,306206,306207,306208,306209,
306210,306211,306212,306213,306214,306215,306216,306217,
306218,306219,306220,306221,306222
)


