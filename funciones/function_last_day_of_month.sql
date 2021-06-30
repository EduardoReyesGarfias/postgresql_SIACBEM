CREATE OR REPLACE FUNCTION last_day_of_month(fecha text)
RETURNS integer
AS $$
DECLARE
	reg RECORD;
	cur CURSOR FOR 
		SELECT SUBSTRING( CAST( (date_trunc('month', date($1)) + interval '1 month') - interval '1 day' as text) FROM 9 FOR 2) as dia;
BEGIN
	FOR reg IN cur LOOP
		RETURN reg.dia;
	END LOOP;
	
END; $$ 
 
LANGUAGE 'plpgsql';


select * from last_day_of_month('2016-02-13')