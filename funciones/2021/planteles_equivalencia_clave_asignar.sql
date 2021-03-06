CREATE OR REPLACE FUNCTION planteles_equivalencia_clave_asignar(_id_empleado int, _id_estructura_ocupacional int, _hsm int, _id_cat_categoria int, _categoria_padre character varying, _alta int, _id_componente int, _id_materia int, _id_subprograma int)
RETURNS TABLE(
    id_cat_categoria_padre integer,
    categoria_padre character varying,
    hrs_categoria smallint,
    hrs_usadas smallint,
    hrs_libres smallint,
    alta int,
    id_plantilla_base_docente_rh int
)
AS $$

DECLARE

    _id_categoria_equivalente int;
    _categoria_equivalente text;
    _es_orientacion int;

    reg RECORD;
	cur CURSOR FOR (

        SELECT 
            a.id_plantilla_base_docente_rh,
            b.id_cat_categoria_padre, 
            b.categoria_padre,
            a.hrs_categoria,
            COALESCE((
                SELECT 
                    sum(horas_grupo)
                FROM view_horas_asignadas_empleado_eb x
                INNER JOIN cat_categorias_padre b ON x.categoria_padre = b.categoria_padre 
                WHERE id_empleado = _id_empleado
                AND id_estructura_ocupacional = _id_estructura_ocupacional
                --AND licencia = 0
                AND baja = 0
                AND x.id_plantilla_base_docente_rh = a.id_plantilla_base_docente_rh
                GROUP BY
                    b.id_cat_categoria_padre, 
                    b.categoria_padre
            ),0) AS hrs_usadas,
            COALESCE((
               SELECT *
               FROM planteles_hrs_descarga_en_licencia(_id_empleado, _id_estructura_ocupacional, a.id_plantilla_base_docente_rh)
            ),0) AS hrs_desc_en_lic,
            COALESCE((
                SELECT 
                    sum(horas_grupo)
                FROM view_horas_asignadas_empleado_tf_2 y
                INNER JOIN cat_categorias_padre b ON y.categoria_padre = b.categoria_padre 
                WHERE id_empleado = _id_empleado
                AND id_estructura_ocupacional = _id_estructura_ocupacional
                AND licencia_tf = 0
                AND baja_tf = 0
                AND codigo = 14
                AND y.id_plantilla_base_docente_rh = a.id_plantilla_base_docente_rh
                GROUP BY
                    b.id_cat_categoria_padre, 
                    b.categoria_padre
            ),0) AS hrs_usadas_tf
        FROM view_planteles_asignacion_eb a
        INNER JOIN cat_categorias_padre b ON a.categoria_padre = b.categoria_padre 
        WHERE a.id_estructura_ocupacional = _id_estructura_ocupacional
        AND a.id_empleado = _id_empleado
        --AND a.id_subprograma = _id_subprograma
        GROUP BY
            a.id_plantilla_base_docente_rh,
            b.id_cat_categoria_padre, 
            b.categoria_padre,
            a.hrs_categoria
     

    );


BEGIN

    _es_orientacion:= 0;
    _id_categoria_equivalente:= 78;
    _categoria_equivalente:= 'TCBI';

    -- Saber si se cambia la categoria dependiendo de la descarga y de la materia
    SELECT INTO _es_orientacion
        id_detalle_materia
    FROM detalle_materias a
    INNER JOIN cat_materias b ON a.id_materia = b.id_materia
    WHERE
        a.id_detalle_materia = _id_materia
        AND palabra_acentos(b.materia) ilike palabra_acentos('%ORIENTACION%');

    IF _id_componente in (1,2,3) THEN
        
        IF _es_orientacion = 0 OR _es_orientacion is null THEN
            _id_categoria_equivalente:= 13;
            _categoria_equivalente:= 'CBI';
        END IF;

    END IF;    


    CREATE TEMP TABLE temp_equivalencia_clave_asignar(
        id_cat_categoria_padre integer,
        categoria_padre character varying,
        hrs_categoria smallint,
        hrs_usadas smallint,
        hrs_libres smallint,
        alta int,
        id_plantilla_base_docente_rh int
    );

    FOR reg IN cur LOOP

        -- Saber si hago cambio de clave o no
        IF (reg.id_cat_categoria_padre NOT IN (78, 79)) THEN

            _id_categoria_equivalente:= reg.id_cat_categoria_padre;
            _categoria_equivalente:= reg.categoria_padre;

        END IF;


        IF(_hsm > 0) THEN

            IF(_hsm >= (reg.hrs_categoria - (reg.hrs_usadas + reg.hrs_desc_en_lic + reg.hrs_usadas_tf))) THEN

                INSERT INTO temp_equivalencia_clave_asignar(id_cat_categoria_padre, categoria_padre, hrs_categoria, hrs_usadas, hrs_libres, alta, id_plantilla_base_docente_rh) VALUES
                (_id_categoria_equivalente, _categoria_equivalente, reg.hrs_categoria, reg.hrs_usadas, (reg.hrs_categoria - (reg.hrs_usadas + reg.hrs_desc_en_lic + reg.hrs_usadas_tf)), 2, reg.id_plantilla_base_docente_rh);

                _hsm:= _hsm - (reg.hrs_categoria - (reg.hrs_usadas + reg.hrs_desc_en_lic + reg.hrs_usadas_tf));

            ELSIF( (reg.hrs_categoria - (reg.hrs_usadas + reg.hrs_desc_en_lic + reg.hrs_usadas_tf)) > _hsm) THEN

                INSERT INTO temp_equivalencia_clave_asignar(id_cat_categoria_padre, categoria_padre, hrs_categoria, hrs_usadas, hrs_libres, alta, id_plantilla_base_docente_rh) VALUES
                (_id_categoria_equivalente, _categoria_equivalente, reg.hrs_categoria, reg.hrs_usadas, _hsm, 2, reg.id_plantilla_base_docente_rh);

                _hsm:= _hsm - (reg.hrs_categoria - (reg.hrs_usadas + reg.hrs_desc_en_lic + reg.hrs_usadas_tf));

            END IF;

        END IF;

    END LOOP;

    -- Si no tiene horas de descarga entra aqui
    IF( _hsm > 0) THEN

         INSERT INTO temp_equivalencia_clave_asignar(id_cat_categoria_padre, categoria_padre, hrs_categoria, hrs_usadas, hrs_libres, alta, id_plantilla_base_docente_rh) VALUES
        (_id_cat_categoria, _categoria_padre, 0, 0, _hsm, _alta, null);

    END IF;
    
    
    RETURN query SELECT * FROM temp_equivalencia_clave_asignar teca WHERE teca.hrs_libres > 0;

    /* Al retornar se destruye la tambla temporal */
	DROP TABLE temp_equivalencia_clave_asignar;	


END; $$ 
LANGUAGE 'plpgsql';