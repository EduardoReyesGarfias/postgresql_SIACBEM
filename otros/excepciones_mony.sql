COPY 
(SELECT 
 timbrado_cfdi.id_cfdi,ct,nombre_ct,filiacion,origen_recurso,monto_recurso_propio,receptor_nombre,receptor_rfc,tipo_nomina,fecha_pago,fecha_inicial_pago,fecha_final_pago,dias_pagados,subsidio_causado,total_percepciones,total_deducciones,total_otros_pagos,total_liquido,registro_patronal,recepetor_curp,nss,fecha_ingreso,antiguedad,tipo_contrato,sindicalizado,tipo_jornada,tipo_regimen,no_empleado,departamento,puesto,riesgo_puesto,perioricidad_pago,salario_base,salario_diario_integrado,entidad_federativa,total_sueldos,total_gravado,total_exento,total_otras_deducciones,total_impuestos_retenidos 
 FROM timbrado_cfdi 
 INNER JOIN timbrado_conceptos ON timbrado_conceptos.id_cfdi = timbrado_cfdi.id_cfdi 
 WHERE --timbrado_cfdi.qna like '%2018%' 
 --and timbrado_cfdi.nominas = '592' 
 --and timbrado_conceptos.cancelado = 'f' 
 --and timbrado_cfdi.cancelado = 'f'
 --and 
 timbrado_cfdi.id_cfdi in (
 	138045
 ) 
 GROUP BY timbrado_cfdi.id_cfdi 
 ORDER BY timbrado_cfdi.id_cfdi
) 
 TO '/var/www/html/siacbem/SIACBEM/Timbrados2/Excepciones/2018/Marzo/timbrado_cfdi_Excepciones_Centavo_Abril_2018.txt'  
DELIMITER ',';

/********************************************/
COPY 
(SELECT 
 a.id_conceptos,a.id_cfdi,a.clave_plaza,a.tipo_concepto,tipo,'0'||''||a.clave as clave,a.concepto,a.importe,a.importe_exento 
 FROM timbrado_conceptos a 
 INNER JOIN timbrado_cfdi b ON a.id_cfdi = b.id_cfdi 
 WHERE --b.qna like '%2018%' 
 --and b.nominas = '592' 
 --and a.cancelado = 'f' 
 --and b.cancelado = 'f' 
--and 
 b.id_cfdi in (
 	138045
 ) 
) 
 TO '/var/www/html/siacbem/SIACBEM/Timbrados2/Excepciones/2018/Marzo/timbrado_conceptos_Excepciones_Centavo_Abril_2018.txt'  
DELIMITER ',';

