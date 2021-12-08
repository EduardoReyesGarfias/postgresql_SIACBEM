DECLARE
BEGIN

    -- Creo tabla temporal para acomodo de las asignaciones
    CREATE TEMP TABLE temp_planteles_acuerdo(
        paterno character varying,
        materno character varying,
        nombre character varying,
        nombre_completo text,
        rfc character varying,
        grado_academico text,
        profesion text,
        valida_archivo text,
        materia text,
        horas_grupo bigint,
        categoria_padre character varying,
        codigo smallint,
        descripcion character varying(100),
        qna_desde integer,
        qna_hasta integer,
        nombre_grupo text,
        sustituye text,
        observacion_comision_mixta character varying,
        observacion_plantel character varying,
        nombre_subprograma character varying,
        periodo character varying(6),
        fecha_apertura timestamp with time zone,
        fecha_cierre timestamp with time zone,
        prefijo_director text,
        nombre_director text,
        puesto_director text,
        prefijo_coordinador text,
        nombre_coordinador text,
        puesto_coordinador text
    );

    INSERT INTO temp_planteles_acuerdo
    SELECT
        emp_asign.paterno, emp_asign.materno, emp_asign.nombre, 
        emp_asign.paterno||' '||emp_asign.materno||' '||emp_asign.nombre AS nombre_completo,
        emp_asign.rfc,
        (
            SELECT STRING_AGG(UPPER(vega.grado_academico), ',' ORDER BY vega.nivel_grado_academico DESC )
            FROM view_empleado_grados_academicos_actual vega
            WHERE vega.id_empleado = emp_asign.id_empleado
        )as grado_academico,
        (
            SELECT STRING_AGG(UPPER(vega.profesion), ',' ORDER BY vega.nivel_grado_academico DESC )
            FROM view_empleado_grados_academicos_actual vega
            WHERE vega.id_empleado = emp_asign.id_empleado
        )as profesion,
        (
            SELECT STRING_AGG(UPPER(vega.valida_archivo_reportes), ',' ORDER BY vega.nivel_grado_academico DESC )
            FROM view_empleado_grados_academicos_actual vega
            WHERE vega.id_empleado = emp_asign.id_empleado
        )as valida_archivo,
        STRING_AGG((
            mat.materia||' ('||
            atf.horas_grupo||' hrs - '||
            gpos.nombre_grupo||' )'
        ),'++') as materia, 
        SUM(atf.horas_grupo) AS horas_grupo,
        catego.categoria_padre,
        mov.codigo, 
        mov.descripcion, 
        atf.qna_desde,
        atf.qna_hasta,
        STRING_AGG(gpos.nombre_grupo, ',' ORDER BY gpos.nombre_grupo ASC) as nombre_grupo,
        (
            COALESCE((
                SELECT prefijo
                FROM view_empleado_grados_academicos_actual
                WHERE id_empleado = emp_sust.id_empleado
                ORDER BY nivel_grado_academico DESC
                LIMIT 1
            ),'')||' '||
            COALESCE(emp_sust.paterno,'')||' '||COALESCE(emp_sust.materno,'')||' '||COALESCE(emp_sust.nombre,'')
        )||''||
        (
            COALESCE((
                SELECT prefijo
                FROM view_empleado_grados_academicos_actual
                WHERE id_empleado = emp_sust_tf.id_empleado
                ORDER BY nivel_grado_academico DESC
                LIMIT 1
            ),'')||' '||
            COALESCE(emp_sust_tf.paterno,'')||' '||COALESCE(emp_sust_tf.materno,'')||' '||COALESCE(emp_sust_tf.nombre,'')
        ) AS sustituye,
        atf.observacion_comision_mixta,
        atf.observacion_plantel,
        subp.nombre_subprograma,
        estructura.periodo,
        estructura.fecha_apertura,
        estructura.fecha_cierre,
        firmantes.prefijo_director,
        firmantes.nombre_director,
        firmantes.puesto_director,
        firmantes.prefijo_coordinador,
        firmantes.nombre_coordinador,
        firmantes.puesto_coordinador
    FROM asignacion_tiempo_fijo_basico atf
    INNER JOIN empleados emp_asign ON emp_asign.id_empleado = atf.id_empleado
    INNER JOIN cat_categorias_padre catego ON catego.id_cat_categoria_padre = atf.id_cat_categoria_padre
    INNER JOIN detalle_materias detalle_mat ON detalle_mat.id_detalle_materia = atf.id_detalle_materia
    INNER JOIN cat_materias mat ON mat.id_materia = detalle_mat.id_materia
    INNER JOIN cat_tipo_movimiento_personal mov ON mov.id_tipo_movimiento_personal = atf.id_tipo_movimiento_personal
    INNER JOIN subprogramas subp ON subp.id_subprograma = atf.id_subprograma
    INNER JOIN claves_sep sep ON sep.id_sep = subp.id_sep
    INNER JOIN grupos_estructura_base gpos ON atf.id_grupo_estructura_base = gpos.id_grupo_estructura_base
    INNER JOIN cat_estructuras_ocupacionales estructura ON estructura.id_estructura_ocupacional = atf.id_estructura_ocupacional
    LEFT JOIN planteles_firmantes(_id_subp,_id_estruc) firmantes ON _id_subp = subp.id_subprograma
    LEFT JOIN tramites_licencias_asignaciones licencia_asign1 ON licencia_asign1.id_tramite_licencia_asignacion = atf.id_tramites_licencias_asignaciones AND licencia_asign1.id_componente = 1
    LEFT JOIN tramites_licencias licencia1 ON licencia1.id_tramite_licencia = licencia_asign1.id_tramite_licencia
    LEFT JOIN empleados emp_sust ON emp_sust.id_empleado = licencia1.id_empleado
    LEFT JOIN tramites_licencias_asignaciones_tf licencia_asign2 ON licencia_asign2.id_tramite_licencia_asignacion_tf = atf.id_tramites_licencias_asignaciones_tf AND licencia_asign2.id_componente = 1
    LEFT JOIN tramites_licencias licencia2 ON licencia2.id_tramite_licencia = licencia_asign2.id_tramite_licencia
    LEFT JOIN empleados emp_sust_tf ON emp_sust_tf.id_empleado = licencia2.id_empleado
    WHERE atf.id_asignacion_tiempo_fijo_basico = ANY(_ids_basi)
    GROUP BY 
        emp_asign.rfc,
        emp_asign.paterno,
        emp_asign.materno,
        emp_asign.nombre,
        emp_asign.id_empleado,
        catego.categoria_padre, 
        mat.materia, 
        atf.qna_desde,
        atf.qna_hasta,
        mov.codigo,
        mov.descripcion,
        emp_sust.paterno,
        emp_sust.materno,
        emp_sust.nombre,
        emp_sust.id_empleado,
        emp_sust_tf.paterno,
        emp_sust_tf.materno,
        emp_sust_tf.nombre,
        emp_sust_tf.id_empleado,
        atf.observacion_comision_mixta,
        atf.observacion_plantel,
        detalle_mat.semestre,
        subp.nombre_subprograma,
        estructura.periodo,
        estructura.fecha_apertura,
        estructura.fecha_cierre,
        firmantes.prefijo_director,
        firmantes.nombre_director,
        firmantes.puesto_director,
        firmantes.prefijo_coordinador,
        firmantes.nombre_coordinador,
        firmantes.puesto_coordinador
    ORDER BY
        emp_asign.rfc,
        detalle_mat.semestre,
        mat.materia,
        nombre_grupo;

    INSERT INTO temp_planteles_acuerdo
    SELECT 
        emp_asign.paterno, emp_asign.materno, emp_asign.nombre, 
        emp_asign.paterno||' '||emp_asign.materno||' '||emp_asign.nombre AS nombre_completo,
        emp_asign.rfc,
        (
            SELECT STRING_AGG(UPPER(vega.grado_academico), ',' ORDER BY vega.nivel_grado_academico DESC )
            FROM view_empleado_grados_academicos_actual vega
            WHERE vega.id_empleado = emp_asign.id_empleado
        )as grado_academico,
        (
            SELECT STRING_AGG(UPPER(vega.profesion), ',' ORDER BY vega.nivel_grado_academico DESC )
            FROM view_empleado_grados_academicos_actual vega
            WHERE vega.id_empleado = emp_asign.id_empleado
        )as profesion,
        (
            SELECT STRING_AGG(UPPER(vega.valida_archivo_reportes), ',' ORDER BY vega.nivel_grado_academico DESC )
            FROM view_empleado_grados_academicos_actual vega
            WHERE vega.id_empleado = emp_asign.id_empleado
        )as valida_archivo,
        STRING_AGG((
            mat.materia||' ('||
            atf.horas_grupo||' hrs - '||
            gpos.nombre_grupo_capacitacion||' )'
        ),'++') as materia, 
        SUM(atf.horas_grupo) AS horas_grupo,
        catego.categoria_padre,
        mov.codigo, 
        mov.descripcion, 
        atf.qna_desde,
        atf.qna_hasta,
        STRING_AGG(gpos.nombre_grupo_capacitacion, ',' ORDER BY gpos.nombre_grupo_capacitacion ASC) as nombre_grupo,
        (
            COALESCE((
                SELECT prefijo
                FROM view_empleado_grados_academicos_actual
                WHERE id_empleado = emp_sust.id_empleado
                ORDER BY nivel_grado_academico DESC
                LIMIT 1
            ),'')||' '||
            COALESCE(emp_sust.paterno,'')||' '||COALESCE(emp_sust.materno,'')||' '||COALESCE(emp_sust.nombre,'')
        )||''||
        (
            COALESCE((
                SELECT prefijo
                FROM view_empleado_grados_academicos_actual
                WHERE id_empleado = emp_sust_tf.id_empleado
                ORDER BY nivel_grado_academico DESC
                LIMIT 1
            ),'')||' '||
            COALESCE(emp_sust_tf.paterno,'')||' '||COALESCE(emp_sust_tf.materno,'')||' '||COALESCE(emp_sust_tf.nombre,'')
        ) AS sustituye,
        atf.observacion_comision_mixta,
        atf.observacion_plantel,
        subp.nombre_subprograma,
        estructura.periodo,
        estructura.fecha_apertura,
        estructura.fecha_cierre,
        firmantes.prefijo_director,
        firmantes.nombre_director,
        firmantes.puesto_director,
        firmantes.prefijo_coordinador,
        firmantes.nombre_coordinador,
        firmantes.puesto_coordinador
    FROM asignacion_tiempo_fijo_capacitacion atf
    INNER JOIN empleados emp_asign ON emp_asign.id_empleado = atf.id_empleado
    INNER JOIN cat_categorias_padre catego ON catego.id_cat_categoria_padre = atf.id_cat_categoria_padre
    INNER JOIN detalle_materias detalle_mat ON detalle_mat.id_detalle_materia = atf.id_detalle_materia
    INNER JOIN cat_materias mat ON mat.id_materia = detalle_mat.id_materia
    INNER JOIN cat_tipo_movimiento_personal mov ON mov.id_tipo_movimiento_personal = atf.id_tipo_movimiento_personal
    INNER JOIN subprogramas subp ON subp.id_subprograma = atf.id_subprograma
    INNER JOIN claves_sep sep ON sep.id_sep = subp.id_sep
    INNER JOIN grupos_capacitacion gpos ON atf.id_grupo_capacitacion = gpos.id_grupo_capacitacion
    INNER JOIN cat_estructuras_ocupacionales estructura ON estructura.id_estructura_ocupacional = atf.id_estructura_ocupacional
    LEFT JOIN planteles_firmantes(_id_subp,_id_estruc) firmantes ON _id_subp = subp.id_subprograma
    LEFT JOIN tramites_licencias_asignaciones licencia_asign1 ON licencia_asign1.id_tramite_licencia_asignacion = atf.id_tramites_licencias_asignaciones AND licencia_asign1.id_componente = 3
    LEFT JOIN tramites_licencias licencia1 ON licencia1.id_tramite_licencia = licencia_asign1.id_tramite_licencia
    LEFT JOIN empleados emp_sust ON emp_sust.id_empleado = licencia1.id_empleado
    LEFT JOIN tramites_licencias_asignaciones_tf licencia_asign2 ON licencia_asign2.id_tramite_licencia_asignacion_tf = atf.id_tramites_licencias_asignaciones_tf AND licencia_asign2.id_componente = 3
    LEFT JOIN tramites_licencias licencia2 ON licencia2.id_tramite_licencia = licencia_asign2.id_tramite_licencia
    LEFT JOIN empleados emp_sust_tf ON emp_sust_tf.id_empleado = licencia2.id_empleado
    WHERE atf.id_asignacion_tiempo_fijo_capacitacion = ANY(_ids_capa)
    GROUP BY 
        emp_asign.rfc,
        emp_asign.paterno,
        emp_asign.materno,
        emp_asign.nombre,
        emp_asign.id_empleado,
        catego.categoria_padre, 
        mat.materia, 
        atf.qna_desde,
        atf.qna_hasta,
        mov.codigo,
        mov.descripcion,
        emp_sust.paterno,
        emp_sust.materno,
        emp_sust.nombre,
        emp_sust.id_empleado,
        emp_sust_tf.paterno,
        emp_sust_tf.materno,
        emp_sust_tf.nombre,
        emp_sust_tf.id_empleado,
        atf.observacion_comision_mixta,
        atf.observacion_plantel,
        detalle_mat.semestre,
        subp.nombre_subprograma,
        estructura.periodo,
        estructura.fecha_apertura,
        estructura.fecha_cierre,
        firmantes.prefijo_director,
        firmantes.nombre_director,
        firmantes.puesto_director,
        firmantes.prefijo_coordinador,
        firmantes.nombre_coordinador,
        firmantes.puesto_coordinador
    ORDER BY
        emp_asign.rfc,
        detalle_mat.semestre,
        mat.materia,
        nombre_grupo;

    INSERT INTO temp_planteles_acuerdo
    SELECT 
        emp_asign.paterno, emp_asign.materno, emp_asign.nombre, 
        emp_asign.paterno||' '||emp_asign.materno||' '||emp_asign.nombre AS nombre_completo,
        emp_asign.rfc,
        (
            SELECT STRING_AGG(UPPER(vega.grado_academico), ',' ORDER BY vega.nivel_grado_academico DESC )
            FROM view_empleado_grados_academicos_actual vega
            WHERE vega.id_empleado = emp_asign.id_empleado
        )as grado_academico,
        (
            SELECT STRING_AGG(UPPER(vega.profesion), ',' ORDER BY vega.nivel_grado_academico DESC )
            FROM view_empleado_grados_academicos_actual vega
            WHERE vega.id_empleado = emp_asign.id_empleado
        )as profesion,
        (
            SELECT STRING_AGG(UPPER(vega.valida_archivo_reportes), ',' ORDER BY vega.nivel_grado_academico DESC )
            FROM view_empleado_grados_academicos_actual vega
            WHERE vega.id_empleado = emp_asign.id_empleado
        )as valida_archivo,
        STRING_AGG((
            mat.materia||' ('||
            atf.horas_grupo||' hrs - '||
            gpos.nombre_grupo_optativas||' )'
        ),'++') as materia, 
        SUM(atf.horas_grupo) AS horas_grupo,
        catego.categoria_padre,
        mov.codigo, 
        mov.descripcion, 
        atf.qna_desde,
        atf.qna_hasta,
        STRING_AGG(gpos.nombre_grupo_optativas, ',' ORDER BY gpos.nombre_grupo_optativas ASC) as nombre_grupo,
        (
            COALESCE((
                SELECT prefijo
                FROM view_empleado_grados_academicos_actual
                WHERE id_empleado = emp_sust.id_empleado
                ORDER BY nivel_grado_academico DESC
                LIMIT 1
            ),'')||' '||
            COALESCE(emp_sust.paterno,'')||' '||COALESCE(emp_sust.materno,'')||' '||COALESCE(emp_sust.nombre,'')
        )||''||
        (
            COALESCE((
                SELECT prefijo
                FROM view_empleado_grados_academicos_actual
                WHERE id_empleado = emp_sust_tf.id_empleado
                ORDER BY nivel_grado_academico DESC
                LIMIT 1
            ),'')||' '||
            COALESCE(emp_sust_tf.paterno,'')||' '||COALESCE(emp_sust_tf.materno,'')||' '||COALESCE(emp_sust_tf.nombre,'')
        ) AS sustituye,
        atf.observacion_comision_mixta,
        atf.observacion_plantel,
        subp.nombre_subprograma,
        estructura.periodo,
        estructura.fecha_apertura,
        estructura.fecha_cierre,
        firmantes.prefijo_director,
        firmantes.nombre_director,
        firmantes.puesto_director,
        firmantes.prefijo_coordinador,
        firmantes.nombre_coordinador,
        firmantes.puesto_coordinador
    FROM asignacion_tiempo_fijo_optativas atf
    INNER JOIN empleados emp_asign ON emp_asign.id_empleado = atf.id_empleado
    INNER JOIN cat_categorias_padre catego ON catego.id_cat_categoria_padre = atf.id_cat_categoria_padre
    INNER JOIN detalle_materias detalle_mat ON detalle_mat.id_detalle_materia = atf.id_detalle_materia
    INNER JOIN cat_materias mat ON mat.id_materia = detalle_mat.id_materia
    INNER JOIN cat_tipo_movimiento_personal mov ON mov.id_tipo_movimiento_personal = atf.id_tipo_movimiento_personal
    INNER JOIN subprogramas subp ON subp.id_subprograma = atf.id_subprograma
    INNER JOIN claves_sep sep ON sep.id_sep = subp.id_sep
    INNER JOIN grupos_optativas gpos ON atf.id_grupo_optativa = gpos.id_grupo_optativa
    INNER JOIN cat_estructuras_ocupacionales estructura ON estructura.id_estructura_ocupacional = atf.id_estructura_ocupacional
    LEFT JOIN planteles_firmantes(_id_subp,_id_estruc) firmantes ON _id_subp = subp.id_subprograma
    LEFT JOIN tramites_licencias_asignaciones licencia_asign1 ON licencia_asign1.id_tramite_licencia_asignacion = atf.id_tramites_licencias_asignaciones AND licencia_asign1.id_componente = 2
    LEFT JOIN tramites_licencias licencia1 ON licencia1.id_tramite_licencia = licencia_asign1.id_tramite_licencia
    LEFT JOIN empleados emp_sust ON emp_sust.id_empleado = licencia1.id_empleado
    LEFT JOIN tramites_licencias_asignaciones_tf licencia_asign2 ON licencia_asign2.id_tramite_licencia_asignacion_tf = atf.id_tramites_licencias_asignaciones_tf AND licencia_asign2.id_componente = 2
    LEFT JOIN tramites_licencias licencia2 ON licencia2.id_tramite_licencia = licencia_asign2.id_tramite_licencia
    LEFT JOIN empleados emp_sust_tf ON emp_sust_tf.id_empleado = licencia2.id_empleado
    WHERE atf.id_asignacion_tiempo_fijo_optativa = ANY(_ids_opta)
    GROUP BY 
        emp_asign.rfc,
        emp_asign.paterno,
        emp_asign.materno,
        emp_asign.nombre,
        emp_asign.id_empleado,
        catego.categoria_padre, 
        mat.materia, 
        atf.qna_desde,
        atf.qna_hasta,
        mov.codigo,
        mov.descripcion,
        emp_sust.paterno,
        emp_sust.materno,
        emp_sust.nombre,
        emp_sust.id_empleado,
        emp_sust_tf.paterno,
        emp_sust_tf.materno,
        emp_sust_tf.nombre,
        emp_sust_tf.id_empleado,
        atf.observacion_comision_mixta,
        atf.observacion_plantel,
        detalle_mat.semestre,
        subp.nombre_subprograma,
        estructura.periodo,
        estructura.fecha_apertura,
        estructura.fecha_cierre,
        firmantes.prefijo_director,
        firmantes.nombre_director,
        firmantes.puesto_director,
        firmantes.prefijo_coordinador,
        firmantes.nombre_coordinador,
        firmantes.puesto_coordinador
    ORDER BY
        emp_asign.rfc,
        detalle_mat.semestre,
        mat.materia,
        nombre_grupo; 

    INSERT INTO temp_planteles_acuerdo
    SELECT 
        emp_asign.paterno, emp_asign.materno, emp_asign.nombre, 
        emp_asign.paterno||' '||emp_asign.materno||' '||emp_asign.nombre AS nombre_completo,
        emp_asign.rfc,
        (
            SELECT STRING_AGG(UPPER(vega.grado_academico), ',' ORDER BY vega.nivel_grado_academico DESC )
            FROM view_empleado_grados_academicos_actual vega
            WHERE vega.id_empleado = emp_asign.id_empleado
        )as grado_academico,
        (
            SELECT STRING_AGG(UPPER(vega.profesion), ',' ORDER BY vega.nivel_grado_academico DESC )
            FROM view_empleado_grados_academicos_actual vega
            WHERE vega.id_empleado = emp_asign.id_empleado
        )as profesion,
        (
            SELECT STRING_AGG(UPPER(vega.valida_archivo_reportes), ',' ORDER BY vega.nivel_grado_academico DESC )
            FROM view_empleado_grados_academicos_actual vega
            WHERE vega.id_empleado = emp_asign.id_empleado
        )as valida_archivo,
        STRING_AGG((
            mat.nombre||' ('||
            atf.horas_grupo||' hrs - '||
            gpos.nombre||' )'
        ),'++') as materia, 
        SUM(atf.horas_grupo) AS horas_grupo,
        catego.categoria_padre,
        mov.codigo, 
        mov.descripcion, 
        atf.qna_desde,
        atf.qna_hasta,
        STRING_AGG(gpos.nombre, ',' ORDER BY gpos.nombre ASC) as nombre_grupo,
        (
            COALESCE((
                SELECT prefijo
                FROM view_empleado_grados_academicos_actual
                WHERE id_empleado = emp_sust.id_empleado
                ORDER BY nivel_grado_academico DESC
                LIMIT 1
            ),'')||' '||
            COALESCE(emp_sust.paterno,'')||' '||COALESCE(emp_sust.materno,'')||' '||COALESCE(emp_sust.nombre,'')
        )||''||
        (
            COALESCE((
                SELECT prefijo
                FROM view_empleado_grados_academicos_actual
                WHERE id_empleado = emp_sust_tf.id_empleado
                ORDER BY nivel_grado_academico DESC
                LIMIT 1
            ),'')||' '||
            COALESCE(emp_sust_tf.paterno,'')||' '||COALESCE(emp_sust_tf.materno,'')||' '||COALESCE(emp_sust_tf.nombre,'')
        ) AS sustituye,
        atf.observacion_comision_mixta,
        atf.observacion_plantel,
        subp.nombre_subprograma,
        estructura.periodo,
        estructura.fecha_apertura,
        estructura.fecha_cierre,
        firmantes.prefijo_director,
        firmantes.nombre_director,
        firmantes.puesto_director,
        firmantes.prefijo_coordinador,
        firmantes.nombre_coordinador,
        firmantes.puesto_coordinador
    FROM asignacion_tiempo_fijo_paraescolares atf
    INNER JOIN empleados emp_asign ON emp_asign.id_empleado = atf.id_empleado
    INNER JOIN cat_categorias_padre catego ON catego.id_cat_categoria_padre = atf.id_cat_categoria_padre
    INNER JOIN cat_materias_paraescolares mat ON mat.id_paraescolar = atf.id_cat_materias_paraescolares
    INNER JOIN cat_tipo_movimiento_personal mov ON mov.id_tipo_movimiento_personal = atf.id_tipo_movimiento_personal
    INNER JOIN subprogramas subp ON subp.id_subprograma = atf.id_subprograma
    INNER JOIN claves_sep sep ON sep.id_sep = subp.id_sep
    INNER JOIN grupos_paraescolares gpos ON atf.id_grupo_paraescolares = gpos.id_grupo_paraescolar
    INNER JOIN cat_estructuras_ocupacionales estructura ON estructura.id_estructura_ocupacional = atf.id_estructura_ocupacional
    LEFT JOIN planteles_firmantes(_id_subp,_id_estruc) firmantes ON _id_subp = subp.id_subprograma
    LEFT JOIN tramites_licencias_asignaciones licencia_asign1 ON licencia_asign1.id_tramite_licencia_asignacion = atf.id_tramites_licencias_asignaciones AND licencia_asign1.id_componente = 4
    LEFT JOIN tramites_licencias licencia1 ON licencia1.id_tramite_licencia = licencia_asign1.id_tramite_licencia
    LEFT JOIN empleados emp_sust ON emp_sust.id_empleado = licencia1.id_empleado
    LEFT JOIN tramites_licencias_asignaciones_tf licencia_asign2 ON licencia_asign2.id_tramite_licencia_asignacion_tf = atf.id_tramites_licencias_asignaciones_tf AND licencia_asign2.id_componente = 4
    LEFT JOIN tramites_licencias licencia2 ON licencia2.id_tramite_licencia = licencia_asign2.id_tramite_licencia
    LEFT JOIN empleados emp_sust_tf ON emp_sust_tf.id_empleado = licencia2.id_empleado
    WHERE atf.id_asignacion_tiempo_fijo_paraescolares = ANY(_ids_para)
    GROUP BY 
        emp_asign.rfc,
        emp_asign.paterno,
        emp_asign.materno,
        emp_asign.nombre,
        emp_asign.id_empleado,
        catego.categoria_padre, 
        mat.nombre, 
        atf.qna_desde,
        atf.qna_hasta,
        mov.codigo,
        mov.descripcion,
        emp_sust.paterno,
        emp_sust.materno,
        emp_sust.nombre,
        emp_sust.id_empleado,
        emp_sust_tf.paterno,
        emp_sust_tf.materno,
        emp_sust_tf.nombre,
        emp_sust_tf.id_empleado,
        atf.observacion_comision_mixta,
        atf.observacion_plantel,
        gpos.nombre,
        subp.nombre_subprograma,
        estructura.periodo,
        estructura.fecha_apertura,
        estructura.fecha_cierre,
        firmantes.prefijo_director,
        firmantes.nombre_director,
        firmantes.puesto_director,
        firmantes.prefijo_coordinador,
        firmantes.nombre_coordinador,
        firmantes.puesto_coordinador
    ORDER BY
        emp_asign.rfc,
        gpos.nombre,
        mat.nombre,
        nombre_grupo;       	

    /* Pinto los datos del plantel (plantilla base con/sin asigncion) */	
	RETURN query 
    SELECT 
		t.paterno, t.materno, t.nombre, t.nombre_completo, t.rfc, t.grado_academico, t.profesion, t.valida_archivo,
        STRING_AGG(t.materia, '++') as materia,SUM(t.horas_grupo) as horas_grupo, t.categoria_padre, t.codigo, t.descripcion, t.qna_desde, t.qna_hasta, t.sustituye, t.observacion_comision_mixta,
        t.observacion_plantel, t.nombre_subprograma, t.periodo, t.fecha_apertura, t.fecha_cierre, t.prefijo_director, t.nombre_director,
        t.puesto_director, t.prefijo_coordinador, t.nombre_coordinador, t.puesto_coordinador
    FROM temp_planteles_acuerdo t
    GROUP BY 
        t.paterno, t.materno, t.nombre, t.nombre_completo, t.rfc, t.grado_academico, t.profesion, t.valida_archivo,
        t.categoria_padre, t.codigo, t.descripcion, t.qna_desde, t.qna_hasta, t.sustituye, t.observacion_comision_mixta,
        t.observacion_plantel, t.nombre_subprograma, t.periodo, t.fecha_apertura, t.fecha_cierre, t.prefijo_director, t.nombre_director,
        t.puesto_director, t.prefijo_coordinador, t.nombre_coordinador, t.puesto_coordinador
    ORDER BY t.nombre_completo;
	
	/* Al retornar se destruye la tambla temporal */
	DROP TABLE temp_planteles_acuerdo;	


END; 