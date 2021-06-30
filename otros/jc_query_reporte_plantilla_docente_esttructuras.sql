
(SELECT 
a.id_plantilla_base_docente_rh,(b.paterno||' '||b.materno||' '||b.nombre) as nombre,
b.filiacion,e.prefijo,e.profesion,(f.categoria_padre||'/'||num_plz||'/'||a.hrs_categoria)as plaza,
xd.materia,COALESCE(sum(xb.horas_grupo_base),0)as horas_asignadas, 

(select nombre_subprograma
from subprogramas 
where id_subprograma=133)as nom_subp,

(select clave_sep
from claves_sep
join subprogramas 
on subprogramas.id_sep=claves_sep.id_sep
where id_subprograma=133)as clave_sep,

(select periodo
from cat_estructuras_ocupacionales
where id_estructura_ocupacional=24)as periodo,

(select coordinacion
from subprogramas
where subprogramas.id_subprograma=133)as coord,

COALESCE(hrs_fortalecimiento_x_trabajador,0) as hrs_fort,

COALESCE(xc.id_componente,0) as id_componente

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
WHERE a.id_subprograma = 133
and a.id_estructura_ocupacional = 24
and revision_rh is true

GROUP BY xd.materia,xb.horas_grupo_base,a.id_plantilla_base_docente_rh,b.paterno,
b.materno,b.nombre,b.filiacion,e.prefijo,e.profesion,f.categoria_padre,num_plz,a.hrs_categoria,id_componente

ORDER BY b.filiacion,plaza
)
UNION ALL
(
SELECT 
a.id_plantilla_base_docente_rh,(b.paterno||' '||b.materno||' '||b.nombre) as nombre,
b.filiacion,e.prefijo,e.profesion,(f.categoria_padre||'/'||num_plz||'/'||a.hrs_categoria)as plaza,
yd.materia,COALESCE(sum(yb.horas_grupo_capacitacion),0)as horas_asignadas, 

(select nombre_subprograma
from subprogramas 
where id_subprograma=133)as nom_subp,

(select clave_sep
from claves_sep
join subprogramas 
on subprogramas.id_sep=claves_sep.id_sep
where id_subprograma=133)as clave_sep, 

(select periodo
from cat_estructuras_ocupacionales
where id_estructura_ocupacional=24)as periodo,

(select coordinacion
from subprogramas
where subprogramas.id_subprograma=133)as coord,

COALESCE(hrs_fortalecimiento_x_trabajador,0) as hrs_fort, 

COALESCE(yc.id_componente,0) as id_componente

FROM plantilla_base_docente_rh a

INNER JOIN empleados b ON a.id_empleado = b.id_empleado
INNER JOIN cat_categorias_padre c ON c.id_cat_categoria_padre = a.id_cat_categoria_padre
LEFT JOIN curricula_estudios_empleados d ON d.id_empleado = b.id_empleado
LEFT JOIN cat_profesiones e ON e.id_profesion = d.id_profesion

LEFT JOIN profesores_profesor_asignado_capacitacion yb ON yb.id_plantilla_base_docente_rh = a.id_plantilla_base_docente_rh
LEFT JOIN profesor_asignado_capacitacion ya ON ya.id_profesor_asignado_capacitacion = yb.id_profesor_asignado_capacitacion 
LEFT JOIN detalle_materias yc ON yc.id_detalle_materia = ya.id_detalle_materia
LEFT JOIN cat_materias yd ON yd.id_materia = yc.id_materia

INNER JOIN cat_categorias_padre f ON f.id_cat_categoria_padre = a.id_cat_categoria_padre

WHERE a.id_subprograma = 133
and a.id_estructura_ocupacional = 24
and revision_rh is true

GROUP BY yd.materia,yb.horas_grupo_capacitacion,a.id_plantilla_base_docente_rh,b.paterno,
b.materno,b.nombre,b.filiacion,e.prefijo,e.profesion,f.categoria_padre,num_plz,a.hrs_categoria,id_componente

ORDER BY b.filiacion,plaza
)

UNION ALL
(
SELECT 
a.id_plantilla_base_docente_rh,(b.paterno||' '||b.materno||' '||b.nombre) as nombre,
b.filiacion,e.prefijo,e.profesion,(f.categoria_padre||'/'||num_plz||'/'||a.hrs_categoria)as plaza
,zd.materia,COALESCE(sum(zb.horas_grupo_optativas),0)as horas_asignadas, 

(select nombre_subprograma
from subprogramas 
where id_subprograma=133)as nom_subp,

(select clave_sep
from claves_sep
join subprogramas 
on subprogramas.id_sep=claves_sep.id_sep
where id_subprograma=133)as clave_sep, 

(select periodo
from cat_estructuras_ocupacionales
where id_estructura_ocupacional=24)as periodo,

(select coordinacion
from subprogramas
where subprogramas.id_subprograma=133)as coord,

COALESCE(hrs_fortalecimiento_x_trabajador,0) as hrs_fort, 

COALESCE(zc.id_componente,0) as id_componente

FROM plantilla_base_docente_rh a

INNER JOIN empleados b ON a.id_empleado = b.id_empleado
INNER JOIN cat_categorias_padre c ON c.id_cat_categoria_padre = a.id_cat_categoria_padre
LEFT JOIN curricula_estudios_empleados d ON d.id_empleado = b.id_empleado
LEFT JOIN cat_profesiones e ON e.id_profesion = d.id_profesion

LEFT JOIN profesores_profesor_asignado_optativas zb ON zb.id_plantilla_base_docente_rh = a.id_plantilla_base_docente_rh
LEFT JOIN profesor_asignado_optativas za ON za.id_profesor_asignado_optativa = zb.id_profesor_asignado_optativa 
LEFT JOIN detalle_materias zc ON zc.id_detalle_materia = za.id_detalle_materia
LEFT JOIN cat_materias zd ON zd.id_materia = zc.id_materia

INNER JOIN cat_categorias_padre f ON f.id_cat_categoria_padre = a.id_cat_categoria_padre

WHERE a.id_subprograma = 133
and a.id_estructura_ocupacional = 24
and revision_rh is true

GROUP BY zd.materia,zb.horas_grupo_optativas,a.id_plantilla_base_docente_rh,
b.paterno,b.materno,b.nombre,b.filiacion,e.prefijo,e.profesion,f.categoria_padre,num_plz,a.hrs_categoria,id_componente

ORDER BY b.filiacion,plaza
)