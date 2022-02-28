CREATE VIEW view_nombramientos_planeacion_tf AS
(
SELECT 
	nomb.id_nombramiento_planeacion_tf,
	estruc.id_estructura_ocupacional,
	estruc.periodo,
	nomb.no_oficio,
	nomb.id_empleado_nombramiento,
	emp1.nombre||' '||emp1.paterno||' '||emp1.materno AS empleado_nombramiento,
	subp.id_subprograma,
	subp.nombre_subprograma,
	detalle.id_detalle_materia,
	0 AS id_paraescolar,
	cat_materia.materia,
	materias.hrs_materia,
	materias.fecha_desde,
	materias.fecha_hasta,
	nomb.id_empleado_director_general,
	emp2.nombre||' '||emp2.paterno||' '||emp2.materno AS empleado_director_general,
	(
		SELECT 
			prefijo
		FROM view_empleado_grados_academicos_actual
		WHERE id_empleado = emp2.id_empleado
		ORDER BY nivel_grado_academico DESC
		LIMIT 1
	) as prefijo_director_general,
	(
		SELECT 
			profesion
		FROM view_empleado_grados_academicos_actual
		WHERE id_empleado = emp2.id_empleado
		ORDER BY nivel_grado_academico DESC
		LIMIT 1
	) as profesion_director_general,
	nomb.id_empleado_director_planeacion,
	emp3.nombre||' '||emp3.paterno||' '||emp3.materno AS empleado_director_planeacion,
	(
		SELECT 
			prefijo
		FROM view_empleado_grados_academicos_actual
		WHERE id_empleado = emp3.id_empleado
		ORDER BY nivel_grado_academico DESC
		LIMIT 1
	) as prefijo_director_planeacion,
	(
		SELECT 
			profesion
		FROM view_empleado_grados_academicos_actual
		WHERE id_empleado = emp3.id_empleado
		ORDER BY nivel_grado_academico DESC
		LIMIT 1
	) as profesion_director_planeacion,
	nomb.id_empleado_delegado_admvo,
	emp4.nombre||' '||emp4.paterno||' '||emp4.materno AS empleado_delegado_admvo,
	(
		SELECT 
			prefijo
		FROM view_empleado_grados_academicos_actual
		WHERE id_empleado = emp4.id_empleado
		ORDER BY nivel_grado_academico DESC
		LIMIT 1
	) as prefijo_delegado_admvo,
	(
		SELECT 
			profesion
		FROM view_empleado_grados_academicos_actual
		WHERE id_empleado = emp4.id_empleado
		ORDER BY nivel_grado_academico DESC
		LIMIT 1
	) as profesion_delegado_admvo,
	nomb.id_empleado_coordinador_sectorial,
	emp5.nombre||' '||emp5.paterno||' '||emp5.materno AS empleado_coordinador_sectorial,
	(
		SELECT 
			prefijo
		FROM view_empleado_grados_academicos_actual
		WHERE id_empleado = emp5.id_empleado
		ORDER BY nivel_grado_academico DESC
		LIMIT 1
	) as prefijo_coordinador_sectorial,
	(
		SELECT 
			profesion
		FROM view_empleado_grados_academicos_actual
		WHERE id_empleado = emp5.id_empleado
		ORDER BY nivel_grado_academico DESC
		LIMIT 1
	) as profesion_coordinador_sectorial,
	nomb.id_empleado_director,
	emp6.nombre||' '||emp6.paterno||' '||emp6.materno AS empleado_director,
	(
		SELECT 
			prefijo
		FROM view_empleado_grados_academicos_actual
		WHERE id_empleado = emp6.id_empleado
		ORDER BY nivel_grado_academico DESC
		LIMIT 1
	) as prefijo_director,
	(
		SELECT 
			profesion
		FROM view_empleado_grados_academicos_actual
		WHERE id_empleado = emp6.id_empleado
		ORDER BY nivel_grado_academico DESC
		LIMIT 1
	) as profesion_director,
	nomb.id_empleado_jefe_rh,
	emp7.nombre||' '||emp7.paterno||' '||emp7.materno AS empleado_jefe_rh,
	(
		SELECT 
			prefijo
		FROM view_empleado_grados_academicos_actual
		WHERE id_empleado = emp7.id_empleado
		ORDER BY nivel_grado_academico DESC
		LIMIT 1
	) as prefijo_jefe_rh,
	(
		SELECT 
			profesion
		FROM view_empleado_grados_academicos_actual
		WHERE id_empleado = emp7.id_empleado
		ORDER BY nivel_grado_academico DESC
		LIMIT 1
	) as profesion_jefe_rh,
	usr.id_usuario,
	emp8.nombre||' '||emp8.paterno||' '||emp8.materno AS usuario_captura,
	nomb.fecha_creacion,
	nomb.tipo_reporte
FROM nombramientos_planeacion_tf nomb
INNER JOIN nombramientos_planeacion_tf_materias materias ON materias.id_nombramiento_planeacion_tf = nomb.id_nombramiento_planeacion_tf
INNER JOIN detalle_materias detalle ON detalle.id_detalle_materia = materias.id_detalle_materia
INNER JOIN cat_materias cat_materia ON cat_materia.id_materia = detalle.id_materia
INNER JOIN empleados emp1 ON emp1.id_empleado = nomb.id_empleado_nombramiento
INNER JOIN subprogramas subp ON subp.id_subprograma = nomb.id_subprograma
INNER JOIN cat_estructuras_ocupacionales estruc ON estruc.id_estructura_ocupacional = nomb.id_estructura_ocupacional
INNER JOIN usuarios usr ON usr.id_usuario = nomb.id_usuario_captura
INNER JOIN empleados emp8 ON emp8.id_empleado = usr.id_empleado
LEFT JOIN empleados emp2 ON emp2.id_empleado = nomb.id_empleado_director_general
LEFT JOIN empleados emp3 ON emp3.id_empleado = nomb.id_empleado_director_planeacion
LEFT JOIN empleados emp4 ON emp4.id_empleado = nomb.id_empleado_delegado_admvo
LEFT JOIN empleados emp5 ON emp5.id_empleado = nomb.id_empleado_coordinador_sectorial
LEFT JOIN empleados emp6 ON emp6.id_empleado = nomb.id_empleado_director
LEFT JOIN empleados emp7 ON emp7.id_empleado = nomb.id_empleado_jefe_rh
ORDER BY
	nomb.id_estructura_ocupacional,
	nomb.id_empleado_nombramiento,
	cat_materia.materia
)
UNION ALL
(
SELECT 
	nomb.id_nombramiento_planeacion_tf,
	estruc.id_estructura_ocupacional,
	estruc.periodo,
	nomb.no_oficio,
	nomb.id_empleado_nombramiento,
	emp1.nombre||' '||emp1.paterno||' '||emp1.materno AS empleado_nombramiento,
	subp.id_subprograma,
	subp.nombre_subprograma,
	0 AS id_detalle_materia,
	cat_materia.id_paraescolar,
	cat_materia.nombre AS materia,
	materias.hrs_materia,
	materias.fecha_desde,
	materias.fecha_hasta,
	nomb.id_empleado_director_general,
	emp2.nombre||' '||emp2.paterno||' '||emp2.materno AS empleado_director_general,
	nomb.id_empleado_director_planeacion,
	emp3.nombre||' '||emp3.paterno||' '||emp3.materno AS empleado_director_planeacion,
	nomb.id_empleado_delegado_admvo,
	emp4.nombre||' '||emp4.paterno||' '||emp4.materno AS empleado_delegado_admvo,
	nomb.id_empleado_coordinador_sectorial,
	emp5.nombre||' '||emp5.paterno||' '||emp5.materno AS empleado_coordinador_sectorial,
	nomb.id_empleado_director,
	emp6.nombre||' '||emp6.paterno||' '||emp6.materno AS empleado_director,
	nomb.id_empleado_jefe_rh,
	emp7.nombre||' '||emp7.paterno||' '||emp7.materno AS empleado_jefe_rh,
	usr.id_usuario,
	emp8.nombre||' '||emp8.paterno||' '||emp8.materno AS usuario_captura,
	nomb.fecha_creacion,
	nomb.tipo_reporte
FROM nombramientos_planeacion_tf nomb
INNER JOIN nombramientos_planeacion_tf_materias_paraescolares materias ON materias.id_nombramiento_planeacion_tf = nomb.id_nombramiento_planeacion_tf
INNER JOIN cat_materias_paraescolares cat_materia ON cat_materia.id_paraescolar = materias.id_paraescolar
INNER JOIN empleados emp1 ON emp1.id_empleado = nomb.id_empleado_nombramiento
INNER JOIN subprogramas subp ON subp.id_subprograma = nomb.id_subprograma
INNER JOIN cat_estructuras_ocupacionales estruc ON estruc.id_estructura_ocupacional = nomb.id_estructura_ocupacional
INNER JOIN usuarios usr ON usr.id_usuario = nomb.id_usuario_captura
INNER JOIN empleados emp8 ON emp8.id_empleado = usr.id_empleado
LEFT JOIN empleados emp2 ON emp2.id_empleado = nomb.id_empleado_director_general
LEFT JOIN empleados emp3 ON emp3.id_empleado = nomb.id_empleado_director_planeacion
LEFT JOIN empleados emp4 ON emp4.id_empleado = nomb.id_empleado_delegado_admvo
LEFT JOIN empleados emp5 ON emp5.id_empleado = nomb.id_empleado_coordinador_sectorial
LEFT JOIN empleados emp6 ON emp6.id_empleado = nomb.id_empleado_director
LEFT JOIN empleados emp7 ON emp7.id_empleado = nomb.id_empleado_jefe_rh
ORDER BY
	nomb.id_estructura_ocupacional,
	nomb.id_empleado_nombramiento,
	cat_materia.nombre
)
