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
	timbrado_cfdi.id_cfdi,ct,nombre_ct,filiacion,origen_recurso,monto_recurso_propio,receptor_nombre,receptor_rfc,tipo_nomina,fecha_pago,fecha_inicial_pago,fecha_final_pago,dias_pagados,subsidio_causado,total_percepciones,total_deducciones,total_otros_pagos,total_liquido,registro_patronal,recepetor_curp,nss,fecha_ingreso,antiguedad,tipo_contrato,sindicalizado,tipo_jornada,tipo_regimen,no_empleado,departamento,puesto,riesgo_puesto,perioricidad_pago,salario_base,salario_diario_integrado,entidad_federativa,total_sueldos,total_gravado,total_exento,total_otras_deducciones,total_impuestos_retenidos
	FROM timbrado_cfdi 
	INNER JOIN timbrado_conceptos ON timbrado_conceptos.id_cfdi = timbrado_cfdi.id_cfdi 
	WHERE timbrado_conceptos.cancelado = 'f' 
	AND timbrado_cfdi.cancelado = 'f'
	AND timbrado_cfdi.nss != '' 
    AND  timbrado_cfdi.nss != ' ' 
    AND timbrado_cfdi.nss is not null 
    AND timbrado_cfdi.nss != '0' 
    AND timbrado_cfdi.id_cfdi = ANY(ARRAY[434373,436466,448597,465816,541255,
		543338,548761,553317,553977,557067,557735,555439,560849,558750,561519,558562,
		565302,562347,564632,562534,566318,568010,569088,566131,568417,569445,569181,567436,
		567673,566516,567196,572872,572202,570103,569916,574076,573889,576845,576175,578535])
	GROUP BY timbrado_cfdi.id_cfdi 
	ORDER BY timbrado_cfdi.id_cfdi
) TO '/var/www/html/siacbem/SIACBEM/Timbrados2/Excepciones_2020/04_03_2021/Excepciones_de_2020_extraido_04_03_2021_cfdi.txt' DELIMITER ',' 


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
) TO '/var/www/html/siacbem/SIACBEM/Timbrados2/Excepciones_2020/04_03_2021/Excepciones_de_2020_extraido_04_03_2021_conceptos.txt' DELIMITER ',' 


/*
	funcion para comparar totales entre CFDI y Conceptos
	Se le pasa un arreglo de los id_cfdi a consultar en formato Array[1,2,3]
*/
-- funcion Comparar totales entre CFDI y Conceptos
SELECT *
FROM timbrado_compara_totales(Array[434373,436466,448597]);