CREATE OR REPLACE FUNCTION planteles_hrs_descarga_en_licencia(_id_empleado int, _id_estructura int, _id_plantilla int)
RETURNS integer
AS $$

DECLARE

    hrs_descarga_en_lic int;


BEGIN

    hrs_descarga_en_lic = 0;

    CREATE TEMP TABLE temp_planteles_hrs_descarga_lic(
        hrs_licencia int,
        hrs_basico int,
        hrs_capacitacion int,
        hrs_optativas int,
        hrs_paraescolares int
    );

    INSERT INTO temp_planteles_hrs_descarga_lic(hrs_licencia, hrs_basico, hrs_capacitacion, hrs_optativas, hrs_paraescolares)
    VALUES(0, 0, 0, 0, 0);

    UPDATE temp_planteles_hrs_descarga_lic
    SET hrs_licencia = (
    SELECT 
        COALESCE(tlpd.hrs_licencia, 0)
    FROM tramites_licencias tl
    INNER JOIN tramites_licencias_plazas_docente tlpd ON tlpd.id_tramite_licencia = tl.id_tramite_licencia
    LEFT JOIN tramites_licencias_asignaciones tla ON tla.id_tramite_licencia = tl.id_tramite_licencia
    WHERE
        tl.id_empleado = _id_empleado
        AND tl.id_estructura_ocupacional = _id_estructura
        AND tl.id_cat_tramite_status = 3
        AND tlpd.id_plantilla_base_docente_rh = _id_plantilla
        AND (now()::date BETWEEN tl.fecha_desde AND tl.fecha_hasta )
    GROUP BY
        tlpd.hrs_licencia,
        tlpd.id_plantilla_base_docente_rh
    );


    -- basico
    UPDATE temp_planteles_hrs_descarga_lic
    SET hrs_basico = (
    SELECT 
         COALESCE(SUM(ppa.horas_grupo_base),0)
    FROM tramites_licencias tl
    INNER JOIN tramites_licencias_plazas_docente tlpd ON tlpd.id_tramite_licencia = tl.id_tramite_licencia
    INNER JOIN tramites_licencias_asignaciones tla ON tla.id_tramite_licencia = tl.id_tramite_licencia
    INNER JOIN profesores_profesor_asignado_base ppa ON ppa.id_profesores_profesor_asignado_base = tla.id_asignacion
    WHERE 
        tl.id_empleado = _id_empleado
        AND tl.id_estructura_ocupacional = _id_estructura
        AND tl.id_cat_tramite_status = 3
        AND tlpd.id_plantilla_base_docente_rh = _id_plantilla
        AND ppa.id_plantilla_base_docente_rh = _id_plantilla
        AND tla.id_componente = 1
        AND (now()::date BETWEEN tl.fecha_desde AND tl.fecha_hasta )
    );   

    -- capacitacion
    UPDATE temp_planteles_hrs_descarga_lic
    SET hrs_capacitacion = (
    SELECT 
         COALESCE(SUM(ppa.horas_grupo_capacitacion),0)
    FROM tramites_licencias tl
    INNER JOIN tramites_licencias_plazas_docente tlpd ON tlpd.id_tramite_licencia = tl.id_tramite_licencia
    INNER JOIN tramites_licencias_asignaciones tla ON tla.id_tramite_licencia = tl.id_tramite_licencia
    INNER JOIN profesores_profesor_asignado_capacitacion ppa ON ppa.id_profesores_profesor_asignado_capacitacion = tla.id_asignacion
    WHERE 
        tl.id_empleado = _id_empleado
        AND tl.id_estructura_ocupacional = _id_estructura
        AND tl.id_cat_tramite_status = 3
        AND tlpd.id_plantilla_base_docente_rh = _id_plantilla
        AND ppa.id_plantilla_base_docente_rh = _id_plantilla
        AND tla.id_componente = 3
        AND (now()::date BETWEEN tl.fecha_desde AND tl.fecha_hasta )
    );

    -- optativas
    UPDATE temp_planteles_hrs_descarga_lic
    SET hrs_optativas = (
    SELECT 
         COALESCE(SUM(ppa.horas_grupo_optativas),0)
    FROM tramites_licencias tl
    INNER JOIN tramites_licencias_plazas_docente tlpd ON tlpd.id_tramite_licencia = tl.id_tramite_licencia
    INNER JOIN tramites_licencias_asignaciones tla ON tla.id_tramite_licencia = tl.id_tramite_licencia
    INNER JOIN profesores_profesor_asignado_optativas ppa ON ppa.id_profesores_profesor_asignado_optativas = tla.id_asignacion
    WHERE 
        tl.id_empleado = _id_empleado
        AND tl.id_estructura_ocupacional = _id_estructura
        AND tl.id_cat_tramite_status = 3
        AND tlpd.id_plantilla_base_docente_rh = _id_plantilla
        AND ppa.id_plantilla_base_docente_rh = _id_plantilla
        AND tla.id_componente = 2
        AND (now()::date BETWEEN tl.fecha_desde AND tl.fecha_hasta )
    );  

    -- paraescolares
    UPDATE temp_planteles_hrs_descarga_lic
    SET hrs_paraescolares = (
    SELECT 
         COALESCE(SUM(ppa.horas_grupo_paraescolares), 0)
    FROM tramites_licencias tl
    INNER JOIN tramites_licencias_plazas_docente tlpd ON tlpd.id_tramite_licencia = tl.id_tramite_licencia
    INNER JOIN tramites_licencias_asignaciones tla ON tla.id_tramite_licencia = tl.id_tramite_licencia
    INNER JOIN profesores_profesor_asignado_paraescolares ppa ON ppa.id_profesores_profesor_asignado_paraescolares = tla.id_asignacion
    WHERE 
        tl.id_empleado = _id_empleado
        AND tl.id_estructura_ocupacional = _id_estructura
        AND tl.id_cat_tramite_status = 3
        AND tlpd.id_plantilla_base_docente_rh = _id_plantilla
        AND ppa.id_plantilla_base_docente_rh = _id_plantilla
        AND tla.id_componente = 4
        AND (now()::date BETWEEN tl.fecha_desde AND tl.fecha_hasta )
    );          

     SELECT INTO  hrs_descarga_en_lic
        COALESCE(hrs_licencia, 0) - (COALESCE(hrs_basico, 0) + COALESCE(hrs_capacitacion, 0) + COALESCE(hrs_optativas, 0) + COALESCE(hrs_paraescolares, 0))
        FROM temp_planteles_hrs_descarga_lic; 

    /* Al retornar se destruye la tambla temporal */
	DROP TABLE temp_planteles_hrs_descarga_lic;	               

    RETURN hrs_descarga_en_lic; 
        
   
      

END; $$ 
LANGUAGE 'plpgsql';        