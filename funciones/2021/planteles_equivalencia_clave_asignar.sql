CREATE OR REPLACE FUNCTION planteles_equivalencia_clave_asignar(_id_empleado int, _id_estructura_ocupacional int, _hsm int, _id_cat_categoria int, _categoria_padre character varying, _alta int)
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
    /*
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

        */  
        
        

       

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
            AND licencia = 0
            AND baja = 0
            AND x.id_plantilla_base_docente_rh = a.id_plantilla_base_docente_rh
            GROUP BY
                b.id_cat_categoria_padre, 
                b.categoria_padre
        ),0) AS hrs_usadas,
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
    GROUP BY
        a.id_plantilla_base_docente_rh,
        b.id_cat_categoria_padre, 
        b.categoria_padre,
        a.hrs_categoria
     

    );


BEGIN

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

        IF(_hsm > 0) THEN

            IF(_hsm >= (reg.hrs_categoria - (reg.hrs_usadas + reg.hrs_usadas_tf))) THEN

                INSERT INTO temp_equivalencia_clave_asignar(id_cat_categoria_padre, categoria_padre, hrs_categoria, hrs_usadas, hrs_libres, alta, id_plantilla_base_docente_rh) VALUES
                (reg.id_cat_categoria_padre, reg.categoria_padre, reg.hrs_categoria, reg.hrs_usadas, (reg.hrs_categoria - (reg.hrs_usadas + reg.hrs_usadas_tf)), 2, reg.id_plantilla_base_docente_rh);

                _hsm:= _hsm - (reg.hrs_categoria - (reg.hrs_usadas + reg.hrs_usadas_tf));

            ELSIF( (reg.hrs_categoria - (reg.hrs_usadas + reg.hrs_usadas_tf)) > _hsm) THEN

                INSERT INTO temp_equivalencia_clave_asignar(id_cat_categoria_padre, categoria_padre, hrs_categoria, hrs_usadas, hrs_libres, alta, id_plantilla_base_docente_rh) VALUES
                (reg.id_cat_categoria_padre, reg.categoria_padre, reg.hrs_categoria, reg.hrs_usadas, _hsm, 2, reg.id_plantilla_base_docente_rh);

                _hsm:= _hsm - (reg.hrs_categoria - (reg.hrs_usadas + reg.hrs_usadas_tf));

            END IF;

        END IF;

    END LOOP;

    IF( _hsm > 0) THEN

         INSERT INTO temp_equivalencia_clave_asignar(id_cat_categoria_padre, categoria_padre, hrs_categoria, hrs_usadas, hrs_libres, alta, id_plantilla_base_docente_rh) VALUES
        (_id_cat_categoria, _categoria_padre, 0, 0, _hsm, _alta, null);

    END IF;
    
    
    RETURN query SELECT * FROM temp_equivalencia_clave_asignar teca WHERE teca.hrs_libres > 0;

    /* Al retornar se destruye la tambla temporal */
	DROP TABLE temp_equivalencia_clave_asignar;	


END; $$ 
LANGUAGE 'plpgsql';