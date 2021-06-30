
SELECT c.rfc,c.filiacion,c.nombre,c.paterno,c.materno,a.qnapago,a.consecu,c.email_institucional,c.email_institucional_alias 
,(substring(CAST(a.qnapago as text) from 0 for 5)||'/'||substring(CAST(a.qnapago as text) from 5 for 8)||'/'||a.consecu||'/') as ruta
,b.id_subprograma,d.id_cfdi
FROM nominas_sispagos a
INNER JOIN pagos_sispagos b ON a.id_nomina = b.id_nomina
INNER JOIN empleados c ON c.id_empleado = b.id_empleado
INNER JOIN subprogramas e ON e.id_subprograma = b.id_subprograma
LEFT JOIN timbrado_cfdi d ON d.filiacion = c.filiacion
WHERE a.id_nomina = 462 and d.nominas = '462' and cancelado is not true
GROUP BY c.rfc,c.filiacion,c.nombre,c.paterno,c.materno,a.qnapago,a.consecu,c.email_institucional,c.email_institucional_alias,b.id_subprograma,d.id_cfdi 
ORDER BY b.id_subprograma,c.paterno,c.materno,c.nombre

-- huetamo tiene 133 registros