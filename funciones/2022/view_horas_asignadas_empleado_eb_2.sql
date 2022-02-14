CREATE VIEW view_horas_asignadas_empleado_eb AS
(
SELECT 
plan.id_plantilla_base_docente_rh,
plan.id_empleado,
plan.id_estructura_ocupacional,
subp.id_subprograma,
subp.nombre_subprograma,
ppa.horas_grupo_base as horas_grupo,
materia.materia,
'Básico' AS componente,
gpos.nombre_grupo,
catego.categoria_padre,
COALESCE((
	SELECT 
		CASE WHEN (tl.id_tramite_licencia is not null AND now()::date <= tl.fecha_hasta) THEN 1 ELSE 0 END
	FROM tramites_licencias_asignaciones tla 
	INNER JOIN tramites_licencias tl ON tl.id_tramite_licencia = tla.id_tramite_licencia 
	WHERE tla.id_asignacion = ppa.id_profesor_asignado_base  
	AND tla.id_componente = 1
	AND tl.id_cat_tramite_status = 3
),0) AS licencia,
--CASE WHEN (tl.id_tramite_licencia is not null AND now()::date <= tl.fecha_hasta) THEN 1 ELSE 0 END AS licencia,
CASE WHEN (tb.id_tramite_baja is not null) THEN 1 ELSE 0 END AS baja
FROM profesores_profesor_asignado_base ppa
INNER JOIN profesor_asignado_base pa ON pa.id_profesor_asignado_base = ppa.id_profesor_asignado_base
INNER JOIN plantilla_base_docente_rh plan ON plan.id_plantilla_base_docente_rh = ppa.id_plantilla_base_docente_rh
INNER JOIN subprogramas subp ON subp.id_subprograma = plan.id_subprograma
INNER JOIN detalle_materias detalle ON detalle.id_detalle_materia = pa.id_detalle_materia
INNER JOIN cat_materias materia ON materia.id_materia = detalle.id_materia
INNER JOIN grupos_estructura_base gpos ON gpos.id_grupo_estructura_base = pa.id_grupo_estructura_base
INNER JOIN cat_categorias_padre catego ON catego.id_cat_categoria_padre = plan.id_cat_categoria_padre
LEFT JOIN tramites_licencias_asignaciones tla ON tla.id_asignacion = ppa.id_profesor_asignado_base  AND tla.id_componente = 1
LEFT JOIN tramites_licencias tl ON tl.id_tramite_licencia = tla.id_tramite_licencia AND tl.id_cat_tramite_status = 3
LEFT JOIN tramites_bajas_plazas_docente tbp ON tbp.id_plantilla_docente_rh = plan.id_plantilla_base_docente_rh
LEFT JOIN tramites_bajas tb ON tb.id_tramite_baja = tbp.id_tramite_baja AND tb.id_cat_tramite_status = 3
WHERE
	plan.revision_rh = true
)

UNION ALL

(
SELECT 
plan.id_plantilla_base_docente_rh,
plan.id_empleado,
plan.id_estructura_ocupacional,
subp.id_subprograma,
subp.nombre_subprograma,
ppa.horas_grupo_capacitacion as horas_grupo,
materia.materia,
'Capacitación' AS componente,
gpos.nombre_grupo_capacitacion,
catego.categoria_padre,
COALESCE((
	SELECT 
		CASE WHEN (tl.id_tramite_licencia is not null AND now()::date <= tl.fecha_hasta) THEN 1 ELSE 0 END
	FROM tramites_licencias_asignaciones tla 
	INNER JOIN tramites_licencias tl ON tl.id_tramite_licencia = tla.id_tramite_licencia 
	WHERE tla.id_asignacion = ppa.id_profesor_asignado_capacitacion  
	AND tla.id_componente = 3
	AND tl.id_cat_tramite_status = 3
),0) AS licencia,
-- CASE WHEN (tl.id_tramite_licencia is not null AND now()::date <= tl.fecha_hasta) THEN 1 ELSE 0 END AS licencia,
CASE WHEN (tb.id_tramite_baja is not null) THEN 1 ELSE 0 END AS baja
FROM profesores_profesor_asignado_capacitacion ppa
INNER JOIN profesor_asignado_capacitacion pa ON pa.id_profesor_asignado_capacitacion = ppa.id_profesor_asignado_capacitacion
INNER JOIN plantilla_base_docente_rh plan ON plan.id_plantilla_base_docente_rh = ppa.id_plantilla_base_docente_rh
INNER JOIN subprogramas subp ON subp.id_subprograma = plan.id_subprograma
INNER JOIN detalle_materias detalle ON detalle.id_detalle_materia = pa.id_detalle_materia
INNER JOIN cat_materias materia ON materia.id_materia = detalle.id_materia
INNER JOIN grupos_capacitacion gpos ON gpos.id_grupo_capacitacion = pa.id_grupo_capacitacion
INNER JOIN cat_categorias_padre catego ON catego.id_cat_categoria_padre = plan.id_cat_categoria_padre
--LEFT JOIN tramites_licencias_asignaciones tla ON tla.id_asignacion = ppa.id_profesor_asignado_capacitacion  AND tla.id_componente = 3
--LEFT JOIN tramites_licencias tl ON tl.id_tramite_licencia = tla.id_tramite_licencia AND tl.id_cat_tramite_status = 3
LEFT JOIN tramites_bajas_plazas_docente tbp ON tbp.id_plantilla_docente_rh = plan.id_plantilla_base_docente_rh
LEFT JOIN tramites_bajas tb ON tb.id_tramite_baja = tbp.id_tramite_baja AND tb.id_cat_tramite_status = 3
WHERE
	plan.revision_rh = true
)

