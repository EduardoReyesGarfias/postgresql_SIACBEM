SELECT * 
FROM grupos_paraescolares a
INNER JOIN horas_autorizadas b ON b.id_hora_autorizada = a.id_hora_autorizada
--INNER JOIN horas_componente_plan_estudios c ON c.id_hora_componente_plan_estudio = b.id_hora_componente_plan_estudio
INNER JOIN grupos d ON d.id_grupo = b.id_grupo
INNER JOIN periodos e ON e.id_periodo = d.id_periodo
WHERE id_estructura_ocupacional = 25 and id_subprograma = 133
