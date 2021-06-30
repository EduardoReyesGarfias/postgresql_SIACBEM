SELECT (CAST (2 as int))as id_componente,semestre,i.id_detalle_materia,sum(hora_semana_mes)as hora_semana_mes,materia,sum(hora_semana_mes)as hora_semana_mes
,(sum(hora_semana_mes)-COALESCE(sum(l.horas_grupo_optativas),0))AS hrs_vacantes 
FROM grupos_optativas a
INNER JOIN horas_autorizadas b ON a.id_hora_autorizada = b.id_hora_autorizada
INNER JOIN grupos c ON c.id_grupo = b.id_grupo
INNER JOIN periodos d ON d.id_periodo = c.id_periodo
INNER JOIN grupos_combinaciones_planes e ON e.id_grupo_combinacion_plan = c.id_grupo_combinacion_plan
LEFT JOIN grupos_optativas_formacion f ON f.id_grupo_optativa = a.id_grupo_optativa
LEFT JOIN cat_formacion_propedeutica g ON f.id_formacion_propedeutica = g.id_formacion_propedeutica 
LEFT JOIN materias_componente_propedeutico h ON g.id_formacion_propedeutica = h.id_formacion_propedeutica
LEFT JOIN detalle_materias i ON h.id_detalle_materia = i.id_detalle_materia and i.semestre =  CAST(substring(nombre_grupo_optativas from 1 for 1)as int)
LEFT JOIN cat_materias j ON i.id_materia = j.id_materia

LEFT JOIN profesor_asignado_optativas k ON k.id_grupo_optativa = a.id_grupo_optativa AND k.id_detalle_materia = i.id_detalle_materia
LEFT JOIN profesores_profesor_asignado_optativas l ON l.id_profesor_asignado_optativa = k.id_profesor_asignado_optativa

WHERE d.id_subprograma = 71 and d.id_estructura_ocupacional = 26
and 
(CASE WHEN(i.semestre = 1 OR i.semestre = 2) THEN
	i.id_plan_estudio in(id_plan_grupo_activo1)
	WHEN (i.semestre = 3 OR i.semestre = 4) THEN
		i.id_plan_estudio in(id_plan_grupo_activo2)
	WHEN (i.semestre = 5 OR i.semestre = 6) THEN
		i.id_plan_estudio in(id_plan_grupo_activo3)
	END
)
GROUP BY semestre,hora_semana_mes,materia,i.id_detalle_materia
