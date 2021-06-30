-- sacar los años que se le han timbrado
SELECT substring(qna from 0 for 5)
FROM timbrado_cfdi
WHERE CAST(no_empleado as integer) = 9819
and (cancelado = null OR cancelado = false or devolucion = null or devolucion = false)
GROUP BY substring(qna from 0 for 5)

-- sacar las qnas de esos años
SELECT qna
FROM timbrado_cfdi
WHERE CAST(no_empleado as integer) = 9819
and (cancelado = null OR cancelado = false or devolucion = null or devolucion = false)
and substring(qna from 0 for 5) = '2018'
ORDER BY qna DESC