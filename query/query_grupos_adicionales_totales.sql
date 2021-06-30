(SELECT 
(
	case when id_tipo_periodo = 1 THEN
		'Base'
	WHEN id_tipo_periodo = 2 THEN 
		'Grupo Adicional'
	ELSE
		'Grpo Adicional Fuera de plantel'
	END
) as tipo_grupo
,'Básico' as componente, count(*)
,substring(a.nombre_grupo,1,1)
FROM grupos_estructura_base a
INNER JOIN horas_autorizadas b ON b.id_hora_autorizada = a.id_hora_autorizada
INNER JOIN grupos c ON b.id_grupo = c.id_grupo
INNER JOIN grupos_combinaciones_planes gc ON gc.id_grupo_combinacion_plan = c.id_grupo_combinacion_plan
INNER JOIN periodos d ON c.id_periodo = d.id_periodo
WHERE 
d.id_estructura_ocupacional = 28
--AND a.nombre_grupo like '%1%'
GROUP BY id_tipo_periodo, substring(a.nombre_grupo,1,1)
)
UNION ALL
(
-- capacitacion
SELECT
(
	case when id_tipo_periodo = 1 THEN
		'Base'
	WHEN id_tipo_periodo = 2 THEN 
		'Grupo Adicional'
	ELSE
		'Grpo Adicional Fuera de plantel'
	END
) as tipo_grupo
,'Capacitación' as componente, count(*)
,substring(a.nombre_grupo_capacitacion,1,1)
FROM grupos_capacitacion a
INNER JOIN horas_autorizadas b ON a.id_hora_autorizada = b.id_hora_autorizada
INNER JOIN grupos c ON c.id_grupo = b.id_grupo
INNER JOIN periodos d ON d.id_periodo = c.id_periodo
INNER JOIN grupos_combinaciones_planes e ON e.id_grupo_combinacion_plan = c.id_grupo_combinacion_plan
WHERE 
d.id_estructura_ocupacional = 28
and id_formacion_trabajo is not null
--and nombre_grupo_capacitacion like '$semestre%'
GROUP BY id_tipo_periodo, substring(a.nombre_grupo_capacitacion,1,1)
)
UNION ALL
(
-- optativas
SELECT
(
	case when id_tipo_periodo = 1 THEN
		'Base'
	WHEN id_tipo_periodo = 2 THEN 
		'Grupo Adicional'
	ELSE
		'Grpo Adicional Fuera de plantel'
	END
) as tipo_grupo
,'Optativas' as componente, count(*)
,substring(a.nombre_grupo_optativas,1,1)
FROM grupos_optativas a
INNER JOIN horas_autorizadas b ON a.id_hora_autorizada = b.id_hora_autorizada
INNER JOIN grupos c ON c.id_grupo = b.id_grupo
INNER JOIN periodos d ON d.id_periodo = c.id_periodo
INNER JOIN grupos_combinaciones_planes e ON e.id_grupo_combinacion_plan = c.id_grupo_combinacion_plan
LEFT JOIN grupos_optativas_formacion f ON f.id_grupo_optativa = a.id_grupo_optativa
WHERE 
d.id_estructura_ocupacional = 28
AND f.id_formacion_propedeutica IS NOT null
GROUP BY id_tipo_periodo, substring(a.nombre_grupo_optativas,1,1)
)
UNION ALL
(
-- paraescolares
SELECT 
(
	case when id_tipo_periodo = 1 THEN
		'Base'
	WHEN id_tipo_periodo = 2 THEN 
		'Grupo Adicional'
	ELSE
		'Grpo Adicional Fuera de plantel'
	END
) as tipo_grupo
,'Paraescolares' as componente, count(*)
,substring(a.nombre,1,1)
FROM grupos_paraescolares a
INNER JOIN horas_autorizadas b ON b.id_hora_autorizada = a.id_hora_autorizada
INNER JOIN grupos d ON d.id_grupo = b.id_grupo
INNER JOIN periodos e ON e.id_periodo = d.id_periodo
WHERE id_estructura_ocupacional = 28 
--and a.nombre like '".$semestre."%'
GROUP BY id_tipo_periodo, substring(a.nombre,1,1)
)