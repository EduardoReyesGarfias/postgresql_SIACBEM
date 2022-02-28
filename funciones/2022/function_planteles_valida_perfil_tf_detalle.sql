CREATE OR REPLACE FUNCTION planteles_valida_perfil_tf_detalle(_id_empleado int, _id_estructura int, _id_materia int, _id_componente int)
RETURNS integer
AS $$
DECLARE

    _cumplePerfil smallint;
    _tieneGradosAcademicos boolean;
    _tieneDocumentos smallint;
    _tieneDocumentosValidados smallint;

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

    _cumplePerfil = 0;    

    -- query para ver si tiene grados academicos
    SELECT INTO _tieneGradosAcademicos
    CASE WHEN (count(profesion) > 0 ) THEN true ELSE false END
    FROM view_empleado_grados_academicos_actual
    WHERE id_empleado = _id_empleado;

    -- Ver si tiene grados academicos
    IF _tieneGradosAcademicos THEN

        _tieneDocumentos = 1;

        -- Recorre los grados academicos
        FOR reg IN cur LOOP

            IF reg.grado_academico = '09 Licenciatura con título' THEN

                IF LENGTH(reg.ruta_archivo_array::text) < 100 THEN
                    _tieneDocumentos = 0;   
                END IF;    

            ELSE
                
                IF LENGTH(reg.ruta_archivo_array::text) < 10 THEN
                    _tieneDocumentos = 0;
                END IF;    

            END IF;    


        END LOOP; -- END recorre los grados academicos
        
        IF _tieneDocumentos = 1 THEN
            
            _tieneDocumentosValidados = 1;
            _cumplePerfil = 1;
            -- ver si tiene documentos en los grados académicos
            SELECT INTO _tieneDocumentosValidados
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


            IF _tieneDocumentosValidados = 1 OR _tieneDocumentosValidados IS NULL THEN
                _cumplePerfil = 1;

                /*
                Empiezo a validar la relacion con la materia
                */

                -- Se evalua cuando es materia de paraescolares
                IF _id_componente = 4 THEN

                    SELECT INTO match_grado_materia,
                        a.id_empleado_grado_academico
                    FROM view_empleado_grados_academicos_actual a
                    INNER JOIN profesiones_materias_paraescolares b ON b.id_profesion = a.id_profesion
                    INNER JOIN cat_materias_paraescolares c ON c.id_paraescolar = b.id_paraescolar
                    WHERE 
                        a.id_empleado = _id_empleado
                        AND c.id_paraescolar = _id_materia
                        AND a.nivel_grado_academico >= 23
                    LIMIT 1;

                    IF match_grado_materia > 0 THEN

                        _cumplePerfil:= 1;

                    ELSE
                    END IF; -- END valida relacion con paraescolares	

                END IF; -- END si es paraescolares

            ELSE
                _cumplePerfil = -3;

            END IF; -- END para ver si tiene validado los documentos

        ELSE    
            _cumplePerfil = -2;

        END IF; -- END para validar si tiene documentos   


    ELSE

        _cumplePerfil:= -1;
        
    END IF; -- END para saber si tiene grados academicos    

    RETURN _cumplePerfil;

END; $$ 
LANGUAGE 'plpgsql';