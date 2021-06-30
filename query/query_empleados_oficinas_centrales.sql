SELECT d.nombre,d.paterno,d.materno
,d.curp,d.rfc,d.genero,d.fecha_nacimiento,d.nacionalidad,d.estado_civil,d.fecha_ingreso,d.lugar_nacimiento
,b.categoria,b.numero_plz,b.numero_hr,b.clave_tipo_nombramiento,c.nombre_subprograma
FROM nominas_sispagos a
INNER JOIN pagos_sispagos b ON a.id_nomina = b.id_nomina
INNER JOIN subprogramas c ON c.id_subprograma = b.id_subprograma
INNER JOIN empleados d ON d.id_empleado = b.id_empleado
WHERE a.qnapago = '201918'
AND c.coordinacion = 0
GROUP BY d.nombre,d.paterno,d.materno
,d.curp,d.rfc,d.genero,d.fecha_nacimiento,d.nacionalidad,d.estado_civil,d.fecha_ingreso,d.lugar_nacimiento
,b.categoria,b.numero_plz,b.numero_hr,b.clave_tipo_nombramiento,c.nombre_subprograma
ORDER BY c.nombre_subprograma,d.nombre,d.paterno,d.materno
