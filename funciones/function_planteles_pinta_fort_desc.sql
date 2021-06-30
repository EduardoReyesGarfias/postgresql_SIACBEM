/*
SELECT sum(a.hrs_categoria)as hrs_categoria 
FROM plantilla_base_docente_rh a
INNER JOIN empleados b ON a.id_empleado = b.id_empleado
WHERE a.id_estructura_ocupacional = 26
AND a.revision_rh = true
AND b.filiacion = 'CIMA770107000'
AND a.id_subprograma NOT IN (52)
GROUP BY a.id_subprograma
*/

CREATE OR REPLACE FUNCTION planteles_pinta_fort_desc(filiacion text,tot_hrs_base bigint,id_subprograma int,id_estructura int)
RETURNS boolean AS
$BODY$
DECLARE
	flag_pinta boolean;
	reg          RECORD;
    cur_horas CURSOR FOR SELECT sum(a.hrs_categoria)as hrs_categoria 
		FROM plantilla_base_docente_rh a
		INNER JOIN empleados b ON a.id_empleado = b.id_empleado
		WHERE a.id_estructura_ocupacional = $4
		AND a.revision_rh = true
		AND b.filiacion = $1
		AND a.id_subprograma NOT IN ($3)
		GROUP BY a.id_subprograma;
BEGIN
	flag_pinta:=true;
    FOR reg IN cur_horas LOOP
		--RAISE NOTICE ' PROCESANDO  %', reg.nombre_cliente;
		IF $2 >= reg.hrs_categoria THEN
			flag_pinta := true;
		ELSE
			flag_pinta := false;
		END IF;
		
    END LOOP;
    RETURN flag_pinta;
END
$BODY$
LANGUAGE 'plpgsql' ;


select * from planteles_pinta_fort_desc('CIMA770107000',12,52,26);


--ID_EMPLEADO CHIMAL 6216

--select * from empleados where paterno = 'CHIMAL'