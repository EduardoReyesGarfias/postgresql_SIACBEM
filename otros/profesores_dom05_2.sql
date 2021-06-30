SELECT b.filiacion,b.paterno,b.materno,b.nombre,sum(hrs_categoria) as hrs_base
,(
	SELECT COALESCE(sum(horas_grupo_base),0)
	FROM profesores_profesor_asignado_base wa
	INNER JOIN profesor_asignado_base wb ON wb.id_profesor_asignado_base = wa.id_profesor_asignado_base
	INNER JOIN detalle_materias wc ON wc.id_detalle_materia = wb.id_detalle_materia 
	INNER JOIN cat_materias wd ON wd.id_materia = wc.id_materia
	INNER JOIN plantilla_base_docente_rh we ON we.id_plantilla_base_docente_rh = wa.id_plantilla_base_docente_rh
	INNER JOIN empleados wf ON wf.id_empleado = we.id_empleado
	WHERE wf.filiacion = b.filiacion
	and we.id_subprograma = 13 and we.id_estructura_ocupacional = 26
	and revision_rh = true
	 
) +
(
	SELECT COALESCE(sum(horas_grupo_capacitacion),0)
	FROM profesores_profesor_asignado_capacitacion wa
	INNER JOIN profesor_asignado_capacitacion wb ON wb.id_profesor_asignado_capacitacion = wa.id_profesor_asignado_capacitacion
	INNER JOIN detalle_materias wc ON wc.id_detalle_materia = wb.id_detalle_materia 
	INNER JOIN cat_materias wd ON wd.id_materia = wc.id_materia
	INNER JOIN plantilla_base_docente_rh we ON we.id_plantilla_base_docente_rh = wa.id_plantilla_base_docente_rh
	INNER JOIN empleados wf ON wf.id_empleado = we.id_empleado
	WHERE wf.filiacion = b.filiacion
	and we.id_subprograma = 13 and we.id_estructura_ocupacional = 26
	and revision_rh = true
	 
) +
(
	SELECT COALESCE(sum(horas_grupo_optativas),0)
	FROM profesores_profesor_asignado_optativas wa
	INNER JOIN profesor_asignado_optativas wb ON wb.id_profesor_asignado_optativa = wa.id_profesor_asignado_optativa
	INNER JOIN detalle_materias wc ON wc.id_detalle_materia = wb.id_detalle_materia 
	INNER JOIN cat_materias wd ON wd.id_materia = wc.id_materia
	INNER JOIN plantilla_base_docente_rh we ON we.id_plantilla_base_docente_rh = wa.id_plantilla_base_docente_rh
	INNER JOIN empleados wf ON wf.id_empleado = we.id_empleado
	WHERE wf.filiacion = b.filiacion
	and we.id_subprograma = 13 and we.id_estructura_ocupacional = 26
	and revision_rh = true
	 
) +
(
	SELECT COALESCE(sum(horas_grupo_paraescolares),0)
	FROM profesores_profesor_asignado_paraescolares wa
	INNER JOIN profesor_asignado_paraescolares wb ON wb.id_profesor_asignado_paraescolares = wa.id_profesor_asignado_paraescolares
	INNER JOIN cat_materias_paraescolares wd ON wd.id_paraescolar = wa.id_cat_materias_paraescolares
	INNER JOIN plantilla_base_docente_rh we ON we.id_plantilla_base_docente_rh = wa.id_plantilla_base_docente_rh
	INNER JOIN empleados wf ON wf.id_empleado = we.id_empleado
	WHERE wf.filiacion = b.filiacion
	and we.id_subprograma = 13 and we.id_estructura_ocupacional = 26
	and revision_rh = true
	 
) tot_horas_asignadas
,COALESCE((
	SELECT 
	CASE WHEN xc.categoria_padre like '%EH4%' AND xa.hrs_categoria = 40 THEN
		10
	WHEN xc.categoria_padre = 'CBIII' AND xa.hrs_categoria = 40 THEN
		8
	WHEN xc.categoria_padre = 'CBIV' AND xa.hrs_categoria = 40 THEN
		8
	WHEN xc.categoria_padre = 'CBV' AND xa.hrs_categoria = 40 THEN
		8
	ELSE
		0
	END
	
	FROM plantilla_base_docente_rh xa
	INNER JOIN empleados xb ON xb.id_empleado = xa.id_empleado
	INNER JOIN cat_categorias_padre xc ON xc.id_cat_categoria_padre = xa.id_cat_categoria_padre
	WHERE xb.filiacion = b.filiacion
	and xa.id_subprograma = 13 and xa.id_estructura_ocupacional = 26
	and xa.revision_rh = true
	and ((xc.categoria_padre like '%EH4%' and xa.hrs_categoria = 40) OR (xc.categoria_padre = 'CBIII' and xa.hrs_categoria=40)
		OR (xc.categoria_padre = 'CBIV' and xa.hrs_categoria=40) OR (xc.categoria_padre = 'CBV' and xa.hrs_categoria=40))
	LIMIT 1
	
),0) as hrs_fort,
(
	sum(a.hrs_categoria) - (
	SELECT 
	CASE WHEN xc.categoria_padre like '%EH4%' AND xa.hrs_categoria = 40 THEN
		10
	WHEN xc.categoria_padre = 'CBIII' AND xa.hrs_categoria = 40 THEN
		8
	WHEN xc.categoria_padre = 'CBIV' AND xa.hrs_categoria = 40 THEN
		8
	WHEN xc.categoria_padre = 'CBV' AND xa.hrs_categoria = 40 THEN
		8
	ELSE
		0
	END
	
	FROM plantilla_base_docente_rh xa
	INNER JOIN empleados xb ON xb.id_empleado = xa.id_empleado
	INNER JOIN cat_categorias_padre xc ON xc.id_cat_categoria_padre = xa.id_cat_categoria_padre
	WHERE xb.filiacion = b.filiacion
	and xa.id_subprograma = 13 and xa.id_estructura_ocupacional = 26
	and xa.revision_rh = true
	and ((xc.categoria_padre like '%EH4%' and xa.hrs_categoria = 40) OR (xc.categoria_padre = 'CBIII' and xa.hrs_categoria=40)
		OR (xc.categoria_padre = 'CBIV' and xa.hrs_categoria=40) OR (xc.categoria_padre = 'CBV' and xa.hrs_categoria=40))
	LIMIT 1
	
)
) AS resta
FROM plantilla_base_docente_rh a
INNER JOIN empleados b ON a.id_empleado = b.id_empleado 
INNER JOIN cat_categorias_padre c ON c.id_cat_categoria_padre = a.id_cat_categoria_padre
WHERE 
id_subprograma = 13 AND 
id_estructura_ocupacional = 26 AND
revision_rh = true
GROUP BY b.filiacion,b.paterno,b.materno,b.nombre
ORDER BY b.filiacion,b.paterno,b.materno,b.nombre