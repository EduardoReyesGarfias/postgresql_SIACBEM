CREATE OR REPLACE FUNCTION planteles_total_hrs_asignadas_tiempo_fijo_de_base( filiacion text, id_estructura integer )
RETURNS integer
AS $$
DECLARE 
	total_hrs_tiempo_fijo integer;
BEGIN
	
	SELECT INTO total_hrs_tiempo_fijo
	(SELECT COALESCE(sum(a.horas_grupo),0)
	FROM asignacion_tiempo_fijo_basico a
	INNER JOIN empleados b ON a.id_empleado = b.id_empleado
	INNER JOIN detalle_materias c ON c.id_detalle_materia = a.id_detalle_materia
	INNER JOIN cat_materias d ON d.id_materia = c.id_materia
	INNER JOIN cat_categorias_padre e ON e.id_cat_categoria_padre = a.id_cat_categoria_padre
	WHERE a.id_estructura_ocupacional = $2
	AND b.filiacion = $1
	AND a.id_tipo_movimiento_personal = 2
	)
	+(SELECT COALESCE(sum(a.horas_grupo),0)
	FROM asignacion_tiempo_fijo_optativas a
	INNER JOIN empleados b ON a.id_empleado = b.id_empleado
	INNER JOIN detalle_materias c ON c.id_detalle_materia = a.id_detalle_materia
	INNER JOIN cat_materias d ON d.id_materia = c.id_materia
	INNER JOIN cat_categorias_padre e ON e.id_cat_categoria_padre = a.id_cat_categoria_padre
	WHERE a.id_estructura_ocupacional = $2
	AND b.filiacion = $1
	AND a.id_tipo_movimiento_personal = 2
	)
	+(SELECT COALESCE(sum(a.horas_grupo),0)
	FROM asignacion_tiempo_fijo_capacitacion a
	INNER JOIN empleados b ON a.id_empleado = b.id_empleado
	INNER JOIN detalle_materias c ON c.id_detalle_materia = a.id_detalle_materia
	INNER JOIN cat_materias d ON d.id_materia = c.id_materia
	INNER JOIN cat_categorias_padre e ON e.id_cat_categoria_padre = a.id_cat_categoria_padre
	WHERE a.id_estructura_ocupacional = $2
	AND b.filiacion = $1
	AND a.id_tipo_movimiento_personal = 2
	)
	+(
		SELECT COALESCE(sum(a.horas_grupo),0)
		FROM asignacion_tiempo_fijo_paraescolares a
		INNER JOIN empleados b ON a.id_empleado = b.id_empleado
		INNER JOIN cat_materias_paraescolares c ON c.id_paraescolar = a.id_cat_materias_paraescolares
		INNER JOIN cat_categorias_padre e ON e.id_cat_categoria_padre = a.id_cat_categoria_padre
		WHERE a.id_estructura_ocupacional = $2
		AND b.filiacion = $1
		AND a.id_tipo_movimiento_personal = 2
	);
	
	RETURN total_hrs_tiempo_fijo;
	
END; $$ 
LANGUAGE 'plpgsql';


SELECT * FROM planteles_total_hrs_asignadas_tiempo_fijo('VAPM720810000',27)

