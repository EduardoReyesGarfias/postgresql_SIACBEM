SELECT subprogramas.nombre_subprograma,empleados.paterno,empleados.materno,empleados.nombre
,empleados.rfc
,cat_tipo_movimiento_personal.codigo
,cat_categorias.descripcion as descripcion_cat_padre
,(cat_categorias.categoria||'/'||plantilla_base_administrativo_plantel.num_plz)as plaza
,0 as hrs_licencia
,empleados.fecha_ingreso, tramites_licencias.fecha_desde, tramites_licencias.fecha_hasta
,cat_tramites.descripcion_tramite,cat_tramite_articulos.num_articulo
,numero_a_letras(cat_tramite_articulos.num_articulo) as letra_articulo
,cat_tramite_articulos.des_motivo,cat_tramite_articulos.id_cat_tramite_articulo,tramites_licencias.fecha_sistema,no_folio
,num_oficio_autorizacion,fecha_autorizacion,procede,observacion_no_procede

FROM tramites_licencias
JOIN tramites_licencias_plazas_administrativas
ON tramites_licencias_plazas_administrativas.id_tramite_licencia = tramites_licencias.id_tramite_licencia

JOIN plantilla_base_administrativo_plantel
ON plantilla_base_administrativo_plantel.id_plantilla_base_administrativo_plantel = tramites_licencias_plazas_administrativas.id_plantilla_base_administrativo_plantel

INNER JOIN plazas
ON plazas.id_plaza = plantilla_base_administrativo_plantel.id_plaza
INNER JOIN cat_categorias
ON cat_categorias.id_categoria = plazas.id_categoria
JOIN cat_tipo_movimiento_personal
ON cat_tipo_movimiento_personal.id_tipo_movimiento_personal=plantilla_base_administrativo_plantel.id_cat_tipo_movimiento_personal
INNER JOIN empleados
ON empleados.id_empleado = tramites_licencias.id_empleado
JOIN cat_tramites
ON cat_tramites.id_tramite = tramites_licencias .id_tramite
JOIN cat_tramite_articulos
ON cat_tramite_articulos.id_cat_tramite_articulo = tramites_licencias.id_cat_tramite_articulo
JOIN subprogramas
ON subprogramas.id_subprograma = tramites_licencias.id_subprograma

WHERE tramites_licencias.id_tramite_licencia=67
/*--and plantilla_base_administrativo_plantel.id_estructura_ocupacional=23*/
union
/*--PARA SACAR LOS DATOS DE LA LICENAIA doceente*/
SELECT subprogramas.nombre_subprograma,e.paterno,e.materno,e.nombre,e.rfc
,mp.codigo
,p.categoria_padre
,(p.categoria_padre||'/'||rh.num_plz||'/'||rh.hrs_categoria)as plaza
,x.hrs_licencia
,e.fecha_ingreso,t.fecha_desde,t.fecha_hasta
,cat_tramites.descripcion_tramite,cat_tramite_articulos.num_articulo
,numero_a_letras(cat_tramite_articulos.num_articulo) as letra_articulo
,cat_tramite_articulos.des_motivo,cat_tramite_articulos.id_cat_tramite_articulo,t.fecha_sistema,no_folio,num_oficio_autorizacion
,fecha_autorizacion,procede,observacion_no_procede

FROM tramites_licencias t
JOIN tramites_licencias_plazas_docente x
ON x.id_tramite_licencia = t.id_tramite_licencia
JOIN plantilla_base_docente_rh rh
ON rh.id_plantilla_base_docente_rh = x.id_plantilla_base_docente_rh
INNER JOIN empleados e
ON e.id_empleado = t.id_empleado
JOIN cat_categorias_padre p
ON rh.id_cat_categoria_padre = p.id_cat_categoria_padre
JOIN cat_tipo_movimiento_personal mp
ON rh.id_cat_tipo_movimiento_personal = mp.id_tipo_movimiento_personal
JOIN cat_tramites
ON cat_tramites.id_tramite = t.id_tramite
JOIN cat_tramite_articulos
ON cat_tramite_articulos.id_cat_tramite_articulo = t.id_cat_tramite_articulo
JOIN subprogramas
ON subprogramas.id_subprograma = t.id_subprograma

WHERE t.id_tramite_licencia= 67