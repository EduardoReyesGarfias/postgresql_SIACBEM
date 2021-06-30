SELECT *
FROM profesor_asignado_base a
INNER JOIN profesores_profesor_asignado_base b USING(id_profesor_asignado_base)
INNER JOIN tramites_bajas_plazas_docente c USING(id_plantilla_base_docente_rh)
INNER JOIN tramites_bajas d USING (id_tramite_baja)
WHERE d.id_cat_tramite_status = 3
AND 

-- Basico
SELECT 
a.id_grupo_estructura_base,h.id_detalle_materia,h.hora_semana_mes,sum(horas_grupo_base) as horas_grupo_base 
FROM profesor_asignado_base a
INNER JOIN profesores_profesor_asignado_base pp ON pp.id_profesor_asignado_base = a.id_profesor_asignado_base 
INNER JOIN plantilla_base_docente_rh pbr ON pbr.id_plantilla_base_docente_rh = pp.id_plantilla_base_docente_rh
INNER JOIN cat_categorias_padre ccp ON ccp.id_cat_categoria_padre = pbr.id_cat_categoria_padre
INNER JOIN empleados b ON b.id_empleado = pbr.id_empleado
INNER JOIN grupos_estructura_base c ON c.id_grupo_estructura_base = a.id_grupo_estructura_base
INNER JOIN horas_autorizadas d ON d.id_hora_autorizada = c.id_hora_autorizada
INNER JOIN grupos e ON e.id_grupo = d.id_grupo
INNER JOIN periodos f ON f.id_periodo = e.id_periodo 
INNER JOIN grupos_combinaciones_planes g ON g.id_grupo_combinacion_plan = e.id_grupo_combinacion_plan
INNER JOIN detalle_materias h ON h.id_detalle_materia = a.id_detalle_materia 
INNER JOIN cat_materias i ON i.id_materia = h.id_materia
INNER JOIN cat_tipo_movimiento_personal j ON j.id_tipo_movimiento_personal = pp.id_tipo_movimiento_personal

INNER JOIN tramites_bajas_plazas_docente tbpd ON tbpd.id_plantilla_docente_rh = pbr.id_plantilla_base_docente_rh
INNER JOIN tramites_bajas tb ON tb.id_tramite_baja = tbpd.id_tramite_baja

WHERE f.id_subprograma = 89 
AND f.id_estructura_ocupacional = 28 
AND i.fecha_fin is null
--AND  h.semestre = 3
--AND e.id_grupo_combinacion_plan = 11
AND tb.id_cat_tramite_status = 3
GROUP BY a.id_grupo_estructura_base,h.id_detalle_materia,h.hora_semana_mes
ORDER BY a.id_grupo_estructura_base, h.id_detalle_materia



-- Paraescolares
SELECT 
-- a.id_grupo_estructura_base,h.id_detalle_materia,h.hora_semana_mes,sum(horas_grupo_base) as horas_grupo_base 
a.id_grupo_paraescolares,id_paraescolar,3 as hora_semana_mes, sum(pp.horas_grupo_paraescolares) as horas_grupo_paraescolares
FROM profesor_asignado_paraescolares a
INNER JOIN profesores_profesor_asignado_paraescolares pp ON pp.id_profesor_asignado_paraescolares = a.id_profesor_asignado_paraescolares 
INNER JOIN plantilla_base_docente_rh pbr ON pbr.id_plantilla_base_docente_rh = pp.id_plantilla_base_docente_rh
INNER JOIN cat_categorias_padre ccp ON ccp.id_cat_categoria_padre = pbr.id_cat_categoria_padre
INNER JOIN empleados b ON b.id_empleado = pbr.id_empleado
INNER JOIN grupos_paraescolares c ON c.id_grupo_paraescolar = a.id_grupo_paraescolares
INNER JOIN horas_autorizadas d ON d.id_hora_autorizada = c.id_hora_autorizada
INNER JOIN grupos e ON e.id_grupo = d.id_grupo
INNER JOIN periodos f ON f.id_periodo = e.id_periodo 
INNER JOIN grupos_combinaciones_planes g ON g.id_grupo_combinacion_plan = e.id_grupo_combinacion_plan
INNER JOIN cat_materias_paraescolares h ON h.id_paraescolar = pp.id_cat_materias_paraescolares 
INNER JOIN cat_tipo_movimiento_personal j ON j.id_tipo_movimiento_personal = pp.id_tipo_movimiento_personal

INNER JOIN tramites_bajas_plazas_docente tbpd ON tbpd.id_plantilla_docente_rh = pbr.id_plantilla_base_docente_rh
INNER JOIN tramites_bajas tb ON tb.id_tramite_baja = tbpd.id_tramite_baja

WHERE f.id_subprograma = 89 
AND f.id_estructura_ocupacional = 28 
--AND  h.semestre = 3
--AND e.id_grupo_combinacion_plan = 11
AND tb.id_cat_tramite_status = 3
GROUP BY a.id_grupo_paraescolares,id_paraescolar
ORDER BY a.id_grupo_paraescolares, id_paraescolar



select *
from subprogramas
order by nombre_subprograma

SELECT *
FROM tramites_bajas_plazas_docente


select *
from empleados
WHERE nombre = 'CARLOS'
AND paterno = 'TORRES'


/*
id_empleado = 6171
*/

SELECT *
FROM tramites_bajas

BEGIN;

INSERT INTO tramites_bajas(id_usuario_captura, id_subprograma, id_estructura_ocupacional, id_empleado, fecha_baja, no_folio, fecha_autorizacion, id_cat_tramite_status, id_movimiento_interino, id_movimiento_titular, fecha_sistema)
VALUES(69,89,28,6171, now(), '001Prueba', now(), 3, 6, 6, now())

commit;


SELECT *
FROM plantilla_base_docente_rh
WHERE id_empleado = 6171
AND id_estructura_ocupacional = 28

SELECT *
FROM tramites_bajas

BEGIN;

INSERT INTO tramites_bajas_plazas_docente(id_tramite_baja, id_plantilla_docente_rh)
VALUES(1, 65028)

commit;


SELECT *
FROM cat_tipo_movimiento_personal
ORDER BY id_tipo_movimiento_personal


BEGIN;

UPDATE tramites_bajas
SET id_movimiento_interino = 84

commit;

















