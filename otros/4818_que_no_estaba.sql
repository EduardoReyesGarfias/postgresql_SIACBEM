COPY
(SELECT id_cfdi,ct,nombre_ct,filiacion,origen_recurso,monto_recurso_propio,receptor_nombre,receptor_rfc,tipo_nomina,
 fecha_pago,fecha_inicial_pago,fecha_final_pago,dias_pagados,subsidio_causado,total_percepciones,
 total_deducciones,total_otros_pagos,total_liquido,registro_patronal,recepetor_curp,nss,fecha_ingreso,antiguedad,
 tipo_contrato,sindicalizado,tipo_jornada,tipo_regimen,no_empleado,departamento,puesto,riesgo_puesto,
 perioricidad_pago,salario_base,salario_diario_integrado,entidad_federativa,total_sueldos,total_gravado,total_exento,
 total_otras_deducciones,total_impuestos_retenidos,qna,nominas,cancelado,id_cfdi_original,fecha_sistema,devolucion
FROM siacbem_produccion_tmp.public.timbrado_cfdi
WHERE nominas = '752'
ORDER BY id_cfdi)
TO '/var/www/html/siacbem/SIACBEM/Timbrados2/datos_de_4818_que_no_estaban.csv'  DELIMITER ';' CSV HEADER