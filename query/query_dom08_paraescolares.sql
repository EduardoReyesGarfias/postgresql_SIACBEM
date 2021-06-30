-------------------------------
-- QUERY DOM 08 PARAESCOLARES
-------------------------------
SELECT s.nombre_subprograma ,e.rfc,e.nombre,e.paterno,e.materno,o.periodo,cm.nombre as materia,a.horas_grupo,
d.categoria_padre,m.codigo,m.descripcion,a.qna_desde,a.qna_hasta,
f.prefijo_director,f.nombre_director,f.puesto_director,f.prefijo_coordinador,
f.nombre_coordinador,f.puesto_coordinador,a.id_grupo_paraescolares,
string_agg(dp.profesion,',' ORDER BY dp.id_profesion DESC) as profesion,
string_agg(b.grado_academico,',' ORDER BY dp.id_profesion DESC) as grado_academico,
string_agg(
(CASE WHEN g.valida_archivo = true THEN
'SI'
WHEN g.valida_archivo = false THEN
'NO'
WHEN g.valida_archivo is null THEN
'PEN'
END),',' ORDER BY dp.id_profesion DESC) as valida_archivo

FROM asignacion_tiempo_fijo_paraescolares a

INNER JOIN empleados e ON e.id_empleado = a.id_empleado
INNER JOIN subprogramas s ON s.id_subprograma = a.id_subprograma
INNER JOIN cat_estructuras_ocupacionales o ON o.id_estructura_ocupacional = a.id_estructura_ocupacional
INNER JOIN cat_materias_paraescolares cm ON cm.id_paraescolar = a.id_cat_materias_paraescolares
INNER JOIN cat_categorias_padre d ON d.id_cat_categoria_padre = a.id_cat_categoria_padre
INNER JOIN cat_tipo_movimiento_personal m ON m.id_tipo_movimiento_personal = a.id_tipo_movimiento_personal

INNER JOIN empleado_grados_academicos g ON g.id_empleado = a.id_empleado
INNER JOIN cat_grados_academicos b ON b.id_grado_academico = g.id_grado_academico
LEFT JOIN curricula_estudios_empleados c ON c.id_empleado_grado_academico = g.id_empleado_grado_academico
LEFT JOIN cat_profesiones dp ON dp.id_profesion = c.id_profesion
LEFT JOIN cat_instituciones_educativas ed ON ed.id_institucion_educativa = c.id_institucion_educativa
LEFT JOIN cat_documento_de_acreditacion fa ON fa.id_documento_acreditacion = g.id_documento_acreditacion

INNER JOIN planteles_firmantes(97,27) f ON 97=s.id_subprograma

WHERE a.id_subprograma = 97
GROUP BY
s.nombre_subprograma ,e.rfc,e.nombre,e.paterno,e.materno,o.periodo,cm.nombre,a.horas_grupo,
d.categoria_padre,m.codigo,m.descripcion,a.qna_desde,a.qna_hasta,
f.prefijo_director,f.nombre_director,f.puesto_director,f.prefijo_coordinador,
f.nombre_coordinador,f.puesto_coordinador,a.id_grupo_paraescolares



