CREATE OR REPLACE FUNCTION planteles_equivalencia_clave_asignar(_id_empleado int, _id_estructura_ocupacional int, _hsm int, _id_cat_categoria int, _categoria_padre character varying, _alta int)
RETURNS TABLE(
    id_cat_categoria_padre integer,
    categoria_padre character varying,
    hrs_categoria smallint,
    hrs_usadas smallint,
    hrs_libres smallint,
    alta int
)

AS $$
DECLARE

    reg RECORD;
	cur CURSOR FOR (

       /* SELECT 
            catego.id_cat_categoria_padre, 
            vpaeb.categoria_padre,
            vpaeb.hrs_categoria, 
            CAST(sum(vpaeb.horas_usadas) as smallint) as hrs_usadas,
            CAST((vpaeb.hrs_categoria - sum(vpaeb.horas_usadas)) AS smallint) as hrs_libres
        FROM view_planteles_asignacion_eb vpaeb
        INNER JOIN cat_categorias_padre catego ON catego.categoria_padre = vpaeb.categoria_padre
        WHERE 
            vpaeb.id_empleado = _id_empleado
        AND vpaeb.id_estructura_ocupacional = _id_estructura_ocupacional
        GROUP BY 
            catego.id_cat_categoria_padre,
            vpaeb.categoria_padre, 
            vpaeb.hrs_categoria
    */

        SELECT 
            catego.id_cat_categoria_padre, 
            vpaeb.categoria_padre,
            vpaeb.hrs_categoria, 
            CAST(sum(vpaeb.horas_usadas) as smallint) as hrs_usadas,
            (
                SELECT SUM(horas_grupo)
                FROM view_horas_asignadas_empleado_tf_1
                WHERE
                    id_empleado = _id_empleado
                    AND id_tipo_movimiento_personal = 2
                    AND id_estructura_ocupacional = _id_estructura_ocupacional
                
            ) AS hrs_usadas_tf,
            CAST(
                (vpaeb.hrs_categoria - (sum(vpaeb.horas_usadas) + (
                    SELECT SUM(horas_grupo)
                    FROM view_horas_asignadas_empleado_tf_1
                    WHERE
                        id_empleado = _id_empleado
                        AND id_tipo_movimiento_personal = 2
                        AND id_estructura_ocupacional = _id_estructura_ocupacional
                ))  ) 
                AS smallint
            ) as hrs_libres
        FROM view_planteles_asignacion_eb vpaeb
        INNER JOIN cat_categorias_padre catego ON catego.categoria_padre = vpaeb.categoria_padre
        WHERE 
            vpaeb.id_empleado = _id_empleado
        AND vpaeb.id_estructura_ocupacional = _id_estructura_ocupacional
        GROUP BY 
            catego.id_cat_categoria_padre,
            vpaeb.categoria_padre, 
            vpaeb.hrs_categoria    

    );


BEGIN

    CREATE TEMP TABLE temp_equivalencia_clave_asignar(
        id_cat_categoria_padre integer,
        categoria_padre character varying,
        hrs_categoria smallint,
        hrs_usadas smallint,
        hrs_libres smallint,
        alta int
    );

    FOR reg IN cur LOOP

        IF(_hsm > 0) THEN

            IF(_hsm >= reg.hrs_libres) THEN

                INSERT INTO temp_equivalencia_clave_asignar(id_cat_categoria_padre, categoria_padre, hrs_categoria, hrs_usadas, hrs_libres, alta) VALUES
                (reg.id_cat_categoria_padre, reg.categoria_padre, reg.hrs_categoria, reg.hrs_usadas, reg.hrs_libres, 2);

                _hsm:= _hsm - reg.hrs_libres;

            ELSIF( reg.hrs_libres > _hsm) THEN

                INSERT INTO temp_equivalencia_clave_asignar(id_cat_categoria_padre, categoria_padre, hrs_categoria, hrs_usadas, hrs_libres, alta) VALUES
                (reg.id_cat_categoria_padre, reg.categoria_padre, reg.hrs_categoria, reg.hrs_usadas, _hsm, 2);

                _hsm:= _hsm - reg.hrs_libres;

            END IF;

        END IF;

    END LOOP;

    IF( _hsm > 0) THEN

         INSERT INTO temp_equivalencia_clave_asignar(id_cat_categoria_padre, categoria_padre, hrs_categoria, hrs_usadas, hrs_libres, alta) VALUES
        (_id_cat_categoria, _categoria_padre, 0, 0, _hsm, _alta);

    END IF;

    
    RETURN query SELECT * FROM temp_equivalencia_clave_asignar teca WHERE teca.hrs_libres > 0;

    /* Al retornar se destruye la tambla temporal */
	DROP TABLE temp_equivalencia_clave_asignar;	

END; $$ 
LANGUAGE 'plpgsql';