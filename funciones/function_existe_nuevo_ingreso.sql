CREATE OR REPLACE FUNCTION existe_empleado_nuevo_ingreso(curp text)
RETURNS TABLE(
	emp int,
	nuevo int
)

AS $$

DECLARE

	reg_empleado RECORD;
    cur_empleado CURSOR FOR SELECT a.id_empleado FROM empleados a WHERE a.curp = $1; 
	
	reg_nuevo RECORD;
    cur_nuevo CURSOR FOR SELECT b.curp FROM empleados_nuevo_ingreso b WHERE b.curp = $1; 
	
	existe_emp int;
	existe_nuev int;
	
BEGIN
	existe_emp:=0;
	existe_nuev:=0;
	
	FOR reg_empleado IN cur_empleado LOOP
		IF reg_empleado.id_empleado > 0 THEN
			existe_emp:=1;
		END IF;
	END LOOP;
	
	FOR reg_nuevo IN cur_nuevo LOOP
		IF reg_nuevo.curp != '' THEN
			existe_nuev:=1;
		END IF;
	END LOOP;
	
	RETURN QUERY SELECT existe_emp,existe_nuev; 

END; $$ 
 
LANGUAGE 'plpgsql';

select * from existe_empleado_nuevo_ingreso('PETC790821MSLRRL02')
