
SELECT d.nombre,d.paterno,d.materno,b.id_pago, (
CASE WHEN e.tipo_categoria = '1'  THEN
	'FUNCIONARIO'
ELSE
	CASE WHEN b.clave_tipo_nombramiento = '14' OR b.clave_tipo_nombramiento = '15' THEN
		'SERVIDOR PUBLICO'
	ELSE
		'SERVIDOR PÚBLICO EVENTUAL'
	END
END
)as tipo_integrante, b.categoria,b.numero_plz,b.numero_hr,e.descripcion_cat_padre,h.nombre_subprograma
,(
	CASE WHEN d.genero = 'M' THEN
		'Masculino'
	ELSE
		'Femenino'
	END
)as sexo
, STRING_AGG( ',', c.cod_pd||'-'||g.id_tipo_pd ) as cod_pd
,(
	SELECT importe_mensual_60 + importe_mensual_06
	FROM tabulador_recibe_2019
	WHERE id_tabulador_datos = (
		SELECT id_tabulador_datos 
		FROM tabulador_datos_2019
		ORDER BY id_tabulador_datos DESC
		LIMIT 1
	)
	AND id_zona_economica = h.id_zona_economica
	AND id_cat_categoria_padre = e.id_cat_categoria_padre
) as tabulador_mensual
FROM nominas_sispagos a
INNER JOIN pagos_sispagos b ON a.id_nomina = b.id_nomina
INNER JOIN percepciones_deducciones_sispagos c ON c.id_pago = b.id_pago
INNER JOIN empleados d ON d.id_empleado = b.id_empleado
INNER JOIN cat_categorias_padre e ON e.categoria_padre = b.categoria
INNER JOIN cat_tipo_categoria f ON f.id_tipo_categoria = e.tipo_categoria
INNER JOIN cat_percepciones_deducciones_sispagos g ON g.clave = c.cod_pd
INNER JOIN subprogramas h ON h.id_subprograma = b.id_subprograma
WHERE a.id_nomina in( 910 )
GROUP BY b.id_pago,d.nombre,d.paterno,d.materno,b.categoria,b.numero_plz,e.descripcion_cat_padre
,b.numero_hr,h.nombre_subprograma,d.genero,e.tipo_categoria,h.id_zona_economica,e.id_cat_categoria_padre
LIMIT 100