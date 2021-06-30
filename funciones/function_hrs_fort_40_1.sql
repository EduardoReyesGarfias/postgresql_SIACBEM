CREATE OR REPLACE FUNCTION planteles_hrs_fort_40_profesor1(id_subprograma int,filiacion text, id_estructura int)
RETURNS integer 

AS $$

DECLARE
	hrs_fort_temp smallint;
	sum_hrs  smallint;
	plz_jor  boolean;
	plz_cbii boolean;
	plz_cbiii boolean;
	plz_cbiv boolean;
	plz_cbv boolean;
	reg RECORD;
    cur_plzs_horas CURSOR FOR SELECT c.categoria_padre,sum(a.hrs_categoria) as hrs_categoria
					FROM plantilla_base_docente_rh a
					INNER JOIN empleados b ON a.id_empleado = b.id_empleado
					INNER JOIN cat_categorias_padre c ON c.id_cat_categoria_padre = a.id_cat_categoria_padre
					WHERE a.id_subprograma = $1
					AND a.id_estructura_ocupacional = $3
					AND b.filiacion = $2
					AND a.revision_rh = true
					AND ((c.categoria_padre like '%EH4%') 
						OR (c.categoria_padre = 'CBII')
						OR (c.categoria_padre = 'CBIII')
						OR (c.categoria_padre = 'CBIV') 
						OR (c.categoria_padre = 'CBV'))
					GROUP BY c.categoria_padre	
					ORDER BY c.categoria_padre;
BEGIN
	sum_hrs:=0;
	hrs_fort_temp:=0;
	plz_jor:= false;
	plz_cbii:= false;
	plz_cbiii:= false;
	plz_cbiv:= false;
	plz_cbv:= false;
	
	FOR reg IN cur_plzs_horas LOOP
		sum_hrs:= sum_hrs+reg.hrs_categoria;
		
		IF  reg.categoria_padre = 'CBII' THEN
			plz_cbii:=true;
		ELSIF reg.categoria_padre = 'CBIII' THEN
			plz_cbiii:=true;
		ELSIF reg.categoria_padre = 'CBIV' THEN
			plz_cbiv:=true;
		ELSIF reg.categoria_padre = 'CBV' THEN
			plz_cbv:=true;	
		ELSIF reg.categoria_padre like '%EH%' THEN
			plz_jor:=true;		
		END IF;
		
    END LOOP;
	
	IF sum_hrs = 40 THEN
		IF plz_jor = true THEN
			hrs_fort_temp:=10;
		ELSIF plz_cbii = true THEN
			hrs_fort_temp:=8;
		ELSIF plz_cbiii = true THEN
			hrs_fort_temp:=8;
		ELSIF plz_cbiv = true THEN
			hrs_fort_temp:=8;
		ELSIF plz_cbv = true THEN
			hrs_fort_temp:=8;
		ELSE
			hrs_fort_temp:=0;
		END IF;	
	END IF;	
	
    RETURN hrs_fort_temp;
END; $$ 
 
LANGUAGE 'plpgsql';

select * FROM planteles_hrs_fort_40_profesor1(42,'CEMA811226000',26);

select * from planteles_dom05(42,26);
