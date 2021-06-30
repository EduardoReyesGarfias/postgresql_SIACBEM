CREATE VIEW view_planteles_asignacion_eb AS ( 
    SELECT 
        p_b_d_p.id_subprograma,
        p_b_d_p.id_estructura_ocupacional,
        p_b_d_p.id_plantilla_base_docente_rh,
        p_b_d_p.hrs_categoria,
        emp.id_empleado,
        emp.rfc,
        emp.filiacion,
        emp.paterno,
        emp.materno,
        emp.nombre,
        c_c_p.categoria_padre,
        c_t_m_p.codigo,
        c_t_m_p.descripcion,
        p_b_d_p.num_plz,
        COALESCE(sum(pp.horas_grupo_base), (0)::bigint) AS horas_usadas
    FROM plantilla_base_docente_rh p_b_d_p
    JOIN empleados emp ON emp.id_empleado = p_b_d_p.id_empleado
    JOIN cat_categorias_padre c_c_p ON c_c_p.id_cat_categoria_padre = p_b_d_p.id_cat_categoria_padre
    JOIN cat_tipo_movimiento_personal c_t_m_p ON c_t_m_p.id_tipo_movimiento_personal = p_b_d_p.id_cat_tipo_movimiento_personal
    LEFT JOIN profesores_profesor_asignado_base pp ON pp.id_plantilla_base_docente_rh = p_b_d_p.id_plantilla_base_docente_rh
    LEFT JOIN profesor_asignado_base pab ON pab.id_profesor_asignado_base = pp.id_profesor_asignado_base
    LEFT JOIN grupos_estructura_base geb ON geb.id_grupo_estructura_base = pab.id_grupo_estructura_base
    LEFT JOIN horas_autorizadas ha ON ha.id_hora_autorizada = geb.id_hora_autorizada
    LEFT JOIN grupos gpos ON gpos.id_grupo = ha.id_grupo
    LEFT JOIN periodos per ON per.id_periodo = gpos.id_periodo
    LEFT JOIN grupos_combinaciones_planes gposcomb ON gposcomb.id_grupo_combinacion_plan = gpos.id_grupo_combinacion_plan
    LEFT JOIN detalle_materias detmat ON detmat.id_detalle_materia = pab.id_detalle_materia
    LEFT JOIN cat_materias catmat ON catmat.id_materia = detmat.id_materia
    WHERE 
        p_b_d_p.id_cat_tipo_movimiento_personal = ANY (ARRAY[2, 3]) 
        AND catmat.fecha_fin IS NULL 
        AND p_b_d_p.revision_rh = true 
        AND pp.horas_grupo_base > 0
    GROUP BY 
        p_b_d_p.id_subprograma, 
        p_b_d_p.id_estructura_ocupacional, 
        p_b_d_p.id_plantilla_base_docente_rh, 
        p_b_d_p.hrs_categoria,
        emp.id_empleado,
        emp.rfc,
        emp.filiacion, 
        emp.paterno, 
        emp.materno, 
        emp.nombre, 
        c_c_p.categoria_padre, 
        c_t_m_p.codigo, 
        c_t_m_p.descripcion, 
        p_b_d_p.num_plz
    ORDER BY 
        emp.paterno, 
        emp.materno, 
        emp.nombre
)
UNION ALL
( 
    SELECT 
        p_b_d_p.id_subprograma,
        p_b_d_p.id_estructura_ocupacional,
        p_b_d_p.id_plantilla_base_docente_rh,
        p_b_d_p.hrs_categoria,
        emp.id_empleado,
        emp.rfc,
        emp.filiacion, 
        emp.paterno,
        emp.materno,
        emp.nombre,
        c_c_p.categoria_padre,
        c_t_m_p.codigo,
        c_t_m_p.descripcion,
        p_b_d_p.num_plz,
        COALESCE(sum(ppc.horas_grupo_capacitacion), (0)::bigint) AS horas_usadas
    FROM plantilla_base_docente_rh p_b_d_p
    JOIN empleados emp ON emp.id_empleado = p_b_d_p.id_empleado
    JOIN cat_categorias_padre c_c_p ON c_c_p.id_cat_categoria_padre = p_b_d_p.id_cat_categoria_padre
    JOIN cat_tipo_movimiento_personal c_t_m_p ON c_t_m_p.id_tipo_movimiento_personal = p_b_d_p.id_cat_tipo_movimiento_personal
    LEFT JOIN profesores_profesor_asignado_capacitacion ppc ON ppc.id_plantilla_base_docente_rh = p_b_d_p.id_plantilla_base_docente_rh
    LEFT JOIN profesor_asignado_capacitacion pac ON pac.id_profesor_asignado_capacitacion = ppc.id_profesor_asignado_capacitacion
    LEFT JOIN grupos_capacitacion gc ON gc.id_grupo_capacitacion = pac.id_grupo_capacitacion
    LEFT JOIN horas_autorizadas ha ON ha.id_hora_autorizada = gc.id_hora_autorizada
    LEFT JOIN grupos gpos ON gpos.id_grupo = ha.id_grupo
    LEFT JOIN periodos per ON per.id_periodo = gpos.id_periodo
    LEFT JOIN grupos_combinaciones_planes gposcomb ON gposcomb.id_grupo_combinacion_plan = gpos.id_grupo_combinacion_plan
    LEFT JOIN detalle_materias detmat ON detmat.id_detalle_materia = pac.id_detalle_materia
    LEFT JOIN cat_materias catmat ON catmat.id_materia = detmat.id_materia
    WHERE 
        p_b_d_p.id_cat_tipo_movimiento_personal = ANY (ARRAY[2, 3]) 
        AND catmat.fecha_fin IS NULL 
        AND p_b_d_p.revision_rh = true 
        AND ppc.horas_grupo_capacitacion > 0
    GROUP BY 
        p_b_d_p.id_subprograma, 
        p_b_d_p.id_estructura_ocupacional, 
        p_b_d_p.id_plantilla_base_docente_rh, 
        p_b_d_p.hrs_categoria, emp.paterno,
        emp.id_empleado,
        emp.rfc,
        emp.filiacion,  
        emp.materno, 
        emp.nombre, 
        c_c_p.categoria_padre, 
        c_t_m_p.codigo, 
        c_t_m_p.descripcion, 
        p_b_d_p.num_plz
    ORDER BY emp.paterno, emp.materno, emp.nombre
)   
UNION ALL
( 
    SELECT 
    p_b_d_p.id_subprograma,
    p_b_d_p.id_estructura_ocupacional,
    p_b_d_p.id_plantilla_base_docente_rh,
    p_b_d_p.hrs_categoria,
    emp.id_empleado,
    emp.rfc,
    emp.filiacion, 
    emp.paterno,
    emp.materno,
    emp.nombre,
    c_c_p.categoria_padre,
    c_t_m_p.codigo,
    c_t_m_p.descripcion,
    p_b_d_p.num_plz,
    COALESCE(sum(ppc.horas_grupo_optativas), (0)::bigint) AS horas_usadas
    FROM plantilla_base_docente_rh p_b_d_p
    JOIN empleados emp ON emp.id_empleado = p_b_d_p.id_empleado
    JOIN cat_categorias_padre c_c_p ON c_c_p.id_cat_categoria_padre = p_b_d_p.id_cat_categoria_padre
    JOIN cat_tipo_movimiento_personal c_t_m_p ON c_t_m_p.id_tipo_movimiento_personal = p_b_d_p.id_cat_tipo_movimiento_personal
    LEFT JOIN profesores_profesor_asignado_optativas ppc ON ppc.id_plantilla_base_docente_rh = p_b_d_p.id_plantilla_base_docente_rh
    LEFT JOIN profesor_asignado_optativas pac ON pac.id_profesor_asignado_optativa = ppc.id_profesor_asignado_optativa
    LEFT JOIN grupos_optativas gc ON gc.id_grupo_optativa = pac.id_grupo_optativa
    LEFT JOIN horas_autorizadas ha ON ha.id_hora_autorizada = gc.id_hora_autorizada
    LEFT JOIN grupos gpos ON gpos.id_grupo = ha.id_grupo
    LEFT JOIN periodos per ON per.id_periodo = gpos.id_periodo
    LEFT JOIN grupos_combinaciones_planes gposcomb ON gposcomb.id_grupo_combinacion_plan = gpos.id_grupo_combinacion_plan
    LEFT JOIN detalle_materias detmat ON detmat.id_detalle_materia = pac.id_detalle_materia
    LEFT JOIN cat_materias catmat ON catmat.id_materia = detmat.id_materia
    WHERE 
        p_b_d_p.id_cat_tipo_movimiento_personal = ANY (ARRAY[2, 3]) 
        AND catmat.fecha_fin IS NULL 
        AND p_b_d_p.revision_rh = true 
        AND ppc.horas_grupo_optativas > 0
    GROUP BY 
        p_b_d_p.id_subprograma,
        p_b_d_p.id_estructura_ocupacional, 
        p_b_d_p.id_plantilla_base_docente_rh, 
        p_b_d_p.hrs_categoria,
        emp.id_empleado,
        emp.rfc,
        emp.filiacion,  
        emp.paterno, 
        emp.materno, 
        emp.nombre, 
        c_c_p.categoria_padre, 
        c_t_m_p.codigo, 
        c_t_m_p.descripcion, 
        p_b_d_p.num_plz
    ORDER BY 
        emp.paterno, 
        emp.materno, 
        emp.nombre
)   
UNION ALL
( 
    SELECT 
        p_b_d_p.id_subprograma,
        p_b_d_p.id_estructura_ocupacional,
        p_b_d_p.id_plantilla_base_docente_rh,
        p_b_d_p.hrs_categoria,
        emp.id_empleado,
        emp.rfc,
        emp.filiacion,
        emp.paterno,
        emp.materno,
        emp.nombre,
        c_c_p.categoria_padre,
        c_t_m_p.codigo,
        c_t_m_p.descripcion,
        p_b_d_p.num_plz,
        COALESCE(sum(ppc.horas_grupo_paraescolares), (0)::bigint) AS horas_usadas
    FROM plantilla_base_docente_rh p_b_d_p
    JOIN empleados emp ON emp.id_empleado = p_b_d_p.id_empleado
    JOIN cat_categorias_padre c_c_p ON c_c_p.id_cat_categoria_padre = p_b_d_p.id_cat_categoria_padre
    JOIN cat_tipo_movimiento_personal c_t_m_p ON c_t_m_p.id_tipo_movimiento_personal = p_b_d_p.id_cat_tipo_movimiento_personal
    LEFT JOIN profesores_profesor_asignado_paraescolares ppc ON ppc.id_plantilla_base_docente_rh = p_b_d_p.id_plantilla_base_docente_rh
    LEFT JOIN profesor_asignado_paraescolares pac ON pac.id_profesor_asignado_paraescolares = ppc.id_profesor_asignado_paraescolares
    LEFT JOIN cat_materias_paraescolares cmp ON cmp.id_paraescolar = ppc.id_cat_materias_paraescolares
    WHERE 
        p_b_d_p.id_cat_tipo_movimiento_personal = ANY (ARRAY[2, 3])
        AND (p_b_d_p.revision_rh = true) 
        AND (ppc.horas_grupo_paraescolares > 0)
    GROUP BY 
        p_b_d_p.id_subprograma, 
        p_b_d_p.id_estructura_ocupacional, 
        p_b_d_p.id_plantilla_base_docente_rh, 
        p_b_d_p.hrs_categoria,
        emp.id_empleado,
        emp.rfc,
        emp.filiacion, 
        emp.paterno, 
        emp.materno, 
        emp.nombre, 
        c_c_p.categoria_padre, 
        c_t_m_p.codigo, 
        c_t_m_p.descripcion, 
        p_b_d_p.num_plz
    ORDER BY 
        emp.paterno, 
        emp.materno, 
        emp.nombre
)        