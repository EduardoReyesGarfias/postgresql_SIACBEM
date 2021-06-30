--SELECT * FROM folios_nombramientos

CREATE OR REPLACE FUNCTION folio_nombramiento(datos character)
RETURNS integer

AS $$

DECLARE
	
	fol integer;
	last_folio integer;
	reg_existe RECORD;
	cur_existe CURSOR FOR SELECT folio 
			FROM folios_nombramientos
			WHERE filiacion||','||categoria||','||num_plz||','||num_hrs||','||subprograma||','||alta||','||qna_mov||','||desde||','||hasta = $1;
	reg_ultimo  RECORD;
	cur_ultimo  CURSOR FOR SELECT folio 
				FROM folios_nombramientos
				ORDER BY id_folio_nombramiento DESC
				LIMIT 1;
				
	/* para partir datos para ponerle comillas a los strings */
	param1 character(13);
	reg_comillas1 RECORD;
	cur_comillas1 CURSOR FOR SELECT split_part( $1, ',' ,1) as parte;
	
	param2 character(10);
	reg_comillas2 RECORD;
	cur_comillas2 CURSOR FOR SELECT split_part( $1, ',' ,2) as parte;
	
	param3 character(5);
	reg_comillas3 RECORD;
	cur_comillas3 CURSOR FOR SELECT split_part( $1, ',' ,3) as parte;
	
	param4 character(100);
	reg_comillas4 RECORD;
	cur_comillas4 CURSOR FOR SELECT split_part( $1, ',' ,4) as parte;
	
	param5 character(100);
	reg_comillas5 RECORD;
	cur_comillas5 CURSOR FOR SELECT split_part( $1, ',' ,5) as parte;
	
	param6 character(100);
	reg_comillas6 RECORD;
	cur_comillas6 CURSOR FOR SELECT split_part( $1, ',' ,6) as parte;
	
	param7 character(100);
	reg_comillas7 RECORD;
	cur_comillas7 CURSOR FOR SELECT split_part( $1, ',' ,7) as parte;
	
	param8 character(100);
	reg_comillas8 RECORD;
	cur_comillas8 CURSOR FOR SELECT split_part( $1, ',' ,8) as parte;
	
	param9 character(100);
	reg_comillas9 RECORD;
	cur_comillas9 CURSOR FOR SELECT split_part( $1, ',' ,9) as parte;
	
				
BEGIN
	/* Ver si el registro ya existe */
	fol:= 0;
	last_folio:=0;
	FOR reg_existe IN cur_existe LOOP
		IF reg_existe.folio > 0 THEN
			fol:= reg_existe.folio;
		END IF;
	END LOOP;
	
	/* SI existe */
	IF (fol > 0) THEN
		last_folio:=fol;
	ELSE
	/* No existe */
		/* Obtengo el ultimo folio */
		FOR reg_ultimo IN cur_ultimo LOOP
			last_folio:=reg_ultimo.folio;
		END LOOP;
		
		/* 
		Si es el primer registro que se hara en la tabla entonces 
		le toca el 133159 ya que RH se quedo en el 133158 
		*/
		IF last_folio = 0 || last_folio = null THEN
			last_folio:=133159;
		ELSE
			last_folio:= last_folio+1;
		END IF;
		
		/* parto datos para poner a los que son string las comillas para el insert */
		FOR reg_comillas1 IN cur_comillas1 LOOP
			param1:=reg_comillas1.parte;
		END LOOP;
		
		FOR reg_comillas2 IN cur_comillas2 LOOP
			param2:=reg_comillas2.parte;
		END LOOP;
		
		FOR reg_comillas3 IN cur_comillas3 LOOP
			param3:=reg_comillas3.parte;
		END LOOP;
		
		FOR reg_comillas4 IN cur_comillas4 LOOP
			param4:=reg_comillas4.parte;
		END LOOP;
		
		FOR reg_comillas5 IN cur_comillas5 LOOP
			param5:=reg_comillas5.parte;
		END LOOP;
		
		FOR reg_comillas6 IN cur_comillas6 LOOP
			param6:=reg_comillas6.parte;
		END LOOP;
		
		FOR reg_comillas7 IN cur_comillas7 LOOP
			param7:=reg_comillas7.parte;
		END LOOP;
		
		FOR reg_comillas8 IN cur_comillas8 LOOP
			param8:=reg_comillas8.parte;
		END LOOP;
		
		FOR reg_comillas9 IN cur_comillas9 LOOP
			param9:=reg_comillas9.parte;
		END LOOP;
		
		INSERT INTO folios_nombramientos
		(folio,filiacion,categoria,num_plz,num_hrs,subprograma,alta,qna_mov,desde,hasta,fecha_sistema)
		VALUES(last_folio, param1,param2,param3,CAST(param4 as smallint),param5,CAST(param6 as smallint),CAST(param7 as int),CAST(param8 as int),CAST(param9 as int) ,now());
		
		
	END IF;
		
	
	RETURN last_folio;

END; $$
LANGUAGE 'plpgsql';

SELECT * FROM folio_nombramiento('EODJ711025000,EH4863,256,40,Plantel Tarímbaro,14,201522,201519,999999')

SELECT * FROM folios_nombramientos
