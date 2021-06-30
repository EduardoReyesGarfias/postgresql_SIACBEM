SELECT a.qnapago,a.consecu
,(
	select count(ya.id_nomina) 
	from nominas_sispagos ya 
	INNER JOIN pagos_sispagos yb ON ya.id_nomina = yb.id_nomina
	where ya.consecu = a.consecu
	LIMIT 1
)as registros
,SUM(
	CASE WHEN id_tipo_pd = 1 THEN
		importe
	ELSE
		0
	END
)as tp
,SUM(
	CASE WHEN id_tipo_pd = 2 THEN
		importe
	ELSE
		0
	END
)as td
FROM nominas_sispagos a
INNER JOIN pagos_sispagos c ON c.id_nomina = a.id_nomina
INNER JOIN percepciones_deducciones_sispagos d ON d.id_pago = c.id_pago
INNER JOIN cat_percepciones_deducciones_sispagos e ON e.clave = d.cod_pd
WHERE consecu in('4676',
'4678',
'4679',
'4682',
'4683',
'4684',
'4685',
'4688',
'4691',
'4692',
'4694',
'4696',
'4701',
'4702',
'4705',
'4706',
'4709',
'4710',
'4711',
'4712',
'4721',
'4722',
'4723',
'4724',
'4727',
'4730',
'4731',
'4734',
'4733',
'4735',
'4736',
'4738',
'4745',
'4746',
'4752',
'4753',
'4754',
'4728',
'4729',
'4747',
'4748',
'4749',
'4757',
'4759',
'4765',
'4766',
'4758',
'4760',
'4762',
'4763',
'4767',
'4768',
'4769',
'4770',
'4773',
'4781',
'4782',
'4783',
'4786',
'4787',
'4788',
'4790',
'4793',
'4794',
'4797',
'4799',
'4803',
'4804',
'4808',
'4809',
'4810',
'4815',
'4816',
'4817',
'4818',
'4819',
'4820',
'4821',
'4824',
'4825',
'4827',
'4828'
)
GROUP BY a.qnapago,a.consecu
ORDER BY a.qnapago