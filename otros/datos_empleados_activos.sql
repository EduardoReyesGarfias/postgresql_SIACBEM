SELECT  
b.paterno,b.materno,b.nombre,b.filiacion,b.id_empleado,b.rfc,b.curp,b.genero,b.lugar_nacimiento,entidad_federativa, 
fecha_nacimiento,nacionalidad, estado_civil, domicilio,calle, no_ext, no_int, telefono, no_seguridad_social, fecha_ingreso, d_asenta
,d_mnpio, d_ciudad, d_estado, c_estado, d_codigo
,(
	SELECT 
    zb.nombre_subprograma
    FROM pagos_sispagos za
    INNER JOIN subprogramas zb ON za.id_subprograma = zb.id_subprograma
    WHERE za.id_nomina in (SELECT id_nomina FROM nominas_sispagos WHERE qnapago = 201822 and id_tipo_nomina != 2)
    and za.filiacion = b.filiacion
    ORDER BY za.numero_hr DESC
    LIMIT 1
) as nombre_subprograma

FROM pagos_sispagos a
INNER JOIN empleados b ON b.id_empleado = a.id_empleado

INNER JOIN codigos_postales c ON c.id_cp = b.id_cp
INNER JOIN cat_estados d ON d.id_estado = b.id_estado_lugar_nacimiento
LEFT JOIN empleado_grados_academicos e ON e.id_empleado = b.id_empleado
LEFT JOIN cat_grados_academicos f ON f.id_grado_academico = e.id_grado_academico
LEFT JOIN curricula_estudios_empleados g ON g.id_empleado = b.id_empleado
LEFT JOIN cat_profesiones h ON h.id_profesion = g.id_profesion

WHERE a.id_nomina in (SELECT id_nomina FROM nominas_sispagos WHERE qnapago = 201822 and id_tipo_nomina != 2)
GROUP BY 
b.paterno,b.materno,b.nombre,b.filiacion,b.id_empleado,b.rfc,b.curp,b.genero,b.lugar_nacimiento,entidad_federativa, 
fecha_nacimiento,nacionalidad, estado_civil, domicilio,calle, no_ext, no_int, telefono, no_seguridad_social, fecha_ingreso, d_asenta
,d_mnpio, d_ciudad, d_estado, c_estado, d_codigo
ORDER BY b.filiacion
