CREATE OR REPLACE FUNCTION planteles_hrs_totales_asignadas (filiacion text,id_subprograma int, id_estructura int)
RETURNS TABLE(
	horas_asignadas_totales_emp bigint
)

AS $$
BEGIN

	RETURN QUERY SELECT
	(
	SELECT COALESCE(sum(wa.horas_grupo_base),0)
	FROM profesores_profesor_asignado_base wa
	INNER JOIN profesor_asignado_base wb ON wb.id_profesor_asignado_base = wa.id_profesor_asignado_base
	INNER JOIN detalle_materias wc ON wc.id_detalle_materia = wb.id_detalle_materia 
	INNER JOIN cat_materias wd ON wd.id_materia = wc.id_materia
	INNER JOIN plantilla_base_docente_rh we ON we.id_plantilla_base_docente_rh = wa.id_plantilla_base_docente_rh
	INNER JOIN empleados wf ON wf.id_empleado = we.id_empleado
	WHERE wf.filiacion = b.filiacion
	and we.id_subprograma = $2 and we.id_estructura_ocupacional = $3
	and we.revision_rh = true

	) +
	(
	SELECT COALESCE(sum(wa.horas_grupo_capacitacion),0)
	FROM profesores_profesor_asignado_capacitacion wa
	INNER JOIN profesor_asignado_capacitacion wb ON wb.id_profesor_asignado_capacitacion = wa.id_profesor_asignado_capacitacion
	INNER JOIN detalle_materias wc ON wc.id_detalle_materia = wb.id_detalle_materia 
	INNER JOIN cat_materias wd ON wd.id_materia = wc.id_materia
	INNER JOIN plantilla_base_docente_rh we ON we.id_plantilla_base_docente_rh = wa.id_plantilla_base_docente_rh
	INNER JOIN empleados wf ON wf.id_empleado = we.id_empleado
	WHERE wf.filiacion = b.filiacion
	and we.id_subprograma = $2 and we.id_estructura_ocupacional = $3
	and we.revision_rh = true

	) +
	(
	SELECT COALESCE(sum(wa.horas_grupo_optativas),0)
	FROM profesores_profesor_asignado_optativas wa
	INNER JOIN profesor_asignado_optativas wb ON wb.id_profesor_asignado_optativa = wa.id_profesor_asignado_optativa
	INNER JOIN detalle_materias wc ON wc.id_detalle_materia = wb.id_detalle_materia 
	INNER JOIN cat_materias wd ON wd.id_materia = wc.id_materia
	INNER JOIN plantilla_base_docente_rh we ON we.id_plantilla_base_docente_rh = wa.id_plantilla_base_docente_rh
	INNER JOIN empleados wf ON wf.id_empleado = we.id_empleado
	WHERE wf.filiacion = b.filiacion
	and we.id_subprograma = $2 and we.id_estructura_ocupacional = $3
	and we.revision_rh = true

	) +
	(
	SELECT COALESCE(sum(wa.horas_grupo_paraescolares),0)
	FROM profesores_profesor_asignado_paraescolares wa
	INNER JOIN profesor_asignado_paraescolares wb ON wb.id_profesor_asignado_paraescolares = wa.id_profesor_asignado_paraescolares
	INNER JOIN cat_materias_paraescolares wd ON wd.id_paraescolar = wa.id_cat_materias_paraescolares
	INNER JOIN plantilla_base_docente_rh we ON we.id_plantilla_base_docente_rh = wa.id_plantilla_base_docente_rh
	INNER JOIN empleados wf ON wf.id_empleado = we.id_empleado
	WHERE wf.filiacion = b.filiacion
	and we.id_subprograma = $2 and we.id_estructura_ocupacional = $3
	and we.revision_rh = true

	) as tot_horas_asignadas
	FROM plantilla_base_docente_rh a
	INNER JOIN empleados b ON a.id_empleado = b.id_empleado 
	INNER JOIN cat_categorias_padre c ON c.id_cat_categoria_padre = a.id_cat_categoria_padre
	WHERE 
	a.id_subprograma = $2 AND 
	a.id_estructura_ocupacional = $3 AND
	a.revision_rh = true AND
	b.filiacion = $1;

END; $$ 
 
LANGUAGE 'plpgsql';

select * from planteles_hrs_totales_asignadas('AEGE770624000',13,26); --20


select * from planteles_hrs_totales_asignadas('CECA751218000',1,1); --7