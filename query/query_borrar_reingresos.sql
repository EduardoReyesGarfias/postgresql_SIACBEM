SELECT *
FROM empleados_reingreso
WHERE id_empleado = (
	SELECT id_empleado
	FROM empleados
	WHERE filiacion = 'DIES941004000'
)

BEGIN;
DELETE FROM empleados_reingreso
WHERE id_empleado_reingreso in(647)


commit;
