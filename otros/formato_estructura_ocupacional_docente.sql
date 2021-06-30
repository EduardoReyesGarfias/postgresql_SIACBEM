SELECT 
a.id_plantilla_base_docente_rh,(b.paterno||' '||b.materno||' '||b.nombre) as nombre,b.filiacion,e.prefijo,e.profesion,(f.categoria_padre||'/'||num_plz||'/'||a.hrs_categoria)as plaza
,xd.materia,xb.horas_grupo_base
FROM plantilla_base_docente_rh a
INNER JOIN empleados b ON a.id_empleado = b.id_empleado
INNER JOIN cat_categorias_padre c ON c.id_cat_categoria_padre = a.id_cat_categoria_padre
LEFT JOIN curricula_estudios_empleados d ON d.id_empleado = b.id_empleado
LEFT JOIN cat_profesiones e ON e.id_profesion = d.id_profesion

LEFT JOIN profesores_profesor_asignado_base xb ON xb.id_plantilla_base_docente_rh = a.id_plantilla_base_docente_rh
LEFT JOIN profesor_asignado_base xa ON xa.id_profesor_asignado_base = xb.id_profesor_asignado_base 
LEFT JOIN detalle_materias xc ON xc.id_detalle_materia = xa.id_detalle_materia
LEFT JOIN cat_materias xd ON xd.id_materia = xc.id_materia

INNER JOIN cat_categorias_padre f ON f.id_cat_categoria_padre = a.id_cat_categoria_padre
WHERE a.id_subprograma = 114
and a.id_estructura_ocupacional = 24
and revision_rh is true
ORDER BY b.paterno,hrs_categoria desc