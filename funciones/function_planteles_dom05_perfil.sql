CREATE OR REPLACE FUNCTION planteles_dom05_perfil( filiacion text )
RETURNS table(
	profesion text,
	prefijo text,
	grado_academico text,
	validacion text
)
AS $$
DECLARE
	var_prefijo text;
	var_profesion text;
	var_grado_academico text;
	var_validacion text;
BEGIN
		/* prefijo */
		SELECT STRING_AGG((
			CASE WHEN xz.genero = 'F' THEN 
				xb.prefijo_fem
			ELSE
				xb.prefijo
			END
		),',' ORDER BY xc.nivel_grado_academico ) INTO var_prefijo
		FROM curricula_estudios_empleados xa
		INNER JOIN cat_profesiones xb ON xb.id_profesion = xa.id_profesion
		INNER JOIN cat_grados_academicos xc ON xc.id_grado_academico = xb.id_grado_academico
		INNER JOIN empleados xz ON xz.id_empleado = xa.id_empleado
		INNER JOIN empleado_grados_academicos xy ON xy.id_empleado_grado_academico = xa.id_empleado_grado_academico 
		WHERE xz.filiacion = $1
		AND xc.nivel_grado_academico >= 23;
		
		/* profesion */
		SELECT STRING_AGG(xb.profesion,',' ORDER BY xc.nivel_grado_academico) INTO var_profesion
		FROM curricula_estudios_empleados xa
		INNER JOIN cat_profesiones xb ON xb.id_profesion = xa.id_profesion
		INNER JOIN cat_grados_academicos xc ON xc.id_grado_academico = xb.id_grado_academico
		INNER JOIN empleados xz ON xz.id_empleado = xa.id_empleado
		INNER JOIN empleado_grados_academicos xy ON xy.id_empleado_grado_academico = xa.id_empleado_grado_academico 
		WHERE xz.filiacion = $1
		AND xc.nivel_grado_academico >= 23;
		
		/* grado_academico */
		SELECT STRING_AGG(xc.grado_academico,',' ORDER BY xc.nivel_grado_academico) INTO var_grado_academico
		FROM curricula_estudios_empleados xa
		INNER JOIN cat_profesiones xb ON xb.id_profesion = xa.id_profesion
		INNER JOIN cat_grados_academicos xc ON xc.id_grado_academico = xb.id_grado_academico
		INNER JOIN empleados xz ON xz.id_empleado = xa.id_empleado
		INNER JOIN empleado_grados_academicos xy ON xy.id_empleado_grado_academico = xa.id_empleado_grado_academico 
		WHERE xz.filiacion = $1
		AND xc.nivel_grado_academico >= 23;
		
		/* validacion */
		SELECT 
			STRING_AGG(
		(CASE WHEN (xy.valida_archivo is null) THEN
			'NO revisado'
			WHEN (xy.valida_archivo = true) THEN
				'Validado'
			WHEN (xy.valida_archivo = false) THEN
				'Rechazado'
		END)
		,',' ORDER BY xc.nivel_grado_academico) INTO var_validacion
		FROM curricula_estudios_empleados xa
		INNER JOIN cat_profesiones xb ON xb.id_profesion = xa.id_profesion
		INNER JOIN cat_grados_academicos xc ON xc.id_grado_academico = xb.id_grado_academico
		INNER JOIN empleados xz ON xz.id_empleado = xa.id_empleado
		INNER JOIN empleado_grados_academicos xy ON xy.id_empleado_grado_academico = xa.id_empleado_grado_academico 
		WHERE xz.filiacion = $1
		AND xc.nivel_grado_academico >= 23;
		
		
	
	RETURN QUERY SELECT var_profesion, var_prefijo, var_grado_academico, var_validacion;

END; $$ 
 
LANGUAGE 'plpgsql';

select * from planteles_dom05_perfil('REGE920409000')
