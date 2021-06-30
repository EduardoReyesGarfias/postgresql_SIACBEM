SELECT 
a.filiacion,b.paterno,b.materno,b.nombre,b.genero,b.fecha_nacimiento,b.lugar_nacimiento,b.nacionalidad,b.estado_civil
,d_codigo,d_asenta,d_mnpio,d_estado,d_ciudad,b.calle,b.telefono,a.clave_plz,a.numero_plz,a.numero_hr,d.descripcion_cat_padre
,b.fecha_ingreso,b.fecha_ingreso_sispagos_impresion,a.desde_plz,a.hasta_plz,a.tipo_nombr
FROM plazas_nomina_rh_recibe a
INNER JOIN empleados b ON a.filiacion = b.filiacion
INNER JOIN codigos_postales c ON c.id_cp = b.id_cp
INNER JOIN cat_categorias_padre d ON d.categoria_padre = a.clave_plz
WHERE a.id_plaza_nomina_rh_datos = 45
AND a.desde_plz >= '201601'
AND a.filiacion ='LIAC900908000'

AND a.tipo_nombr in('14','15')
AND a.estado_rec in('0','08','09')
AND a.motivo_mov in ('06','07','08','09','14','15','60','61','62','63','64','65','66','67','68','69')

AND id_plaza_nomina_rh_datos = 45
AND id_plaza_nomina_rh_recibe = 11882085

ORDER BY a.desde_plz





select * from cat_categorias_padre