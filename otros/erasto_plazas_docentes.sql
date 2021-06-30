--COPY (
SELECT 
c.filiacion,c.nombre,c.paterno,c.materno,categoria,numero_plz,numero_hr,d.nombre_subprograma
FROM nominas_sispagos a
INNER JOIN pagos_sispagos b ON a.id_nomina = b.id_nomina
INNER JOIN empleados c ON c.filiacion = b.filiacion
INNER JOIN subprogramas d ON d.id_subprograma = b.id_subprograma
WHERE a.qnapago = '201906' and id_tipo_nomina = 1
and (categoria like 'CB%' OR categoria like 'EH%' OR categoria like 'TCB%')
GROUP BY c.filiacion,c.nombre,c.paterno,c.materno,categoria,numero_plz,numero_hr,d.nombre_subprograma
ORDER BY nombre,paterno,materno,categoria,numero_plz,numero_hr
--)
--TO '/var/www/html/siacbem/SIACBEM/PreTimbrado/plazas_docentes_03_04_2019.csv'  DELIMITER ';' CSV HEADER


