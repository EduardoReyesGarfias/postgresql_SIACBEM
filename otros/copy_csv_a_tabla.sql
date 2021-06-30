BEGIN;
COPY timbrado_cfdi(id_cfdi,ct,nombre_ct,filiacion,origen_recurso,monto_recurso_propio,receptor_nombre,receptor_rfc,tipo_nomina,
 fecha_pago,fecha_inicial_pago,fecha_final_pago,dias_pagados,subsidio_causado,total_percepciones,
 total_deducciones,total_otros_pagos,total_liquido,registro_patronal,recepetor_curp,nss,fecha_ingreso,antiguedad,
 tipo_contrato,sindicalizado,tipo_jornada,tipo_regimen,no_empleado,departamento,puesto,riesgo_puesto,
 perioricidad_pago,salario_base,salario_diario_integrado,entidad_federativa,total_sueldos,total_gravado,total_exento,
 total_otras_deducciones,total_impuestos_retenidos,qna,nominas,cancelado,id_cfdi_original,fecha_sistema,devolucion
) 
FROM '/var/www/html/siacbem/SIACBEM/Timbrados2/datos_cfdi_de_4818_que_no_estaban.csv' DELIMITER ';' CSV HEADER;

--commit;

SELECT * 
FROM timbrado_conceptos
WHERE id_cfdi = 251803
--WHERE nominas = '752';



/****** CONCEPTOS ********/
BEGIN;
COPY timbrado_conceptos(
	id_conceptos,id_cfdi,clave_plaza,tipo_concepto,tipo
,clave,concepto,importe,importe_exento,id_pago,cancelado
,id_conceptos_original,devolucion
) 
FROM '/var/www/html/siacbem/SIACBEM/Timbrados2/datos_conceptos_de_4818_que_no_estaban.csv' DELIMITER ';' CSV HEADER;

--commit;

SELECT 
id_conceptos,b.id_cfdi,clave_plaza,tipo_concepto,tipo
,clave,concepto,importe,importe_exento,id_pago,b.cancelado
,id_conceptos_original,b.devolucion
FROM timbrado_conceptos b
INNER JOIN timbrado_cfdi a ON a.id_cfdi = b.id_cfdi
WHERE a.nominas = '752'
ORDER BY b.id_conceptos,a.id_cfdi
