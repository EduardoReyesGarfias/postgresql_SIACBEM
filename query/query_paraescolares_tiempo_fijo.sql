SELECT
b.filiacion,b.nombre,b.paterno,b.materno,b.genero
,b.lugar_nacimiento,b.fecha_nacimiento,b.nacionalidad,b.estado_civil,b.calle,b.no_ext,b.no_int
,f.d_codigo,f.d_asenta,f.d_mnpio,f.d_estado,f.d_ciudad,
b.fecha_ingreso,b.fecha_ingreso_sispagos_impresion
,g.codigo,g.descripcion,e.categoria_padre,e.descripcion_cat_padre
,a.horas_grupo as hrs,a.qna_desde,a.qna_hasta
,h.nombre_subprograma as adscrip_nombre_ct,cs.clave_sep as adscrip_clave_ct
,c.nombre as materia, gp.nombre as nombre_grupo
,pf.prefijo_director,pf.nombre_director,pf.puesto_director,pf.prefijo_coordinador
,pf.nombre_coordinador,pf.puesto_coordinador
,(SELECT profesion /*grado_academico*/
FROM empleado_grados_academicos a
INNER JOIN cat_grados_academicos b ON b.id_grado_academico = a.id_grado_academico
INNER JOIN empleados g ON g.id_empleado = a.id_empleado
LEFT JOIN curricula_estudios_empleados c ON c.id_empleado_grado_academico = a.id_empleado_grado_academico
LEFT JOIN cat_profesiones d ON d.id_profesion = c.id_profesion
LEFT JOIN cat_instituciones_educativas e ON e.id_institucion_educativa = c.id_institucion_educativa
LEFT JOIN cat_documento_de_acreditacion f ON f.id_documento_acreditacion = a.id_documento_acreditacion
WHERE g.id_empleado = 9819
ORDER BY nivel_grado_academico DESC
LIMIT 1) as profesion

,(SELECT grado_academico
FROM empleado_grados_academicos a
INNER JOIN cat_grados_academicos b ON b.id_grado_academico = a.id_grado_academico
INNER JOIN empleados g ON g.id_empleado = a.id_empleado
LEFT JOIN curricula_estudios_empleados c ON c.id_empleado_grado_academico = a.id_empleado_grado_academico
LEFT JOIN cat_profesiones d ON d.id_profesion = c.id_profesion
LEFT JOIN cat_instituciones_educativas e ON e.id_institucion_educativa = c.id_institucion_educativa
LEFT JOIN cat_documento_de_acreditacion f ON f.id_documento_acreditacion = a.id_documento_acreditacion
WHERE g.id_empleado = 9819
ORDER BY nivel_grado_academico DESC
LIMIT 1) as grado_academico
FROM asignacion_tiempo_fijo_paraescolares a
INNER JOIN empleados b ON a.id_empleado = b.id_empleado
INNER JOIN cat_materias_paraescolares c ON c.id_paraescolar = a.id_cat_materias_paraescolares
INNER JOIN cat_categorias_padre e ON e.id_cat_categoria_padre = a.id_cat_categoria_padre
INNER JOIN codigos_postales f ON f.id_cp = b.id_cp
INNER JOIN cat_tipo_movimiento_personal g ON g.id_tipo_movimiento_personal = a.id_tipo_movimiento_personal
INNER JOIN subprogramas h ON h.id_subprograma = a.id_subprograma
INNER JOIN claves_sep cs ON cs.id_sep = h.id_sep
INNER JOIN grupos_paraescolares gp ON gp.id_grupo_paraescolar = a.id_grupo_paraescolares
INNER JOIN planteles_firmantes(97,27) pf ON 97 = h.id_subprograma
WHERE a.id_estructura_ocupacional = 27
AND a.id_subprograma = 97
AND a.id_empleado = 9819
AND c.id_paraescolar = 37

select *
from empleados
where id_empleado = 9819


select e.rfc,e.nombre,e.paterno,e.materno,e.genero,e.lugar_nacimiento,e.fecha_nacimiento,e.nacionalidad,
e.estado_civil,e.calle,e.no_ext,e.no_int,c.d_codigo,c.d_asenta,c.d_mnpio,c.d_estado,c.d_ciudad,
e.fecha_ingreso,e.fecha_ingreso_sispagos_impresion,m.codigo,m.descripcion,
d.categoria_padre,d.descripcion_cat_padre,a.horas_grupo as hrs,
a.qna_desde,a.qna_hasta,s.nombre_subprograma as adscrip_nombre_ct,cs.clave_sep as adscrip_clave_ct,
eb.nombre_grupo,
f.prefijo_director,f.nombre_director,f.puesto_director,f.prefijo_coordinador,
f.nombre_coordinador,f.puesto_coordinador,cm.materia

,(SELECT profesion /*grado_academico*/
FROM empleado_grados_academicos a
INNER JOIN cat_grados_academicos b ON b.id_grado_academico = a.id_grado_academico
INNER JOIN empleados g ON g.id_empleado = a.id_empleado
LEFT JOIN curricula_estudios_empleados c ON c.id_empleado_grado_academico = a.id_empleado_grado_academico
LEFT JOIN cat_profesiones d ON d.id_profesion = c.id_profesion
LEFT JOIN cat_instituciones_educativas e ON e.id_institucion_educativa = c.id_institucion_educativa
LEFT JOIN cat_documento_de_acreditacion f ON f.id_documento_acreditacion = a.id_documento_acreditacion
WHERE g.id_empleado = 9375
ORDER BY nivel_grado_academico DESC
LIMIT 1)

,(SELECT grado_academico
FROM empleado_grados_academicos a
INNER JOIN cat_grados_academicos b ON b.id_grado_academico = a.id_grado_academico
INNER JOIN empleados g ON g.id_empleado = a.id_empleado
LEFT JOIN curricula_estudios_empleados c ON c.id_empleado_grado_academico = a.id_empleado_grado_academico
LEFT JOIN cat_profesiones d ON d.id_profesion = c.id_profesion
LEFT JOIN cat_instituciones_educativas e ON e.id_institucion_educativa = c.id_institucion_educativa
LEFT JOIN cat_documento_de_acreditacion f ON f.id_documento_acreditacion = a.id_documento_acreditacion
WHERE g.id_empleado = 9375
ORDER BY nivel_grado_academico DESC
LIMIT 1)


FROM asignacion_tiempo_fijo_basico a

INNER JOIN empleados e ON e.id_empleado = a.id_empleado
INNER JOIN grupos_estructura_base eb ON eb.id_grupo_estructura_base = a.id_grupo_estructura_base
INNER JOIN codigos_postales c ON c.id_cp = e.id_cp
INNER JOIN cat_categorias_padre d ON d.id_cat_categoria_padre = a.id_cat_categoria_padre
INNER JOIN cat_tipo_movimiento_personal m ON m.id_tipo_movimiento_personal = a.id_tipo_movimiento_personal
INNER JOIN subprogramas s ON s.id_subprograma = a.id_subprograma
INNER JOIN claves_sep cs ON cs.id_sep = s.id_sep
INNER JOIN detalle_materias ma ON ma.id_detalle_materia = a.id_detalle_materia
INNER JOIN cat_materias cm ON cm.id_materia = ma.id_materia

INNER JOIN planteles_firmantes(34,27) f ON 34=s.id_subprograma

where a.id_empleado = 9375
and a.id_detalle_materia = 712


select * from grupos_paraescolares
