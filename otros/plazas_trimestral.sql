SELECT * 
FROM nominas_sispagos a
INNER JOIN pagos_sispagos b ON a.id_nomina = b.id_nomina
where qnapago in (201813,201814)


SELECT categoria, count(*) as num_categoria
FROM nominas_sispagos a
INNER JOIN pagos_sispagos b ON a.id_nomina = b.id_nomina
where qnapago in (201813,201814)
GROUP BY categoria
ORDER BY categoria asc
