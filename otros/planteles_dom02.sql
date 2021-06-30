SELECT a.id_plaza,subprogramas.nombre_subprograma,
cat_categorias.descripcion_planteles,
cat_categorias.categoria, cat_categorias.descripcion,
subprogramas.clave_subprograma, subprogramas.clave_extension_u_organica,
subprogramas.id_programa
,(
	SELECT c.paterno||' '||c.materno||' '||c.nombre 
	FROM plantilla_base_administrativo_plantel b 
	INNER JOIN empleados c ON c.id_empleado = b.id_empleado
	WHERE b.id_subprograma = 92 and id_estructura_ocupacional = 26
	and b.id_plaza = a.id_plaza
)as empleado
,(
	SELECT e.profesion 
	FROM plantilla_base_administrativo_plantel b 
	INNER JOIN empleados c ON c.id_empleado = b.id_empleado
	LEFT JOIN curricula_estudios_empleados d ON d.id_empleado = c.id_empleado
	LEFT JOIN cat_profesiones e ON e.id_profesion = d.id_profesion
	WHERE b.id_subprograma = 92 and id_estructura_ocupacional = 26
	and b.id_plaza = a.id_plaza
)as profesion
,(
	CASE WHEN cat_tipo_plaza_admon.des_tipo_plaza = 'BASE' THEN
		14
	ELSE
		15
	END
) as alta

,( SELECT cat_estructuras_ocupacionales.periodo FROM cat_estructuras_ocupacionales 
WHERE cat_estructuras_ocupacionales .id_estructura_ocupacional = 26
)as periodo
FROM plazas a 
JOIN subprogramas ON a.id_subprograma = subprogramas.id_subprograma 
JOIN cat_categorias ON a.id_categoria=cat_categorias.id_categoria
INNER JOIN cat_tipo_plaza_admon ON cat_tipo_plaza_admon.id_tipo_plaza_admon = a.id_tipo_plaza_admon
WHERE a.id_subprograma = 92
--and id_status_plaza_estructura_ocupacional<3
and id_status_plaza_estructura_ocupacional in(1,2,8)
ORDER By a.id_plaza

