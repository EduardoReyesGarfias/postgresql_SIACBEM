CREATE OR REPLACE FUNCTION fecha_a_periodo( qna date )
RETURNS varchar

AS $$

DECLARE
	qna varchar;
	qnapago varchar;
	anio varchar;
	periodo varchar;

BEGIN

	/* convierto fecha a qnapago */
	SELECT * FROM convierte_de_fecha_a_qna($1) INTO qnapago;
	
	/* guardo el año en la variable */
	SELECT substring(qnapago,1,4) INTO anio;
	
	/* guardo qna en la variable */
	SELECT substring(qnapago,5,2) INTO qna;
	
	IF ( qna::int >= 3 AND qna::int <= 14 ) THEN
		periodo:= anio||'-1';
	ELSE
		periodo:= anio||'-2';
	END IF;	
		
	
	return periodo;	
	
END; $$ 
 
LANGUAGE 'plpgsql';


select * from fecha_a_periodo('2019-12-01')

