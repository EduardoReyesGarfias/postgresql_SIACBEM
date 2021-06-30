select * from nominas_sispagos where qnapago = 201811 order by qnapago desc
/*********************************************
		BORRAR TODO LO RELACIONADO AL 2018 
    			MENOS LA QNA 201811
*********************************************/
SELECT id_cfdi,qna 
FROM timbrado_cfdi 
WHERE 
nominas not in ('642','643','644') 
and qna like '%2018%' and (qna not like '%2017%' or qna not like ('%2016%') )
order by qna,id_cfdi

SELECT *
FROM timbrado_conceptos
WHERE id_cfdi in (
	SELECT id_cfdi 
    FROM timbrado_cfdi 
    WHERE 
    nominas not in ('642','643','644') 
    and qna like '%2018%' 
    order by qna,id_cfdi
)


DELETE FROM timbrado_conceptos WHERE id_cfdi in (
	SELECT id_cfdi 
    FROM timbrado_cfdi 
    WHERE 
    nominas not in ('642','643','644') 
    and qna like '%2018%' and (qna not like '%2017%' or qna not like ('%2016%') )
    order by qna,id_cfdi
);
DELETE 
FROM timbrado_cfdi 
WHERE 
nominas not in ('642','643','644') 
and qna like '%2018%' and (qna not like '%2017%' or qna not like ('%2016%') );
