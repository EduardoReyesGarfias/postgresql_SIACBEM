
CREATE OR REPLACE VIEW view_horas_asignadas_empleado_tf as 
(
-- básico
SELECT 
	a.id_empleado,
	a.id_estructura_ocupacional,
	b.id_cat_categoria_padre,
	b.categoria_padre, 
	SUM(DISTINCT a.horas_grupo) as horas_grupo,
	a.id_tramites_licencias_asignaciones,
	a.id_tramites_licencias_asignaciones_tf,
	1 as id_componente,
	(
		SELECT 
		(
			CASE WHEN aa.id_tramite_licencia_asignacion_tf IS NOT NULL THEN
				true
			ELSE
				false
			END		
		)
		FROM tramites_licencias_asignaciones_tf aa
		INNER JOIN tramites_licencias bb on aa.id_tramite_licencia = bb.id_tramite_licencia
		WHERE aa.id_componente = 1
		AND bb.id_cat_tramite_status = 3
		AND bb.id_estructura_ocupacional = a.id_estructura_ocupacional
		AND aa.id_asignacion = a.id_asignacion_tiempo_fijo_basico
	) as licencia
FROM asignacion_tiempo_fijo_basico a
INNER JOIN cat_categorias_padre b ON a.id_cat_categoria_padre = b.id_cat_categoria_padre
GROUP BY 
	a.id_empleado,
	a.id_estructura_ocupacional,
	b.id_cat_categoria_padre,
	b.categoria_padre,
	a.id_tramites_licencias_asignaciones,
	a.id_tramites_licencias_asignaciones_tf,
	a.id_asignacion_tiempo_fijo_basico
)
UNION ALL
(
-- capacitación
SELECT 
	a.id_empleado,
	a.id_estructura_ocupacional,
	b.id_cat_categoria_padre,
	b.categoria_padre, 
	SUM(DISTINCT a.horas_grupo) as horas_grupo,
	a.id_tramites_licencias_asignaciones,
	a.id_tramites_licencias_asignaciones_tf,
	3 as id_componente,
	(
		SELECT 
		(
			CASE WHEN aa.id_tramite_licencia_asignacion_tf IS NOT NULL THEN
				true
			ELSE
				false
			END		
		)
		FROM tramites_licencias_asignaciones_tf aa
		INNER JOIN tramites_licencias bb on aa.id_tramite_licencia = bb.id_tramite_licencia
		WHERE aa.id_componente = 3
		AND bb.id_cat_tramite_status = 3
		AND bb.id_estructura_ocupacional = a.id_estructura_ocupacional
		AND aa.id_asignacion = a.id_asignacion_tiempo_fijo_capacitacion
	) as licencia
FROM asignacion_tiempo_fijo_capacitacion a
INNER JOIN cat_categorias_padre b ON a.id_cat_categoria_padre = b.id_cat_categoria_padre
GROUP BY 
	a.id_empleado,
	a.id_estructura_ocupacional, 
	b.id_cat_categoria_padre,
	b.categoria_padre,
	a.id_tramites_licencias_asignaciones,
	a.id_tramites_licencias_asignaciones_tf,
	a.id_asignacion_tiempo_fijo_capacitacion
)
UNION ALL
(
-- optativas
SELECT 
	a.id_empleado,a.id_estructura_ocupacional,
	b.id_cat_categoria_padre,
	b.categoria_padre, 
	SUM(DISTINCT a.horas_grupo) as horas_grupo,
	a.id_tramites_licencias_asignaciones,
	a.id_tramites_licencias_asignaciones_tf,
	2 as id_componente,
	(
		SELECT 
		(
			CASE WHEN aa.id_tramite_licencia_asignacion_tf IS NOT NULL THEN
				true
			ELSE
				false
			END		
		)
		FROM tramites_licencias_asignaciones_tf aa
		INNER JOIN tramites_licencias bb on aa.id_tramite_licencia = bb.id_tramite_licencia
		WHERE aa.id_componente = 2
		AND bb.id_cat_tramite_status = 3
		AND bb.id_estructura_ocupacional = a.id_estructura_ocupacional
		AND aa.id_asignacion = a.id_asignacion_tiempo_fijo_optativa
	) as licencia
FROM asignacion_tiempo_fijo_optativas a
INNER JOIN cat_categorias_padre b ON a.id_cat_categoria_padre = b.id_cat_categoria_padre
GROUP BY  
	a.id_empleado,
	a.id_estructura_ocupacional,
	b.id_cat_categoria_padre,
	b.categoria_padre,
	a.id_tramites_licencias_asignaciones,
	a.id_tramites_licencias_asignaciones_tf,
	a.id_asignacion_tiempo_fijo_optativa
)
UNION ALL
(
-- paraescolares
SELECT 
	a.id_empleado,
	a.id_estructura_ocupacional,
	b.id_cat_categoria_padre,
	b.categoria_padre, 
	SUM(DISTINCT a.horas_grupo) as horas_grupo,
	a.id_tramites_licencias_asignaciones,
	a.id_tramites_licencias_asignaciones_tf,
	4 as id_componente,
	(
		SELECT 
		(
			CASE WHEN aa.id_tramite_licencia_asignacion_tf IS NOT NULL THEN
				true
			ELSE
				false
			END		
		)
		FROM tramites_licencias_asignaciones_tf aa
		INNER JOIN tramites_licencias bb on aa.id_tramite_licencia = bb.id_tramite_licencia
		WHERE aa.id_componente = 4
		AND bb.id_cat_tramite_status = 3
		AND bb.id_estructura_ocupacional = a.id_estructura_ocupacional
		AND aa.id_asignacion = a.id_asignacion_tiempo_fijo_paraescolares
	) as licencia
FROM asignacion_tiempo_fijo_paraescolares a
INNER JOIN cat_categorias_padre b ON a.id_cat_categoria_padre = b.id_cat_categoria_padre
GROUP BY  
	a.id_empleado,
	a.id_estructura_ocupacional,
	b.id_cat_categoria_padre,
	b.categoria_padre,
	a.id_tramites_licencias_asignaciones,
	a.id_tramites_licencias_asignaciones_tf,
	a.id_asignacion_tiempo_fijo_paraescolares
)


SELECT *
FROM view_horas_asignadas_empleado_tf
WHERE id_empleado = 5181
AND id_estructura_ocupacional = 27
AND categoria_padre = 'EH4%'
