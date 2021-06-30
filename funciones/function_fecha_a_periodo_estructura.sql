CREATE OR REPLACE FUNCTION fecha_a_periodo_estructura(_fecha timestamp with time zone)
RETURNS character varying 
AS $$
DECLARE
	
	fecha_qna character varying;
	qna integer;
	anio integer;
	periodo character varying;

BEGIN
	
	SELECT INTO fecha_qna convierte_de_fecha_a_qna(CAST(substring(CAST(_fecha AS text),0,11) AS date));
	anio:= CAST(substring(fecha_qna, 1,4) AS int);
	qna:= CAST(substring(fecha_qna, 5,6) AS int);

	IF(qna >= 1 AND qna <= 3) THEN
		periodo:= (anio-1)||'16'||'-'||anio||'03';
	ELSIF (qna >= 16) THEN
		periodo:= anio||'16'||'-'||(anio+1)||'03';	
	ELSE
		periodo:= anio||'04'||'-'||anio||'15';	
	END IF;

	RETURN periodo;


END; $$ 
LANGUAGE 'plpgsql';