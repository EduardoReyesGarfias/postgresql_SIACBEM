( SELECT a.id_estructura_ocupacional,
    a.id_plantilla_base_docente_rh,
    b.id_empleado,
    b.nombre,
    b.paterno,
    b.materno,
    c.id_cat_categoria_padre,
    c.categoria_padre,
    a.num_plz,
    a.hrs_categoria,
    d.id_subprograma,
    d.nombre_subprograma,
    COALESCE((ppab.horas_grupo_base)::integer, 0) AS horas_asignadas,
    cm.materia,
        CASE
            WHEN (COALESCE(( SELECT tla.id_tramite_licencia
               FROM (tramites_licencias_asignaciones tla
                 JOIN tramites_licencias tl ON ((tl.id_tramite_licencia = tla.id_tramite_licencia)))
              WHERE ((tl.id_cat_tramite_status = 3) AND (tla.id_componente = 1) AND (tla.id_asignacion = ppab.id_profesores_profesor_asignado_base))), 0) > 0) THEN true
            ELSE false
        END AS licencia,
    geb.nombre_grupo
   FROM ((((((((plantilla_base_docente_rh a
     JOIN empleados b ON ((b.id_empleado = a.id_empleado)))
     JOIN cat_categorias_padre c ON ((c.id_cat_categoria_padre = a.id_cat_categoria_padre)))
     JOIN subprogramas d ON ((d.id_subprograma = a.id_subprograma)))
     LEFT JOIN profesores_profesor_asignado_base ppab ON ((ppab.id_plantilla_base_docente_rh = a.id_plantilla_base_docente_rh)))
     LEFT JOIN profesor_asignado_base pab ON ((pab.id_profesor_asignado_base = ppab.id_profesor_asignado_base)))
     LEFT JOIN detalle_materias dm ON ((dm.id_detalle_materia = pab.id_detalle_materia)))
     LEFT JOIN cat_materias cm ON ((cm.id_materia = dm.id_materia)))
     LEFT JOIN grupos_estructura_base geb ON ((geb.id_grupo_estructura_base = pab.id_grupo_estructura_base)))
  WHERE (a.revision_rh = true)
  ORDER BY d.id_subprograma, b.id_empleado, c.categoria_padre, a.hrs_categoria)
UNION ALL
( SELECT a.id_estructura_ocupacional,
    a.id_plantilla_base_docente_rh,
    b.id_empleado,
    b.nombre,
    b.paterno,
    b.materno,
    c.id_cat_categoria_padre,
    c.categoria_padre,
    a.num_plz,
    a.hrs_categoria,
    d.id_subprograma,
    d.nombre_subprograma,
    COALESCE((ppao.horas_grupo_optativas)::integer, 0) AS horas_asignadas,
    cm.materia,
        CASE
            WHEN (COALESCE(( SELECT tla.id_tramite_licencia
               FROM (tramites_licencias_asignaciones tla
                 JOIN tramites_licencias tl ON ((tl.id_tramite_licencia = tla.id_tramite_licencia)))
              WHERE ((tl.id_cat_tramite_status = 3) AND (tla.id_componente = 2) AND (tla.id_asignacion = ppao.id_profesores_profesor_asignado_optativas))), 0) > 0) THEN true
            ELSE false
        END AS licencia,
    go.nombre_grupo_optativas AS nombre_grupo
   FROM ((((((((plantilla_base_docente_rh a
     JOIN empleados b ON ((b.id_empleado = a.id_empleado)))
     JOIN cat_categorias_padre c ON ((c.id_cat_categoria_padre = a.id_cat_categoria_padre)))
     JOIN subprogramas d ON ((d.id_subprograma = a.id_subprograma)))
     LEFT JOIN profesores_profesor_asignado_optativas ppao ON ((ppao.id_plantilla_base_docente_rh = a.id_plantilla_base_docente_rh)))
     LEFT JOIN profesor_asignado_optativas pao ON ((pao.id_profesor_asignado_optativa = ppao.id_profesor_asignado_optativa)))
     LEFT JOIN detalle_materias dm ON ((dm.id_detalle_materia = pao.id_detalle_materia)))
     LEFT JOIN cat_materias cm ON ((cm.id_materia = dm.id_materia)))
     LEFT JOIN grupos_optativas go ON ((go.id_grupo_optativa = pao.id_grupo_optativa)))
  WHERE (a.revision_rh = true)
  ORDER BY d.id_subprograma, b.id_empleado, c.categoria_padre, a.hrs_categoria)
