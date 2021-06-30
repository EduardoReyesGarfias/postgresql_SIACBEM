SELECT 
a.id_plantilla_base_docente_rh,(b.paterno||' '||b.materno||' '||b.nombre)as nombre,e.prefijo,e.profesion
,(c.categoria_padre||'/'||num_plz||'/'||a.hrs_categoria)as plaza
,COALESCE(sum(xa.horas_grupo_paraescolares),0)as horas_asignadas
,(f.nombre_subprograma) as nom_subp,g.clave_sep,h.periodo,coordinacion
,COALESCE(hrs_fortalecimiento_x_trabajador,0) as hrs_fort,(4) as id_componente
FROM plantilla_base_docente_rh a
INNER JOIN empleados b ON b.id_empleado = a.id_empleado
INNER JOIN cat_categorias_padre c ON c.id_cat_categoria_padre = a.id_cat_categoria_padre
INNER JOIN subprogramas f ON f.id_subprograma = a.id_subprograma
INNER JOIN claves_sep g ON f.id_sep = g.id_sep
INNER JOIN cat_estructuras_ocupacionales h ON h.id_estructura_ocupacional = a.id_estructura_ocupacional
LEFT JOIN curricula_estudios_empleados d ON d.id_empleado = b.id_empleado
LEFT JOIN cat_profesiones e ON e.id_profesion = d.id_profesion
LEFT JOIN profesores_profesor_asignado_paraescolares xa ON xa.id_plantilla_base_docente_rh = a.id_plantilla_base_docente_rh
LEFT JOIN profesor_asignado_paraescolares xb ON xb.id_profesor_asignado_paraescolares = xa.id_profesor_asignado_paraescolares
WHERE a.id_estructura_ocupacional = 25 and a.id_subprograma = 133
GROUP BY b.filiacion,a.id_plantilla_base_docente_rh,b.paterno,b.materno,b.nombre,e.prefijo,e.profesion
,c.categoria_padre,num_plz,a.hrs_categoria,xa.horas_grupo_paraescolares,f.nombre_subprograma,g.clave_sep,h.periodo
,coordinacion
ORDER BY b.filiacion,plaza

