CREATE OR REPLACE FUNCTION planteles_valida_perfil_eb(_id_empleado integer, _id_detalle_materia integer, _id_componente integer)
RETURNS smallint

AS $$
DECLARE

	cumple_perfil smallint;
	es_habilitado integer;
	es_asignatura_ingles boolean;
	match_grado_materia integer;
	match_grado_materia_validado boolean;

	-- Recorrer grados academicos de paraescolares 
	record_paraescolares RECORD;
	cursor_paraescolares CURSOR FOR(
		SELECT (CASE WHEN a.valida_archivo = 'SI' THEN true ELSE false END) as valida_archivo
		FROM view_empleado_grados_academicos a
		WHERE a.id_empleado = _id_empleado
		ORDER BY a.valida_archivo DESC	
	);	

BEGIN

	/*
	1.- validar paraescolares
	2.- validar habilitados
	3.- validar ingles
	4.- validar asignatura normal
   */

	cumple_perfil:= 0;	
	es_habilitado:= 0;
	es_asignatura_ingles:= false;
	match_grado_materia:= 0;
	match_grado_materia_validado:= false;

	-- Ver si es componente paraescolar
	IF _id_componente = 4 THEN

		FOR record_paraescolares IN cursor_paraescolares LOOP
			match_grado_materia_validado:= record_paraescolares.valida_archivo;	
		END LOOP;

		IF match_grado_materia_validado = true THEN
			cumple_perfil:= 1;
		ELSE
			cumple_perfil:= 3;
		END IF;

	ELSE 	

		-- Ver si es habilitado
	 	SELECT INTO es_habilitado
		a.id_profesor_habilitado
		FROM profesores_habilitados a
		WHERE a.id_empleado = _id_empleado
		AND a.id_detalle_materia = _id_detalle_materia
		LIMIT 1;

		IF es_habilitado > 0 THEN
			cumple_perfil:= 4;
		ELSE
			

			-- Saber si es materia de ingles
			SELECT INTO es_asignatura_ingles
			CASE WHEN (
				palabra_acentos(b.materia) ilike palabra_acentos('INGLES%') OR 
				palabra_acentos(b.materia) ilike palabra_acentos('%MANEJO DE UNA AGENDA EMPRESARIAL%') OR
				palabra_acentos(b.materia) ilike palabra_acentos('%Solución de Problemas%') OR
				palabra_acentos(b.materia) ilike palabra_acentos('%PLANEACIÓN DE EVENTOS EMPRESARIALES%') OR
				palabra_acentos(b.materia) ilike palabra_acentos('%ESTABLECE RELACIONES EMPRESARIALES%') OR
				palabra_acentos(b.materia) ilike palabra_acentos('%ATENCIÓN TELEFÓNICA%') OR
				palabra_acentos(b.materia) ilike palabra_acentos('%Documentos Empresariales%')
			) THEN true ELSE false END
			FROM detalle_materias a
			INNER JOIN cat_materias b ON a.id_materia = b.id_materia
			WHERE id_detalle_materia = _id_detalle_materia;

			IF es_asignatura_ingles = true THEN

				-- Ver si hace match un grado academico con Ingles
				SELECT INTO match_grado_materia, match_grado_materia_validado
				a.id_empleado_grado_academico,CASE WHEN a.valida_archivo = 'SI' THEN true ELSE false END
				FROM view_empleado_grados_academicos a
				INNER JOIN profesiones_materias b ON b.id_profesion = a.id_profesion
				INNER JOIN detalle_materias c ON c.id_detalle_materia = b.id_detalle_materia 
				INNER JOIN cat_materias d ON d.id_materia = c.id_materia
				WHERE a.id_empleado = _id_empleado
				AND c.id_detalle_materia = _id_detalle_materia
				LIMIT 1;

				IF match_grado_materia > 0 THEN

					IF match_grado_materia_validado = true THEN 
						cumple_perfil:= 1;
					ELSE
						cumple_perfil:= 3;
					END IF;

				ELSE

					cumple_perfil:= 0;			

				END IF;


			ELSE

				-- Es asignatura normal (Matematicas, Taller de lectura, etc...)
				SELECT INTO match_grado_materia, match_grado_materia_validado
				a.id_empleado_grado_academico,CASE WHEN a.valida_archivo = 'SI' THEN true ELSE false END
				FROM view_empleado_grados_academicos a
				INNER JOIN profesiones_materias b ON b.id_profesion = a.id_profesion
				INNER JOIN detalle_materias c ON c.id_detalle_materia = b.id_detalle_materia 
				INNER JOIN cat_materias d ON d.id_materia = c.id_materia
				WHERE a.id_empleado = _id_empleado
				AND c.id_detalle_materia = _id_detalle_materia
				AND a.nivel_grado_academico >= 23
				LIMIT 1;

				IF match_grado_materia > 0 THEN

					IF match_grado_materia_validado = true THEN 
						cumple_perfil:= 1;
					ELSE
						cumple_perfil:= 3;
					END IF;

				ELSE

					cumple_perfil:= 0;			

				END IF;


			END IF;	



		END IF;

	END IF;

	RETURN cumple_perfil;

END; $$ 
LANGUAGE 'plpgsql';