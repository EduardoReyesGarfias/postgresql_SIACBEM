CREATE OR REPLACE FUNCTION planteles_valida_perfil_tf_1(_id_empleado int, _id_materia int, _id_estructura int,  _id_componente int default 1, _id_grupo int default null)
RETURNS smallint
AS $$
DECLARE
	
	cumple_perfil smallint;
	es_asignatura_ingles boolean;
	match_grado_materia integer;
	match_grado_materia_validado text;
	lic_titulo_adelante integer;
	constancia_laboral integer;
	match_lic_no_dan_ingles integer;
	match_es_base integer;
	certificacion_ingles_vigente text;

BEGIN

   cumple_perfil:= 0;	
   es_asignatura_ingles:= false;
   match_grado_materia:= 0;
   match_grado_materia_validado:= false;
   lic_titulo_adelante:= 0;
   constancia_laboral:= 0;
   match_lic_no_dan_ingles:= 0;
   match_es_base:= 0;
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

			-- 04/02/2022 - Algunas licenciaturas en tf no pueden dar ingles pero en base si.
			/*
			3488	"LICENCIADA EN RELACIONES INTERNACIONALES"
			3487	"LICENCIADO EN RELACIONES INTERNACIONALES"
			93	    "LICENCIATURA EN RELACIONES INTERNACIONALES"
			437	    "LICENCIADO EN ADMINISTRACIÓN DE LA HOSPITALIDAD"
			1378	"LICENCIATURA EN ADMINISTRACIÓN DE LA HOSPITALIDAD"
			3889	"LICENCIADA EN COMERCIO INTERNACIONAL"
			2413	"LICENCIADA EN COMERCIO INTERNACIONAL"
			111	    "LICENCIADO EN COMERCIO INTERNACIONAL"
			3890	"LICENCIADO EN COMERCIO INTERNACIONAL"
			1454	"LICENCIATURA EN COMERCIO INTERNACIONAL"
			3888	"LICENCIATURA EN COMERCIO INTERNACIONAL"
			2526	"LICENCIADA EN TURISMO"
			349	    "LICENCIADO EN TURISMO"
			1632	"LICENCIATURA EN TURISMO"
			3946	"LICENCIADA EN NEGOCIOS INTERNACIONALES"
			3947	"LICENCIADO EN NEGOCIOS INTERNACIONALES"
			296	    "LICENCIADO EN NEGOCIOS INTERNACIONALES"
			1659	"LICENCIATURA EN NEGOCIOS INTERNACIONALES"
			3945	"LICENCIATURA EN NEGOCIOS INTERNACIONALES"
			*/

			-- saber si la persona es de base
			SELECT INTO match_es_base
			id_plantilla_base_docente_rh
			FROM plantilla_base_docente_rh
			WHERE 
				id_empleado = _id_empleado
				AND id_estructura_ocupacional = _id_estructura
			LIMIT 1;

			-- Si no es de base reviso lo de las licenciaturas	
			IF match_es_base = 0 THEN	

				-- saber si tiene algunas de las licenciaturas	
				SELECT INTO match_lic_no_dan_ingles
					id_empleado_grado_academico
				FROM view_empleado_grados_academicos_actual a
				WHERE a.id_empleado = $1
				AND id_profesion in ( 3488, 3487, 93, 437, 1378, 3889, 2413, 111, 3890, 1454, 3888, 2526, 349, 1632, 3946, 3947, 296, 1659, 3945 )
				LIMIT 1;

				IF(match_lic_no_dan_ingles > 0) THEN
					cumple_perfil:= 0;
				ELSE

					-- Ver si hace match un grado academico con Ingles
					SELECT INTO match_grado_materia, match_grado_materia_validado
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

					/*IF match_grado_materia > 0 THEN

						IF match_grado_materia_validado = true THEN 
							cumple_perfil:= 1;
						ELSE
							cumple_perfil:= 0;

						END IF;

					ELSE

						cumple_perfil:= 0;*/
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

				END IF;

			ELSE

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
   
END; $$ 
LANGUAGE 'plpgsql';