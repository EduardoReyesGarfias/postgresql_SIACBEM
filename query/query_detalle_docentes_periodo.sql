SELECT 
--*
b.filiacion,b.nombre,b.paterno,b.materno, c.categoria_padre||'/'||a.num_plz||'/'||a.hrs_categoria as clave,d.nombre_subprograma,d.coordinacion,d.id_zona_economica
FROM plantilla_base_docente_rh a
INNER JOIN empleados b ON a.id_empleado = b.id_empleado
INNER JOIN cat_categorias_padre c ON c.id_cat_categoria_padre = a.id_cat_categoria_padre
INNER JOIN subprogramas d ON d.id_subprograma = a.id_subprograma
WHERE a.id_estructura_ocupacional = 27
GROUP BY b.filiacion,b.nombre,b.paterno,b.materno, c.categoria_padre,a.num_plz,a.hrs_categoria,d.nombre_subprograma,d.coordinacion,d.id_zona_economica
ORDER BY b.nombre,b.paterno,b.materno, c.categoria_padre,a.num_plz,a.hrs_categoria,b.filiacion,d.nombre_subprograma,d.coordinacion,d.id_zona_economica



--select * from subprogramas