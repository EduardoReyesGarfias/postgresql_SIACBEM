SELECT 
a.filiacion,b.rfc,b.paterno,b.materno,b.nombre,b.genero,b.fecha_nacimiento,b.lugar_nacimiento,b.nacionalidad,b.estado_civil
,d_codigo,d_asenta,d_mnpio,d_estado,d_ciudad,b.calle,b.telefono,a.clave_plz,a.numero_plz,a.numero_hr,d.descripcion_cat_padre
,b.fecha_ingreso,b.fecha_ingreso_sispagos_impresion,a.desde_plz,a.hasta_plz,a.tipo_nombr,b.no_ext,b.no_int,clave_plz,numero_plz,numero_hr,
subprograma,(
	SELECT nombre_subprograma 
	FROM subprogramas 
	where clave_subprograma = CAST( substring( TRIM(subprograma) from 2 for length( TRIM(subprograma) ) )  as text) 
	OR clave_extension_u_organica = CAST( substring( TRIM(subprograma) from 2 for length( TRIM(subprograma) ) )  as text)
	--La siguiente linea es para que tome el subprograma que le corresponde dependiendo de la fecha de Movimiento
	AND CAST(fecha_ini as text) <= fecha_pago_con_numero(qna_sit::int) 
	AND ( CAST(fecha_fin as text) >= fecha_pago_con_numero(qna_sit::int) OR fecha_fin IS null )
	ORDER BY clave_extension_u_organica 
	LIMIT 1
)as adscripcion,fecha_pago_con_numero(qna_sit::int)
FROM plazas_nomina_rh_recibe a
INNER JOIN empleados b ON a.filiacion = b.filiacion
INNER JOIN codigos_postales c ON c.id_cp = b.id_cp
INNER JOIN cat_categorias_padre d ON d.categoria_padre = a.clave_plz
WHERE a.id_plaza_nomina_rh_datos = 53
AND a.id_plaza_nomina_rh_recibe = 14014227
AND a.filiacion ='MEPE780101000'
AND a.desde_plz >= '200901'

AND a.tipo_nombr in('14','15' )
AND a.estado_rec in('0','8','9','08','09' )
AND a.motivo_mov in ('6','7','8','9','06','07','08','09','14','15','60','61','62','63','64','65','66','67','68','69' )

-- 1140
"1140"

-- depto informatica - erasto mendoza
id_plz_datos=53&id_plz_recibe=14063340&filiacion=MEPE780101000
-- plantel tarimbaro - erasto mendoza
id_plz_datos=53&id_plz_recibe=14014227&filiacion=MEPE780101000