UNION ALL

(
SELECT 
plan.id_plantilla_base_docente_rh,
plan.id_empleado,
plan.id_estructura_ocupacional,
subp.id_subprograma,
subp.nombre_subprograma,
ppa.horas_grupo_optativas as horas_grupo,
materia.materia,
'Optativas' AS componente,
gpos.nombre_grupo_optativas,
catego.categoria_padre,
COALESCE((
	SELECT 
		CASE WHEN (tl.id_tramite_licencia is not null AND now()::date <= tl.fecha_hasta) THEN 1 ELSE 0 END
	FROM tramites_licencias_asignaciones tla 
	INNER JOIN tramites_licencias tl ON tl.id_tramite_licencia = tla.id_tramite_licencia 
	WHERE tla.id_asignacion = ppa.id_profesor_asignado_optativa  
	AND tla.id_componente = 2
	AND tl.id_cat_tramite_status = 3
),0) AS licencia,
--CASE WHEN (tl.id_tramite_licencia is not null AND now()::date <= tl.fecha_hasta) THEN 1 ELSE 0 END AS licencia,
CASE WHEN (tb.id_tramite_baja is not null) THEN 1 ELSE 0 END AS baja
FROM profesores_profesor_asignado_optativas ppa
INNER JOIN profesor_asignado_optativas pa ON pa.id_profesor_asignado_optativa = ppa.id_profesor_asignado_optativa
INNER JOIN plantilla_base_docente_rh plan ON plan.id_plantilla_base_docente_rh = ppa.id_plantilla_base_docente_rh
INNER JOIN subprogramas subp ON subp.id_subprograma = plan.id_subprograma
INNER JOIN detalle_materias detalle ON detalle.id_detalle_materia = pa.id_detalle_materia
INNER JOIN cat_materias materia ON materia.id_materia = detalle.id_materia
INNER JOIN grupos_optativas gpos ON gpos.id_grupo_optativa = pa.id_grupo_optativa
INNER JOIN cat_categorias_padre catego ON catego.id_cat_categoria_padre = plan.id_cat_categoria_padre
--LEFT JOIN tramites_licencias_asignaciones tla ON tla.id_asignacion = ppa.id_profesor_asignado_optativa  AND tla.id_componente = 2
--LEFT JOIN tramites_licencias tl ON tl.id_tramite_licencia = tla.id_tramite_licencia AND tl.id_cat_tramite_status = 3
LEFT JOIN tramites_bajas_plazas_docente tbp ON tbp.id_plantilla_docente_rh = plan.id_plantilla_base_docente_rh
LEFT JOIN tramites_bajas tb ON tb.id_tramite_baja = tbp.id_tramite_baja AND tb.id_cat_tramite_status = 3
WHERE
	plan.revision_rh = true
)

UNION ALL

(
SELECT 
plan.id_plantilla_base_docente_rh,
plan.id_empleado,
plan.id_estructura_ocupacional,
subp.id_subprograma,
subp.nombre_subprograma,
ppa.horas_grupo_paraescolares as horas_grupo,
materia.nombre AS materia,
'Paraescolares' AS componente,
gpos.nombre,
catego.categoria_padre,
COALESCE((
	SELECT 
		CASE WHEN (tl.id_tramite_licencia is not null AND now()::date <= tl.fecha_hasta) THEN 1 ELSE 0 END
	FROM tramites_licencias_asignaciones tla 
	INNER JOIN tramites_licencias tl ON tl.id_tramite_licencia = tla.id_tramite_licencia 
	WHERE tla.id_asignacion = ppa.id_profesor_asignado_paraescolares  
	AND tla.id_componente = 4
	AND tl.id_cat_tramite_status = 3
),0) AS licencia,
--CASE WHEN (tl.id_tramite_licencia is not null AND now()::date <= tl.fecha_hasta) THEN 1 ELSE 0 END AS licencia,
CASE WHEN (tb.id_tramite_baja is not null) THEN 1 ELSE 0 END AS baja
FROM profesores_profesor_asignado_paraescolares ppa
INNER JOIN profesor_asignado_paraescolares pa ON pa.id_profesor_asignado_paraescolares = ppa.id_profesor_asignado_paraescolares
INNER JOIN plantilla_base_docente_rh plan ON plan.id_plantilla_base_docente_rh = ppa.id_plantilla_base_docente_rh
INNER JOIN subprogramas subp ON subp.id_subprograma = plan.id_subprograma
INNER JOIN cat_materias_paraescolares materia ON materia.id_paraescolar = ppa.id_cat_materias_paraescolares
INNER JOIN grupos_paraescolares gpos ON gpos.id_grupo_paraescolar = pa.id_grupo_paraescolares
INNER JOIN cat_categorias_padre catego ON catego.id_cat_categoria_padre = plan.id_cat_categoria_padre
LEFT JOIN tramites_licencias_asignaciones tla ON tla.id_asignacion = ppa.id_profesor_asignado_paraescolares  AND tla.id_componente = 2
LEFT JOIN tramites_licencias tl ON tl.id_tramite_licencia = tla.id_tramite_licencia AND tl.id_cat_tramite_status = 3
LEFT JOIN tramites_bajas_plazas_docente tbp ON tbp.id_plantilla_docente_rh = plan.id_plantilla_base_docente_rh
LEFT JOIN tramites_bajas tb ON tb.id_tramite_baja = tbp.id_tramite_baja AND tb.id_cat_tramite_status = 3
WHERE
	plan.revision_rh = true
)