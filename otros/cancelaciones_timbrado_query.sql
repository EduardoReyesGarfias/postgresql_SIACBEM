/* saco los que tienen detalles con subsidio de los 2 tipos, calculado y causado */
SELECT 
a.id_cfdi,a.filiacion,a.qna,a.nominas,a.cancelado
FROM timbrado_cfdi a
INNER JOIN timbrado_conceptos b ON a.id_cfdi = b.id_cfdi
WHERE a.qna in ('201803','201804') and (a.qna in ('201803','201804') OR b.clave = '42')
and a.subsidio_causado > 0
GROUP BY a.id_cfdi
ORDER BY a.id_cfdi
/* 
	1212 rows 
*/

/* saco los que tienen codigo 42 */
SELECT 
a.id_cfdi,a.filiacion,a.qna,a.nominas,a.cancelado
--a.id_cfdi||','
FROM timbrado_cfdi a
INNER JOIN timbrado_conceptos b ON a.id_cfdi = b.id_cfdi
WHERE a.qna in ('201803','201804') and b.clave = '42'
and nominas = '591'
GROUP BY a.id_cfdi
ORDER BY a.id_cfdi
/* 857 */


/* CAMBIAR CANCELADO A TRUE EN CFDI */
UPDATE timbrado_cfdi set cancelado = false 
WHERE id_cfdi in (
	SELECT 
    a.id_cfdi
    FROM timbrado_cfdi a
    INNER JOIN timbrado_conceptos b ON a.id_cfdi = b.id_cfdi
    WHERE a.qna in ('201803','201804') and (a.qna in ('201803','201804') OR b.clave = '42')
    and a.subsidio_causado > 0
    GROUP BY a.id_cfdi
    ORDER BY a.id_cfdi
) 

/* CAMBIAR CANCELADO A TRUE EN CONCEPTOS */
UPDATE timbrado_conceptos set cancelado = false 
WHERE id_cfdi in (
	SELECT 
    a.id_cfdi
    FROM timbrado_cfdi a
    INNER JOIN timbrado_conceptos b ON a.id_cfdi = b.id_cfdi
    WHERE a.qna in ('201803','201804') and (a.qna in ('201803','201804') OR b.clave = '42')
    and a.subsidio_causado > 0
    GROUP BY a.id_cfdi
    ORDER BY a.id_cfdi
) 
/*
	27726 rows
*/
select * 
from timbrado_conceptos 
WHERE id_cfdi in (
	SELECT 
    a.id_cfdi
    FROM timbrado_cfdi a
    INNER JOIN timbrado_conceptos b ON a.id_cfdi = b.id_cfdi
    WHERE a.qna in ('201803','201804') and (a.qna in ('201803','201804') OR b.clave = '42')
    and a.subsidio_causado > 0
    GROUP BY a.id_cfdi
    ORDER BY a.id_cfdi
)
order by id_cfdi


select * from nominas_sispagos where id_nomina in (591,592,593)