UNION ALL
( SELECT a.id_estructura_ocupacional,
    a.id_plantilla_base_docente_rh,
    b.id_empleado,
    b.nombre,
    b.paterno,
    b.materno,
    c.id_cat_categoria_padre,
    c.categoria_padre,
    a.num_plz,
    a.hrs_categoria,
    d.id_subprograma,
    d.nombre_subprograma,
    COALESCE((ppac.horas_grupo_capacitacion)::integer, 0) AS horas_asignadas,
    cm.materia,
        CASE
            WHEN (COALESCE(( SELECT tla.id_tramite_licencia
               FROM (tramites_licencias_asignaciones tla
                 JOIN tramites_licencias tl ON ((tl.id_tramite_licencia = tla.id_tramite_licencia)))
              WHERE ((tl.id_cat_tramite_status = 3) AND (tla.id_componente = 3) AND (tla.id_asignacion = ppac.id_profesores_profesor_asignado_capacitacion))), 0) > 0) THEN true
            ELSE false
        END AS licencia,
    go.nombre_grupo_capacitacion AS nombre_grupo
   FROM ((((((((plantilla_base_docente_rh a
     JOIN empleados b ON ((b.id_empleado = a.id_empleado)))
     JOIN cat_categorias_padre c ON ((c.id_cat_categoria_padre = a.id_cat_categoria_padre)))
     JOIN subprogramas d ON ((d.id_subprograma = a.id_subprograma)))
     LEFT JOIN profesores_profesor_asignado_capacitacion ppac ON ((ppac.id_plantilla_base_docente_rh = a.id_plantilla_base_docente_rh)))
     LEFT JOIN profesor_asignado_capacitacion pac ON ((pac.id_profesor_asignado_capacitacion = ppac.id_profesor_asignado_capacitacion)))
     LEFT JOIN detalle_materias dm ON ((dm.id_detalle_materia = pac.id_detalle_materia)))
     LEFT JOIN cat_materias cm ON ((cm.id_materia = dm.id_materia)))
     LEFT JOIN grupos_capacitacion go ON ((go.id_grupo_capacitacion = pac.id_grupo_capacitacion)))
  WHERE (a.revision_rh = true)
  ORDER BY d.id_subprograma, b.id_empleado, c.categoria_padre, a.hrs_categoria)
UNION ALL
( SELECT a.id_estructura_ocupacional,
    a.id_plantilla_base_docente_rh,
    b.id_empleado,
    b.nombre,
    b.paterno,
    b.materno,
    c.id_cat_categoria_padre,
    c.categoria_padre,
    a.num_plz,
    a.hrs_categoria,
    d.id_subprograma,
    d.nombre_subprograma,
    COALESCE(ppap.horas_grupo_paraescolares, 0) AS horas_asignadas,
    cmp.nombre AS materia,
        CASE
            WHEN (COALESCE(( SELECT tla.id_tramite_licencia
               FROM (tramites_licencias_asignaciones tla
                 JOIN tramites_licencias tl ON ((tl.id_tramite_licencia = tla.id_tramite_licencia)))
              WHERE ((tl.id_cat_tramite_status = 3) AND (tla.id_componente = 4) AND (tla.id_asignacion = ppap.id_profesores_profesor_asignado_paraescolares))), 0) > 0) THEN true
            ELSE false
        END AS licencia,
    gp.nombre AS nombre_grupo
   FROM (((((((plantilla_base_docente_rh a
     JOIN empleados b ON ((b.id_empleado = a.id_empleado)))
     JOIN cat_categorias_padre c ON ((c.id_cat_categoria_padre = a.id_cat_categoria_padre)))
     JOIN subprogramas d ON ((d.id_subprograma = a.id_subprograma)))
     LEFT JOIN profesores_profesor_asignado_paraescolares ppap ON ((ppap.id_plantilla_base_docente_rh = a.id_plantilla_base_docente_rh)))
     LEFT JOIN profesor_asignado_paraescolares pap ON ((pap.id_profesor_asignado_paraescolares = ppap.id_profesor_asignado_paraescolares)))
     LEFT JOIN cat_materias_paraescolares cmp ON ((cmp.id_paraescolar = ppap.id_cat_materias_paraescolares)))
     LEFT JOIN grupos_paraescolares gp ON ((gp.id_grupo_paraescolar = pap.id_grupo_paraescolares)))
  WHERE (a.revision_rh = true)
  ORDER BY d.id_subprograma, b.id_empleado, c.categoria_padre, a.hrs_categoria);