SELECT 
a.id_empleado_nuevo_ingreso,a.filiacion,a.nombre,a.paterno,a.materno,a.curp
,a.fecha_nacimiento,a.lugar_nacimiento,a.nombre_padre,a.nombre_madre,a.no_acta_nacimiento
,a.anio_acta_nacimiento,a.foja_acta_nacimiento,a.libro_acta_nacimiento,a.no_cartilla_militar
,a.estado_civil,a.nombre_esposo_a,a.calle,a.num_ext,a.num_int,a.colonia
,a.municipio,a.estado,a.id_cp,a.telefono,a.senales_visibles,a.estatura
,a.fecha_filiacion,a.lugar_filiacion,a.fecha_sistema
,(
	SELECT c.paterno||' '||c.materno||' '||c.nombre
	FROM responsables_por_oficina b 
	INNER JOIN empleados c ON c.id_empleado = b.id_empleado_reviso
	WHERE b.id_responsable_oficina = a.id_responsable_filiacion
) as reviso
,(
	SELECT e.paterno||' '||e.materno||' '||e.nombre
	FROM responsables_departamentos d 
	INNER JOIN empleados e ON e.id_empleado = d.id_empleado_responsable
	WHERE d.id_responsable_oficina = a.id_responsable_admon 
) as responsable
FROM empleados_nuevo_ingreso a 
WHERE a.id_empleado_nuevo_ingreso = 1

SELECT 
descripcion_rasgo_fisico_empleado||'-'||descripcion_caracteristica as descripcion
FROM empleado_caracteristicas a
INNER JOIN cat_caracteristicas_empleado b USING(id_caracteristica_empleado)
INNER JOIN cat_rasgos_fisicos_empleado c USING(id_rasgo_fisico_empleado)
WHERE a.id_empleado_nuevo_ingreso = 1
ORDER BY b.id_caracteristica_empleado


select * from responsables_departamentos


