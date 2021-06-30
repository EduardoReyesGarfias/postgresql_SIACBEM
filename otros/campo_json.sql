/********************************************************
	http://www.postgresqltutorial.com/postgresql-json/
********************************************************/
--DELETE FROM timbrado_cfdi_json

/*consulta normal*/
select * from timbrado_cfdi_json

select datos_cfdi_json from timbrado_cfdi_json


/* consulta para traer los nombres*/
SELECT datos_cfdi_json -> 'NOMBRE' AS trabajador
FROM timbrado_cfdi_json;

/*Trae lo mismo que el anterior solo que trae la info como texto*/
SELECT datos_cfdi_json ->> 'NOMBRE' AS trabajador
FROM timbrado_cfdi_json;

/*Trae todos los datos que coincidan con la qna*/
SELECT datos_cfdi_json 
FROM timbrado_cfdi_json
WHERE datos_cfdi_json ->> 'QNA' = '201805'

/*Trae nombre y qna que coincidan con la qna*/
SELECT datos_cfdi_json ->> 'NOMBRE' as nombre_trabajador, datos_cfdi_json ->> 'QNA' as qna
FROM timbrado_cfdi_json
WHERE datos_cfdi_json ->> 'QNA' = '201805'

/* ORDER BY*/
SELECT datos_cfdi_json ->> 'NOMBRE' as nombre_trabajador, datos_cfdi_json ->> 'QNA' as qna
FROM timbrado_cfdi_json
WHERE datos_cfdi_json ->> 'QNA' = '201805'
ORDER BY nombre_trabajador desc
