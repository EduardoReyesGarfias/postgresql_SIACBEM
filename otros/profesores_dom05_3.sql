/*
Asignados de base
*/
(
SELECT 
	--row_number() over (partition by a.id_plantilla_base_docente_rh) as registro_trabajador ,
a.id_plantilla_base_docente_rh,b.paterno,b.materno,b.nombre
,g.categoria_padre||'/'||num_plz||'/'||hrs_categoria as clave,f.materia as materias_basico,sum(c.horas_grupo_base) as horas_grupo_base
,hrs_fortalecimiento_x_trabajador,hrs_descarga_x_trabajador
FROM plantilla_base_docente_rh a
INNER JOIN empleados b ON a.id_empleado = b.id_empleado 
INNER JOIN cat_categorias_padre g ON g.id_cat_categoria_padre = a.id_cat_categoria_padre

LEFT JOIN profesores_profesor_asignado_base c ON c.id_plantilla_base_docente_rh = a.id_plantilla_base_docente_rh
LEFT JOIN profesor_asignado_base d ON d.id_profesor_asignado_base = c.id_profesor_asignado_base
LEFT JOIN detalle_materias e ON e.id_detalle_materia = d.id_detalle_materia 
LEFT JOIN cat_materias f ON f.id_materia = e.id_materia

WHERE 
id_subprograma = 123 AND 
id_estructura_ocupacional = 26 AND
revision_rh = true
GROUP BY a.id_plantilla_base_docente_rh,paterno,materno,nombre,g.categoria_padre,num_plz,hrs_categoria,materias_basico,horas_grupo_base
,hrs_fortalecimiento_x_trabajador,hrs_descarga_x_trabajador
	ORDER BY b.paterno,b.materno,b.nombre
)
UNION ALL
(
SELECT a.id_plantilla_base_docente_rh,b.paterno,b.materno,b.nombre
,g.categoria_padre||'/'||num_plz||'/'||hrs_categoria as clave,be.materia as materias_capacitacion, sum(ba.horas_grupo_capacitacion) as horas_grupo_capacitacion
,hrs_fortalecimiento_x_trabajador,hrs_descarga_x_trabajador
	FROM plantilla_base_docente_rh a
INNER JOIN empleados b ON a.id_empleado = b.id_empleado 
INNER JOIN cat_categorias_padre g ON g.id_cat_categoria_padre = a.id_cat_categoria_padre

LEFT JOIN profesores_profesor_asignado_capacitacion ba ON ba.id_plantilla_base_docente_rh = a.id_plantilla_base_docente_rh
LEFT JOIN profesor_asignado_capacitacion bb ON bb.id_profesor_asignado_capacitacion = ba.id_profesor_asignado_capacitacion
LEFT JOIN detalle_materias bc ON bc.id_detalle_materia = bb.id_detalle_materia 
LEFT JOIN cat_materias be ON be.id_materia = bc.id_materia

WHERE 
id_subprograma = 123 AND 
id_estructura_ocupacional = 26 AND
revision_rh = true
GROUP BY a.id_plantilla_base_docente_rh,paterno,materno,nombre,g.categoria_padre,num_plz,hrs_categoria,be.materia,horas_grupo_capacitacion
,hrs_fortalecimiento_x_trabajador,hrs_descarga_x_trabajador
	ORDER BY b.paterno,b.materno,b.nombre
)
UNION ALL
(
	SELECT a.id_plantilla_base_docente_rh,b.paterno,b.materno,b.nombre
,g.categoria_padre||'/'||num_plz||'/'||hrs_categoria as clave
,cd.materia as materias_optativas, sum(ca.horas_grupo_optativas)as horas_grupo_optativas
,hrs_fortalecimiento_x_trabajador,hrs_descarga_x_trabajador
FROM plantilla_base_docente_rh a
INNER JOIN empleados b ON a.id_empleado = b.id_empleado 
INNER JOIN cat_categorias_padre g ON g.id_cat_categoria_padre = a.id_cat_categoria_padre

LEFT JOIN profesores_profesor_asignado_optativas ca ON ca.id_plantilla_base_docente_rh = a.id_plantilla_base_docente_rh
LEFT JOIN profesor_asignado_optativas cb ON cb.id_profesor_asignado_optativa = ca.id_profesor_asignado_optativa
LEFT JOIN detalle_materias cc ON cc.id_detalle_materia = cb.id_detalle_materia
LEFT JOIN cat_materias cd ON cd.id_materia = cc.id_materia

WHERE 
id_subprograma = 123 AND 
id_estructura_ocupacional = 26 AND
revision_rh = true
GROUP BY a.id_plantilla_base_docente_rh,b.paterno,b.materno,b.nombre
,g.categoria_padre,num_plz,hrs_categoria
,cd.materia,ca.horas_grupo_optativas
	ORDER BY b.paterno,b.materno,b.nombre
)
UNION ALL
(
	SELECT a.id_plantilla_base_docente_rh,b.paterno,b.materno,b.nombre
	,g.categoria_padre||'/'||num_plz||'/'||hrs_categoria as clave
	,dc.nombre as materias_paraescolares, sum(da.horas_grupo_paraescolares)as horas_grupo_paraescolares
	,hrs_fortalecimiento_x_trabajador,hrs_descarga_x_trabajador
	FROM plantilla_base_docente_rh a
	INNER JOIN empleados b ON a.id_empleado = b.id_empleado 
	INNER JOIN cat_categorias_padre g ON g.id_cat_categoria_padre = a.id_cat_categoria_padre

	LEFT JOIN profesores_profesor_asignado_paraescolares da ON da.id_plantilla_base_docente_rh = a.id_plantilla_base_docente_rh
	LEFT JOIN profesor_asignado_paraescolares db ON db.id_profesor_asignado_paraescolares = da.id_profesor_asignado_paraescolares 
	LEFT JOIN cat_materias_paraescolares dc ON dc.id_paraescolar = da.id_cat_materias_paraescolares

	WHERE 
	id_subprograma = 123 AND 
	id_estructura_ocupacional = 26 AND
	revision_rh = true
	GROUP BY a.id_plantilla_base_docente_rh,paterno,materno,b.nombre,g.categoria_padre,num_plz,hrs_categoria,materias_paraescolares,horas_grupo_paraescolares
	,hrs_fortalecimiento_x_trabajador,hrs_descarga_x_trabajador
		ORDER BY b.paterno,b.materno,b.nombre
)
ORDER BY paterno,materno,nombre