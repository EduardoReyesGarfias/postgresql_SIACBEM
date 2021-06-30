SELECT i.nombre_subprograma,sum(b.horas_grupo_paraescolares) as horas_metidas,e.nombre,e.paterno,e.materno,g.categoria_padre,c.num_plz,c.hrs_categoria,h.nombre as materia
FROM profesor_asignado_paraescolares a
INNER JOIN profesores_profesor_asignado_paraescolares b ON a.id_profesor_asignado_paraescolares = b.id_profesor_asignado_paraescolares
INNER JOIN plantilla_base_docente_rh c ON c.id_plantilla_base_docente_rh = b.id_plantilla_base_docente_rh 
INNER JOIN grupos_paraescolares d ON d.id_grupo_paraescolar = a.id_grupo_paraescolares
INNER JOIN empleados e ON e.id_empleado = c.id_empleado
INNER JOIN cat_categorias_padre g ON g.id_cat_categoria_padre = c.id_cat_categoria_padre
INNER JOIN cat_materias_paraescolares h ON h.id_paraescolar = b.id_cat_materias_paraescolares
INNER JOIN subprogramas i ON i.id_subprograma = c.id_subprograma
WHERE 
--i.id_subprograma = 98 AND
c.id_estructura_ocupacional = 26
AND categoria_padre not in('TCBI','TCBII')
GROUP BY i.nombre_subprograma,b.horas_grupo_paraescolares,e.nombre,e.paterno,e.materno,g.categoria_padre,c.num_plz,c.hrs_categoria,h.nombre
ORDER BY i.nombre_subprograma, e.nombre,e.paterno,e.materno,categoria_padre,materia


