SELECT 
a.id_cfdi,a.filiacion,a.receptor_nombre,a.receptor_rfc,a.recepetor_curp,c.consecu
,b.uuid
FROM timbrado_cfdi a
INNER JOIN timbrado_respuesta b ON a.id_cfdi = b.id_cfdi
INNER JOIN nominas_sispagos c ON c.id_nomina = CAST(a.nominas as int) 
WHERE consecu in('4811')
AND (a.cancelado = false OR a.devolucion = null)
ORDER BY c.consecu,a.id_Cfdi

4809 1
4810 176

copy (
	SELECT 
a.id_cfdi,a.filiacion,a.receptor_nombre,a.receptor_rfc,a.recepetor_curp,c.consecu
,b.uuid
FROM timbrado_cfdi a
INNER JOIN timbrado_respuesta b ON a.id_cfdi = b.id_cfdi
INNER JOIN nominas_sispagos c ON c.id_nomina = CAST(a.nominas as int) 
WHERE consecu in('4808','4809','4810','4811','4813')
AND (a.cancelado = false OR a.devolucion = null)
ORDER BY c.consecu,a.id_Cfdi
)
TO '/var/www/html/siacbem/SIACBEM/Timbrados2/a_cancelar_nominas_4808_4809_4810_4813.CSV'  
DELIMITER ';' CSV HEADER;



SELECT 
a.id_cfdi
FROM timbrado_cfdi a
INNER JOIN timbrado_respuesta b ON a.id_cfdi = b.id_cfdi
INNER JOIN nominas_sispagos c ON c.id_nomina = CAST(a.nominas as int) 
WHERE consecu in('4808','4809','4810','4811','4813')
AND (a.cancelado = false OR a.devolucion = null)
ORDER BY c.consecu,a.id_Cfdi

BEGIN;

UPDATE timbrado_cfdi SET cancelado = true WHERE id_cfdi in (
	SELECT 
	a.id_cfdi,cancelado
	FROM timbrado_cfdi a
	INNER JOIN timbrado_respuesta b ON a.id_cfdi = b.id_cfdi
	INNER JOIN nominas_sispagos c ON c.id_nomina = CAST(a.nominas as int) 
	WHERE consecu in('4808','4809','4810','4811','4813')
	ORDER BY c.consecu,a.id_Cfdi
);

commit;



/*******/

SELECT id_cfdi,cancelado
FROM timbrado_pre_cfdi a
INNER JOIN nominas_sispagos b ON b.id_nomina = CAST(a.nominas as int)
WHERE consecu in('4808','4809','4810')

BEGIN;
UPDATE timbrado_pre_cfdi SET cancelado = true WHERE id_cfdi in(
	SELECT a.id_cfdi
	FROM timbrado_pre_cfdi a
	INNER JOIN nominas_sispagos b ON b.id_nomina = CAST(a.nominas as int)
	WHERE consecu in('4808','4809','4810')
)
commit;

/*****/

BEGIN;
DELETE FROM timbrado_pre_cfdi a
WHERE a.id_cfdi in(
	SELECT *
	FROM timbrado_pre_cfdi a
	INNER JOIN nominas_sispagos b ON b.id_nomina = CAST(a.nominas as int)
	WHERE consecu in('4808')
);

commit;


BEGIN;

UPDATE timbrado_cfdi SET cancelado = true WHERE id_cfdi in(
	SELECT a.id_cfdi,cancelado
	FROM timbrado_cfdi a
	LEFT JOIN timbrado_respuesta b ON a.id_cfdi = b.id_cfdi
	LEFT JOIN nominas_sispagos c ON c.id_nomina = CAST(a.nominas as int) 
	WHERE consecu in('4808','4809','4810')
	AND b.id_cfdi is null
	ORDER BY c.consecu,a.id_Cfdi
);

commit;

