CREATE OR REPLACE FUNCTION planteles_valida_perfil(filiacion text, id_detalle_materia integer)
RETURNS boolean

AS $$
DECLARE 
	registro integer;
	cumple_perfil boolean;
BEGIN
	registro:= 0;
	cumple_perfil:= false;
	
	SELECT INTO registro
	a.id_profesion
	FROM empleados b
	INNER JOIN curricula_estudios_empleados a ON b.id_empleado = a.id_empleado
	INNER JOIN cat_profesiones c ON a.id_profesion = c.id_profesion
	INNER JOIN cat_grados_academicos d ON d.id_grado_academico = c.id_grado_academico
	INNER JOIN profesiones_materias e ON e.id_profesion = a.id_profesion
	INNER JOIN detalle_materias f ON f.id_detalle_materia = e.id_detalle_materia 
	INNER JOIN cat_materias g ON g.id_materia = f.id_materia
	where b.filiacion = $1
	AND f.id_detalle_materia = $2
	--AND d.nivel_grado_academico >= 23
	AND (d.nivel_grado_academico >= 23 OR (d.id_grado_academico = 41) )
	LIMIT 1;
	
	IF (registro > 0) THEN
		cumple_perfil:= true;
	END IF;
	
	return cumple_perfil;
END; $$ 
LANGUAGE 'plpgsql';

SELECT * FROM planteles_valida_perfil('SOGF791019000',723);

-- 621
-- 474
-- 202
-- 723