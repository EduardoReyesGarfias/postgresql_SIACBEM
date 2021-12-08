DECLARE
	
	cumple_perfil smallint;
	es_asignatura_ingles boolean;
	match_grado_materia integer;
	match_grado_materia_validado text;
	lic_titulo_adelante integer;
	constancia_laboral integer;
    certificacion_ingles_vigente text;

BEGIN

   cumple_perfil:= 0;	
   es_asignatura_ingles:= false;
   match_grado_materia:= 0;
   /* match_grado_materia_validado:= false; */
   lic_titulo_adelante:= 0;
   constancia_laboral:= 0;
   certificacion_ingles_vigente:= '';

    /*
	1.- validar paraescolares

		Es banda de guerra o escoltas
			Match con grado academico (Unicamente de bachillerato validado en adelante)
				SI -> Cumple perfil
				NO -> No cumple perfil
		
		Es materia diferente a banda de guerra o escoltas
			Match con grado academico (Licenciatura terminada validada en adelante)
				SI -> Cumple perfil
				NO -> 
					Tiene licenciatura con titulo validada en adelante 
						SI -> Tiene constancia laboral
								SI -> Cumple el perfil
								No -> No cumple perfil
						NO -> No cumple perfil		
						
	2.- validar ingles
	3.- validar asignatura normal
   */

   -- Saber si es materia de paraescolares
	IF _id_componente = 4 THEN

		/*
		Si es banda de guerra o escoltas se valida desde bachillerato
		se desactivo esta parte, porque estas materias se les da tratamiento como a todas las paraescolares
		18/01/2021
		*/
		--IF $2 = 62 OR $2 = 64 THEN
		IF false THEN

			SELECT INTO match_grado_materia, match_grado_materia_validado
			a.id_empleado_grado_academico,
			CASE WHEN grado_academico = '09 Licenciatura con título' THEN 
				CASE WHEN (valida_archivo_reportes = 'Ced Si<br>Tit Si' OR valida_archivo_reportes = 'Tit Si<br>Ced Si') THEN 'SI' ELSE 'NO' END
			ELSE
				upper(valida_archivo_reportes)
			END
			FROM view_empleado_grados_academicos_actual a
			WHERE a.id_empleado = $1
			AND a.nivel_grado_academico >= 7;

			IF match_grado_materia > 0 THEN

				IF match_grado_materia_validado = 'SI' THEN 
					cumple_perfil:= 1;
				ELSE
					cumple_perfil:= 3;
				END IF;	

			END IF;	

		ELSE

			-- Es materia paraescolar pero es diferente a banda de guerra o escoltas
			-- 18/01/2021 Valida si es cualquier materia paraescolar

			SELECT INTO match_grado_materia, match_grado_materia_validado
			a.id_empleado_grado_academico,
			CASE WHEN grado_academico = '09 Licenciatura con título' THEN 
				CASE WHEN (valida_archivo_reportes = 'Ced Si<br>Tit Si' OR valida_archivo_reportes = 'Tit Si<br>Ced Si') THEN 'SI' ELSE 'NO' END
			ELSE
				upper(valida_archivo_reportes)
			END
			FROM view_empleado_grados_academicos_actual a
			INNER JOIN profesiones_materias_paraescolares b ON b.id_profesion = a.id_profesion
			INNER JOIN cat_materias_paraescolares c ON c.id_paraescolar = b.id_paraescolar
			WHERE a.id_empleado = $1
			AND c.id_paraescolar = $2
			AND a.nivel_grado_academico >= 23
			LIMIT 1;	

			IF match_grado_materia > 0 THEN

				IF match_grado_materia_validado = 'SI' THEN 
					cumple_perfil:= 1;
				ELSE
					cumple_perfil:= 3;
				END IF;

			ELSE

				-- Entonces ver los que tienen constancia de acreditaccion para dar la materia
				-- Ver si tiene Licenciatura con título
				SELECT INTO lic_titulo_adelante, match_grado_materia_validado
				a.id_empleado_grado_academico,
				CASE WHEN grado_academico = '09 Licenciatura con título' THEN 
					CASE WHEN (valida_archivo_reportes = 'Ced Si<br>Tit Si' OR valida_archivo_reportes = 'Tit Si<br>Ced Si') THEN 'SI' ELSE 'NO' END
				ELSE
					upper(valida_archivo_reportes)
				END
				FROM view_empleado_grados_academicos_actual a
				WHERE a.id_empleado = $1
				AND a.nivel_grado_academico >= 23
				LIMIT 1;

				IF lic_titulo_adelante > 0 THEN

					IF match_grado_materia_validado = 'SI' THEN 
						-- Ver si tiene grado_academico: constancia laboral
						match_grado_materia_validado:= false;

						SELECT INTO constancia_laboral, match_grado_materia_validado
						a.id_empleado_grado_academico,
						CASE WHEN grado_academico = '09 Licenciatura con título' THEN 
							CASE WHEN (valida_archivo_reportes = 'Ced Si<br>Tit Si' OR valida_archivo_reportes = 'Tit Si<br>Ced Si') THEN 'SI' ELSE 'NO' END
						ELSE
							upper(valida_archivo_reportes)
						END
						FROM view_empleado_grados_academicos_actual a
						WHERE a.id_empleado = $1
						AND a.grado_academico = '15 CONSTANCIA DE EXPERIENCIA LABORAL'
						LIMIT 1;

						IF constancia_laboral > 0 THEN

							IF match_grado_materia_validado = 'SI' THEN
								cumple_perfil:= 1;
							ELSE
								cumple_perfil:= 3;
							END IF;
									
						ELSE		
							cumple_perfil:= 0;
							/*
							Valida si el profesor en base fue habilitado y se le da opcion a completar un grupo incompleto de base en la etapa de tf
							*/
							SELECT INTO cumple_perfil
							CASE WHEN(planteles_valida_perfil_tf_complementa_grupo is true) THEN 1 ELSE 0 END
							FROM planteles_valida_perfil_tf_complementa_grupo(_id_empleado, _id_estructura, _id_grupo);


						END IF;
						
					ELSE
						cumple_perfil:= 3;
					END IF;

				ELSE
					cumple_perfil:= 0;
				END IF;				

			END IF;

		END IF;

		


	ELSE

	
		-- Saber si es materia de ingles
		SELECT INTO es_asignatura_ingles
		CASE WHEN (palabra_acentos(b.materia) ilike palabra_acentos('INGLES%') ) THEN true ELSE false END
		FROM detalle_materias a
		INNER JOIN cat_materias b ON a.id_materia = b.id_materia
		WHERE id_detalle_materia = $2;

		IF es_asignatura_ingles = true THEN

			-- Ver si hace match un grado academico con Ingles
			SELECT INTO match_grado_materia, match_grado_materia_validado, certificacion_ingles_vigente
			a.id_empleado_grado_academico,
            CASE WHEN grado_academico = '09 Licenciatura con título' THEN 
                CASE WHEN (valida_archivo_reportes = 'Ced Si<br>Tit Si' OR valida_archivo_reportes = 'Tit Si<br>Ced Si') THEN 'SI' ELSE 'NO' END
            ELSE
                upper(valida_archivo_reportes)
            END,
            (
                --CASE WHEN NOW()::date BETWEEN fecha_expedicion AND fecha_vigencia THEN 'SI' ELSE 'NO' END
				'SI'
            )
            FROM view_empleado_grados_academicos_actual a
			INNER JOIN profesiones_materias b ON b.id_profesion = a.id_profesion
			INNER JOIN detalle_materias c ON c.id_detalle_materia = b.id_detalle_materia 
			INNER JOIN cat_materias d ON d.id_materia = c.id_materia
			WHERE a.id_empleado = $1
			AND c.id_detalle_materia = $2
			LIMIT 1;

			IF match_grado_materia > 0 THEN

				IF match_grado_materia_validado = 'SI' THEN 

                    IF certificacion_ingles_vigente = 'SI' THEN
                        cumple_perfil:= 1;
                    ELSE
                        cumple_perfil:= 0;
					END IF;	
                            
				ELSE
					cumple_perfil:= 3;

				END IF;

			ELSE

				cumple_perfil:= 0;

				/*
				Valida si el profesor en base fue habilitado y se le da opcion a completar un grupo incompleto de base en la etapa de tf
				*/
				SELECT INTO cumple_perfil
				CASE WHEN(planteles_valida_perfil_tf_complementa_grupo is true) THEN 1 ELSE 0 END
				FROM planteles_valida_perfil_tf_complementa_grupo(_id_empleado, _id_estructura, _id_grupo);			

			END IF;


		ELSE

			-- Es asignatura normal (Matematicas, Taller de lectura, etc...)
			SELECT INTO match_grado_materia, match_grado_materia_validado
			a.id_empleado_grado_academico,
			CASE WHEN grado_academico = '09 Licenciatura con título' THEN 
				CASE WHEN (valida_archivo_reportes = 'Ced Si<br>Tit Si' OR valida_archivo_reportes = 'Tit Si<br>Ced Si') THEN 'SI' ELSE 'NO' END
			ELSE
				upper(valida_archivo_reportes)
			END
			FROM view_empleado_grados_academicos_actual a
			INNER JOIN profesiones_materias b ON b.id_profesion = a.id_profesion
			INNER JOIN detalle_materias c ON c.id_detalle_materia = b.id_detalle_materia 
			INNER JOIN cat_materias d ON d.id_materia = c.id_materia
			WHERE a.id_empleado = $1
			AND c.id_detalle_materia = $2
			AND a.nivel_grado_academico >= 23
			LIMIT 1;

			IF match_grado_materia > 0 THEN

				IF match_grado_materia_validado = 'SI' THEN 
					cumple_perfil:= 1;
				ELSE
					cumple_perfil:= 3;
				END IF;

			ELSE

				cumple_perfil:= 0;

				/*
				Valida si el profesor en base fue habilitado y se le da opcion a completar un grupo incompleto de base en la etapa de tf
				*/
				SELECT INTO cumple_perfil
				CASE WHEN(planteles_valida_perfil_tf_complementa_grupo is true) THEN 1 ELSE 0 END
				FROM planteles_valida_perfil_tf_complementa_grupo(_id_empleado, _id_estructura, _id_grupo);		

			END IF;


		END IF;		

			


	END IF;


   RETURN cumple_perfil;
   
END; 