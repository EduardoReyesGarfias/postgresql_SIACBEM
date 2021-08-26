
CREATE OR REPLACE view view_horas_asignadas_empleado_tf as 
(
    -- basico
SELECT 
a.id_empleado,
a.id_estructura_ocupacional,
b.id_cat_categoria_padre,
b.categoria_padre,
a.horas_grupo,
a.id_tramites_licencias_asignaciones,
a.id_tramites_licencias_asignaciones_tf
FROM asignacion_tiempo_fijo_basico a
INNER JOIN cat_categorias_padre b ON a.id_cat_categoria_padre = b.id_cat_categoria_padre
--WHERE id_empleado = 4295
--AND id_estructura_ocupacional = 30
)
UNION ALL
(
    -- capacitacion
SELECT 
a.id_empleado,
a.id_estructura_ocupacional,
b.id_cat_categoria_padre,
b.categoria_padre,
a.horas_grupo,
a.id_tramites_licencias_asignaciones,
a.id_tramites_licencias_asignaciones_tf
FROM asignacion_tiempo_fijo_capacitacion a
INNER JOIN cat_categorias_padre b ON a.id_cat_categoria_padre = b.id_cat_categoria_padre
--WHERE id_empleado = 4295
--AND id_estructura_ocupacional = 30
)
UNION ALL 
(
    -- optativas
SELECT 
a.id_empleado,
a.id_estructura_ocupacional,
b.id_cat_categoria_padre,
b.categoria_padre,
a.horas_grupo,
a.id_tramites_licencias_asignaciones,
a.id_tramites_licencias_asignaciones_tf
FROM asignacion_tiempo_fijo_optativas a
INNER JOIN cat_categorias_padre b ON a.id_cat_categoria_padre = b.id_cat_categoria_padre
--WHERE id_empleado = 4295
--AND id_estructura_ocupacional = 30
)
UNION ALL
(
    -- paraescolares
SELECT 
a.id_empleado,
a.id_estructura_ocupacional,
b.id_cat_categoria_padre,
b.categoria_padre,
a.horas_grupo,
a.id_tramites_licencias_asignaciones,
a.id_tramites_licencias_asignaciones_tf
FROM asignacion_tiempo_fijo_paraescolares a
INNER JOIN cat_categorias_padre b ON a.id_cat_categoria_padre = b.id_cat_categoria_padre
--WHERE id_empleado = 4295
--AND id_estructura_ocupacional = 30
)
/*
(
-- básico
SELECT a.id_empleado,a.id_estructura_ocupacional,b.id_cat_categoria_padre,b.categoria_padre, SUM(DISTINCT a.horas_grupo) as horas_grupo
,a.id_tramites_licencias_asignaciones,a.id_tramites_licencias_asignaciones_tf
FROM asignacion_tiempo_fijo_basico a
INNER JOIN cat_categorias_padre b ON a.id_cat_categoria_padre = b.id_cat_categoria_padre
GROUP BY a.id_empleado,a,id_estructura_ocupacional,b.id_cat_categoria_padre,b.categoria_padre,a.id_tramites_licencias_asignaciones,a.id_tramites_licencias_asignaciones_tf
)
UNION ALL
(
-- capacitación
SELECT a.id_empleado,a.id_estructura_ocupacional,b.id_cat_categoria_padre,b.categoria_padre, SUM(DISTINCT a.horas_grupo) as horas_grupo
,a.id_tramites_licencias_asignaciones,a.id_tramites_licencias_asignaciones_tf
FROM asignacion_tiempo_fijo_capacitacion a
INNER JOIN cat_categorias_padre b ON a.id_cat_categoria_padre = b.id_cat_categoria_padre
GROUP BY a.id_empleado,a,id_estructura_ocupacional, b.id_cat_categoria_padre,b.categoria_padre,a.id_tramites_licencias_asignaciones,a.id_tramites_licencias_asignaciones_tf
)
UNION ALL
(
-- optativas
SELECT a.id_empleado,a.id_estructura_ocupacional,b.id_cat_categoria_padre,b.categoria_padre, SUM(DISTINCT a.horas_grupo) as horas_grupo
,a.id_tramites_licencias_asignaciones,a.id_tramites_licencias_asignaciones_tf
FROM asignacion_tiempo_fijo_optativas a
INNER JOIN cat_categorias_padre b ON a.id_cat_categoria_padre = b.id_cat_categoria_padre
GROUP BY  a.id_empleado,a,id_estructura_ocupacional,b.id_cat_categoria_padre,b.categoria_padre,a.id_tramites_licencias_asignaciones,a.id_tramites_licencias_asignaciones_tf
)
UNION ALL
(
-- paraescolares
SELECT a.id_empleado,a.id_estructura_ocupacional,b.id_cat_categoria_padre,b.categoria_padre, SUM(DISTINCT a.horas_grupo) as horas_grupo
,a.id_tramites_licencias_asignaciones,a.id_tramites_licencias_asignaciones_tf
FROM asignacion_tiempo_fijo_paraescolares a
INNER JOIN cat_categorias_padre b ON a.id_cat_categoria_padre = b.id_cat_categoria_padre
GROUP BY  a.id_empleado,a,id_estructura_ocupacional,b.id_cat_categoria_padre,b.categoria_padre,a.id_tramites_licencias_asignaciones,a.id_tramites_licencias_asignaciones_tf
)


SELECT *
FROM view_horas_asignadas_empleado_tf
WHERE id_empleado = 5181
AND id_estructura_ocupacional = 27
AND categoria_padre = 'EH4%'
*/