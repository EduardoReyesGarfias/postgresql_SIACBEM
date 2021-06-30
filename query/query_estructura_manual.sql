SELECT *
FROM subprogramas
WHERE nombre_subprograma ilike 'PLANTEL TARÍMBARO%'

/*
134	"Plantel Tarímbaro Extensión Indaparapeo"
133	"Plantel Tarímbaro"
*/

SELECT  
a.id_plantilla_base_docente_rh,
b.id_empleado, b.paterno||' '||b.materno||' '||b.nombre as nombre_empleado,
c.id_subprograma, c.nombre_subprograma,
d.categoria_padre||'/'||a.num_plz||'/'||a.hrs_categoria as clave_plz
,a.revision_rh
FROM plantilla_base_docente_rh a
INNER JOIN empleados b ON b.id_empleado = a.id_empleado
INNER JOIN subprogramas c ON c.id_subprograma = a.id_subprograma
INNER JOIN cat_categorias_padre d ON d.id_cat_categoria_padre = a.id_cat_categoria_padre
WHERE 
	a.id_subprograma in (134,133)
	AND id_estructura_ocupacional = 30
ORDER BY nombre_empleado, clave_plz

/* ACTUALIZAR REGISTRO */
BEGIN;

UPDATE plantilla_base_docente_rh
SET 
--id_subprograma = 133
--hrs_categoria = 20
revision_rh = true
WHERE id_plantilla_base_docente_rh in(71356);

ROLLBACK;

COMMIT;

/* INSERTAR NUEVA PLAZA */

BEGIN;

INSERT INTO plantilla_base_docente_rh(id_empleado, id_subprograma, id_cat_categoria_padre, hrs_categoria, id_cat_tipo_movimiento_personal, id_usuario, fecha_sistema, id_estructura_ocupacional, num_plz, revision_rh)
SELECT id_empleado, id_subprograma, id_cat_categoria_padre, hrs_categoria, id_cat_tipo_movimiento_personal, id_usuario, now(), 30, num_plz, revision_rh
FROM plantilla_base_docente_rh a
WHERE id_subprograma in (134,133)
AND id_estructura_ocupacional = 30
AND id_plantilla_base_docente_rh;

ROLLBACK;

COMMIT;

/* ELIMINAR REGISTRO */

BEGIN;

DELETE FROM plantilla_base_docente_rh
WHERE id_plantilla_base_docente_rh  = 71410

ROLLBACK;

COMMIT;
