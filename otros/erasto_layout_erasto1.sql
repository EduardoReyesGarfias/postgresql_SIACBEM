COPY(
SELECT
a.id_empleado,a.email_institucional,a.email_institucional_alias
,a.paterno,a.materno,a.nombre,a.filiacion,a.rfc,a.telefono as telefono_personal
,b.d_mnpio as municipio,b.d_ciudad as ciudad,b.d_estado as estado
,'58000' as cp_centro_trabajo,'México' as País_o_región
,d.nombre_subprograma as centro_trabajo,e.descripcion_cat_padre
,(
	CASE WHEN d.clave_subprograma = '001' THEN
    	f.programa
    ELSE
    	'COORDINACIÓN SECTORIAL NO. '||d.coordinacion
    END
) as coordinación
FROM empleados a
INNER JOIN codigos_postales b ON a.id_cp = b.id_cp
INNER JOIN pagos_sispagos c ON c.id_empleado = a.id_empleado
INNER JOIN subprogramas d ON d.id_subprograma = c.id_subprograma
INNER JOIN cat_categorias_padre e ON e.categoria_padre = c.categoria
INNER JOIN programas f ON f.id_programa = d.id_programa
WHERE c.id_nomina = 772
GROUP BY a.id_empleado,a.email_institucional,a.email_institucional_alias
,a.paterno,a.materno,a.nombre,a.filiacion,a.rfc,a.telefono
,b.d_mnpio,b.d_ciudad,b.d_estado
,d.nombre_subprograma,e.descripcion_cat_padre,d.clave_subprograma,f.programa,d.coordinacion
ORDER BY centro_trabajo,paterno,materno,nombre
)
TO '/var/www/html/siacbem/SIACBEM/Timbrados2/Reporte_Empleados_201902.csv'  
DELIMITER ';' CSV HEADER;