SELECT * from empleados WHERE paterno = 'AGUADO' AND materno = 'OSORNIO'
order by nombre

SELECT * 
FROM empleados_reingreso a
INNER JOIN empleados b ON a.id_empleado = b.id_empleado
WHERE UPPER(b.filiacion) = UPPER('AUOE670828000')

BEGIN;
DELETE FROM empleados_reingreso
WHERE id_empleado_reingreso in(818);

commit;