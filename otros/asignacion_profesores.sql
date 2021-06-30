SELECT 
a.id_plantilla_base_docente_rh,b.id_empleado,(b.paterno||' '||b.materno||' '||b.nombre) as nombre_profesor,(c.categoria_padre||'/'||num_plz||'/'||hrs_categoria)as plaza,hrs_categoria
,(
	SELECT COALESCE(sum(horas_grupo_base),0) 
    FROM profesor_asignado_base za
    INNER JOIN profesores_profesor_asignado_base zb ON za.id_profesor_asignado_base = zb.id_profesor_asignado_base
    WHERE zb.id_plantilla_base_docente_rh = a.id_plantilla_base_docente_rh
) as horas_basico
,(
	SELECT COALESCE(sum(horas_grupo_optativas),0) 
    FROM profesor_asignado_optativas oa
    INNER JOIN profesores_profesor_asignado_optativas ob ON oa.id_profesor_asignado_optativa = ob.id_profesor_asignado_optativa
    WHERE ob.id_plantilla_base_docente_rh = a.id_plantilla_base_docente_rh
) as horas_optativas
,(
	SELECT COALESCE(sum(horas_grupo_capacitacion),0) 
    FROM profesor_asignado_capacitacion ca
    INNER JOIN profesores_profesor_asignado_capacitacion cb ON ca.id_profesor_asignado_capacitacion = cb.id_profesor_asignado_capacitacion
    WHERE cb.id_plantilla_base_docente_rh = a.id_plantilla_base_docente_rh
) as horas_capacitacion
FROM plantilla_base_docente_rh a
INNER JOIN empleados b ON b.id_empleado = a.id_empleado
INNER JOIN cat_categorias_padre c ON c.id_cat_categoria_padre = a.id_cat_categoria_padre
WHERE a.id_subprograma = 47 and a.id_estructura_ocupacional = 25
and revision_rh = true
ORDER BY b.paterno




