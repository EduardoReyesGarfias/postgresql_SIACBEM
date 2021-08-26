-- actualiza numeros de seguro social
UPDATE
timbrado_cfdi t1
SET
nss = t2.no_seguridad_social
FROM
empleados t2
WHERE CAST(t1.no_empleado as int) = t2.id_empleado
AND t1.id_cfdi = ANY(ARRAY[434373,436466])

-- actualiza fecha de ingreso
UPDATE
timbrado_cfdi t1
SET
fecha_ingreso = t2.fecha_ingreso
FROM
empleados t2
WHERE CAST(t1.no_empleado as int) = t2.id_empleado
AND t1.id_cfdi = ANY(ARRAY[434373,436466])

--Actulalizar RFC (unicamente en timbrado)
/*
	Este caso se cambio solo en timbrado de 
	POMS671231M89 a POMJ671231M89
*/
UPDATE timbrado_cfdi
SET receptor_rfc = 'POMJ671231M89'
WHERE id_cfdi = ANY(ARRAY[548761,553317,557067,560849,564632,568417,572202,576175,578535])


-- Generar excepciones

-- cfdi

COPY (
	SELECT 
	timbrado_cfdi_2021.id_cfdi,ct,nombre_ct,filiacion,origen_recurso,monto_recurso_propio,receptor_nombre,receptor_rfc,tipo_nomina,fecha_pago,fecha_inicial_pago,fecha_final_pago,dias_pagados,subsidio_causado,total_percepciones,total_deducciones,total_otros_pagos,total_liquido,registro_patronal,recepetor_curp,nss,fecha_ingreso,antiguedad,tipo_contrato,sindicalizado,tipo_jornada,tipo_regimen,no_empleado,departamento,puesto,riesgo_puesto,perioricidad_pago,salario_base,salario_diario_integrado,entidad_federativa,total_sueldos,total_gravado,total_exento,total_otras_deducciones,total_impuestos_retenidos
	FROM timbrado_cfdi_2021 
	INNER JOIN timbrado_conceptos_2021 ON timbrado_conceptos_2021.id_cfdi = timbrado_cfdi_2021.id_cfdi 
	WHERE timbrado_conceptos_2021.cancelado = 'f' 
	AND timbrado_cfdi_2021.cancelado = 'f'
	AND timbrado_cfdi_2021.nss != '' 
    AND  timbrado_cfdi_2021.nss != ' ' 
    AND timbrado_cfdi_2021.nss is not null 
    AND timbrado_cfdi_2021.nss != '0' 
    AND timbrado_cfdi_2021.id_cfdi = ANY(ARRAY[434373,436466,448597,465816,541255,
		543338,548761,553317,553977,557067,557735,555439,560849,558750,561519,558562,
		565302,562347,564632,562534,566318,568010,569088,566131,568417,569445,569181,567436,
		567673,566516,567196,572872,572202,570103,569916,574076,573889,576845,576175,578535])
	GROUP BY timbrado_cfdi_2021.id_cfdi 
	ORDER BY timbrado_cfdi_2021.id_cfdi
) TO '/var/www/html/siacbem/SIACBEM/Timbrados2/Excepciones_2020/04_03_2021/Excepciones_de_2020_extraido_12_08_2021_cfdi.txt' DELIMITER ',' 


-- conceptos

COPY (
	SELECT  
	a.id_conceptos,a.id_cfdi,a.clave_plaza,a.tipo_concepto,tipo,'0'||''||a.clave as clave,a.concepto,a.importe,a.importe_exento
	FROM timbrado_conceptos a 
	INNER JOIN timbrado_cfdi b ON a.id_cfdi = b.id_cfdi 
	WHERE  a.cancelado = 'f' 
	and b.cancelado = 'f' 
	AND b.nss != '' 
    AND b.nss != ' '
    AND b.nss is not null 
    AND b.nss != '0'
    AND b.id_cfdi = ANY(ARRAY[434373,436466,448597,465816,541255,
		543338,548761,553317,553977,557067,557735,555439,560849,558750,561519,558562,
		565302,562347,564632,562534,566318,568010,569088,566131,568417,569445,569181,567436,
		567673,566516,567196,572872,572202,570103,569916,574076,573889,576845,576175,578535])
	ORDER BY a.id_cfdi,a.tipo_concepto,a.clave,a.importe 
) TO '/var/www/html/siacbem/SIACBEM/Timbrados2/Excepciones_2020/04_03_2021/Excepciones_de_2020_extraido_12_08_2021_conceptos.txt' DELIMITER ',' 


/*
	funcion para comparar totales entre CFDI y Conceptos
	Se le pasa un arreglo de los id_cfdi a consultar en formato Array[1,2,3]
*/
-- funcion Comparar totales entre CFDI y Conceptos
SELECT *
FROM timbrado_compara_totales(Array[434373,436466,448597]);


