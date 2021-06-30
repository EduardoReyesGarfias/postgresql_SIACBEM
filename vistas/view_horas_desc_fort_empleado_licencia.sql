CREATE OR REPLACE VIEW view_horas_desc_fort_empleado_licencia AS 

-- Horas en licencia que son de desccarga o fortalecimiento

-- Horas de estructura base
SELECT 
	a.id_empleado,
	a.id_estructura_ocupacional,
	e.id_cat_categoria_padre,
	e.categoria_padre,
	sum(DISTINCT c.hrs_licencia) AS hrs_licencia,
	CAST(null as int) as id_tramites_licencias_asignaciones,
	CAST(null as int) as id_tramites_licencias_asignaciones_tf
FROM tramites_licencias a
LEFT JOIN tramites_licencias_asignaciones b ON a.id_tramite_licencia = b.id_tramite_licencia
LEFT JOIN tramites_licencias_plazas_docente c ON c.id_tramite_licencia = a.id_tramite_licencia
LEFT JOIN plantilla_base_docente_rh d ON d.id_plantilla_base_docente_rh = c.id_plantilla_base_docente_rh
LEFT JOIN cat_categorias_padre e ON e.id_cat_categoria_padre = d.id_cat_categoria_padre
WHERE 
	b.id_tramite_licencia_asignacion is null
--a.id_tramite_licencia = 2066 AND
--a.id_estructura_ocupacional = 29
GROUP BY
	a.id_empleado,
	a.id_estructura_ocupacional,
	e.id_cat_categoria_padre,
	e.categoria_padre

-- Horas de TF no pueden existir de descarga o fort	


-- Ejemplo
SELECT 
	id_empleado,
	id_estructura_ocupacional,
	id_cat_categoria_padre,
	categoria_padre,
	sum(DISTINCT hrs_licencia) AS hrs_licencia,
	id_tramites_licencias_asignaciones,
	id_tramites_licencias_asignaciones_tf
FROM view_horas_desc_fort_empleado_licencia
WHERE 
	id_empleado = 6814 AND
	id_estructura_ocupacional = 29
GROUP BY
	id_empleado,
	id_estructura_ocupacional,
	id_cat_categoria_padre,
	categoria_padre,
	id_tramites_licencias_asignaciones,
	id_tramites_licencias_asignaciones_tf