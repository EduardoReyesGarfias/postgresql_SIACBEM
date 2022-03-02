CREATE OR REPLACE FUNCTION planteles_valida_perfil_tf_detalle(_id_empleado int, _id_estructura int, _id_materia int, _id_componente int default 1, _id_grupo int default null)
RETURNS TABLE(
    codigo smallint,
    texto_codigo character varying
)
AS $$
DECLARE

    _codigo_perfil smallint;
    _texto_codigo character varying;
    _tiene_grados_academicos boolean;
    _tiene_documentos smallint;
    _tiene_documentos_validados smallint;
    _match_grado_materia int;
    _es_lic_con_titulo int;
    _constancia_laboral int;
    _es_asignatura_ingles boolean;
    _es_docente_de_base int;
    _tiene_lic_no_dan_ingles int;

    reg RECORD;
	cur CURSOR FOR (

        SELECT 
            *
        FROM view_empleado_grados_academicos_actual 
        WHERE id_empleado = _id_empleado

    );

BEGIN
    
    /*
        RETURN:

        -1 -> No tiene grados académicos
        -2 -> Tiene grados, NO tiene documentos
        -3 -> Tiene grados, tiene documentos, NO estan validados
         0 -> No tiene relacion materia - licenciatura
         1 -> Cumple con el perfil
    */

    _codigo_perfil = 0; 
    _es_asignatura_ingles = false;   

    -- query para ver si tiene grados academicos
    SELECT INTO _tiene_grados_academicos
    CASE WHEN (count(profesion) > 0 ) THEN true ELSE false END
    FROM view_empleado_grados_academicos_actual
    WHERE id_empleado = _id_empleado;

    -- Ver si tiene grados academicos
    IF _tiene_grados_academicos THEN

        _tiene_documentos = 1;

        -- Recorre los grados academicos
        FOR reg IN cur LOOP

            IF reg.grado_academico = '09 Licenciatura con título' THEN

                IF LENGTH(reg.ruta_archivo_array::text) < 100 THEN
                    _tiene_documentos = 0;   
                END IF;    

            ELSE
                
                IF LENGTH(reg.ruta_archivo_array::text) < 10 THEN
                    _tiene_documentos = 0;
                END IF;    

            END IF;    


        END LOOP; -- END recorre los grados academicos
        
        IF _tiene_documentos = 1 THEN
            
            _tiene_documentos_validados = 1;
            -- ver si tiene documentos en los grados académicos
            SELECT INTO _tiene_documentos_validados
                CASE WHEN grado_academico = '09 Licenciatura con título' THEN 
                    CASE WHEN (valida_archivo_reportes = 'Ced Si<br>Tit Si' OR valida_archivo_reportes = 'Tit Si<br>Ced Si') THEN 1 ELSE 0 END
                ELSE
                    CASE WHEN upper(valida_archivo_reportes) = 'SI' THEN 1 ELSE 0 END
                END
            FROM view_empleado_grados_academicos_actual a
            WHERE 
                a.id_empleado = _id_empleado
                AND a.nivel_grado_academico >= 23
                AND 
                (
                    CASE WHEN grado_academico = '09 Licenciatura con título' THEN 
                        CASE WHEN (valida_archivo_reportes = 'Ced Si<br>Tit Si' OR valida_archivo_reportes = 'Tit Si<br>Ced Si') THEN 1 ELSE 0 END
                    ELSE
                        CASE WHEN upper(valida_archivo_reportes) = 'SI' THEN 1 ELSE 0 END
                    END
                ) = 0;


            IF _tiene_documentos_validados = 1 OR _tiene_documentos_validados IS NULL THEN
               
                _codigo_perfil = 1;
                _texto_codigo = 'Cumple perfil';

                /*
                Empiezo a validar la relacion con la materia
                */

                -- Se evalua cuando es materia de paraescolares
                IF _id_componente = 4 THEN

                    -- Revisar si tiene relacion con la materia
                    SELECT INTO _match_grado_materia
                        a.id_empleado_grado_academico
                    FROM view_empleado_grados_academicos_actual a
                    INNER JOIN profesiones_materias_paraescolares b ON b.id_profesion = a.id_profesion
                    INNER JOIN cat_materias_paraescolares c ON c.id_paraescolar = b.id_paraescolar
                    WHERE 
                        a.id_empleado = _id_empleado
                        AND c.id_paraescolar = _id_materia
                        AND a.nivel_grado_academico >= 23
                    LIMIT 1;

                    IF _match_grado_materia > 0 THEN

                        _codigo_perfil = 1;
                        _texto_codigo = 'Cumple perfil';

                    ELSE

                        /* 
                            ver si tiene constancia de acreditación para poder dar la materia

                            1.- Primero ver que tenga lic con titulo
                            2.- ver que tenga constancia
                        
                        */    
                        SELECT INTO _es_lic_con_titulo
                            a.id_empleado_grado_academico 
                        FROM view_empleado_grados_academicos_actual a
                        WHERE a.id_empleado = _id_empleado
                        AND a.nivel_grado_academico >= 23
                        LIMIT 1;

                        IF _es_lic_con_titulo > 0 THEN

                            -- Ver si tiene grado_academico: constancia laboral
                            SELECT INTO _constancia_laboral
                            a.id_empleado_grado_academico 
                            FROM view_empleado_grados_academicos_actual a
                            WHERE a.id_empleado = _id_empleado
                            AND a.grado_academico = '15 CONSTANCIA DE EXPERIENCIA LABORAL'
                            LIMIT 1;

                            IF _constancia_laboral > 0 THEN
                                _codigo_perfil = 1;
                                _texto_codigo = 'Cumple perfil';
                            ELSE		
                                _codigo_perfil = 0;
                                _texto_codigo = 'No cumple perfil';
                                /*
                                Valida si el profesor en base fue habilitado y se le da opcion a completar un grupo incompleto de base en la etapa de tf
                                */
                                SELECT INTO _codigo_perfil
                                CASE WHEN(planteles_valida_perfil_tf_complementa_grupo is true) THEN 1 ELSE 0 END
                                FROM planteles_valida_perfil_tf_complementa_grupo(_id_empleado, _id_estructura, _id_grupo);

                                IF _codigo_perfil = 1 THEN
                                    _texto_codigo = 'Cumple perfil';
                                END IF;


                            END IF;

                        ELSE
                            _codigo_perfil:= 0;
                        END IF;


                    END IF; -- END valida relacion con paraescolares
                    	

                END IF; -- END si es paraescolares

                /*
                Validaciones para asignatura de ingles
                */
                -- Saber si es materia de ingles
                IF _id_componente = 1 THEN
                
                    SELECT INTO _es_asignatura_ingles
                    CASE WHEN (palabra_acentos(b.materia) ilike palabra_acentos('INGLES%') ) THEN true ELSE false END
                    FROM detalle_materias a
                    INNER JOIN cat_materias b ON a.id_materia = b.id_materia
                    WHERE id_detalle_materia = _id_materia;
                
                END IF;


                IF es_asignatura_ingles = true THEN
                    /*
                    04/02/2022 - Algunas licenciaturas en T.F. no pueden dar ingles esto aplica solo para los que NO son docentes de base.
                    
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
                    SELECT INTO _es_docente_de_base
                        id_plantilla_base_docente_rh
                    FROM plantilla_base_docente_rh
                    WHERE 
                        id_empleado = _id_empleado
                        AND id_estructura_ocupacional = _id_estructura
                    LIMIT 1;

                    -- Si no es de base reviso lo de las licenciaturas	
                    IF _es_docente_de_base = 0 THEN	

                        -- saber si tiene algunas de las licenciaturas	
                        SELECT INTO _tiene_lic_no_dan_ingles
                            id_empleado_grado_academico
                        FROM view_empleado_grados_academicos_actual a
                        WHERE a.id_empleado = _id_empleado
                        AND id_profesion in ( 3488, 3487, 93, 437, 1378, 3889, 2413, 111, 3890, 1454, 3888, 2526, 349, 1632, 3946, 3947, 296, 1659, 3945 )
                        LIMIT 1;

                        IF _tiene_lic_no_dan_ingles > 0 THEN
                            _codigo_perfil = 0;
                            _texto_codigo = 'No cumple perfil';
                        ELSE

                            -- Ver si hace match un grado academico con Ingles
                            SELECT INTO _match_grado_materia
                                a.id_empleado_grado_academico
                            FROM view_empleado_grados_academicos_actual a
                            INNER JOIN profesiones_materias b ON b.id_profesion = a.id_profesion
                            INNER JOIN detalle_materias c ON c.id_detalle_materia = b.id_detalle_materia 
                            INNER JOIN cat_materias d ON d.id_materia = c.id_materia
                            WHERE a.id_empleado = _id_empleado
                            AND c.id_detalle_materia = _id_materia
                            LIMIT 1;

                            /*IF match_grado_materia > 0 THEN

                                IF match_grado_materia_validado = true THEN 
                                    _codigo_perfil:= 1;
                                ELSE
                                    _codigo_perfil:= 0;

                                END IF;

                            ELSE

                                _codigo_perfil:= 0;*/
                            IF _match_grado_materia > 0 THEN

                                _codigo_perfil = 1;
                                _texto_codigo = 'Cumple perfil';

                            ELSE

                                _codigo_perfil = 0;	
                                _texto_codigo = 'No cumple perfil';

                                /*
                                Valida si el profesor en base fue habilitado y se le da opcion a completar un grupo incompleto de base en la etapa de tf
                                */
                                SELECT INTO _codigo_perfil
                                CASE WHEN(planteles_valida_perfil_tf_complementa_grupo is true) THEN 1 ELSE 0 END
                                FROM planteles_valida_perfil_tf_complementa_grupo(_id_empleado, _id_estructura, _id_grupo);	

                                IF _codigo_perfil = 1 THEN
                                    _texto_codigo = 'Cumple perfil';
                                END IF;		

                            END IF;

                        END IF;

                    ELSE
                        -- Si es docente de base

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
                                    _codigo_perfil:= 1;
                                ELSE
                                    _codigo_perfil:= 0;
                                END IF;	
                                        
                            ELSE
                                _codigo_perfil:= 3;

                            END IF;

                        ELSE

                            _codigo_perfil:= 0;

                            /*
                            Valida si el profesor en base fue habilitado y se le da opcion a completar un grupo incompleto de base en la etapa de tf
                            */
                            SELECT INTO _codigo_perfil
                            CASE WHEN(planteles_valida_perfil_tf_complementa_grupo is true) THEN 1 ELSE 0 END
                            FROM planteles_valida_perfil_tf_complementa_grupo(_id_empleado, _id_estructura, _id_grupo);			

                        END IF;	

                    END IF;	

                END IF;








            ELSE
                _codigo_perfil = -3;
                _texto_codigo = 'No tiene validados los documentos';

            END IF; -- END para ver si tiene validado los documentos

        ELSE    
            _codigo_perfil = -2;
            _texto_codigo = 'No tiene documentos en los grados academicos';

        END IF; -- END para validar si tiene documentos   


    ELSE

        _codigo_perfil:= -1;
        _texto_codigo = 'No tiene grados academicos';
        
    END IF; -- END para saber si tiene grados academicos    

    RETURN QUERY SELECT _codigo_perfil, _texto_codigo;

END; $$ 
LANGUAGE 'plpgsql';