/**
* Retimbrar tal cual el registro
*/
INSERT INTO timbrado_cfdi_2021(
    ct,nombre_ct,filiacion,origen_recurso,monto_recurso_propio,receptor_nombre,receptor_rfc,tipo_nomina,fecha_pago,
    fecha_inicial_pago,fecha_final_pago,dias_pagados,subsidio_causado,total_percepciones,total_deducciones,total_otros_pagos,total_liquido,
    registro_patronal,receptor_curp,nss,fecha_ingreso,antiguedad,tipo_contrato,sindicalizado,tipo_jornada,tipo_regimen,no_empleado,departamento,
    puesto,riesgo_puesto,perioricidad_pago,salario_base,salario_diario_integrado,entidad_federativa,total_sueldos,total_gravado,total_exento,
    total_otras_deducciones,total_impuestos_retenidos, qna, id_nomina, id_cfdi_original, fecha_sistema

)
SELECT 
    ct,nombre_ct,filiacion,origen_recurso,monto_recurso_propio,receptor_nombre,receptor_rfc,tipo_nomina,fecha_pago,
    fecha_inicial_pago,fecha_final_pago,dias_pagados,subsidio_causado,total_percepciones,total_deducciones,total_otros_pagos,total_liquido,
    registro_patronal,receptor_curp,nss,fecha_ingreso,antiguedad,tipo_contrato,sindicalizado,tipo_jornada,tipo_regimen,no_empleado,departamento,
    puesto,riesgo_puesto,perioricidad_pago,salario_base,salario_diario_integrado,entidad_federativa,total_sueldos,total_gravado,total_exento,
    total_otras_deducciones,total_impuestos_retenidos, qna, id_nomina, 485039, now()
   FROM timbrado_cfdi_2021
   WHERE id_cfdi = 485039
  RETURNING id_cfdi 

  -- Nuevo id_cfdi = 1194112 


INSERT INTO timbrado_conceptos_2021(id_cfdi, clave_plaza, tipo_concepto, tipo, clave, concepto, importe, importe_exento, id_pago, id_conceptos_original)
SELECT 
    1194112,a.clave_plaza,a.tipo_concepto,tipo,a.clave as clave,a.concepto,a.importe,a.importe_exento, a.id_pago, a.id_conceptos
FROM timbrado_conceptos_2021 a
WHERE id_cfdi =  485039
RETURNING id_conceptos


/**
* Excepciones de cancelar una parte del pago
* 1 se procesa de nuevo el pre
* 2 cancelar el registro anterior
* 3 referenciar el pago cancelado en el nuevo (id_cfdi_original)
*/
SELECT * FROM 
timbrado_excepciones_referencia_ids(466700, 1194116)


2do registro 1194114

3er registro 1194116

4to registro 1194118 anterior 466817

5to registro  1194120 anterior 468662

6to registro 1194122 anterior 472356



SELECT 
	id_cfdi_original,timbrado_cfdi_2021.id_cfdi,ct,nombre_ct,filiacion,origen_recurso,monto_recurso_propio,receptor_nombre,receptor_rfc,tipo_nomina,fecha_pago,
	fecha_inicial_pago,fecha_final_pago,dias_pagados,subsidio_causado,total_percepciones,total_deducciones,total_otros_pagos,total_liquido,
	registro_patronal,receptor_curp,nss,fecha_ingreso,antiguedad,tipo_contrato,sindicalizado,tipo_jornada,tipo_regimen,no_empleado,departamento,
	puesto,riesgo_puesto,perioricidad_pago,salario_base,salario_diario_integrado,entidad_federativa,total_sueldos,total_gravado,total_exento,
	total_otras_deducciones,total_impuestos_retenidos
FROM timbrado_cfdi_2021 
INNER JOIN timbrado_conceptos_2021 ON timbrado_conceptos_2021.id_cfdi = timbrado_cfdi_2021.id_cfdi 
WHERE timbrado_conceptos_2021.cancelado = 'f' 
AND timbrado_cfdi_2021.cancelado = 'f'
AND timbrado_cfdi_2021.nss != '' 
AND  timbrado_cfdi_2021.nss != ' ' 
AND timbrado_cfdi_2021.nss is not null 
AND timbrado_cfdi_2021.nss != '0' 
AND timbrado_cfdi_2021.id_cfdi = ANY(ARRAY[1194112,1194114,1194116,1194118,1194120,1194122])
GROUP BY timbrado_cfdi_2021.id_cfdi 
ORDER BY timbrado_cfdi_2021.id_cfdi



SELECT  
	a.id_conceptos_original,a.id_conceptos,a.id_cfdi,a.clave_plaza,a.tipo_concepto,lpad(tipo,3,'0'),lpad(clave,3,'0'),a.concepto,a.importe,a.importe_exento
FROM timbrado_conceptos_2021 a 
INNER JOIN timbrado_cfdi_2021 b ON a.id_cfdi = b.id_cfdi 
WHERE  a.cancelado = 'f' 
and b.cancelado = 'f' 
AND b.nss != '' 
AND b.nss != ' '
AND b.nss is not null 
AND b.nss != '0'
AND b.id_cfdi = ANY(ARRAY[1194112,1194114,1194116,1194118,1194120,1194122])
ORDER BY a.id_cfdi,a.tipo_concepto,a.clave,a.importe 