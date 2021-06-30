CREATE OR REPLACE FUNCTION qnapago_a_fechapago(qnapago int)
RETURNS text
AS $$
DECLARE
	qnaletra text;
	msg text;
	meses TEXT ARRAY  DEFAULT  ARRAY['01','01','02','02','03','03','04','04','05','05','06','06','07','07','08','08','09','09','10','10','11','11','12','12'];
	mes text;
	anio text;
	dia1 text;
	dia2 text;
	last_day int;
	modulo int;
	reg RECORD;
	cur CURSOR FOR SELECT mod(CAST(substring(qnaletra from 5 for 6) AS INT),2);
	reg_last RECORD;
	cur_last CURSOR FOR SELECT * from last_day_of_month(anio||'/'||mes||'/'||dia1);
	
BEGIN
	qnaletra:= CAST($1 as text); 
	dia2:='0';
	
	/* revisa que la longitud de la qna sea correcta */
	IF( length(qnaletra) <> 6 ) THEN
	   msg:= 'Formato no permitido.';
	ELSE  
	   mes:= meses[ CAST(substring(qnaletra from 5 for 6) AS INT) ];
	   anio:= substring(qnaletra from 1 for 4);
	   
	   /* saber si es principio de mes o fin de mes */
	   FOR reg IN cur LOOP
	   	   /* es par */
		   IF (reg.mod = 1) THEN
			dia1:='01';
			dia2:='15';
		   ELSE
		   	/* es par */
		   	dia1:='16';
		   	/* dia2:='30'; */
			END IF;
	   END LOOP;
	   
	   /* si dia2 tiene '0' e sporque es segunda parte del mes */
	   IF(dia2 = '0') THEN
	   	FOR reg_last IN cur_last LOOP
			last_day:=reg_last.last_day_of_month;
		END LOOP;
			dia2:=last_day;
	   END IF;
	   
	   msg:= anio||'/'||mes||'/'||dia1||'-'||anio||'/'||mes||'/'||dia2;
	END IF;
	
	RETURN msg;

END; $$ 
 
LANGUAGE 'plpgsql';

SELECT * FROM qnapago_a_fechapago(201604);
