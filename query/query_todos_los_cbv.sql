
SELECT
(c.paterno||' '||c.materno||' '||c.nombre)as empleado,
categoria||'/'||numero_plz||'/'||numero_hr as clave,clave_tipo_nombramiento
FROM nominas_sispagos a 
INNER JOIN pagos_sispagos b ON a.id_nomina = b.id_nomina
INNER JOIN empleados c ON c.id_empleado = b.id_empleado
WHERE a.id_nomina = 883 AND
categoria = 'CBV' AND
CAST(clave_tipo_nombramiento as int) not in(12)
GROUP BY c.paterno,c.materno,c.nombre,
categoria,numero_plz,numero_hr,clave_tipo_nombramiento
ORDER BY c.paterno,c.materno,c.nombre