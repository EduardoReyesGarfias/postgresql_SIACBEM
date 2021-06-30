SELECT * FROM nominas_sispagos order by qnapago DESC
-- 201824 ordinaria (752)
/* regimen contratacion */
select a.id_empleado,a.clave_tipo_nombramiento,descripcion,genero   
FROM pagos_sispagos a
INNER JOIN cat_tipo_nombramiento b ON CAST(a.clave_tipo_nombramiento as int) = b.clave_tipo_nombramiento
INNER JOIN empleados c ON c.id_empleado = a.id_empleado
WHERE id_nomina = 752
GROUP BY a.id_empleado,a.clave_tipo_nombramiento,descripcion,genero
ORDER BY a.id_empleado

/* edad */
SELECT a.id_empleado, genero, fecha_nacimiento
,(
    CASE WHEN mod((CAST(substring(CAST(c.qnapago as text) from 5 for 8) as int)),2) = 0
    THEN
    	substring(CAST(c.qnapago as text) from 0 for 5)||'-'||
    	round(CAST (substring(CAST(c.qnapago as text) from 5 for 8) as int) /2)||'-30'
    ELSE
    	substring(CAST(c.qnapago as text) from 0 for 5)||'-'||
    	round(CAST (substring(CAST(c.qnapago as text) from 5 for 8) as int) /2)||'-15'
    END
) as fecha_pago
FROM pagos_sispagos a
INNER JOIN empleados b ON b.id_empleado = a.id_empleado
INNER JOIN nominas_sispagos c ON c.id_nomina = a.id_nomina
WHERE a.id_nomina = 752 and a.id_empleado in(10770,9527,9951)
GROUP BY a.id_empleado, genero, fecha_nacimiento, qnapago

/* ingreso mensual */
SELECT a.id_empleado,d.genero
,sum(
	CASE WHEN c.id_tipo_pd =1
    THEN
    	importe
    ELSE
    	importe*-1
    END
)as ingreso
FROM pagos_sispagos a
INNER JOIN percepciones_deducciones_sispagos b ON a.id_pago = b.id_pago
INNER JOIN cat_percepciones_deducciones_sispagos c ON c.clave = b.cod_pd
INNER JOIN empleados d ON d.id_empleado = a.id_empleado
WHERE id_nomina = 752
GROUP BY a.id_empleado,d.genero
ORDER BY a.id_empleado

/* grado academico */

SELECT a.id_empleado,c.grado_academico,d.genero
FROM pagos_sispagos a
INNER JOIN empleado_grados_academicos b ON b.id_empleado = a.id_empleado
INNER JOIN cat_grados_academicos c ON c.id_grado_academico = b.id_grado_academico
INNER JOIN empleados d ON d.id_empleado = a.id_empleado
WHERE id_nomina = 752
GROUP BY a.id_empleado,c.grado_academico,d.genero
ORDER BY a.id_empleado

select grado_academico from empleado_grados_academicos
	join cat_grados_academicos
	on cat_grados_academicos.id_grado_academico=empleado_grados_academicos.id_grado_academico
	join cat_documento_de_acreditacion
	on cat_documento_de_acreditacion.id_documento_acreditacion=empleado_grados_academicos.id_documento_acreditacion
	left join curricula_estudios_empleados 
	on curricula_estudios_empleados.id_empleado_grado_academico=empleado_grados_academicos.id_empleado_grado_academico
	left join cat_instituciones_educativas
	on cat_instituciones_educativas.id_institucion_educativa=curricula_estudios_empleados.id_institucion_educativa
	left join cat_profesiones
	on cat_profesiones.id_profesion=curricula_estudios_empleados.id_profesion
	where empleado_grados_academicos.id_empleado=9819
    
    
    select * from cat_grados_academicos