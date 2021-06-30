SELECT 
--*
a.id_plaza,b.nombre_subprograma as nom_subp,z.clave_sep,
(
	SELECT substring(nombre_subprograma from 24)
	FROM subprogramas
	WHERE nombre_subprograma ilike '%COORDINACIÓN SECTORIAL No. '||b.coordinacion||',%'
	AND fecha_fin IS NULL
	ORDER BY nombre_subprograma
	LIMIT 1
) as coordinacion,
h.paterno||' '||h.materno||' '||h.nombre as empleado,categoria,num_plz,descripcion,descripcion_planteles,
(
CASE WHEN d.des_tipo_plaza = 'BASE' THEN
14
ELSE
15
END
) as alta,
(
SELECT
STRING_AGG(xb.profesion,',' ORDER BY xc.nivel_grado_academico)
FROM curricula_estudios_empleados xa
INNER JOIN cat_profesiones xb ON xb.id_profesion = xa.id_profesion
INNER JOIN cat_grados_academicos xc ON xc.id_grado_academico = xb.id_grado_academico
INNER JOIN empleados xz ON xz.id_empleado = xa.id_empleado
INNER JOIN empleado_grados_academicos xy ON xy.id_empleado_grado_academico = xa.id_empleado_grado_academico 
WHERE xz.filiacion = h.filiacion
AND xc.nivel_grado_academico >= 23
)as profesion,
(
SELECT
STRING_AGG(xc.grado_academico,',' ORDER BY xc.nivel_grado_academico)
FROM curricula_estudios_empleados xa
INNER JOIN cat_profesiones xb ON xb.id_profesion = xa.id_profesion
INNER JOIN cat_grados_academicos xc ON xc.id_grado_academico = xb.id_grado_academico
INNER JOIN empleados xz ON xz.id_empleado = xa.id_empleado
INNER JOIN empleado_grados_academicos xy ON xy.id_empleado_grado_academico = xa.id_empleado_grado_academico 
WHERE xz.filiacion = h.filiacion
AND xc.nivel_grado_academico >= 23
)as grado_academico,
(
SELECT
STRING_AGG(
(CASE WHEN (xy.valida_archivo is null) THEN
	'PEN'
	WHEN (xy.valida_archivo = true) THEN
		'SI'
	WHEN (xy.valida_archivo = false) THEN
		'NO'
END)
,',' ORDER BY xc.nivel_grado_academico)
FROM curricula_estudios_empleados xa
INNER JOIN cat_profesiones xb ON xb.id_profesion = xa.id_profesion
INNER JOIN cat_grados_academicos xc ON xc.id_grado_academico = xb.id_grado_academico
INNER JOIN empleados xz ON xz.id_empleado = xa.id_empleado
INNER JOIN empleado_grados_academicos xy ON xy.id_empleado_grado_academico = xa.id_empleado_grado_academico 
WHERE xz.filiacion = h.filiacion
AND xc.nivel_grado_academico >= 23
)as validado,
prefijo_director||' '||nombre_director as director,prefijo_coordinador||' '||nombre_coordinador as coordinador
,puesto_director,puesto_coordinador,i.periodo
FROM plazas a
INNER JOIN subprogramas b ON a.id_subprograma = b.id_subprograma
INNER JOIN claves_sep z ON z.id_sep = b.id_sep
INNER JOIN cat_categorias c ON a.id_categoria = c.id_categoria
INNER JOIN cat_tipo_plaza_admon d ON d.id_tipo_plaza_admon = a.id_tipo_plaza_admon
INNER JOIN planteles_firmantes(133,27) pf ON 133 = b.id_subprograma 
LEFT JOIN notas_explicativas_plazas e ON e.id_plaza = a.id_plaza
LEFT JOIN cat_status_plaza_movimientos_personal f ON f.id_status_plaza_movimiento_personal = a.id_status_plaza_movimiento_personal
LEFT JOIN plantilla_base_administrativo_plantel g ON g.id_plaza = a.id_plaza AND g.id_subprograma = 133 AND g.id_estructura_ocupacional = 27
LEFT JOIN empleados h ON h.id_empleado = g.id_empleado
LEFT JOIN cat_estructuras_ocupacionales i ON i.id_estructura_ocupacional = g.id_estructura_ocupacional

WHERE a.id_subprograma = 133
AND a.id_status_plaza_estructura_ocupacional in(1,2,8)
AND (e.id_adcen = 4927 or e.id_adcen IS NULL)
ORDER BY a.id_plaza 



