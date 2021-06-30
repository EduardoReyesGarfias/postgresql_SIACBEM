SELECT table_name --seleccionamos solo la columna del nombre de la tabla
FROM information_schema.tables --seleccionamos la información del esquema 
WHERE table_schema='public' --las tablas se encuentran en el esquema publico
AND table_name ilike '%jorna%'

SELECT filiacion, subprograma, clave_plz, numero_plz, hrs, tipo_nombramiento,suple_a, desde, hasta, motivo_movimiento
,(
	SELECT xa.descripcion
	FROM cat_tipo_movimiento_personal xa
	WHERE CAST(xa.codigo as character varying) = a.motivo_movimiento
	LIMIT 1
) as desc_mov 
FROM jornadas_sispagos_trigger a
WHERE filiacion = 'CASR780508000'
AND desde > 202101
AND ((CAST(motivo_movimiento as smallint) between 6 AND 19) OR motivo_movimiento = '59' OR motivo_movimiento = '14' OR motivo_movimiento = '35')
--AND (desc_mov ilike 'ALTA%' OR desc_mov ilike 'BASIFICACION DE PLAZA%')

"18"

LIMIT 1

SELECT *
FROM subprogramas
WHERE clave_subprograma in('168','139')


SELECT *
FROM plantilla_base_docente_rh
WHERE id_empleado = 1153

SELECT *
FROM subprogramas
WHERE id_subprograma = 65

SELECT *
FROM empleados
WHERE id_empleado = 1153


SELECT * 
FROM cat_tipo_movimiento_personal
--WHERE codigo in (40,18,14)
ORDER BY descripcion, codigo ASC


