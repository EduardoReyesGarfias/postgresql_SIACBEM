BEGIN;

CREATE TEMP TABLE temp_basificacion_alta_12(
	empleado text,
	rfc character varying,
	curp character varying,
	email character varying,
	telefono character varying,
	horas_per1 bigint,
	horas_per2 bigint,
	horas_per3 bigint,
	horas_per4 bigint,
	antiguedad integer,
	grado_academico character varying, 
	profesion character varying
);

DROP TABLE temp_basificacion_alta_12;	

commit

rollback

INSERT INTO temp_basificacion_alta_12(empleado,
	rfc,
	curp,
	email,
	telefono,
	horas_per1,
	horas_per2,
	horas_per3,
	horas_per4)
(SELECT 
	(e.paterno || ' ' || e.materno || ' ' || e.nombre) AS empleado
	,e.rfc
	,e.curp 
	,e.email_institucional email
	,e.telefono 
	,hp.horas_per1
	,hp.horas_per2
	,hp.horas_per3
	,hp.horas_per4
FROM (SELECT
		id_empleado
		,(array_agg (horas_per))[1] AS horas_per1
		,(array_agg (horas_per))[2] AS horas_per2
		,(array_agg (horas_per))[3] AS horas_per3
		,(array_agg (horas_per))[4] AS horas_per4
	FROM (SELECT DISTINCT 
			pag.id_empleado 
			,26 AS id_eo
			,sum( pag.numero_hr ) AS horas_per
		FROM pagos_sispagos pag
		JOIN nominas_sispagos nom
			ON pag.id_nomina = nom.id_nomina
		JOIN cat_categorias_padre cat
			ON pag.categoria = cat.categoria_padre 
		WHERE 
			nom.id_tipo_nomina IN (1)
			AND cat.tipo_categoria IN (2,4)
			AND pag.clave_tipo_nombramiento = '12'
			AND nom.qnapago >= 201916 AND nom.qnapago <= 202003
		GROUP BY id_empleado, 
			id_eo
		HAVING 
			(
				SELECT 
					count(pbd.id_plantilla_base_docente_rh) AS cont
				FROM plantilla_base_docente_rh pbd
				WHERE 
					pbd.id_empleado = pag.id_empleado 
					AND pbd.id_estructura_ocupacional = 29
			) > 0
		UNION ALL 
		SELECT DISTINCT 
			pag.id_empleado 
			,27 AS id_eo
			,sum( pag.numero_hr ) AS horas_per
		FROM pagos_sispagos pag
		JOIN nominas_sispagos nom
			ON pag.id_nomina = nom.id_nomina
		JOIN cat_categorias_padre cat
			ON pag.categoria = cat.categoria_padre 
		WHERE 
			nom.id_tipo_nomina IN (1)
			AND cat.tipo_categoria IN (2,4)
			AND pag.clave_tipo_nombramiento = '12'
			AND nom.qnapago >= 202004 AND nom.qnapago <= 202015
		GROUP BY id_empleado, 
			id_eo
		HAVING 
			(
				SELECT 
					count(pbd.id_plantilla_base_docente_rh) AS cont
				FROM plantilla_base_docente_rh pbd
				WHERE 
					pbd.id_empleado = pag.id_empleado 
					AND pbd.id_estructura_ocupacional = 29
			) > 0
		UNION ALL 
		SELECT DISTINCT 
			pag.id_empleado 
			,28 AS id_eo
			,sum( pag.numero_hr ) AS horas_per
		FROM pagos_sispagos pag
		JOIN nominas_sispagos nom
			ON pag.id_nomina = nom.id_nomina
		JOIN cat_categorias_padre cat
			ON pag.categoria = cat.categoria_padre 
		WHERE 
			nom.id_tipo_nomina IN (1)
			AND cat.tipo_categoria IN (2,4)
			AND pag.clave_tipo_nombramiento = '12'
			AND nom.qnapago >= 202016 AND nom.qnapago <= 202103
		GROUP BY id_empleado, 
			id_eo
		HAVING 
			(
				SELECT 
					count(pbd.id_plantilla_base_docente_rh) AS cont
				FROM plantilla_base_docente_rh pbd
				WHERE 
					pbd.id_empleado = pag.id_empleado 
					AND pbd.id_estructura_ocupacional = 29
			) > 0
		UNION ALL 
		SELECT DISTINCT 
			pag.id_empleado 
			,27 AS id_eo
			,sum( pag.numero_hr ) AS horas_per
		FROM pagos_sispagos pag
		JOIN nominas_sispagos nom
			ON pag.id_nomina = nom.id_nomina
		JOIN cat_categorias_padre cat
			ON pag.categoria = cat.categoria_padre 
		WHERE 
			nom.id_tipo_nomina IN (1)
			AND cat.tipo_categoria IN (2,4)
			AND pag.clave_tipo_nombramiento = '12'
			AND nom.qnapago >= 202104 AND nom.qnapago <= 202115
		GROUP BY id_empleado, 
			id_eo
		HAVING 
			(
				SELECT 
					count(pbd.id_plantilla_base_docente_rh) AS cont
				FROM plantilla_base_docente_rh pbd
				WHERE 
					pbd.id_empleado = pag.id_empleado 
					AND pbd.id_estructura_ocupacional = 29
			) > 0
		ORDER BY
			id_empleado, 
			id_eo
		) AS horas_alta_12
	GROUP BY 
		id_empleado
	HAVING 
		array_length ( array_agg (id_eo), 1 ) = 4
	ORDER BY
		id_empleado
	) AS hp
JOIN empleados e
	ON hp.id_empleado = e.id_empleado 
ORDER BY e.rfc
 );
 

UPDATE temp_basificacion_alta_12
SET antiguedad = (
	
	CASE WHEN temp_basificacion_alta_12.rfc = 'OIMG8605239V4' THEN 0 ELSE
		(SELECT ((anios*24) + qnas) as qnas
		FROM empleados aa
		INNER JOIN obtiene_antiguedad_x_fecha_ing(aa.filiacion, '202111') ab ON aa.filiacion = aa.filiacion
		WHERE aa.rfc = temp_basificacion_alta_12.rfc
		LIMIT 1)
	END
);

UPDATE temp_basificacion_alta_12
SET grado_academico = (
	(SELECT grado_academico
	FROM empleados ba
	INNER JOIN view_empleado_grados_academicos bb ON ba.filiacion = bb.filiacion
	WHERE ba.rfc = temp_basificacion_alta_12.rfc
	ORDER BY nivel_grado_academico DESC
	LIMIT 1
	 )
), profesion = (
	(
	(SELECT profesion
	FROM empleados ba
	INNER JOIN view_empleado_grados_academicos bb ON ba.filiacion = bb.filiacion
	WHERE ba.rfc = temp_basificacion_alta_12.rfc
	ORDER BY nivel_grado_academico DESC
	LIMIT 1
	 )
)
)


commit;


SELECT a.*
FROM temp_basificacion_alta_12 a
ORDER BY rfc

INNER JOIN empleados b ON a.rfc = b.rfc
AND b.filiacion not in ('OIMG860523000')


SELECT *
FROM empleados
WHERE filiacion = 'OIMG860523000'

