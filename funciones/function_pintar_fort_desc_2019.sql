CREATE OR REPLACE FUNCTION planteles_pinta_fort_desc1(filiacion text,tot_hrs_base bigint,id_subprograma int,id_estructura int)
RETURNS boolean AS
$BODY$
DECLARE
	flag_pinta boolean;
	var_hrs_categoria integer;
BEGIN
	flag_pinta:=true;
    
    SELECT INTO var_hrs_categoria
    COALESCE(sum(a.hrs_categoria),0) 
	FROM plantilla_base_docente_rh a
	INNER JOIN empleados b ON a.id_empleado = b.id_empleado
	WHERE a.id_estructura_ocupacional = $4
	AND a.revision_rh = true
	AND b.filiacion = $1
	AND a.id_subprograma NOT IN ($3);
	--GROUP BY a.id_subprograma;

	IF $2 >= var_hrs_categoria THEN
		flag_pinta := true;
	ELSE
		flag_pinta := false;
	END IF;

    RETURN flag_pinta;
END
$BODY$
LANGUAGE 'plpgsql' ;